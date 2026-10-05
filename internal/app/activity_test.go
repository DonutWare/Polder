package app_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/coder/websocket"
	"github.com/coder/websocket/wsjson"

	"polder-server/internal/activity"
)

type activityEntry struct {
	ID       int64  `json:"id"`
	UserID   int64  `json:"userId"`
	Username string `json:"username"`
	Device   string `json:"device"`
	Kind     string `json:"kind"`
	Path     string `json:"path"`
	FromPath string `json:"fromPath"`
	Size     *int64 `json:"size"`
	Bytes    *int64 `json:"bytes"`
	Count    *int64 `json:"count"`
	Status   string `json:"status"`
	Detail   string `json:"detail"`
}

type activityPage struct {
	Entries    []activityEntry `json:"entries"`
	NextCursor int64           `json:"nextCursor"`
}

func (s *testServer) loginFrom(username, password, device string) *client {
	var tokens tokenPair
	s.anonymous().mustJSON(http.MethodPost, "/auth/login",
		map[string]string{"username": username, "password": password, "deviceName": device}, http.StatusOK, &tokens)
	return &client{server: s, token: tokens.AccessToken}
}

func (c *client) activity(query string) activityPage {
	c.server.t.Helper()
	var page activityPage
	c.mustJSON(http.MethodGet, "/activity"+query, nil, http.StatusOK, &page)
	return page
}

func kinds(page activityPage) string {
	var listed []string
	for _, entry := range page.Entries {
		listed = append(listed, entry.Kind+" "+entry.Path)
	}
	return strings.Join(listed, ", ")
}

func eventually(t *testing.T, check func() error) {
	t.Helper()
	deadline := time.Now().Add(3 * time.Second)
	for {
		err := check()
		if err == nil {
			return
		}
		if time.Now().After(deadline) {
			t.Fatal(err)
		}
		time.Sleep(20 * time.Millisecond)
	}
}

func TestActivityLogsFileOperations(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		server.createUser(server.setupAdmin(), "alice", 0)
		alice := server.loginFrom("alice", "password1", "laptop")

		alice.put("/notes.txt", 0, []byte("hello"), http.StatusOK, nil)
		alice.mustJSON(http.MethodPost, "/files/mkdir", map[string]string{"path": "/Docs"}, http.StatusCreated, nil)
		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/notes.txt", "to": "/Docs/notes.txt"}, http.StatusOK, nil)
		alice.expect(alice.request(http.MethodDelete, "/files?path=/Docs/notes.txt", nil, nil), http.StatusNoContent, nil)
		listing := alice.trash()
		alice.restore(listing.Items[0].ID, "fail", http.StatusOK, nil)

		page := alice.activity("")
		want := "restore /Docs/notes.txt, delete /Docs/notes.txt, move /Docs/notes.txt, mkdir /Docs, upload /notes.txt, login , login "
		if kinds(page) != want {
			t.Fatalf("activity = %s\nwant       %s", kinds(page), want)
		}
		upload := page.Entries[4]
		if upload.Device != "laptop" || upload.Bytes == nil || *upload.Bytes != 5 || upload.Size == nil || *upload.Size != 5 || upload.Status != "ok" {
			t.Fatalf("upload entry = %+v", upload)
		}
		if page.Entries[2].FromPath != "/notes.txt" {
			t.Fatalf("move should record its source: %+v", page.Entries[2])
		}
	})
}

func TestFailedUploadIsLoggedAsFailed(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/taken.txt", 0, []byte("one"), http.StatusOK, nil)
		alice.put("/taken.txt", 0, []byte("two"), http.StatusConflict, nil)

		latest := alice.activity("?limit=1").Entries[0]
		if latest.Kind != "upload" || latest.Status != "failed" || latest.Detail == "" {
			t.Fatalf("expected a failed upload, got %+v", latest)
		}
	})
}

func TestDeltaUploadIsLoggedOnce(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		content := pseudoRandomBytes(3<<20, 7)
		request, chunkData := planUpload(t, content, "/sync/big.bin", 0)

		var status uploadStatus
		alice.mustJSON(http.MethodPost, "/sync/uploads", request, http.StatusCreated, &status)
		var sent int64
		for _, missing := range status.Missing {
			sent += int64(len(chunkData[missing]))
			alice.expect(alice.request(http.MethodPut, "/sync/uploads/"+status.UploadID+"/chunks/"+missing, bytes.NewReader(chunkData[missing]), nil), http.StatusNoContent, nil)
		}
		alice.mustJSON(http.MethodPost, "/sync/uploads/"+status.UploadID+"/commit", nil, http.StatusOK, nil)

		page := alice.activity("")
		if kinds(page) != "upload /sync/big.bin, login " {
			t.Fatalf("activity = %s", kinds(page))
		}
		upload := page.Entries[0]
		if *upload.Bytes != sent || *upload.Size != int64(len(content)) || upload.Status != "ok" {
			t.Fatalf("upload entry = %+v, sent %d", upload, sent)
		}
	})
}

