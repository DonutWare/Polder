package app_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"image"
	"image/color"
	"image/png"
	"io"
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

type batchStatus struct {
	BatchID string `json:"batchId"`
	Missing []struct {
		Hash string `json:"hash"`
		Size int64  `json:"size"`
	} `json:"missing"`
	Results []batchResult `json:"results"`
}

type batchResult struct {
	Path  string     `json:"path"`
	Entry *fileEntry `json:"entry"`
	Error *struct {
		Code    string     `json:"code"`
		Current *fileEntry `json:"current"`
	} `json:"error"`
}

func (s batchStatus) result(path string) batchResult {
	for _, result := range s.Results {
		if result.Path == path {
			return result
		}
	}
	return batchResult{}
}

func planUpload(t *testing.T, content []byte, path string, baseRev int64) (map[string]any, map[string][]byte) {
	t.Helper()
	chunks := []map[string]any{}
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

func (c *client) createBatch(plans ...map[string]any) batchStatus {
	c.server.t.Helper()
	var status batchStatus
	c.mustJSON(http.MethodPost, "/sync/batches", map[string]any{"files": plans}, http.StatusCreated, &status)
	return status
}

func (c *client) streamBatch(status batchStatus, data map[string][]byte) batchStatus {
	c.server.t.Helper()
	var body bytes.Buffer
	for _, chunk := range status.Missing {
		body.Write(data[chunk.Hash])
	}
	var result batchStatus
	c.expect(c.request(http.MethodPut, "/sync/batches/"+status.BatchID+"/stream", &body, nil), http.StatusOK, &result)
	return result
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

		status := alice.createBatch(request)
		var uploadedBytes int64
		for _, missing := range status.Missing {
			uploadedBytes += missing.Size
		}
		if uploadedBytes == 0 || uploadedBytes > 2*chunker.MaxSize {
			t.Fatalf("expected a small delta, would upload %d of %d bytes", uploadedBytes, len(edited))
		}

		done := alice.streamBatch(status, chunkData)
		committed := done.result("/big.bin").Entry
		_, downloaded := alice.download("/big.bin", nil)
		if committed == nil || !bytes.Equal(downloaded, edited) || committed.Rev <= base.Rev {
			t.Fatalf("assembled file does not match the edited content: %+v", done)
		}
		alice.expect(alice.request(http.MethodGet, "/sync/batches/"+status.BatchID, nil, nil), http.StatusNotFound, nil)
	})
}

func TestUploadBatchResumesAfterBrokenStream(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		content := pseudoRandomBytes(6<<20, 3)
		request, chunkData := planUpload(t, content, "/resume.bin", 0)
		status := alice.createBatch(request)
		if len(status.Missing) < 2 {
			t.Fatalf("expected several chunks, got %d", len(status.Missing))
		}

		first := status.Missing[0]
		alice.expect(alice.request(http.MethodPut, "/sync/batches/"+status.BatchID+"/stream", bytes.NewReader(chunkData[first.Hash]), nil), http.StatusBadRequest, nil)

		var resumed batchStatus
		alice.mustJSON(http.MethodGet, "/sync/batches/"+status.BatchID, nil, http.StatusOK, &resumed)
		if len(resumed.Missing) != len(status.Missing)-1 || resumed.Missing[0].Hash != status.Missing[1].Hash {
			t.Fatalf("resume should skip the chunk that arrived: %+v", resumed.Missing)
		}

		done := alice.streamBatch(resumed, chunkData)
		_, downloaded := alice.download("/resume.bin", nil)
		if done.result("/resume.bin").Entry == nil || !bytes.Equal(downloaded, content) {
			t.Fatalf("resumed upload = %+v", done)
		}
	})
}

