package app_test

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"slices"
	"testing"
	"time"
)

type resolveResponse struct {
	Entries []fileEntry `json:"entries"`
}

type linksResponse struct {
	Outgoing []struct {
		Kind       string     `json:"kind"`
		Title      string     `json:"title"`
		TargetPath string     `json:"targetPath"`
		Target     *fileEntry `json:"target"`
	} `json:"outgoing"`
	Incoming []struct {
		Kind   string    `json:"kind"`
		Title  string    `json:"title"`
		Source fileEntry `json:"source"`
	} `json:"incoming"`
}

func (r linksResponse) outgoingSummary() []string {
	var summary []string
	for _, link := range r.Outgoing {
		target := "missing"
		if link.Target != nil {
			target = link.Target.Path
		}
		summary = append(summary, fmt.Sprintf("%s %s -> %s (%s)", link.Kind, link.Title, link.TargetPath, target))
	}
	return summary
}

func (r linksResponse) incomingSummary() []string {
	var summary []string
	for _, link := range r.Incoming {
		summary = append(summary, link.Title+" <- "+link.Source.Path)
	}
	return summary
}

func (c *client) links(id int64) linksResponse {
	c.server.t.Helper()
	var response linksResponse
	c.mustJSON(http.MethodGet, fmt.Sprintf("/files/links?id=%d", id), nil, http.StatusOK, &response)
	return response
}

func (c *client) waitForLinks(id int64, done func(linksResponse) error) linksResponse {
	c.server.t.Helper()
	var response linksResponse
	eventually(c.server.t, func() error {
		response = c.links(id)
		return done(response)
	})
	return response
}

func expectSummary(got, want []string) error {
	if !slices.Equal(got, want) {
		return fmt.Errorf("got %q, want %q", got, want)
	}
	return nil
}

func TestFileIDsSurviveMovesOverwritesAndTheTrash(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)

		var written fileEntry
		alice.put("/Docs/a.txt", 0, []byte("one"), http.StatusOK, &written)
		if written.ID == 0 {
			t.Fatal("upload response has no id")
		}
		id := written.ID

		alice.put("/Docs/a.txt", written.Rev, []byte("two"), http.StatusOK, &written)
		if written.ID != id {
			t.Fatalf("overwrite changed the id from %d to %d", id, written.ID)
		}
		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/Docs", "to": "/Archive"}, http.StatusOK, nil)
		if moved := alice.stat("/Archive/a.txt"); moved.ID != id {
			t.Fatalf("move changed the id from %d to %d", id, moved.ID)
		}
		folderID := alice.stat("/Archive").ID

		alice.expect(alice.request(http.MethodDelete, "/files?path=/Archive", nil, nil), http.StatusNoContent, nil)
		alice.restore(alice.trash().Items[0].ID, "fail", http.StatusOK, nil)
		if restored := alice.stat("/Archive/a.txt"); restored.ID != id {
			t.Fatalf("restoring from the trash changed the id from %d to %d", id, restored.ID)
		}
		if restored := alice.stat("/Archive"); restored.ID != folderID {
			t.Fatalf("restoring from the trash changed the folder id from %d to %d", folderID, restored.ID)
		}

		var resolved resolveResponse
		alice.mustJSON(http.MethodPost, "/files/resolve", map[string]any{"ids": []int64{id, 999999}}, http.StatusOK, &resolved)
		if len(resolved.Entries) != 1 || resolved.Entries[0].Path != "/Archive/a.txt" {
			t.Fatalf("resolve = %+v", resolved.Entries)
		}
		bob.mustJSON(http.MethodPost, "/files/resolve", map[string]any{"ids": []int64{id}}, http.StatusOK, &resolved)
		if len(resolved.Entries) != 0 {
			t.Fatalf("bob resolved alice's file: %+v", resolved.Entries)
		}
	})
}

func TestMarkdownIsRecognised(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		var note fileEntry
		alice.put("/Plan.MD", 0, []byte("# Plan"), http.StatusOK, &note)
		if note.Mime != "text/markdown" {
			t.Fatalf("mime = %q", note.Mime)
		}
	})
}

