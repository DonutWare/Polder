package app_test

import (
	"bytes"
	"context"
	"fmt"
	"image"
	"image/color"
	"image/png"
	"net/http"
	"os"
	"path/filepath"
	"testing"
	"time"

	"polder-server/internal/chunker"
)

type changePage struct {
	Changes []struct {
		Seq      int64      `json:"seq"`
		Type     string     `json:"type"`
		Path     string     `json:"path"`
		FromPath string     `json:"fromPath"`
		Entry    *fileEntry `json:"entry"`
	} `json:"changes"`
	Cursor  int64 `json:"cursor"`
	HasMore bool  `json:"hasMore"`
}

func (p changePage) summary() []string {
	var lines []string
	for _, change := range p.Changes {
		line := change.Type + " " + change.Path
		if change.FromPath != "" {
			line += " from " + change.FromPath
		}
		lines = append(lines, line)
	}
	return lines
}

func TestChangeFeedReportsLatestStateSinceCursor(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)

		var initial changePage
		alice.mustJSON(http.MethodGet, "/sync/changes?cursor=0", nil, http.StatusOK, &initial)

		var draft fileEntry
		alice.put("/draft.txt", 0, []byte("one"), http.StatusOK, &draft)
		alice.put("/draft.txt", draft.Rev, []byte("two"), http.StatusOK, nil)
		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/draft.txt", "to": "/final.txt"}, http.StatusOK, nil)

		var page changePage
		alice.mustJSON(http.MethodGet, fmt.Sprintf("/sync/changes?cursor=%d", initial.Cursor), nil, http.StatusOK, &page)
		expected := []string{"move /final.txt from /draft.txt"}
		if fmt.Sprint(page.summary()) != fmt.Sprint(expected) {
			t.Fatalf("changes = %v, want %v", page.summary(), expected)
		}
		if page.Changes[0].Entry == nil || page.Changes[0].Entry.Size != 3 {
			t.Fatalf("move should carry the entry: %+v", page.Changes[0])
		}

		var empty changePage
		alice.mustJSON(http.MethodGet, fmt.Sprintf("/sync/changes?cursor=%d", page.Cursor), nil, http.StatusOK, &empty)
		if len(empty.Changes) != 0 {
			t.Fatalf("expected no new changes, got %v", empty.summary())
		}
	})
}

func TestChangeFeedReportsEveryMovedEntryOfADirectory(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/Photos/2026/a.jpg", 0, []byte("jpeg"), http.StatusOK, nil)

		var before changePage
		alice.mustJSON(http.MethodGet, "/sync/changes?cursor=0", nil, http.StatusOK, &before)
		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/Photos", "to": "/Pictures"}, http.StatusOK, nil)

		var page changePage
		alice.mustJSON(http.MethodGet, fmt.Sprintf("/sync/changes?cursor=%d", before.Cursor), nil, http.StatusOK, &page)
		expected := []string{"move /Pictures from /Photos", "move /Pictures/2026 from /Photos/2026", "move /Pictures/2026/a.jpg from /Photos/2026/a.jpg"}
		if fmt.Sprint(page.summary()) != fmt.Sprint(expected) {
			t.Fatalf("changes = %v, want %v", page.summary(), expected)
		}
	})
}

func TestChangeFeedKeepsSupersededMoves(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/a.txt", 0, []byte("one"), http.StatusOK, nil)

		var before changePage
		alice.mustJSON(http.MethodGet, "/sync/changes?cursor=0", nil, http.StatusOK, &before)
		var moved fileEntry
		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/a.txt", "to": "/b.txt"}, http.StatusOK, &moved)
		alice.put("/b.txt", moved.Rev, []byte("two"), http.StatusOK, nil)

		var page changePage
		alice.mustJSON(http.MethodGet, fmt.Sprintf("/sync/changes?cursor=%d", before.Cursor), nil, http.StatusOK, &page)
		expected := []string{"move /b.txt from /a.txt", "upsert /b.txt"}
		if fmt.Sprint(page.summary()) != fmt.Sprint(expected) {
			t.Fatalf("changes = %v, want %v", page.summary(), expected)
		}
		if page.Changes[0].Entry != nil {
			t.Fatalf("a superseded move should not carry an entry: %+v", page.Changes[0].Entry)
		}
	})
}

