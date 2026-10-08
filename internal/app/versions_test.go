package app_test

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"polder-server/internal/config"
)

type versionListing struct {
	Path     string `json:"path"`
	Versions []struct {
		ID         int64     `json:"id"`
		Size       int64     `json:"size"`
		Hash       string    `json:"hash"`
		ModifiedAt time.Time `json:"modifiedAt"`
		ReplacedAt time.Time `json:"replacedAt"`
		HasPreview bool      `json:"hasPreview"`
	} `json:"versions"`
	Retention versionRetention `json:"retention"`
}

type versionRetention struct {
	Enabled      bool   `json:"enabled"`
	KeepAllHours int    `json:"keepAllHours"`
	MaxAgeDays   int    `json:"maxAgeDays"`
	MaxPerFile   int    `json:"maxPerFile"`
	Source       string `json:"source"`
}

type storageUsage struct {
	UsedBytes    int64 `json:"usedBytes"`
	HistoryBytes int64 `json:"historyBytes"`
}

func (c *client) versions(path string) versionListing {
	c.server.t.Helper()
	var listing versionListing
	c.mustJSON(http.MethodGet, "/files/versions?path="+url.QueryEscape(path), nil, http.StatusOK, &listing)
	return listing
}

func (c *client) versionContent(id int64) string {
	c.server.t.Helper()
	response := c.request(http.MethodGet, fmt.Sprintf("/files/versions/%d/content", id), nil, nil)
	defer response.Body.Close()
	content, _ := io.ReadAll(response.Body)
	if response.StatusCode != http.StatusOK {
		c.server.t.Fatalf("download version %d: status %d: %s", id, response.StatusCode, content)
	}
	return string(content)
}

func (c *client) usage() storageUsage {
	c.server.t.Helper()
	var usage storageUsage
	c.mustJSON(http.MethodGet, "/auth/me", nil, http.StatusOK, &usage)
	return usage
}

func (c *client) waitForUsage(description string, done func(storageUsage) bool) {
	c.server.t.Helper()
	usage := c.usage()
	for deadline := time.Now().Add(10 * time.Second); !done(usage) && time.Now().Before(deadline); usage = c.usage() {
		time.Sleep(50 * time.Millisecond)
	}
	if !done(usage) {
		c.server.t.Fatalf("%s: usage is %+v", description, usage)
	}
}

func (c *client) waitForVersionCount(path string, count int) versionListing {
	c.server.t.Helper()
	listing := c.versions(path)
	for deadline := time.Now().Add(10 * time.Second); len(listing.Versions) != count && time.Now().Before(deadline); listing = c.versions(path) {
		time.Sleep(50 * time.Millisecond)
	}
	if len(listing.Versions) != count {
		c.server.t.Fatalf("want %d versions of %s, have %d", count, path, len(listing.Versions))
	}
	return listing
}

func (s *testServer) historyFiles(username, pattern string) []string {
	s.t.Helper()
	found, err := filepath.Glob(filepath.Join(s.app.Config.DataDir, ".polder", "versions", username, "history", "*", "*", pattern))
	if err != nil {
		s.t.Fatal(err)
	}
	return found
}

func (s *testServer) waitForHistoryFiles(username, pattern string, count int) []string {
	s.t.Helper()
	found := s.historyFiles(username, pattern)
	for deadline := time.Now().Add(10 * time.Second); len(found) != count && time.Now().Before(deadline); found = s.historyFiles(username, pattern) {
		time.Sleep(50 * time.Millisecond)
	}
	if len(found) != count {
		s.t.Fatalf("want %d history files matching %s, have %v", count, pattern, found)
	}
	return found
}

func randomBytes(t *testing.T, size int) []byte {
	t.Helper()
	content := make([]byte, size)
	if _, err := rand.Read(content); err != nil {
		t.Fatal(err)
	}
	return content
}

func TestSavingKeepsEarlierVersions(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/notes.txt", 0, []byte("first"), http.StatusOK, nil)
		alice.put("/notes.txt", -1, []byte("second"), http.StatusOK, nil)
		alice.put("/notes.txt", -1, []byte("second"), http.StatusOK, nil)
		alice.put("/notes.txt", -1, []byte("third"), http.StatusOK, nil)

		history := alice.versions("/notes.txt")
		if len(history.Versions) != 2 {
			t.Fatalf("want 2 earlier versions, saving the same content again should not add one: %+v", history.Versions)
		}
		if got := alice.versionContent(history.Versions[0].ID); got != "second" {
			t.Fatalf("newest version is %q", got)
		}
		alice.waitForUsage("versions are stored", func(usage storageUsage) bool { return usage.HistoryBytes > 0 })
		if got := alice.versionContent(history.Versions[1].ID); got != "first" {
			t.Fatalf("oldest version is %q", got)
		}

		var restored fileEntry
		alice.mustJSON(http.MethodPost, fmt.Sprintf("/files/versions/%d/restore", history.Versions[1].ID), map[string]any{}, http.StatusOK, &restored)
		if _, content := alice.download("/notes.txt", nil); string(content) != "first" {
			t.Fatalf("restore left %q", content)
		}
		if after := alice.versions("/notes.txt"); len(after.Versions) != 3 || alice.versionContent(after.Versions[0].ID) != "third" {
			t.Fatalf("restoring should keep the replaced content as a version: %+v", after.Versions)
		}
	})
}