func TestNotesFolderSetting(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		var settings struct {
			Path *string `json:"path"`
		}
		alice.mustJSON(http.MethodGet, "/notes/settings", nil, http.StatusOK, &settings)
		if settings.Path != nil {
			t.Fatalf("new user has notes folder %q", *settings.Path)
		}
		alice.mustJSON(http.MethodPut, "/notes/settings", map[string]string{"path": "/Notes"}, http.StatusNotFound, nil)
		alice.put("/file.md", 0, []byte("x"), http.StatusOK, nil)
		alice.mustJSON(http.MethodPut, "/notes/settings", map[string]string{"path": "/file.md"}, http.StatusBadRequest, nil)

		alice.mustJSON(http.MethodPost, "/files/mkdir", map[string]string{"path": "/Notities"}, http.StatusCreated, nil)
		alice.mustJSON(http.MethodPut, "/notes/settings", map[string]string{"path": "Notities/"}, http.StatusOK, &settings)
		alice.mustJSON(http.MethodGet, "/notes/settings", nil, http.StatusOK, &settings)
		if settings.Path == nil || *settings.Path != "/Notities" {
			t.Fatalf("notes folder = %v", settings.Path)
		}
		alice.mustJSON(http.MethodPut, "/notes/settings", map[string]any{"path": nil}, http.StatusOK, &settings)
		if settings.Path != nil {
			t.Fatalf("notes folder not cleared: %q", *settings.Path)
		}
	})
}

func TestMarkdownLinksAndBacklinks(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)

		var report fileEntry
		alice.put("/Docs/report.pdf", 0, []byte("%PDF"), http.StatusOK, &report)
		note := fmt.Sprintf("# 计划 overview\n\n"+
			"See [the plan](../Projects/Plan%%20one.md) and ![scan](/Docs/report.pdf?fileId=%d).\n\n"+
			"[web](https://example.com) [anchor](#overview)\n\n"+
			"```\n[not a link](/Docs/report.pdf)\n```\n\n"+
			"[Referenced][ref]\n\n[ref]: ../Docs/report.pdf\n", report.ID)
		var source fileEntry
		alice.put("/Notes/Today.md", 0, []byte(note), http.StatusOK, &source)

		alice.waitForLinks(source.ID, func(r linksResponse) error {
			return expectSummary(r.outgoingSummary(), []string{
				"markdown the plan -> /Projects/Plan one.md (missing)",
				"markdown scan -> /Docs/report.pdf (/Docs/report.pdf)",
				"markdown Referenced -> /Docs/report.pdf (/Docs/report.pdf)",
			})
		})
		alice.waitForLinks(report.ID, func(r linksResponse) error {
			return expectSummary(r.incomingSummary(), []string{"scan <- /Notes/Today.md", "Referenced <- /Notes/Today.md"})
		})

		var plan fileEntry
		alice.put("/Projects/Plan one.md", 0, []byte("# Plan"), http.StatusOK, &plan)
		alice.waitForLinks(plan.ID, func(r linksResponse) error {
			return expectSummary(r.incomingSummary(), []string{"the plan <- /Notes/Today.md"})
		})

		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/Docs/report.pdf", "to": "/Archive/old.pdf"}, http.StatusOK, nil)
		alice.waitForLinks(report.ID, func(r linksResponse) error {
			return expectSummary(r.incomingSummary(), []string{"scan <- /Notes/Today.md", "Referenced <- /Notes/Today.md"})
		})
		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/Notes", "to": "/Journal"}, http.StatusOK, nil)
		alice.waitForLinks(report.ID, func(r linksResponse) error {
			return expectSummary(r.incomingSummary(), []string{"scan <- /Journal/Today.md", "Referenced <- /Journal/Today.md"})
		})

		var bobNote fileEntry
		bob.put("/steal.md", 0, fmt.Appendf(nil, "[x](/whatever.pdf?fileId=%d)", report.ID), http.StatusOK, &bobNote)
		bob.waitForLinks(bobNote.ID, func(r linksResponse) error {
			return expectSummary(r.outgoingSummary(), []string{"markdown x -> /whatever.pdf (missing)"})
		})
		bob.mustJSON(http.MethodGet, fmt.Sprintf("/files/links?id=%d", report.ID), nil, http.StatusNotFound, nil)

		current := alice.stat("/Journal/Today.md")
		alice.put("/Journal/Today.md", current.Rev, []byte("nothing linked"), http.StatusOK, nil)
		alice.waitForLinks(report.ID, func(r linksResponse) error {
			return expectSummary(r.incomingSummary(), nil)
		})

		alice.expect(alice.request(http.MethodDelete, "/files?path=/Journal/Today.md", nil, nil), http.StatusNoContent, nil)
		alice.waitForLinks(plan.ID, func(r linksResponse) error {
			return expectSummary(r.incomingSummary(), nil)
		})
	})
}

