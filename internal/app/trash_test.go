package app_test

import (
	"archive/zip"
	"bytes"
	"context"
	"fmt"
	"image"
	"image/png"
	"io"
	"net/http"
	"net/url"
	"path/filepath"
	"testing"
	"time"

	"polder-server/internal/config"
	"polder-server/internal/preview"
)

type trashItem struct {
	ID           int64      `json:"id"`
	Name         string     `json:"name"`
	OriginalPath string     `json:"originalPath"`
	IsDir        bool       `json:"isDir"`
	Size         int64      `json:"size"`
	Hash         string     `json:"hash"`
	PreviewState string     `json:"previewState"`
	DeletedAt    time.Time  `json:"deletedAt"`
	ExpiresAt    *time.Time `json:"expiresAt"`
}

type trashRetention struct {
	Days        int    `json:"days"`
	Source      string `json:"source"`
	Locked      bool   `json:"locked"`
	UserDays    *int   `json:"userDays"`
	DefaultDays int    `json:"defaultDays"`
}

type trashListing struct {
	Items      []trashItem    `json:"items"`
	TotalBytes int64          `json:"totalBytes"`
	Retention  trashRetention `json:"retention"`
}

func (c *client) trash() trashListing {
	c.server.t.Helper()
	var listing trashListing
	c.mustJSON(http.MethodGet, "/trash", nil, http.StatusOK, &listing)
	return listing
}

func (c *client) restore(id int64, onConflict string, expectedStatus int, target any) {
	c.server.t.Helper()
	c.mustJSON(http.MethodPost, fmt.Sprintf("/trash/%d/restore", id), map[string]string{"onConflict": onConflict}, expectedStatus, target)
}

func TestDeletedItemsCanBeRestored(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/Docs/a.txt", 0, []byte("aaa"), http.StatusOK, nil)
		alice.put("/Docs/sub/b.txt", 0, []byte("bbbb"), http.StatusOK, nil)
		alice.mustJSON(http.MethodDelete, "/files?path=/Docs", nil, http.StatusNoContent, nil)

		listing := alice.trash()
		if len(listing.Items) != 1 || listing.TotalBytes != 7 {
			t.Fatalf("unexpected trash %+v", listing)
		}
		item := listing.Items[0]
		if item.OriginalPath != "/Docs" || !item.IsDir || item.ExpiresAt == nil || item.DeletedAt.IsZero() {
			t.Fatalf("unexpected item %+v", item)
		}

		var restored fileEntry
		alice.restore(item.ID, "fail", http.StatusOK, &restored)
		if restored.Path != "/Docs" || !restored.IsDir {
			t.Fatalf("unexpected restore result %+v", restored)
		}
		_, content := alice.download("/Docs/sub/b.txt", nil)
		if string(content) != "bbbb" {
			t.Fatalf("restored content %q", content)
		}
		if len(alice.trash().Items) != 0 {
			t.Fatal("restored item still in the trash")
		}
	})
}

func TestRestoreOntoExistingPath(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/notes.txt", 0, []byte("old"), http.StatusOK, nil)
		alice.mustJSON(http.MethodDelete, "/files?path=/notes.txt", nil, http.StatusNoContent, nil)
		alice.put("/notes.txt", 0, []byte("new"), http.StatusOK, nil)
		oldID := alice.trash().Items[0].ID

		var conflict errorResponse
		alice.restore(oldID, "fail", http.StatusConflict, &conflict)
		if conflict.Error.Code != "already_exists" || conflict.Current == nil || conflict.Current.Path != "/notes.txt" {
			t.Fatalf("expected already_exists with the current entry, got %+v", conflict)
		}

		alice.restore(oldID, "overwrite", http.StatusOK, nil)
		if _, content := alice.download("/notes.txt", nil); string(content) != "old" {
			t.Fatalf("overwrite did not restore the old file: %q", content)
		}
		listing := alice.trash()
		if len(listing.Items) != 1 || listing.Items[0].OriginalPath != "/notes.txt" {
			t.Fatalf("overwritten file should be in the trash: %+v", listing.Items)
		}

		var kept fileEntry
		alice.restore(listing.Items[0].ID, "keepBoth", http.StatusOK, &kept)
		if kept.Path != "/notes (restored).txt" {
			t.Fatalf("unexpected keep-both path %q", kept.Path)
		}
		if _, content := alice.download("/notes.txt", nil); string(content) != "old" {
			t.Fatalf("keep both changed the existing file: %q", content)
		}
		if _, content := alice.download(kept.Path, nil); string(content) != "new" {
			t.Fatalf("keep both restored the wrong content: %q", content)
		}
	})
}

