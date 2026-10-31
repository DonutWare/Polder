package app_test

import (
	"fmt"
	"net/http"
	"slices"
	"testing"
)

type userTag struct {
	ID    int64  `json:"id"`
	Name  string `json:"name"`
	Color string `json:"color"`
	Count int    `json:"count"`
}

type tagAssignmentResults struct {
	Results []struct {
		Path  string `json:"path"`
		Error string `json:"error"`
	} `json:"results"`
}

func (c *client) tags() []userTag {
	c.server.t.Helper()
	var list []userTag
	c.mustJSON(http.MethodGet, "/tags", nil, http.StatusOK, &list)
	return list
}

func (c *client) tagNamed(name string) (userTag, bool) {
	for _, tag := range c.tags() {
		if tag.Name == name {
			return tag, true
		}
	}
	return userTag{}, false
}

func (c *client) assignTags(paths []string, names ...string) tagAssignmentResults {
	c.server.t.Helper()
	var results tagAssignmentResults
	c.mustJSON(http.MethodPost, "/tags/assign", map[string]any{"paths": paths, "names": names}, http.StatusOK, &results)
	return results
}

func (c *client) unassignTags(paths []string, names ...string) tagAssignmentResults {
	c.server.t.Helper()
	var results tagAssignmentResults
	c.mustJSON(http.MethodPost, "/tags/unassign", map[string]any{"paths": paths, "names": names}, http.StatusOK, &results)
	return results
}

func (c *client) text(path string) string {
	c.server.t.Helper()
	response, body := c.download(path, nil)
	if response.StatusCode != http.StatusOK {
		c.server.t.Fatalf("download %s: %d", path, response.StatusCode)
	}
	return string(body)
}

func (c *client) waitForTag(name string, count int) userTag {
	c.server.t.Helper()
	var found userTag
	eventually(c.server.t, func() error {
		tag, ok := c.tagNamed(name)
		if !ok || tag.Count != count {
			return fmt.Errorf("tag %s: %+v, want count %d", name, c.tags(), count)
		}
		found = tag
		return nil
	})
	return found
}

func TestTagsAreUniquePerUserIgnoringCase(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		var work userTag
		alice.mustJSON(http.MethodPost, "/tags", map[string]string{"name": "Work", "color": "#AA0000"}, http.StatusCreated, &work)
		if work.Name != "Work" || work.Color != "#aa0000" {
			t.Fatalf("created %+v", work)
		}
		alice.mustJSON(http.MethodPost, "/tags", map[string]string{"name": "work"}, http.StatusConflict, nil)
		alice.mustJSON(http.MethodPost, "/tags", map[string]string{"name": "has space"}, http.StatusBadRequest, nil)
		alice.mustJSON(http.MethodPost, "/tags", map[string]string{"name": "123"}, http.StatusBadRequest, nil)
		bob.mustJSON(http.MethodPost, "/tags", map[string]string{"name": "work"}, http.StatusCreated, nil)
		if len(bob.tags()) != 1 || len(alice.tags()) != 1 {
			t.Fatal("each user has their own tags")
		}
		bob.mustJSON(http.MethodPatch, fmt.Sprintf("/tags/%d", work.ID), map[string]string{"color": "#00ff00"}, http.StatusNotFound, nil)
		var recolored userTag
		alice.mustJSON(http.MethodPatch, fmt.Sprintf("/tags/%d", work.ID), map[string]string{"color": "#00ff00"}, http.StatusOK, &recolored)
		if recolored.Color != "#00ff00" || recolored.Name != "Work" {
			t.Fatalf("recolored %+v", recolored)
		}
	})
}

func TestTagsOnFilesAndFolders(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/Taxes/2024.pdf", 0, []byte("pdf"), http.StatusOK, nil)
		alice.put("/Taxes/2023.pdf", 0, []byte("pdf"), http.StatusOK, nil)
		results := alice.assignTags([]string{"/Taxes", "/Taxes/2024.pdf", "/missing.txt"}, "finance")
		if results.Results[0].Error != "" || results.Results[1].Error != "" || results.Results[2].Error == "" {
			t.Fatalf("results %+v", results)
		}
		finance, ok := alice.tagNamed("finance")
		if !ok || finance.Count != 2 {
			t.Fatalf("an unknown name becomes a tag: %+v", alice.tags())
		}
		listed := alice.list("/Taxes")
		tagged, _ := entryNamed(listed, "2024.pdf")
		untagged, _ := entryNamed(listed, "2023.pdf")
		if !slices.Equal(tagged.TagIDs, []int64{finance.ID}) || len(untagged.TagIDs) != 0 {
			t.Fatalf("listing %+v", listed.Entries)
		}
		if folder, _ := entryNamed(alice.list("/"), "Taxes"); !slices.Contains(folder.TagIDs, finance.ID) {
			t.Fatalf("folder %+v", folder)
		}

		expectPaths(t, "#finance", alice.search("#finance"), "/Taxes", "/Taxes/2024.pdf")
		expectPaths(t, "tag=finance type=file", alice.search("tag=finance type=file"), "/Taxes/2024.pdf")
		expectPaths(t, "-#finance in=/Taxes", alice.search("-#finance in=/Taxes"), "/Taxes/2023.pdf")
		expectPaths(t, "#nothing", alice.search("#nothing"))

		alice.unassignTags([]string{"/Taxes"}, "finance")
		if alice.waitForTag("finance", 1); len(alice.stat("/Taxes").TagIDs) != 0 {
			t.Fatal("the folder lost the tag")
		}
		alice.mustJSON(http.MethodDelete, "/files?path=/Taxes/2024.pdf", nil, http.StatusNoContent, nil)
		alice.waitForTag("finance", 0)
	})
}

