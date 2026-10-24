package app_test

import (
	"archive/zip"
	"bytes"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"testing"
)

type outgoingShare struct {
	ID        int64 `json:"id"`
	Available bool  `json:"available"`
	File      struct {
		ID   int64  `json:"id"`
		Path string `json:"path"`
	} `json:"file"`
	Permissions map[string]bool `json:"permissions"`
}

type incomingShare struct {
	ID    int64 `json:"id"`
	Owner struct {
		Username string `json:"username"`
	} `json:"owner"`
	Direct bool `json:"direct"`
	Groups []struct {
		Name string `json:"name"`
	} `json:"groups"`
	Permissions map[string]bool `json:"permissions"`
	Note        string          `json:"note"`
	Entry       fileEntry       `json:"entry"`
	MountPath   string          `json:"mountPath"`
}

type listing struct {
	Path    string      `json:"path"`
	Entries []fileEntry `json:"entries"`
	Mount   *mountInfo  `json:"mount"`
}

var (
	viewOnly = map[string]bool{}
	canEdit  = map[string]bool{"create": true, "edit": true, "delete": true}
)

func preset(name string) map[string]bool {
	if name == "write" {
		return canEdit
	}
	return viewOnly
}

func (c *client) share(fileID int64, kind string, recipientID int64, permission string) outgoingShare {
	c.server.t.Helper()
	return c.shareWith(map[string]any{"fileId": fileID}, kind, recipientID, preset(permission), http.StatusCreated)
}

func (c *client) shareWith(body map[string]any, kind string, recipientID int64, permissions map[string]bool, expectedStatus int) outgoingShare {
	c.server.t.Helper()
	body["recipient"] = map[string]any{"kind": kind, "id": recipientID}
	body["permissions"] = permissions
	var share outgoingShare
	var target any = &share
	if expectedStatus != http.StatusCreated {
		target = nil
	}
	c.mustJSON(http.MethodPost, "/shares", body, expectedStatus, target)
	return share
}

func (c *client) incoming() []incomingShare {
	c.server.t.Helper()
	var list []incomingShare
	c.mustJSON(http.MethodGet, "/shares/incoming", nil, http.StatusOK, &list)
	return list
}

func (c *client) shareList(shareID int64, path string, expectedStatus int) listing {
	c.server.t.Helper()
	var listed listing
	c.mustJSON(http.MethodGet, fmt.Sprintf("/shares/%d/list?path=%s", shareID, url.QueryEscape(path)), nil, expectedStatus, &listed)
	return listed
}

func (c *client) sharePut(shareID int64, path string, baseRev int64, content []byte, expectedStatus int, target any) {
	c.server.t.Helper()
	query := fmt.Sprintf("/shares/%d/content?path=%s&baseRev=%d", shareID, url.QueryEscape(path), baseRev)
	c.expect(c.request(http.MethodPut, query, bytes.NewReader(content), nil), expectedStatus, target)
}

func TestReadSharesExposeOnlyTheSharedFolder(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		carol := server.createUser(admin, "carol", 0)
		alice.put("/Photos/Summer/beach.txt", 0, []byte("sand"), http.StatusOK, nil)
		alice.put("/Private/diary.txt", 0, []byte("secret"), http.StatusOK, nil)
		summer := alice.stat("/Photos/Summer")

		share := alice.share(summer.ID, "user", bob.me(), "read")
		if share.File.Path != "/Photos/Summer" || !share.Available {
			t.Fatalf("unexpected share %+v", share)
		}

		incoming := bob.incoming()
		if len(incoming) != 1 || incoming[0].Entry.Path != "/" || incoming[0].Entry.Name != "Summer" || incoming[0].Owner.Username != "alice" {
			t.Fatalf("unexpected incoming %+v", incoming)
		}
		listed := bob.shareList(share.ID, "/", http.StatusOK)
		if len(listed.Entries) != 1 || listed.Entries[0].Path != "/beach.txt" {
			t.Fatalf("listing leaks or misses paths: %+v", listed)
		}

		response := bob.request(http.MethodGet, fmt.Sprintf("/shares/%d/content?path=/beach.txt", share.ID), nil, nil)
		if body := readBody(t, response); response.StatusCode != http.StatusOK || string(body) != "sand" {
			t.Fatalf("download: %d %q", response.StatusCode, body)
		}
		if response.Header.Get("X-Content-Type-Options") != "nosniff" {
			t.Fatal("shared content must not be sniffed")
		}

		response = bob.request(http.MethodGet, fmt.Sprintf("/shares/%d/archive?path=/", share.ID), nil, nil)
		archiveBytes := readBody(t, response)
		archive, err := zip.NewReader(bytes.NewReader(archiveBytes), int64(len(archiveBytes)))
		if err != nil || len(archive.File) != 1 || archive.File[0].Name != "beach.txt" {
			t.Fatalf("archive: %v %+v", err, archive)
		}

		for _, escape := range []string{"/..", "/../Private", "../../Private/diary.txt"} {
			response := bob.request(http.MethodGet, fmt.Sprintf("/shares/%d/content?path=%s", share.ID, url.QueryEscape(escape)), nil, nil)
			if body := readBody(t, response); response.StatusCode == http.StatusOK || strings.Contains(string(body), "secret") {
				t.Fatalf("escaped the share with %q: %d %s", escape, response.StatusCode, body)
			}
		}

		bob.sharePut(share.ID, "/new.txt", -1, []byte("x"), http.StatusForbidden, nil)
		bob.mustJSON(http.MethodPost, fmt.Sprintf("/shares/%d/mkdir", share.ID), map[string]string{"path": "/Sub"}, http.StatusForbidden, nil)
		bob.expect(bob.request(http.MethodDelete, fmt.Sprintf("/shares/%d/files?path=/beach.txt", share.ID), nil, nil), http.StatusForbidden, nil)

		carol.shareList(share.ID, "/", http.StatusNotFound)
		carol.shareList(999999, "/", http.StatusNotFound)
	})
}