func TestVersionsShareUnchangedChunks(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		const size = 8 << 20
		content := randomBytes(t, size)
		alice.put("/video.bin", 0, content, http.StatusOK, nil)
		for edit := range 2 {
			changed := bytes.Clone(content)
			copy(changed[size-100:], fmt.Sprintf("edit %d", edit))
			alice.put("/video.bin", -1, changed, http.StatusOK, nil)
			content = changed
		}
		alice.waitForUsage("versions share chunks", func(usage storageUsage) bool { return usage.HistoryBytes < size+(5<<20) })
		history := alice.versions("/video.bin")
		if len(history.Versions) != 2 || alice.versionContent(history.Versions[1].ID) == alice.versionContent(history.Versions[0].ID) {
			t.Fatalf("unexpected versions %+v", history.Versions)
		}
	})
}

func TestVersionsFollowTheFileThroughTheTrash(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/Docs/plan.txt", 0, []byte("draft"), http.StatusOK, nil)
		alice.put("/Docs/plan.txt", -1, []byte("final"), http.StatusOK, nil)
		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/Docs", "to": "/Archive"}, http.StatusOK, nil)
		if len(alice.versions("/Archive/plan.txt").Versions) != 1 {
			t.Fatal("versions should follow a moved folder")
		}

		alice.mustJSON(http.MethodDelete, "/files?path=/Archive", nil, http.StatusNoContent, nil)
		item := alice.trash().Items[0]
		alice.mustJSON(http.MethodPost, fmt.Sprintf("/trash/%d/restore", item.ID), map[string]any{}, http.StatusOK, nil)
		history := alice.versions("/Archive/plan.txt")
		if len(history.Versions) != 1 || alice.versionContent(history.Versions[0].ID) != "draft" {
			t.Fatalf("versions lost through the trash: %+v", history.Versions)
		}

		alice.mustJSON(http.MethodDelete, "/files?path=/Archive/plan.txt", nil, http.StatusNoContent, nil)
		alice.mustJSON(http.MethodDelete, "/trash", nil, http.StatusNoContent, nil)
		alice.waitForUsage("history is freed with the trash", func(usage storageUsage) bool { return usage.HistoryBytes == 0 && usage.UsedBytes == 0 })
		if leftovers := server.historyFiles("alice", "*"); len(leftovers) != 0 {
			t.Fatalf("emptying the trash should remove the history on disk: %v", leftovers)
		}
	})
}

func TestHistorySurvivesLosingTheDatabase(t *testing.T) {
	before := startServer(t, config.DriverSQLite, "")
	alice := before.createUser(before.setupAdmin(), "alice", 0)
	for _, content := range []string{"draft", "review", "final"} {
		alice.put("/Docs/plan.txt", -1, []byte(content), http.StatusOK, nil)
	}
	before.waitForHistoryFiles("alice", "*.version", 2)
	alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/Docs", "to": "/Archive"}, http.StatusOK, nil)
	var location struct {
		Path string `json:"path"`
	}
	content, err := os.ReadFile(before.waitForHistoryFiles("alice", "location", 1)[0])
	if err != nil || json.Unmarshal(content, &location) != nil || location.Path != "/Archive/plan.txt" {
		t.Fatalf("the history location should follow the move: %s %v", content, err)
	}
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
	history := alice.waitForVersionCount("/Archive/plan.txt", 2)
	if alice.versionContent(history.Versions[0].ID) != "review" || alice.versionContent(history.Versions[1].ID) != "draft" {
		t.Fatalf("recovered versions have the wrong content: %+v", history.Versions)
	}
	alice.waitForUsage("recovered history counts toward usage", func(usage storageUsage) bool { return usage.HistoryBytes > 0 })
}

func TestHistoryMakesRoomWithinTheQuota(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 3000)
		for save := range 5 {
			baseRev := int64(-1)
			if save == 0 {
				baseRev = 0
			}
			alice.put("/data.bin", baseRev, randomBytes(t, 1000), http.StatusOK, nil)
			if usage := alice.usage(); usage.UsedBytes > 3000 {
				t.Fatalf("save %d went over the quota: %+v", save, usage)
			}
		}
		if count := len(alice.versions("/data.bin").Versions); count != 2 {
			t.Fatalf("want the 2 newest versions to fit, have %d", count)
		}
		alice.put("/data.bin", -1, randomBytes(t, 3500), http.StatusInsufficientStorage, nil)
		alice.put("/data.bin", -1, randomBytes(t, 3000), http.StatusOK, nil)
		if count := len(alice.versions("/data.bin").Versions); count != 0 {
			t.Fatalf("a file filling the quota leaves no room for history, have %d versions", count)
		}
	})
}