func TestRenamesOnDiskKeepIDsHistoryAndBacklinks(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		var plan fileEntry
		alice.put("/Docs/plan.md", 0, []byte("# Plan v1"), http.StatusOK, &plan)
		alice.put("/Docs/plan.md", plan.Rev, []byte("# Plan v2"), http.StatusOK, nil)
		alice.waitForVersionCount("/Docs/plan.md", 1)
		alice.put("/index.md", 0, []byte("[the plan](Docs/plan.md)"), http.StatusOK, nil)
		alice.waitForLinks(plan.ID, func(r linksResponse) error {
			return expectSummary(r.incomingSummary(), []string{"the plan <- /index.md"})
		})
		alice.put("/Docs/same-a.txt", 0, []byte("twin"), http.StatusOK, nil)
		alice.put("/Docs/same-b.txt", 0, []byte("twin"), http.StatusOK, nil)
		twinIDs := []int64{alice.stat("/Docs/same-a.txt").ID, alice.stat("/Docs/same-b.txt").ID}

		root := filepath.Join(server.app.Config.DataDir, "alice")
		if err := os.MkdirAll(filepath.Join(root, "Archive", "2026"), 0o750); err != nil {
			t.Fatal(err)
		}
		for from, to := range map[string]string{
			"Docs/plan.md":    "Archive/2026/Old plan.md",
			"Docs/same-a.txt": "Archive/a.txt",
			"Docs/same-b.txt": "Archive/b.txt",
		} {
			if err := os.Rename(filepath.Join(root, from), filepath.Join(root, to)); err != nil {
				t.Fatal(err)
			}
		}
		var me userResponse
		alice.mustJSON(http.MethodGet, "/auth/me", nil, http.StatusOK, &me)
		owner, err := server.app.Users.ByID(context.Background(), me.ID)
		if err != nil {
			t.Fatal(err)
		}
		if err := server.app.Files.Rescan(context.Background(), owner); err != nil {
			t.Fatal(err)
		}

		renamed := alice.stat("/Archive/2026/Old plan.md")
		if renamed.ID != plan.ID {
			t.Fatalf("renamed note has id %d, want %d", renamed.ID, plan.ID)
		}
		if listing := alice.versions("/Archive/2026/Old plan.md"); len(listing.Versions) != 1 {
			t.Fatalf("renamed note has %d earlier versions, want 1", len(listing.Versions))
		}
		alice.waitForLinks(plan.ID, func(r linksResponse) error {
			return expectSummary(r.incomingSummary(), []string{"the plan <- /index.md"})
		})
		for _, path := range []string{"/Archive/a.txt", "/Archive/b.txt"} {
			if id := alice.stat(path).ID; slices.Contains(twinIDs, id) {
				t.Fatalf("%s took over id %d although its content matches two missing files", path, id)
			}
		}
	})
}