func TestWriteSharesChangeTheOwnersFiles(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 10)
		bob := server.createUser(admin, "bob", 0)
		alice.mustJSON(http.MethodPost, "/files/mkdir", map[string]string{"path": "/Team"}, http.StatusCreated, nil)
		share := alice.share(alice.stat("/Team").ID, "user", bob.me(), "write")

		var written fileEntry
		bob.sharePut(share.ID, "/notes.txt", -1, []byte("hello"), http.StatusOK, &written)
		if written.Path != "/notes.txt" {
			t.Fatalf("written entry path %q", written.Path)
		}
		if alice.stat("/Team/notes.txt").Size != 5 {
			t.Fatal("upload did not land in the owner's tree")
		}
		bob.sharePut(share.ID, "/big.txt", -1, []byte("more than ten bytes"), http.StatusInsufficientStorage, nil)

		bob.mustJSON(http.MethodPost, fmt.Sprintf("/shares/%d/move", share.ID), map[string]any{"from": "/notes.txt", "to": "/../notes.txt"}, http.StatusBadRequest, nil)
		bob.mustJSON(http.MethodPost, fmt.Sprintf("/shares/%d/move", share.ID), map[string]any{"from": "/", "to": "/Elsewhere"}, http.StatusBadRequest, nil)
		bob.expect(bob.request(http.MethodDelete, fmt.Sprintf("/shares/%d/files?path=/", share.ID), nil, nil), http.StatusBadRequest, nil)

		bob.expect(bob.request(http.MethodDelete, fmt.Sprintf("/shares/%d/files?path=/notes.txt", share.ID), nil, nil), http.StatusNoContent, nil)
		if items := alice.trash().Items; len(items) != 1 || items[0].Name != "notes.txt" {
			t.Fatalf("delete should go to the owner's trash: %+v", items)
		}

		var activity struct {
			Entries []struct {
				Kind string `json:"kind"`
				Via  string `json:"via"`
			} `json:"entries"`
		}
		alice.mustJSON(http.MethodGet, "/activity", nil, http.StatusOK, &activity)
		found := false
		for _, entry := range activity.Entries {
			found = found || (entry.Kind == "delete" && entry.Via == "bob")
		}
		if !found {
			t.Fatalf("owner's activity does not say bob deleted: %+v", activity.Entries)
		}
	})
}

func TestGroupSharesFollowMembership(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		carol := server.createUser(admin, "carol", 0)
		groupID := server.createGroup(admin, "Family", alice, bob)
		alice.put("/Recipes/soup.txt", 0, []byte("soup"), http.StatusOK, nil)
		share := alice.share(alice.stat("/Recipes").ID, "group", groupID, "read")

		if len(alice.incoming()) != 0 {
			t.Fatal("the owner should not see their own share as incoming")
		}
		incoming := bob.incoming()
		if len(incoming) != 1 || incoming[0].Direct || len(incoming[0].Groups) != 1 || incoming[0].Groups[0].Name != "Family" {
			t.Fatalf("unexpected incoming %+v", incoming)
		}
		carol.shareList(share.ID, "/", http.StatusNotFound)

		admin.expect(admin.request(http.MethodDelete, fmt.Sprintf("/groups/%d/members/%d", groupID, bob.me()), nil, nil), http.StatusNoContent, nil)
		admin.mustJSON(http.MethodPost, fmt.Sprintf("/groups/%d/members", groupID), map[string]any{"userId": carol.me()}, http.StatusCreated, nil)
		carol.shareList(share.ID, "/", http.StatusOK)
		bob.shareList(share.ID, "/", http.StatusNotFound)
	})
}