func TestNewUploadBatchReusesChunksAnAbandonedBatchReceived(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		content := pseudoRandomBytes(6<<20, 5)
		request, chunkData := planUpload(t, content, "/paused.bin", 0)
		abandoned := alice.createBatch(request)
		first := abandoned.Missing[0]
		alice.expect(alice.request(http.MethodPut, "/sync/batches/"+abandoned.BatchID+"/stream", bytes.NewReader(chunkData[first.Hash]), nil), http.StatusBadRequest, nil)

		retried := alice.createBatch(request)
		if len(retried.Missing) != len(abandoned.Missing)-1 {
			t.Fatalf("the new batch should not ask for the chunk the old one received: %d of %d", len(retried.Missing), len(abandoned.Missing))
		}
		alice.expect(alice.request(http.MethodDelete, "/sync/batches/"+abandoned.BatchID, nil, nil), http.StatusNoContent, nil)
		done := alice.streamBatch(retried, chunkData)
		if _, downloaded := alice.download("/paused.bin", nil); done.result("/paused.bin").Entry == nil || !bytes.Equal(downloaded, content) {
			t.Fatalf("retried upload = %+v", done)
		}
	})
}

func TestUploadBatchStoresManyFilesInOneStream(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		var plans []map[string]any
		data := map[string][]byte{}
		contents := map[string][]byte{}
		for i := range 40 {
			path := fmt.Sprintf("/many/file-%02d.txt", i)
			contents[path] = fmt.Appendf(nil, "file number %d", i%30)
			plan, chunks := planUpload(t, contents[path], path, 0)
			plans = append(plans, plan)
			for hash, chunk := range chunks {
				data[hash] = chunk
			}
		}
		empty, _ := planUpload(t, nil, "/many/empty.txt", 0)
		plans = append(plans, empty)

		status := alice.createBatch(plans...)
		if len(status.Missing) != 30 {
			t.Fatalf("identical files should be sent once: %d missing", len(status.Missing))
		}
		done := alice.streamBatch(status, data)
		if len(done.Results) != len(plans) || len(done.Missing) != 0 {
			t.Fatalf("stream result = %+v", done)
		}
		for path, content := range contents {
			if done.result(path).Entry == nil {
				t.Fatalf("%s was not stored: %+v", path, done.result(path))
			}
			if _, downloaded := alice.download(path, nil); !bytes.Equal(downloaded, content) {
				t.Fatalf("%s = %q", path, downloaded)
			}
		}
		if alice.stat("/many/empty.txt").Size != 0 {
			t.Fatal("the empty file should be stored")
		}
	})
}

func TestUploadBatchReportsFailuresPerFile(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		var stale, raced fileEntry
		alice.put("/stale.txt", 0, []byte("old"), http.StatusOK, &stale)
		alice.put("/stale.txt", stale.Rev, []byte("newer"), http.StatusOK, nil)
		alice.put("/raced.txt", 0, []byte("old"), http.StatusOK, &raced)

		data := map[string][]byte{}
		plan := func(path string, content []byte, baseRev int64) map[string]any {
			request, chunks := planUpload(t, content, path, baseRev)
			for hash, chunk := range chunks {
				data[hash] = chunk
			}
			return request
		}
		status := alice.createBatch(
			plan("/stale.txt", []byte("mine"), stale.Rev),
			plan("/raced.txt", []byte("mine too"), raced.Rev),
			plan("/corrupt.txt", []byte("will be damaged"), 0),
			plan("/fine.txt", []byte("all good"), 0),
		)
		if rejected := status.result("/stale.txt"); rejected.Error == nil || rejected.Error.Code != "conflict" || rejected.Error.Current == nil {
			t.Fatalf("stale file should be rejected up front: %+v", status.Results)
		}
		if len(status.Missing) != 3 {
			t.Fatalf("rejected files should not be asked for: %d missing", len(status.Missing))
		}

		alice.put("/raced.txt", raced.Rev, []byte("someone else won"), http.StatusOK, nil)
		for hash, chunk := range data {
			if string(chunk) == "will be damaged" {
				data[hash] = []byte("will be DAMAGED")
			}
		}
		done := alice.streamBatch(status, data)
		if result := done.result("/raced.txt"); result.Error == nil || result.Error.Code != "conflict" {
			t.Fatalf("raced file should conflict: %+v", result)
		}
		if result := done.result("/corrupt.txt"); result.Error == nil || result.Error.Code != "precondition_failed" {
			t.Fatalf("corrupt file should fail: %+v", result)
		}
		if done.result("/fine.txt").Entry == nil {
			t.Fatalf("other files should still be stored: %+v", done.Results)
		}
	})
}

