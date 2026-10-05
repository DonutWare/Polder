package app_test

import (
	"bytes"
	"net/http"
	"os"
	"path/filepath"
	"testing"
)

func TestFilesAreStoredAsPlainFilesInUserTree(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)

		var created fileEntry
		alice.put("/Documents/Reports/q1.txt", 0, []byte("quarterly"), http.StatusOK, &created)
		if created.Rev == 0 || created.Size != 9 || created.Mime != "text/plain" {
			t.Fatalf("unexpected entry %+v", created)
		}

		onDisk, err := os.ReadFile(filepath.Join(server.app.Config.DataDir, "alice", "Documents", "Reports", "q1.txt"))
		if err != nil || string(onDisk) != "quarterly" {
			t.Fatalf("file not stored as-is on disk: %q %v", onDisk, err)
		}

		var listing struct {
			Path    string      `json:"path"`
			Entries []fileEntry `json:"entries"`
		}
		alice.mustJSON(http.MethodGet, "/files/list?path=/Documents", nil, http.StatusOK, &listing)
		if len(listing.Entries) != 1 || !listing.Entries[0].IsDir || listing.Entries[0].Name != "Reports" {
			t.Fatalf("parent directories not indexed: %+v", listing)
		}
	})
}

func TestUsersCannotSeeEachOthersFiles(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)

		alice.put("/secret.txt", 0, []byte("alice only"), http.StatusOK, nil)
		bob.mustJSON(http.MethodGet, "/files/stat?path=/secret.txt", nil, http.StatusNotFound, nil)
		bob.mustJSON(http.MethodGet, "/files/list?path=/../alice", nil, http.StatusBadRequest, nil)
	})
}

func TestDownloadSupportsRangesAndETags(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		var entry fileEntry
		alice.put("/data.bin", 0, []byte("0123456789"), http.StatusOK, &entry)

		response, content := alice.download("/data.bin", map[string]string{"Range": "bytes=2-5"})
		if response.StatusCode != http.StatusPartialContent || string(content) != "2345" {
			t.Fatalf("range download: %d %q", response.StatusCode, content)
		}

		response, _ = alice.download("/data.bin", map[string]string{"If-Match": `"999"`, "Range": "bytes=0-1"})
		if response.StatusCode != http.StatusPreconditionFailed {
			t.Fatalf("stale If-Match should fail, got %d", response.StatusCode)
		}
		if etag := response.Header.Get("ETag"); etag == "" {
			t.Fatal("missing ETag")
		}
	})
}

func TestWriteConflictsReturnCurrentEntry(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)

		var first fileEntry
		alice.put("/notes.md", 0, []byte("v1"), http.StatusOK, &first)
		alice.put("/notes.md", 0, []byte("again"), http.StatusConflict, nil)

		var second fileEntry
		alice.put("/notes.md", first.Rev, []byte("v2 from laptop"), http.StatusOK, &second)

		var conflict errorResponse
		alice.put("/notes.md", first.Rev, []byte("v2 from phone"), http.StatusConflict, &conflict)
		if conflict.Error.Code != "conflict" || conflict.Current == nil || conflict.Current.Rev != second.Rev {
			t.Fatalf("conflict should include current entry: %+v", conflict)
		}

		alice.put("/notes.md", -1, []byte("forced"), http.StatusOK, nil)
		_, content := alice.download("/notes.md", nil)
		if string(content) != "forced" {
			t.Fatalf("unexpected content %q", content)
		}
	})
}

func TestMkdirMoveAndDelete(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)

		alice.mustJSON(http.MethodPost, "/files/mkdir", map[string]string{"path": "/Photos"}, http.StatusCreated, nil)
		alice.mustJSON(http.MethodPost, "/files/mkdir", map[string]string{"path": "/Photos"}, http.StatusConflict, nil)
		alice.put("/Photos/2026/a.jpg", 0, []byte("jpeg"), http.StatusOK, nil)

		var moved fileEntry
		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/Photos", "to": "/Pictures"}, http.StatusOK, &moved)
		if moved.Path != "/Pictures" || !moved.IsDir {
			t.Fatalf("unexpected move result %+v", moved)
		}
		alice.mustJSON(http.MethodGet, "/files/stat?path=/Pictures/2026/a.jpg", nil, http.StatusOK, nil)
		alice.mustJSON(http.MethodGet, "/files/stat?path=/Photos/2026/a.jpg", nil, http.StatusNotFound, nil)
		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/Pictures", "to": "/Pictures/inside"}, http.StatusBadRequest, nil)

		alice.mustJSON(http.MethodDelete, "/files?path=/Pictures", nil, http.StatusNoContent, nil)
		alice.mustJSON(http.MethodGet, "/files/stat?path=/Pictures/2026/a.jpg", nil, http.StatusNotFound, nil)

		trashed, _ := filepath.Glob(filepath.Join(server.app.Config.DataDir, ".polder", "trash", "alice", "*", "Pictures", "2026", "a.jpg"))
		if len(trashed) != 1 {
			t.Fatal("deleted file should be kept in the trash")
		}
	})
}

func TestQuotaIsEnforced(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 100)

		var first fileEntry
		alice.put("/a.bin", 0, bytes.Repeat([]byte("a"), 60), http.StatusOK, &first)

		var exceeded errorResponse
		alice.put("/b.bin", 0, bytes.Repeat([]byte("b"), 50), http.StatusInsufficientStorage, &exceeded)
		if exceeded.Error.Code != "quota_exceeded" {
			t.Fatalf("unexpected error %+v", exceeded)
		}
		alice.put("/a.bin", first.Rev, bytes.Repeat([]byte("a"), 100), http.StatusOK, nil)

		var me userResponse
		alice.mustJSON(http.MethodGet, "/auth/me", nil, http.StatusOK, &me)
		if me.UsedBytes != 100 || me.QuotaBytes != 100 {
			t.Fatalf("usage not reported: %+v", me)
		}
		leftovers, _ := filepath.Glob(filepath.Join(server.app.Config.DataDir, "alice", ".polder-tmp-*"))
		if len(leftovers) != 0 {
			t.Fatalf("temp files left behind: %v", leftovers)
		}
	})
}