func TestSharesOfTheSameItemAreCombined(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		groupID := server.createGroup(admin, "Family", alice, bob)
		alice.put("/Recipes/soup.txt", 0, []byte("soup"), http.StatusOK, nil)
		folderID := alice.stat("/Recipes").ID
		groupShare := alice.shareWith(map[string]any{"fileId": folderID, "note": "for the family"}, "group", groupID, canEdit, http.StatusCreated)
		direct := alice.shareWith(map[string]any{"fileId": folderID, "note": "just for you"}, "user", bob.me(), viewOnly, http.StatusCreated)

		incoming := bob.incoming()
		if len(incoming) != 1 {
			t.Fatalf("one item shared twice should be listed once: %+v", incoming)
		}
		combined := incoming[0]
		if combined.ID != direct.ID || !combined.Direct || len(combined.Groups) != 1 || combined.Groups[0].Name != "Family" {
			t.Fatalf("unexpected combined share %+v", combined)
		}
		if len(trueKeys(combined.Permissions)) != 3 || combined.Note != "just for you\n\nfor the family" {
			t.Fatalf("permissions and notes should be combined: %+v", combined)
		}
		bob.sharePut(direct.ID, "/via-direct.txt", 0, []byte("data"), http.StatusOK, nil)
		bob.sharePut(groupShare.ID, "/via-group.txt", 0, []byte("data"), http.StatusOK, nil)

		bob.unshare(direct.ID, http.StatusNoContent)
		incoming = bob.incoming()
		if len(incoming) != 1 || incoming[0].ID != groupShare.ID || incoming[0].Direct {
			t.Fatalf("the group share should remain after leaving the personal one: %+v", incoming)
		}
		bob.sharePut(direct.ID, "/after-leaving.txt", 0, []byte("data"), http.StatusNotFound, nil)
		bob.sharePut(groupShare.ID, "/after-leaving.txt", 0, []byte("data"), http.StatusOK, nil)
	})
}

func TestSharesFollowTheItemThroughRenamesAndTrash(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.put("/Docs/a.txt", 0, []byte("a"), http.StatusOK, nil)
		share := alice.share(alice.stat("/Docs").ID, "user", bob.me(), "read")

		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/Docs", "to": "/Archive/Docs"}, http.StatusOK, nil)
		if listed := bob.shareList(share.ID, "/", http.StatusOK); len(listed.Entries) != 1 {
			t.Fatalf("share lost after move: %+v", listed)
		}

		alice.expect(alice.request(http.MethodDelete, "/files?path=/Archive/Docs", nil, nil), http.StatusNoContent, nil)
		bob.shareList(share.ID, "/", http.StatusNotFound)
		if len(bob.incoming()) != 0 {
			t.Fatal("trashed share still listed for the recipient")
		}
		var outgoing []outgoingShare
		alice.mustJSON(http.MethodGet, "/shares/outgoing", nil, http.StatusOK, &outgoing)
		if len(outgoing) != 1 || outgoing[0].Available {
			t.Fatalf("owner should see the share as unavailable: %+v", outgoing)
		}

		alice.restore(alice.trash().Items[0].ID, "fail", http.StatusOK, nil)
		bob.shareList(share.ID, "/", http.StatusOK)

		alice.expect(alice.request(http.MethodDelete, "/files?path=/Archive/Docs", nil, nil), http.StatusNoContent, nil)
		alice.expect(alice.request(http.MethodDelete, "/trash", nil, nil), http.StatusNoContent, nil)
		alice.mustJSON(http.MethodGet, "/shares/outgoing", nil, http.StatusOK, &outgoing)
		if len(outgoing) != 0 {
			t.Fatalf("share of a purged item should be gone: %+v", outgoing)
		}
	})
}

func TestSharingRejectsInvalidRecipients(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.put("/a.txt", 0, []byte("a"), http.StatusOK, nil)
		fileID := alice.stat("/a.txt").ID
		body := func(recipient int64) map[string]any {
			return map[string]any{"fileId": fileID, "recipient": map[string]any{"kind": "user", "id": recipient}, "permissions": viewOnly}
		}
		alice.mustJSON(http.MethodPost, "/shares", body(alice.me()), http.StatusBadRequest, nil)
		alice.mustJSON(http.MethodPost, "/shares", body(bob.me()), http.StatusCreated, nil)
		alice.mustJSON(http.MethodPost, "/shares", body(bob.me()), http.StatusConflict, nil)
		bob.mustJSON(http.MethodPost, "/shares", body(alice.me()), http.StatusNotFound, nil)

		incoming := bob.incoming()
		if len(incoming) != 1 || incoming[0].Entry.IsDir {
			t.Fatalf("unexpected incoming %+v", incoming)
		}
		bob.shareList(incoming[0].ID, "/other", http.StatusNotFound)
		bob.expect(bob.request(http.MethodDelete, fmt.Sprintf("/shares/%d", incoming[0].ID), nil, nil), http.StatusNoContent, nil)
		if len(bob.incoming()) != 0 {
			t.Fatal("recipient could not leave a direct share")
		}
	})
}