func TestNotesGetPreviews(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/Notes/plan.md", 0, []byte("# 計画\n\n- [ ] مهمة\n- नमस्ते\n"), http.StatusOK, nil)
		entry := waitForPreview(t, alice, "/Notes/plan.md")
		if entry.PreviewState == "none" {
			t.Skip("no system fonts to draw notes with")
		}
		if entry.PreviewState != "ready" {
			t.Fatalf("preview state = %q", entry.PreviewState)
		}
		thumbnail := fetchThumbnail(t, alice, "/Notes/plan.md")
		if thumbnail.Bounds().Dy() != 128 {
			t.Fatalf("thumbnail is %v", thumbnail.Bounds())
		}
	})
}

func TestNotesListingTellsWhichFoldersHoldNotes(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/Notes/Plan.md", 0, []byte("# Plan"), http.StatusOK, nil)
		alice.put("/Notes/Plan/attachments/photo.jpg", 0, []byte("jpg"), http.StatusOK, nil)
		alice.put("/Notes/Wiki/README.md", 0, []byte("# Wiki"), http.StatusOK, nil)
		alice.put("/Notes/Journal/2026/october.md", 0, []byte("# October"), http.StatusOK, nil)

		var notes struct {
			Items []struct {
				Entry     fileEntry `json:"entry"`
				HasNotes  bool      `json:"hasNotes"`
				HasReadme bool      `json:"hasReadme"`
			} `json:"items"`
		}
		alice.mustJSON(http.MethodGet, "/notes/list?path=/Notes", nil, http.StatusOK, &notes)
		var summary []string
		for _, item := range notes.Items {
			if item.Entry.IsDir {
				summary = append(summary, fmt.Sprintf("%s=%v/%v", item.Entry.Name, item.HasNotes, item.HasReadme))
			}
		}
		if err := expectSummary(summary, []string{"Journal=true/false", "Plan=false/false", "Wiki=false/true"}); err != nil {
			t.Fatal(err)
		}
	})
}

func TestAttachmentsNoNoteLinksToGoToTheTrash(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		var cat, dog, bird, report fileEntry
		alice.put("/Notes/attachments/cat.png", 0, []byte("cat"), http.StatusOK, &cat)
		alice.put("/Notes/attachments/dog.png", 0, []byte("dog"), http.StatusOK, &dog)
		alice.put("/Notes/attachments/bird.png", 0, []byte("bird"), http.StatusOK, &bird)
		alice.put("/Notes/attachments/fish.png", 0, []byte("fish"), http.StatusOK, nil)
		alice.put("/Docs/report.pdf", 0, []byte("%PDF"), http.StatusOK, &report)
		var plan, journal fileEntry
		alice.put("/Notes/plan.md", 0, fmt.Appendf(nil,
			"![cat](attachments/cat.png?fileId=%d)\n\n![dog](attachments/dog.png?fileId=%d)\n\n[report](../Docs/report.pdf?fileId=%d)\n",
			cat.ID, dog.ID, report.ID), http.StatusOK, &plan)
		alice.put("/Notes/journal.md", 0, []byte("![bird](attachments/bird.png)\n"), http.StatusOK, &journal)
		alice.put("/Notes/diary.md", 0, fmt.Appendf(nil, "![dog](attachments/dog.png?fileId=%d)\n", dog.ID), http.StatusOK, nil)
		alice.waitForLinks(dog.ID, func(r linksResponse) error {
			return expectSummary(r.incomingSummary(), []string{"dog <- /Notes/plan.md", "dog <- /Notes/diary.md"})
		})

		alice.put("/Notes/plan.md", plan.Rev, []byte("Nothing to see\n"), http.StatusOK, nil)
		alice.expect(alice.request(http.MethodDelete, "/files?path=/Notes/journal.md", nil, nil), http.StatusNoContent, nil)
		alice.waitForLinks(cat.ID, func(r linksResponse) error {
			return expectSummary(r.incomingSummary(), nil)
		})

		if err := server.app.TrashUnlinkedAttachments(context.Background(), time.Now()); err != nil {
			t.Fatal(err)
		}
		if items := alice.trash().Items; len(items) != 1 || items[0].Name != "journal.md" {
			t.Fatalf("recent attachments were trashed: %+v", items)
		}

		eventually(t, func() error {
			if err := server.app.TrashUnlinkedAttachments(context.Background(), time.Now().Add(25*time.Hour)); err != nil {
				return err
			}
			var trashed []string
			for _, item := range alice.trash().Items {
				trashed = append(trashed, item.Name)
			}
			slices.Sort(trashed)
			return expectSummary(trashed, []string{"bird.png", "cat.png", "fish.png", "journal.md"})
		})
		alice.stat("/Notes/attachments/dog.png")
		alice.stat("/Docs/report.pdf")
	})
}