func TestTrashedItemsCanBeDownloaded(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/report.txt", 0, []byte("report"), http.StatusOK, nil)
		alice.put("/Album/one.jpg", 0, []byte("jpeg"), http.StatusOK, nil)
		alice.mustJSON(http.MethodDelete, "/files?path=/report.txt", nil, http.StatusNoContent, nil)
		alice.mustJSON(http.MethodDelete, "/files?path=/Album", nil, http.StatusNoContent, nil)

		items := alice.trash().Items
		album, report := items[0], items[1]

		response := alice.request(http.MethodGet, fmt.Sprintf("/trash/%d/content", report.ID), nil, nil)
		content, _ := io.ReadAll(response.Body)
		response.Body.Close()
		if response.StatusCode != http.StatusOK || string(content) != "report" {
			t.Fatalf("file download: %d %q", response.StatusCode, content)
		}

		response = alice.request(http.MethodGet, fmt.Sprintf("/trash/%d/content", album.ID), nil, nil)
		content, _ = io.ReadAll(response.Body)
		response.Body.Close()
		archive, err := zip.NewReader(bytes.NewReader(content), int64(len(content)))
		if err != nil || response.Header.Get("Content-Type") != "application/zip" {
			t.Fatalf("directory download is not a zip: %v", err)
		}
		if len(archive.File) != 1 || archive.File[0].Name != "one.jpg" {
			t.Fatalf("unexpected zip contents %+v", archive.File)
		}
	})
}

func TestTrashCanBeDeletedForGood(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		for _, name := range []string{"/a.txt", "/b.txt", "/c.txt"} {
			alice.put(name, 0, []byte("x"), http.StatusOK, nil)
			alice.mustJSON(http.MethodDelete, "/files?path="+name, nil, http.StatusNoContent, nil)
		}

		first := alice.trash().Items[0]
		alice.mustJSON(http.MethodDelete, fmt.Sprintf("/trash/%d", first.ID), nil, http.StatusNoContent, nil)
		alice.restore(first.ID, "fail", http.StatusNotFound, nil)
		if len(alice.trash().Items) != 2 {
			t.Fatal("item was not deleted")
		}

		alice.mustJSON(http.MethodDelete, "/trash", nil, http.StatusNoContent, nil)
		if len(alice.trash().Items) != 0 {
			t.Fatal("trash was not emptied")
		}
	})
}

func TestUsersCannotTouchEachOthersTrash(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.put("/private.txt", 0, []byte("x"), http.StatusOK, nil)
		alice.mustJSON(http.MethodDelete, "/files?path=/private.txt", nil, http.StatusNoContent, nil)
		id := alice.trash().Items[0].ID

		bob.restore(id, "fail", http.StatusNotFound, nil)
		bob.mustJSON(http.MethodGet, fmt.Sprintf("/trash/%d/content", id), nil, http.StatusNotFound, nil)
		bob.mustJSON(http.MethodDelete, fmt.Sprintf("/trash/%d", id), nil, http.StatusNotFound, nil)
	})
}