func TestDownloadsAreLogged(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/movie.bin", 0, pseudoRandomBytes(10_000, 3), http.StatusOK, nil)

		alice.download("/movie.bin", nil)
		alice.download("/movie.bin", map[string]string{"Range": "bytes=0-99"})
		alice.download("/movie.bin", map[string]string{"Range": "bytes=100-199"})
		eventually(t, func() error {
			if got := kinds(alice.activity("")); got != "download /movie.bin, upload /movie.bin, login " {
				return fmt.Errorf("activity = %s", got)
			}
			return nil
		})
		full := alice.activity("").Entries[0]
		if *full.Bytes != 10_000 || full.Status != "ok" {
			t.Fatalf("full download = %+v", full)
		}

		later := time.Now().Add(time.Minute)
		server.app.Activity.Sweep(later)
		server.app.Activity.Sweep(later.Add(time.Minute))
		page := alice.activity("")
		if kinds(page) != "download /movie.bin, download /movie.bin, upload /movie.bin, login " || *page.Entries[0].Bytes != 200 {
			t.Fatalf("range reads should be one download of 200 bytes: %s %+v", kinds(page), page.Entries[0])
		}
	})
}

func TestActivityScopes(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.put("/a.txt", 0, []byte("a"), http.StatusOK, nil)
		bob.put("/b.txt", 0, []byte("b"), http.StatusOK, nil)

		alice.mustJSON(http.MethodGet, "/activity?user=all", nil, http.StatusForbidden, nil)
		alice.mustJSON(http.MethodGet, "/activity/live?user=all", nil, http.StatusForbidden, nil)
		if got := kinds(alice.activity("?user=me")); got != "upload /a.txt, login " {
			t.Fatalf("alice sees %s", got)
		}
		if got := kinds(admin.activity("")); got != "login " {
			t.Fatalf("admin's own activity should be their login, got %s", got)
		}

		all := admin.activity("?user=all")
		if len(all.Entries) != 5 {
			t.Fatalf("all users = %s", kinds(all))
		}
		bobID := all.Entries[0].UserID
		if got := kinds(admin.activity(fmt.Sprintf("?user=%d", bobID))); got != "upload /b.txt, login " {
			t.Fatalf("bob's activity = %s", got)
		}
		admin.mustJSON(http.MethodGet, "/activity?user=999", nil, http.StatusNotFound, nil)

		first := admin.activity("?user=all&limit=3")
		if len(first.Entries) != 3 || first.NextCursor == 0 {
			t.Fatalf("first page = %+v", first)
		}
		rest := admin.activity(fmt.Sprintf("?user=all&limit=3&before=%d", first.NextCursor))
		if len(rest.Entries) != 2 || rest.NextCursor != 0 || rest.Entries[1].Username != "admin" {
			t.Fatalf("second page = %+v", rest)
		}
	})
}

func TestLogoutAndOldActivity(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		var tokens tokenPair
		server.anonymous().mustJSON(http.MethodPost, "/auth/login",
			map[string]string{"username": "alice", "password": "password1", "deviceName": "phone"}, http.StatusOK, &tokens)
		server.anonymous().mustJSON(http.MethodPost, "/auth/logout", map[string]string{"refreshToken": tokens.RefreshToken}, http.StatusNoContent, nil)

		page := alice.activity("")
		if kinds(page) != "logout , login , login " || page.Entries[0].Device != "phone" {
			t.Fatalf("activity = %s, %+v", kinds(page), page.Entries[0])
		}

		ctx := context.Background()
		store := server.app.Activity.Store()
		old := activity.LogEntry{UserID: page.Entries[0].UserID, Device: "old", Kind: activity.KindMkdir, Path: "/old",
			Status: activity.StatusOK, CreatedAt: time.Now().Add(-activity.Retention - time.Hour)}
		if _, err := store.Insert(ctx, old); err != nil {
			t.Fatal(err)
		}
		removed, err := store.PurgeOlderThan(ctx, time.Now().Add(-activity.Retention))
		if err != nil || removed != 1 {
			t.Fatalf("purged %d, err %v", removed, err)
		}
		if got := kinds(alice.activity("")); got != "logout , login , login " {
			t.Fatalf("recent activity should stay: %s", got)
		}
	})
}

type eventSocket struct {
	t    *testing.T
	conn *websocket.Conn
}

type socketMessage struct {
	Type      string                  `json:"type"`
	UserID    int64                   `json:"userId"`
	Code      string                  `json:"code"`
	Dirs      []string                `json:"dirs"`
	Transfer  *activity.LiveTransfer  `json:"transfer"`
	Transfers []activity.LiveTransfer `json:"transfers"`
	Entry     *activityEntry          `json:"entry"`
}

func (c *client) openEvents() *eventSocket {
	c.server.t.Helper()
	socket := c.dialEvents()
	socket.send(map[string]any{"type": "auth", "token": c.token})
	socket.next("ready")
	socket.next("snapshot")
	return socket
}