func TestMovesKeepLinksInOtherNotesUpToDate(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		var old, report fileEntry
		alice.put("/Notes/Old.md", 0, []byte("# Old"), http.StatusOK, &old)
		alice.put("/Docs/report (final).pdf", 0, []byte("%PDF"), http.StatusOK, &report)
		var plan fileEntry
		alice.put("/Notes/plan.md", 0, fmt.Appendf(nil,
			"[Old](Old.md?fileId=%d) and [my plan](Old.md?fileId=%[1]d#steps)\n\n"+
				"```\n[Old](Old.md?fileId=%[1]d)\n```\n\n[report](../Docs/report%%20%%28final%%29.pdf) `[Old](Old.md?fileId=%[1]d)`\n\n"+
				"[ref]: Old.md?fileId=%[1]d\n", old.ID),
			http.StatusOK, &plan)
		alice.waitForLinks(old.ID, func(r linksResponse) error {
			return expectSummary(r.incomingSummary(), []string{"Old <- /Notes/plan.md", "my plan <- /Notes/plan.md"})
		})

		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/Notes/Old.md", "to": "/Notes/Archive/Road map.md"}, http.StatusOK, nil)
		expectContent(t, alice, "/Notes/plan.md", fmt.Sprintf(
			"[Road map](Archive/Road%%20map.md?fileId=%d) and [my plan](Archive/Road%%20map.md?fileId=%[1]d#steps)\n\n"+
				"```\n[Old](Old.md?fileId=%[1]d)\n```\n\n[report](../Docs/report%%20%%28final%%29.pdf) `[Old](Old.md?fileId=%[1]d)`\n\n"+
				"[ref]: Archive/Road%%20map.md?fileId=%[1]d\n", old.ID))

		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/Notes/plan.md", "to": "/Journal/2026/plan.md"}, http.StatusOK, nil)
		expectContent(t, alice, "/Journal/2026/plan.md", fmt.Sprintf(
			"[Road map](../../Notes/Archive/Road%%20map.md?fileId=%d) and [my plan](../../Notes/Archive/Road%%20map.md?fileId=%[1]d#steps)\n\n"+
				"```\n[Old](Old.md?fileId=%[1]d)\n```\n\n[report](../../Docs/report%%20%%28final%%29.pdf?fileId=%d) `[Old](Old.md?fileId=%[1]d)`\n\n"+
				"[ref]: ../../Notes/Archive/Road%%20map.md?fileId=%[1]d\n", old.ID, report.ID))

		if versions := alice.versions("/Journal/2026/plan.md").Versions; len(versions) != 0 {
			t.Fatalf("link updates were kept as versions: %+v", versions)
		}
		current := alice.stat("/Journal/2026/plan.md")
		alice.put("/Journal/2026/plan.md", current.Rev, []byte("edited by hand"), http.StatusOK, nil)
		alice.waitForVersionCount("/Journal/2026/plan.md", 1)
	})
}

func expectContent(t *testing.T, c *client, path, expected string) {
	t.Helper()
	eventually(t, func() error {
		response, body := c.download(path, nil)
		if response.StatusCode != http.StatusOK || string(body) != expected {
			return fmt.Errorf("%s is %d %q", path, response.StatusCode, body)
		}
		return nil
	})
}