func TestTrashRetentionPrecedence(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		var users []userResponse
		admin.mustJSON(http.MethodGet, "/admin/users", nil, http.StatusOK, &users)
		aliceURL := fmt.Sprintf("/admin/users/%d", users[1].ID)

		retention := func() trashRetention {
			var current trashRetention
			alice.mustJSON(http.MethodGet, "/trash/retention", nil, http.StatusOK, &current)
			return current
		}
		expect := func(days int, source string) {
			t.Helper()
			if current := retention(); current.Days != days || current.Source != source {
				t.Fatalf("want %d days from %s, got %+v", days, source, current)
			}
		}

		expect(30, "default")
		alice.mustJSON(http.MethodPut, "/trash/retention", map[string]any{"days": 7}, http.StatusOK, nil)
		expect(7, "user")

		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"trashRetentionDays": 60, "trashRetentionEnforced": true}, http.StatusOK, nil)
		expect(60, "server")

		admin.mustJSON(http.MethodPatch, aliceURL, map[string]any{"trashRetentionOverrideDays": 3}, http.StatusOK, nil)
		expect(3, "admin")
		if !retention().Locked {
			t.Fatal("an administrator's override should lock the setting")
		}

		admin.mustJSON(http.MethodPatch, aliceURL, map[string]any{"trashRetentionOverrideDays": -1}, http.StatusOK, nil)
		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"trashRetentionEnforced": false}, http.StatusOK, nil)
		expect(7, "user")
		alice.mustJSON(http.MethodPut, "/trash/retention", map[string]any{"days": nil}, http.StatusOK, nil)
		expect(60, "default")

		alice.mustJSON(http.MethodPut, "/trash/retention", map[string]any{"days": 99999}, http.StatusBadRequest, nil)
		alice.mustJSON(http.MethodGet, "/admin/settings", nil, http.StatusForbidden, nil)
	})
}

func TestExpiredTrashIsPurged(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.mustJSON(http.MethodPut, "/trash/retention", map[string]any{"days": 1}, http.StatusOK, nil)
		bob.mustJSON(http.MethodPut, "/trash/retention", map[string]any{"days": 0}, http.StatusOK, nil)
		for _, user := range []*client{alice, bob} {
			user.put("/old.txt", 0, []byte("x"), http.StatusOK, nil)
			user.mustJSON(http.MethodDelete, "/files?path=/old.txt", nil, http.StatusNoContent, nil)
		}

		if err := server.app.PurgeExpiredTrash(context.Background(), time.Now().Add(12*time.Hour)); err != nil {
			t.Fatal(err)
		}
		if len(alice.trash().Items) != 1 {
			t.Fatal("item purged before it expired")
		}

		if err := server.app.PurgeExpiredTrash(context.Background(), time.Now().Add(48*time.Hour)); err != nil {
			t.Fatal(err)
		}
		if len(alice.trash().Items) != 0 {
			t.Fatal("expired item was not purged")
		}
		if len(bob.trash().Items) != 1 {
			t.Fatal("a trash kept forever should never be purged")
		}
	})
}

func TestTrashedImagesKeepTheirPreview(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		hash := uploadWithPreview(t, alice, "/cat.png", encodedPNG(t, 400, 300))
		alice.mustJSON(http.MethodDelete, "/files?path=/cat.png", nil, http.StatusNoContent, nil)

		item := alice.trash().Items[0]
		if item.PreviewState != "ready" || item.Hash != hash {
			t.Fatalf("trashed image lost its preview state: %+v", item)
		}
		response := alice.request(http.MethodGet, fmt.Sprintf("/trash/%d/preview?size=128", item.ID), nil, nil)
		defer response.Body.Close()
		thumbnail, _, err := image.Decode(response.Body)
		if response.StatusCode != http.StatusOK || err != nil || thumbnail.Bounds().Dx() != 128 {
			t.Fatalf("trash thumbnail: status %d err %v", response.StatusCode, err)
		}
	})
}

func TestThumbnailsAreRemovedOnceNothingUsesThem(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		picture := encodedPNG(t, 400, 300)
		hash := uploadWithPreview(t, alice, "/cat.png", picture)
		uploadWithPreview(t, bob, "/same-cat.png", picture)
		thumbnails := filepath.Join(server.app.Config.PreviewCacheDir(), hash[:2], hash+"-*.jpg")

		alice.mustJSON(http.MethodDelete, "/files?path=/cat.png", nil, http.StatusNoContent, nil)
		alice.mustJSON(http.MethodDelete, "/trash", nil, http.StatusNoContent, nil)
		bob.mustJSON(http.MethodDelete, "/files?path=/same-cat.png", nil, http.StatusNoContent, nil)
		expectFiles(t, thumbnails, len(preview.Sizes))

		bob.mustJSON(http.MethodDelete, "/trash", nil, http.StatusNoContent, nil)
		expectFiles(t, thumbnails, 0)

		replacedHash := uploadWithPreview(t, alice, "/dog.png", encodedPNG(t, 200, 100))
		alice.put("/dog.png", -1, []byte("not an image anymore"), http.StatusOK, nil)
		replacedThumbnails := filepath.Join(server.app.Config.PreviewCacheDir(), replacedHash[:2], replacedHash+"-*.jpg")
		history := alice.versions("/dog.png")
		expectFiles(t, replacedThumbnails, len(preview.Sizes))

		alice.mustJSON(http.MethodDelete, fmt.Sprintf("/files/versions/%d", history.Versions[0].ID), nil, http.StatusNoContent, nil)
		expectFiles(t, replacedThumbnails, 0)
	})
}