func TestUploadBatchChecksQuotaAcrossFiles(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 100)
		first, _ := planUpload(t, bytes.Repeat([]byte("a"), 60), "/a.txt", 0)
		second, _ := planUpload(t, bytes.Repeat([]byte("b"), 60), "/b.txt", 0)
		status := alice.createBatch(first, second)
		if result := status.result("/b.txt"); result.Error == nil || result.Error.Code != "quota_exceeded" {
			t.Fatalf("second file should exceed the quota: %+v", status.Results)
		}
		if status.result("/a.txt").Error != nil {
			t.Fatalf("first file fits: %+v", status.Results)
		}
	})
}

type downloadRecord struct {
	Path  string `json:"path"`
	Rev   int64  `json:"rev"`
	Size  int64  `json:"size"`
	Hash  string `json:"hash"`
	Error *struct {
		Code string `json:"code"`
	} `json:"error"`
	content []byte
}

func readDownloadRecords(t *testing.T, body []byte) []downloadRecord {
	t.Helper()
	var records []downloadRecord
	for len(body) > 0 {
		newline := bytes.IndexByte(body, '\n')
		var record downloadRecord
		if err := json.Unmarshal(body[:newline], &record); err != nil {
			t.Fatal(err)
		}
		body = body[newline+1:]
		record.content, body = body[:record.Size], body[record.Size:]
		records = append(records, record)
	}
	return records
}

func TestDownloadBatchStreamsFilesInOrder(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		var first, stale fileEntry
		alice.put("/a.txt", 0, []byte("first file"), http.StatusOK, &first)
		alice.put("/empty.txt", 0, nil, http.StatusOK, nil)
		alice.put("/stale.txt", 0, []byte("old"), http.StatusOK, &stale)
		alice.put("/stale.txt", stale.Rev, []byte("new"), http.StatusOK, nil)

		request := map[string]any{"files": []map[string]any{
			{"path": "/a.txt", "rev": first.Rev}, {"path": "/missing.txt"}, {"path": "/empty.txt"}, {"path": "/stale.txt", "rev": stale.Rev},
		}}
		encoded, _ := json.Marshal(request)
		response := alice.request(http.MethodPost, "/sync/downloads", bytes.NewReader(encoded), map[string]string{"Content-Type": "application/json"})
		defer response.Body.Close()
		body, _ := io.ReadAll(response.Body)
		if response.StatusCode != http.StatusOK {
			t.Fatalf("status %d: %s", response.StatusCode, body)
		}

		records := readDownloadRecords(t, body)
		if len(records) != 4 {
			t.Fatalf("records = %+v", records)
		}
		if string(records[0].content) != "first file" || records[0].Hash != first.Hash || records[0].Rev != first.Rev {
			t.Fatalf("first record = %+v", records[0])
		}
		if records[1].Error == nil || records[1].Error.Code != "not_found" {
			t.Fatalf("missing file should fail on its own: %+v", records[1])
		}
		if records[2].Error != nil || records[2].Size != 0 {
			t.Fatalf("empty file = %+v", records[2])
		}
		if records[3].Error == nil || records[3].Error.Code != "precondition_failed" {
			t.Fatalf("stale revision should fail: %+v", records[3])
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
			if err := os.WriteFile(filepath.Join(folder, fmt.Sprintf("%03d.txt", i)), fmt.Append(nil, i), 0o640); err != nil {
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

// A 200x100pt page whose left half is red; PDFium rebuilds the missing xref table.
const redHalfPDF = "%PDF-1.4\n" +
	"1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n" +
	"2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj\n" +
	"3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 200 100] /Contents 4 0 R >> endobj\n" +
	"4 0 obj << /Length 26 >> stream\n1 0 0 rg 0 0 100 100 re f\nendstream endobj\n" +
	"trailer << /Root 1 0 R >>\n%%EOF\n"

func TestPDFsGetFirstPageThumbnails(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)

		var uploaded fileEntry
		alice.put("/Docs/scan.pdf", 0, []byte(redHalfPDF), http.StatusOK, &uploaded)
		if uploaded.PreviewState != "pending" {
			t.Fatalf("new PDF should await a preview, got %s", uploaded.PreviewState)
		}

		var ready fileEntry
		deadline := time.Now().Add(2 * time.Minute)
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