func TestTagsWrittenInNotes(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/Notes/plan.md", 0, []byte("Plan for #work and `#code`.\n"), http.StatusOK, nil)
		work := alice.waitForTag("work", 1)
		if _, found := alice.tagNamed("code"); found {
			t.Fatal("code spans hold no tags")
		}
		if note := alice.stat("/Notes/plan.md"); !slices.Equal(note.TagIDs, []int64{work.ID}) {
			t.Fatalf("note %+v", note)
		}

		alice.assignTags([]string{"/Notes/plan.md"}, "urgent")
		if got := alice.text("/Notes/plan.md"); got != "Plan for #work and `#code`.\n\n#urgent\n" {
			t.Fatalf("assigning writes the tag into the note: %q", got)
		}
		alice.waitForTag("urgent", 1)

		alice.mustJSON(http.MethodPatch, fmt.Sprintf("/tags/%d", work.ID), map[string]string{"name": "job"}, http.StatusOK, nil)
		if got := alice.text("/Notes/plan.md"); got != "Plan for #job and `#code`.\n\n#urgent\n" {
			t.Fatalf("renaming rewrites the note: %q", got)
		}
		alice.waitForTag("job", 1)

		urgent, _ := alice.tagNamed("urgent")
		alice.mustJSON(http.MethodDelete, fmt.Sprintf("/tags/%d", urgent.ID), nil, http.StatusNoContent, nil)
		if got := alice.text("/Notes/plan.md"); got != "Plan for #job and `#code`.\n" {
			t.Fatalf("deleting strips the note: %q", got)
		}
		if _, found := alice.tagNamed("urgent"); found {
			t.Fatal("the deleted tag stays deleted")
		}
		expectPaths(t, "#job", alice.search("#job"), "/Notes/plan.md")
	})
}

func TestTagsInSharesArePersonal(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.put("/Project/brief.pdf", 0, []byte("pdf"), http.StatusOK, nil)
		alice.put("/Project/notes.md", 0, []byte("Kickoff #work #later\n"), http.StatusOK, nil)
		alice.waitForTag("work", 1)
		alice.share(alice.stat("/Project").ID, "user", bob.me(), "read")
		bob.mustJSON(http.MethodPost, "/tags", map[string]string{"name": "work"}, http.StatusCreated, nil)
		bobWork, _ := bob.tagNamed("work")

		results := bob.assignTags([]string{"/Project/brief.pdf"}, "review")
		if results.Results[0].Error != "" {
			t.Fatalf("bob tags a shared file: %+v", results)
		}
		brief, _ := entryNamed(bob.list("/Project"), "brief.pdf")
		review, _ := bob.tagNamed("review")
		if !slices.Equal(brief.TagIDs, []int64{review.ID}) {
			t.Fatalf("bob sees his tag: %+v", brief)
		}
		if own, _ := entryNamed(alice.list("/Project"), "brief.pdf"); len(own.TagIDs) != 0 {
			t.Fatalf("alice does not see bob's tag: %+v", own)
		}

		notes, _ := entryNamed(bob.list("/Project"), "notes.md")
		if !slices.Equal(notes.TagIDs, []int64{bobWork.ID}) || !slices.Equal(notes.OtherTags, []string{"later"}) {
			t.Fatalf("note tags resolve against bob's tags: %+v", notes)
		}
		if results := bob.assignTags([]string{"/Project/notes.md"}, "mine"); results.Results[0].Error != "" {
			t.Fatalf("a read-only note gets a personal tag: %+v", results)
		}
		if results := bob.unassignTags([]string{"/Project/notes.md"}, "work"); results.Results[0].Error == "" {
			t.Fatal("bob cannot remove a tag written in a note he cannot edit")
		}

		bob.mustJSON(http.MethodPatch, fmt.Sprintf("/tags/%d", bobWork.ID), map[string]string{"name": "job"}, http.StatusOK, nil)
		if got := alice.text("/Project/notes.md"); got != "Kickoff #work #later\n" {
			t.Fatalf("bob's rename leaves alice's note alone: %q", got)
		}
	})
}