func encodedPNG(t *testing.T, width, height int) []byte {
	t.Helper()
	var encoded bytes.Buffer
	if err := png.Encode(&encoded, image.NewRGBA(image.Rect(0, 0, width, height))); err != nil {
		t.Fatal(err)
	}
	return encoded.Bytes()
}

func uploadWithPreview(t *testing.T, user *client, path string, content []byte) string {
	t.Helper()
	user.put(path, 0, content, http.StatusOK, nil)
	var entry fileEntry
	for deadline := time.Now().Add(10 * time.Second); entry.PreviewState != "ready" && time.Now().Before(deadline); {
		time.Sleep(50 * time.Millisecond)
		user.mustJSON(http.MethodGet, "/files/stat?path="+url.QueryEscape(path), nil, http.StatusOK, &entry)
	}
	if entry.PreviewState != "ready" {
		t.Fatalf("no preview for %s", path)
	}
	return entry.Hash
}

func expectFiles(t *testing.T, pattern string, count int) {
	t.Helper()
	var matches []string
	for deadline := time.Now().Add(10 * time.Second); time.Now().Before(deadline); time.Sleep(50 * time.Millisecond) {
		if matches, _ = filepath.Glob(pattern); len(matches) == count {
			return
		}
	}
	t.Fatalf("want %d files matching %s, found %v", count, pattern, matches)
}

func TestTrashSurvivesLosingTheDatabase(t *testing.T) {
	before := startServer(t, config.DriverSQLite, "")
	alice := before.createUser(before.setupAdmin(), "alice", 0)
	alice.put("/Docs/plan.txt", 0, []byte("draft"), http.StatusOK, nil)
	alice.put("/Docs/plan.txt", -1, []byte("final"), http.StatusOK, nil)
	before.waitForHistoryFiles("alice", "*.version", 1)
	alice.mustJSON(http.MethodDelete, "/files?path=/Docs", nil, http.StatusNoContent, nil)
	deleted := alice.trash().Items[0]
	before.stop()

	after := startServer(t, config.DriverSQLite, "", func(cfg *config.Config) { cfg.DataDir = before.app.Config.DataDir })
	alice = after.createUser(after.setupAdmin(), "alice", 0)
	owner, err := after.app.Users.ByID(context.Background(), 2)
	if err != nil {
		t.Fatal(err)
	}
	if err := after.app.Files.Rescan(context.Background(), owner); err != nil {
		t.Fatal(err)
	}
	listing := alice.trash()
	if len(listing.Items) != 1 {
		t.Fatalf("want the trashed folder back, have %+v", listing.Items)
	}
	recovered := listing.Items[0]
	if recovered.OriginalPath != "/Docs" || !recovered.IsDir || recovered.Size != deleted.Size || !recovered.DeletedAt.Equal(deleted.DeletedAt) {
		t.Fatalf("recovered %+v, deleted %+v", recovered, deleted)
	}

	alice.waitForUsage("trashed history is recovered", func(usage storageUsage) bool { return usage.HistoryBytes > 0 })
	alice.restore(recovered.ID, "fail", http.StatusOK, nil)
	if _, content := alice.download("/Docs/plan.txt", nil); string(content) != "final" {
		t.Fatalf("restored file holds %q", content)
	}
	history := alice.versions("/Docs/plan.txt")
	if len(history.Versions) != 1 || alice.versionContent(history.Versions[0].ID) != "draft" {
		t.Fatalf("history should come back with the restored file: %+v", history.Versions)
	}
}