func TestChangeFeedPaginates(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		for i := range 5 {
			alice.put(fmt.Sprintf("/f%d.txt", i), 0, []byte("x"), http.StatusOK, nil)
		}
		var cursor int64
		seen := 0
		for {
			var page changePage
			alice.mustJSON(http.MethodGet, fmt.Sprintf("/sync/changes?cursor=%d&limit=2", cursor), nil, http.StatusOK, &page)
			seen += len(page.Changes)
			cursor = page.Cursor
			if !page.HasMore {
				break
			}
		}
		if seen != 5 {
			t.Fatalf("saw %d changes, want 5", seen)
		}
	})
}

func pseudoRandomBytes(size int, seed uint64) []byte {
	out := make([]byte, size)
	x := seed
	for i := range out {
		x ^= x << 13
		x ^= x >> 7
		x ^= x << 17
		out[i] = byte(x)
	}
	return out
}

type uploadStatus struct {
	UploadID string   `json:"uploadId"`
	Missing  []string `json:"missing"`
}

func planUpload(t *testing.T, content []byte, path string, baseRev int64) (map[string]any, map[string][]byte) {
	t.Helper()
	var chunks []map[string]any
	data := map[string][]byte{}
	manifest, err := chunker.BuildManifest(bytes.NewReader(content))
	if err != nil {
		t.Fatal(err)
	}
	for _, chunk := range manifest.Chunks {
		chunks = append(chunks, map[string]any{"hash": chunk.Hash, "size": chunk.Size})
		data[chunk.Hash] = content[chunk.Offset : chunk.Offset+chunk.Size]
	}
	request := map[string]any{"path": path, "baseRev": baseRev, "size": manifest.Size, "hash": manifest.Hash,
		"mtime": time.Date(2026, 1, 2, 3, 4, 5, 0, time.UTC), "chunks": chunks}
	return request, data
}

func TestDeltaUploadOnlySendsChangedChunks(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		original := pseudoRandomBytes(24<<20, 42)

		var base fileEntry
		alice.put("/big.bin", 0, original, http.StatusOK, &base)

		var serverManifest chunker.Manifest
		alice.mustJSON(http.MethodGet, "/sync/manifest?path=/big.bin", nil, http.StatusOK, &serverManifest)
		if serverManifest.Hash != base.Hash || len(serverManifest.Chunks) < 5 {
			t.Fatalf("unexpected manifest: %d chunks", len(serverManifest.Chunks))
		}

		edited := bytes.Clone(original)
		copy(edited[12<<20:], []byte("a small edit in the middle of a large file"))
		request, chunkData := planUpload(t, edited, "/big.bin", base.Rev)

		var status uploadStatus
		alice.mustJSON(http.MethodPost, "/sync/uploads", request, http.StatusCreated, &status)
		var uploadedBytes int
		for _, missing := range status.Missing {
			uploadedBytes += len(chunkData[missing])
		}
		if uploadedBytes == 0 || uploadedBytes > 2*chunker.MaxSize {
			t.Fatalf("expected a small delta, would upload %d of %d bytes", uploadedBytes, len(edited))
		}

		for i, missing := range status.Missing {
			alice.expect(alice.request(http.MethodPut, "/sync/uploads/"+status.UploadID+"/chunks/"+missing, bytes.NewReader(chunkData[missing]), nil), http.StatusNoContent, nil)
			if i == 0 {
				var resumed uploadStatus
				alice.mustJSON(http.MethodGet, "/sync/uploads/"+status.UploadID, nil, http.StatusOK, &resumed)
				if len(resumed.Missing) != len(status.Missing)-1 {
					t.Fatalf("resume status should shrink: %v", resumed.Missing)
				}
			}
		}

		var committed fileEntry
		alice.mustJSON(http.MethodPost, "/sync/uploads/"+status.UploadID+"/commit", nil, http.StatusOK, &committed)
		_, downloaded := alice.download("/big.bin", nil)
		if !bytes.Equal(downloaded, edited) || committed.Rev <= base.Rev {
			t.Fatal("assembled file does not match the edited content")
		}
	})
}