func (c *client) dialEvents() *eventSocket {
	c.server.t.Helper()
	target := "ws" + strings.TrimPrefix(c.server.server.URL, "http") + "/api/v1/events"
	conn, _, err := websocket.Dial(context.Background(), target, nil)
	if err != nil {
		c.server.t.Fatal(err)
	}
	c.server.t.Cleanup(func() { conn.CloseNow() })
	return &eventSocket{t: c.server.t, conn: conn}
}

func (s *eventSocket) send(message any) {
	s.t.Helper()
	if err := wsjson.Write(context.Background(), s.conn, message); err != nil {
		s.t.Fatal(err)
	}
}

func (s *eventSocket) read() (socketMessage, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	var message socketMessage
	_, raw, err := s.conn.Read(ctx)
	if err != nil {
		return message, err
	}
	return message, json.Unmarshal(raw, &message)
}

func (s *eventSocket) next(messageType string) socketMessage {
	s.t.Helper()
	for {
		message, err := s.read()
		if err != nil {
			s.t.Fatalf("waiting for %s: %v", messageType, err)
		}
		if message.Type == messageType {
			return message
		}
	}
}

func TestEventsRequireAuthentication(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		server.setupAdmin()
		socket := server.anonymous().dialEvents()
		socket.send(map[string]any{"type": "subscribe", "scope": "all"})
		_, err := socket.read()
		if websocket.CloseStatus(err) != 4401 {
			t.Fatalf("expected close 4401, got %v", err)
		}

		socket = server.anonymous().dialEvents()
		socket.send(map[string]any{"type": "auth", "token": "not-a-token"})
		_, err = socket.read()
		if websocket.CloseStatus(err) != 4401 {
			t.Fatalf("expected close 4401 for a bad token, got %v", err)
		}
	})
}

func TestEventsFollowTransfersAndScopes(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)

		aliceEvents := alice.openEvents()
		bobEvents := bob.openEvents()
		adminEvents := admin.openEvents()
		adminEvents.send(map[string]any{"type": "subscribe", "scope": "all"})
		adminEvents.next("snapshot")

		bobEvents.send(map[string]any{"type": "subscribe", "scope": "all"})
		if refused := bobEvents.next("error"); refused.Code != "forbidden" {
			t.Fatalf("bob should not watch everyone: %+v", refused)
		}

		alice.request(http.MethodPut, "/files/content?path=/Photos/cat.jpg&baseRev=0", bytes.NewReader([]byte("meow")),
			map[string]string{"X-Polder-Transfer-Id": "local-1"}).Body.Close()

		started := aliceEvents.next("transfer.started")
		if started.Transfer.Path != "/Photos/cat.jpg" || started.Transfer.ClientID != "local-1" || *started.Transfer.Total != 4 {
			t.Fatalf("started = %+v", started.Transfer)
		}
		changed := aliceEvents.next("files.changed")
		if strings.Join(changed.Dirs, ",") != "/,/Photos" {
			t.Fatalf("changed dirs = %v", changed.Dirs)
		}
		finished := aliceEvents.next("transfer.finished")
		if finished.Transfer.Bytes != 4 {
			t.Fatalf("finished = %+v", finished.Transfer)
		}
		if logged := aliceEvents.next("activity.created"); logged.Entry.Kind != "upload" {
			t.Fatalf("logged = %+v", logged.Entry)
		}
		if seen := adminEvents.next("transfer.started"); seen.Transfer.Username != "alice" {
			t.Fatalf("admin watching everyone should see alice: %+v", seen.Transfer)
		}

		// Bob's own upload comes after alice's events would have, so seeing it proves none reached him.
		bob.put("/mine.txt", 0, []byte("b"), http.StatusOK, nil)
		for {
			message, err := bobEvents.read()
			if err != nil {
				t.Fatal(err)
			}
			if message.UserID == started.Transfer.UserID {
				t.Fatalf("bob received alice's event: %+v", message)
			}
			if message.Type == "activity.created" {
				break
			}
		}
	})
}

func TestRefreshRenamesSessionDevice(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		server.setupAdmin()
		var first, renamed, kept tokenPair
		server.anonymous().mustJSON(http.MethodPost, "/auth/login",
			map[string]string{"username": "admin", "password": "adminpass1", "deviceName": "old name"}, http.StatusOK, &first)
		server.anonymous().mustJSON(http.MethodPost, "/auth/refresh",
			map[string]string{"refreshToken": first.RefreshToken, "deviceName": "new name"}, http.StatusOK, &renamed)
		server.anonymous().mustJSON(http.MethodPost, "/auth/refresh",
			map[string]string{"refreshToken": renamed.RefreshToken}, http.StatusOK, &kept)

		admin := &client{server: server, token: kept.AccessToken}
		admin.mustJSON(http.MethodPost, "/files/mkdir", map[string]string{"path": "/Docs"}, http.StatusCreated, nil)
		if entry := admin.activity("").Entries[0]; entry.Kind != "mkdir" || entry.Device != "new name" {
			t.Fatalf("entry = %+v", entry)
		}
	})
}