func TestServerDecidesAboutHistory(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		var retention versionRetention
		for _, beyondServer := range []map[string]any{
			{"maxAgeDays": 1000},
			{"maxAgeDays": 0},
			{"maxPerFile": 101},
			{"keepAllHours": 7},
		} {
			alice.mustJSON(http.MethodPut, "/versions/settings", beyondServer, http.StatusBadRequest, nil)
		}
		alice.mustJSON(http.MethodPut, "/versions/settings", map[string]any{"maxPerFile": 1, "maxAgeDays": 30, "keepAllHours": 2}, http.StatusOK, &retention)
		if retention.MaxPerFile != 1 || retention.MaxAgeDays != 30 || retention.KeepAllHours != 2 || retention.Source != "user" {
			t.Fatalf("user limits should apply within the server's: %+v", retention)
		}
		for _, content := range []string{"one", "two", "three"} {
			alice.put("/a.txt", -1, []byte(content), http.StatusOK, nil)
		}
		if history := alice.waitForVersionCount("/a.txt", 1); alice.versionContent(history.Versions[0].ID) != "two" {
			t.Fatal("the newest version should be the one kept")
		}

		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"versionsKeepAllHours": 1, "versionsMaxAgeDays": 10}, http.StatusOK, nil)
		alice.mustJSON(http.MethodGet, "/versions/settings", nil, http.StatusOK, &retention)
		if retention.KeepAllHours != 1 || retention.MaxAgeDays != 10 || retention.MaxPerFile != 1 {
			t.Fatalf("lowered server limits should cap the user's: %+v", retention)
		}

		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"versionsEnabled": false}, http.StatusOK, nil)
		alice.mustJSON(http.MethodPut, "/versions/settings", map[string]any{"enabled": true}, http.StatusOK, &retention)
		if retention.Enabled {
			t.Fatalf("history the server turned off cannot be turned on by a user: %+v", retention)
		}
		alice.waitForVersionCount("/a.txt", 0)
		alice.put("/a.txt", -1, []byte("four"), http.StatusOK, nil)
		if count := len(alice.versions("/a.txt").Versions); count != 0 {
			t.Fatalf("history is off, yet %d versions were kept", count)
		}
	})
}

func TestOfficeOpensEarlierVersionsReadOnly(t *testing.T) {
	server := startOfficeServer(t)
	alice := server.createUser(server.setupAdmin(), "alice", 0)
	alice.put("/report.docx", 0, []byte("first draft"), http.StatusOK, nil)
	alice.put("/report.docx", -1, []byte("second draft"), http.StatusOK, nil)
	history := alice.versions("/report.docx")

	var session officeSession
	alice.mustJSON(http.MethodPost, "/office/sessions",
		map[string]any{"path": "/report.docx", "origin": server.server.URL, "versionId": history.Versions[0].ID}, http.StatusCreated, &session)
	if !session.ReadOnly {
		t.Fatal("an earlier version must open read-only")
	}
	response, info := server.wopi(session, http.MethodGet, "", nil, nil)
	if response.StatusCode != http.StatusOK || !strings.Contains(info, `"UserCanWrite":false`) || !strings.Contains(info, `"BaseFileName":"report (`) {
		t.Fatalf("CheckFileInfo: %d %s", response.StatusCode, info)
	}
	if response, content := server.wopi(session, http.MethodGet, "/contents", nil, nil); response.StatusCode != http.StatusOK || content != "first draft" {
		t.Fatalf("GetFile: %d %q", response.StatusCode, content)
	}
	if response, _ := server.wopi(session, http.MethodPost, "/contents", []byte("changed"), nil); response.StatusCode != http.StatusUnauthorized {
		t.Fatalf("saving over an earlier version: %d", response.StatusCode)
	}
}

func TestRestoringGivesTheEditorAFreshDocument(t *testing.T) {
	server := startOfficeServer(t)
	alice := server.createUser(server.setupAdmin(), "alice", 0)
	alice.put("/report.docx", 0, []byte("first draft"), http.StatusOK, nil)
	alice.put("/report.docx", -1, []byte("second draft"), http.StatusOK, nil)
	before := alice.startOfficeSession("/report.docx", http.StatusCreated)

	history := alice.versions("/report.docx")
	alice.mustJSON(http.MethodPost, fmt.Sprintf("/files/versions/%d/restore", history.Versions[0].ID), map[string]any{}, http.StatusOK, nil)
	after := alice.startOfficeSession("/report.docx", http.StatusCreated)

	if wopiSource(t, before) == wopiSource(t, after) {
		t.Fatal("after a restore the editor must not reuse the document it had loaded")
	}
	if response, content := server.wopi(after, http.MethodGet, "/contents", nil, nil); response.StatusCode != http.StatusOK || content != "first draft" {
		t.Fatalf("GetFile after restore: %d %q", response.StatusCode, content)
	}
	if response, _ := server.wopi(before, http.MethodGet, "", nil, nil); response.StatusCode != http.StatusOK {
		t.Fatalf("an editor opened before the restore should still reach the file: %d", response.StatusCode)
	}
}

func wopiSource(t *testing.T, session officeSession) string {
	t.Helper()
	editor, err := url.Parse(session.EditorURL)
	if err != nil {
		t.Fatal(err)
	}
	return editor.Query().Get("WOPISrc")
}