func TestDeltaUploadRejectsWrongChunkAndStaleBase(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		var base fileEntry
		alice.put("/doc.bin", 0, pseudoRandomBytes(1<<20, 7), http.StatusOK, &base)

		request, chunkData := planUpload(t, pseudoRandomBytes(1<<20, 8), "/doc.bin", base.Rev)
		var status uploadStatus
		alice.mustJSON(http.MethodPost, "/sync/uploads", request, http.StatusCreated, &status)

		alice.expect(alice.request(http.MethodPut, "/sync/uploads/"+status.UploadID+"/chunks/"+status.Missing[0], bytes.NewReader([]byte("tampered")), nil), http.StatusBadRequest, nil)
		for _, missing := range status.Missing {
			alice.expect(alice.request(http.MethodPut, "/sync/uploads/"+status.UploadID+"/chunks/"+missing, bytes.NewReader(chunkData[missing]), nil), http.StatusNoContent, nil)
		}

		alice.put("/doc.bin", base.Rev, []byte("someone else won"), http.StatusOK, nil)
		var conflict errorResponse
		alice.mustJSON(http.MethodPost, "/sync/uploads/"+status.UploadID+"/commit", nil, http.StatusConflict, &conflict)
		if conflict.Current == nil || conflict.Current.Size != int64(len("someone else won")) {
			t.Fatalf("commit conflict should include the current entry: %+v", conflict)
		}
	})
}

func TestNewUserSeesFilesAlreadyInTheirFolder(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		folder := filepath.Join(server.app.Config.DataDir, "alice", "Photos")
		if err := os.MkdirAll(folder, 0o750); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(filepath.Join(folder, "cat.jpg"), []byte("cat"), 0o640); err != nil {
			t.Fatal(err)
		}

		alice := server.createUser(admin, "alice", 0)
		eventually(t, func() error {
			var listing struct {
				Entries []fileEntry `json:"entries"`
			}
			alice.mustJSON(http.MethodGet, "/files/list?path=/", nil, http.StatusOK, &listing)
			if len(listing.Entries) != 1 || listing.Entries[0].Name != "Photos" || listing.Entries[0].Size != 3 {
				return fmt.Errorf("listing = %+v, want Photos holding cat.jpg", listing.Entries)
			}
			return nil
		})
	})
}

func TestLargeRescanCommitsInBatchesAndLogsOnce(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		const fileCount = 600
		folder := filepath.Join(server.app.Config.DataDir, "alice", "Imported")
		if err := os.MkdirAll(folder, 0o750); err != nil {
			t.Fatal(err)
		}
		for i := range fileCount {
			if err := os.WriteFile(filepath.Join(folder, fmt.Sprintf("%03d.txt", i)), []byte(fmt.Sprint(i)), 0o640); err != nil {
				t.Fatal(err)
			}
		}
		events := admin.openEvents()
		events.send(map[string]any{"type": "subscribe", "scope": "all"})
		events.next("snapshot")

		alice := server.createUser(admin, "alice", 0)
		batches := 0
		for {
			message := events.next("")
			if message.Type == "files.changed" {
				batches++
			}
			if message.Type == "activity.created" && message.Entry.Kind == "rescan" {
				if message.Entry.Detail != "summary" || message.Entry.Count == nil || *message.Entry.Count != fileCount+1 {
					t.Fatalf("rescan activity = %+v, want one summary of %d", message.Entry, fileCount+1)
				}
				break
			}
		}
		if batches < 3 {
			t.Fatalf("saw %d committed batches, want at least 3", batches)
		}

		var listing struct {
			Entries  []fileEntry `json:"entries"`
			Indexing bool        `json:"indexing"`
		}
		alice.mustJSON(http.MethodGet, "/files/list?path=/Imported", nil, http.StatusOK, &listing)
		if len(listing.Entries) != fileCount || listing.Indexing {
			t.Fatalf("listed %d files, indexing %v; want %d and done", len(listing.Entries), listing.Indexing, fileCount)
		}
		rescans := 0
		for _, entry := range alice.activity("").Entries {
			if entry.Kind == "rescan" {
				rescans++
			}
		}
		if rescans != 1 {
			t.Fatalf("logged %d rescans, want 1", rescans)
		}
	})
}

func TestRescanPicksUpFilesChangedDirectlyOnDisk(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/keep.txt", 0, []byte("keep"), http.StatusOK, nil)
		alice.put("/remove.txt", 0, []byte("remove"), http.StatusOK, nil)

		var before changePage
		alice.mustJSON(http.MethodGet, "/sync/changes?cursor=0", nil, http.StatusOK, &before)

		root := filepath.Join(server.app.Config.DataDir, "alice")
		if err := os.MkdirAll(filepath.Join(root, "Added"), 0o750); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(filepath.Join(root, "Added", "new.txt"), []byte("from disk"), 0o640); err != nil {
			t.Fatal(err)
		}
		if err := os.Remove(filepath.Join(root, "remove.txt")); err != nil {
			t.Fatal(err)
		}
		for _, clutter := range []string{".DS_Store", "Added/.DS_Store", "Added/._new.txt", "Thumbs.db"} {
			if err := os.WriteFile(filepath.Join(root, clutter), []byte("os"), 0o640); err != nil {
				t.Fatal(err)
			}
		}

		owner, err := server.app.Users.ByID(context.Background(), 2)
		if err != nil {
			t.Fatal(err)
		}
		if err := server.app.Files.Rescan(context.Background(), owner); err != nil {
			t.Fatal(err)
		}

		var after changePage
		alice.mustJSON(http.MethodGet, fmt.Sprintf("/sync/changes?cursor=%d", before.Cursor), nil, http.StatusOK, &after)
		expected := []string{"delete /remove.txt", "upsert /Added", "upsert /Added/new.txt"}
		if fmt.Sprint(after.summary()) != fmt.Sprint(expected) {
			t.Fatalf("changes = %v, want %v", after.summary(), expected)
		}

		if err := server.app.Files.Rescan(context.Background(), owner); err != nil {
			t.Fatal(err)
		}
		var unchanged changePage
		alice.mustJSON(http.MethodGet, fmt.Sprintf("/sync/changes?cursor=%d", after.Cursor), nil, http.StatusOK, &unchanged)
		if len(unchanged.Changes) != 0 {
			t.Fatalf("second rescan should be a no-op, got %v", unchanged.summary())
		}
	})
}

func TestImagesGetMetadataAndThumbnails(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)

		picture := image.NewRGBA(image.Rect(0, 0, 800, 600))
		for x := range 800 {
			picture.Set(x, 300, color.RGBA{R: 255, A: 255})
		}
		var encoded bytes.Buffer
		if err := png.Encode(&encoded, picture); err != nil {
			t.Fatal(err)
		}
		var uploaded fileEntry
		alice.put("/Photos/red-line.png", 0, encoded.Bytes(), http.StatusOK, &uploaded)
		if uploaded.PreviewState != "pending" {
			t.Fatalf("new image should await a preview, got %s", uploaded.PreviewState)
		}

		var ready fileEntry
		deadline := time.Now().Add(10 * time.Second)
		for ready.PreviewState != "ready" && time.Now().Before(deadline) {
			time.Sleep(50 * time.Millisecond)
			alice.mustJSON(http.MethodGet, "/files/stat?path=/Photos/red-line.png", nil, http.StatusOK, &ready)
		}
		if ready.PreviewState != "ready" || ready.Meta["width"] != float64(800) || ready.Rev != uploaded.Rev {
			t.Fatalf("preview not generated correctly: %+v", ready)
		}

		response := alice.request(http.MethodGet, "/files/preview?path=/Photos/red-line.png&size=128", nil, nil)
		defer response.Body.Close()
		thumbnail, _, err := image.Decode(response.Body)
		if response.StatusCode != http.StatusOK || err != nil || thumbnail.Bounds().Dx() != 128 || thumbnail.Bounds().Dy() != 96 {
			t.Fatalf("thumbnail: status %d err %v", response.StatusCode, err)
		}
		alice.mustJSON(http.MethodGet, "/files/preview?path=/Photos/red-line.png&size=77", nil, http.StatusBadRequest, nil)
	})
}

func TestPDFsGetFirstPageThumbnails(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)

		// A 200x100pt page whose left half is red; PDFium rebuilds the missing xref table.
		document := "%PDF-1.4\n" +
			"1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n" +
			"2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj\n" +
			"3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 200 100] /Contents 4 0 R >> endobj\n" +
			"4 0 obj << /Length 26 >> stream\n1 0 0 rg 0 0 100 100 re f\nendstream endobj\n" +
			"trailer << /Root 1 0 R >>\n%%EOF\n"
		var uploaded fileEntry
		alice.put("/Docs/scan.pdf", 0, []byte(document), http.StatusOK, &uploaded)
		if uploaded.PreviewState != "pending" {
			t.Fatalf("new PDF should await a preview, got %s", uploaded.PreviewState)
		}

		var ready fileEntry
		deadline := time.Now().Add(30 * time.Second)
		for ready.PreviewState != "ready" && ready.PreviewState != "failed" && time.Now().Before(deadline) {
			time.Sleep(50 * time.Millisecond)
			alice.mustJSON(http.MethodGet, "/files/stat?path=/Docs/scan.pdf", nil, http.StatusOK, &ready)
		}
		if ready.PreviewState != "ready" || ready.Meta["pages"] != float64(1) {
			t.Fatalf("preview not generated correctly: %+v", ready)
		}

		response := alice.request(http.MethodGet, "/files/preview?path=/Docs/scan.pdf&size=128", nil, nil)
		defer response.Body.Close()
		thumbnail, _, err := image.Decode(response.Body)
		if response.StatusCode != http.StatusOK || err != nil || thumbnail.Bounds().Dx() != 128 || thumbnail.Bounds().Dy() != 64 {
			t.Fatalf("thumbnail: status %d err %v", response.StatusCode, err)
		}
		left, _, _, _ := thumbnail.At(32, 32).RGBA()
		_, rightGreen, _, _ := thumbnail.At(96, 32).RGBA()
		if left>>8 < 200 || rightGreen>>8 < 200 {
			t.Fatalf("expected a red left half on white, got %v and %v", thumbnail.At(32, 32), thumbnail.At(96, 32))
		}
	})
}

func TestRescanDropsIndexedSystemFiles(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/.DS_Store", 0, []byte("finder"), http.StatusOK, nil)

		var before changePage
		alice.mustJSON(http.MethodGet, "/sync/changes?cursor=0", nil, http.StatusOK, &before)

		owner, err := server.app.Users.ByID(context.Background(), 2)
		if err != nil {
			t.Fatal(err)
		}
		if err := server.app.Files.Rescan(context.Background(), owner); err != nil {
			t.Fatal(err)
		}

		var after changePage
		alice.mustJSON(http.MethodGet, fmt.Sprintf("/sync/changes?cursor=%d", before.Cursor), nil, http.StatusOK, &after)
		expected := []string{"delete /.DS_Store"}
		if fmt.Sprint(after.summary()) != fmt.Sprint(expected) {
			t.Fatalf("changes = %v, want %v", after.summary(), expected)
		}
	})
}
