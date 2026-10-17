package app_test

import (
	"fmt"
	"net/http"
	"net/url"
	"testing"
	"time"
)

func (c *client) shareDelete(shareID int64, path string, expectedStatus int) {
	c.server.t.Helper()
	c.expect(c.request(http.MethodDelete, fmt.Sprintf("/shares/%d/files?path=%s", shareID, url.QueryEscape(path)), nil, nil), expectedStatus, nil)
}

func (c *client) shareMove(shareID int64, from, to string, expectedStatus int) {
	c.server.t.Helper()
	c.mustJSON(http.MethodPost, fmt.Sprintf("/shares/%d/move", shareID), map[string]any{"from": from, "to": to}, expectedStatus, nil)
}

func (c *client) unshare(shareID int64, expectedStatus int) {
	c.server.t.Helper()
	c.expect(c.request(http.MethodDelete, fmt.Sprintf("/shares/%d", shareID), nil, nil), expectedStatus, nil)
}

func TestGroupRolesDecideWhoSharesAndWhoEdits(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		carol := server.createUser(admin, "carol", 0)
		dave := server.createUser(admin, "dave", 0)
		groupID := server.createGroup(alice, "Team", bob)
		alice.addMember(groupID, carol, "viewer", http.StatusCreated)
		alice.addMember(groupID, dave, "member", http.StatusCreated)

		carol.put("/Mine/c.txt", 0, []byte("c"), http.StatusOK, nil)
		carol.shareWith(map[string]any{"fileId": carol.stat("/Mine").ID}, "group", groupID, viewOnly, http.StatusForbidden)

		bob.put("/Work/a.txt", 0, []byte("a"), http.StatusOK, nil)
		share := bob.shareWith(map[string]any{"fileId": bob.stat("/Work").ID}, "group", groupID, canEdit, http.StatusCreated)
		dave.sharePut(share.ID, "/from-dave.txt", 0, []byte("data"), http.StatusOK, nil)
		carol.sharePut(share.ID, "/from-carol.txt", 0, []byte("data"), http.StatusForbidden, nil)
		if incoming := carol.incoming(); len(incoming) != 1 || len(trueKeys(incoming[0].Permissions)) != 0 {
			t.Fatalf("a viewer only gets to view: %+v", incoming)
		}

		dave.unshare(share.ID, http.StatusForbidden)
		alice.unshare(share.ID, http.StatusNoContent)

		again := bob.shareWith(map[string]any{"fileId": bob.stat("/Work").ID}, "group", groupID, viewOnly, http.StatusCreated)
		var listed []outgoingShare
		dave.mustJSON(http.MethodGet, fmt.Sprintf("/groups/%d/shares", groupID), nil, http.StatusOK, &listed)
		if len(listed) != 1 || listed[0].File.Path != "" {
			t.Fatalf("group members see the share without the owner's path: %+v", listed)
		}
		bob.unshare(again.ID, http.StatusNoContent)
	})
}

func trueKeys(permissions map[string]bool) []string {
	var keys []string
	for key, granted := range permissions {
		if granted {
			keys = append(keys, key)
		}
	}
	return keys
}

func TestSharePermissionsAreChecked(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.put("/Box/old.txt", 0, []byte("old"), http.StatusOK, nil)
		folder := map[string]any{"fileId": alice.stat("/Box").ID}

		share := alice.shareWith(folder, "user", bob.me(), map[string]bool{"create": true}, http.StatusCreated)
		bob.sharePut(share.ID, "/new.txt", 0, []byte("data"), http.StatusOK, nil)
		bob.sharePut(share.ID, "/old.txt", -1, []byte("data"), http.StatusForbidden, nil)
		bob.shareDelete(share.ID, "/old.txt", http.StatusForbidden)
		bob.shareMove(share.ID, "/old.txt", "/renamed.txt", http.StatusForbidden)

		alice.mustJSON(http.MethodPatch, fmt.Sprintf("/shares/%d", share.ID), map[string]any{"permissions": map[string]bool{"edit": true}}, http.StatusOK, nil)
		bob.sharePut(share.ID, "/old.txt", -1, []byte("data"), http.StatusOK, nil)
		bob.sharePut(share.ID, "/another.txt", 0, []byte("data"), http.StatusForbidden, nil)
		bob.shareMove(share.ID, "/old.txt", "/renamed.txt", http.StatusOK)

		alice.mustJSON(http.MethodPatch, fmt.Sprintf("/shares/%d", share.ID), map[string]any{"permissions": map[string]bool{"delete": true}}, http.StatusOK, nil)
		bob.shareDelete(share.ID, "/renamed.txt", http.StatusNoContent)

		alice.put("/single.txt", 0, []byte("s"), http.StatusOK, nil)
		fileShare := alice.shareWith(map[string]any{"fileId": alice.stat("/single.txt").ID}, "user", bob.me(), canEdit, http.StatusCreated)
		if fileShare.Permissions["create"] || fileShare.Permissions["delete"] || !fileShare.Permissions["edit"] {
			t.Fatalf("files only take edit: %+v", fileShare.Permissions)
		}
	})
}

func TestSharesExpireAndCarryANote(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.put("/Soon/a.txt", 0, []byte("a"), http.StatusOK, nil)
		share := alice.shareWith(map[string]any{
			"fileId": alice.stat("/Soon").ID, "note": "for the trip", "expiresAt": time.Now().Add(time.Second),
		}, "user", bob.me(), viewOnly, http.StatusCreated)

		if incoming := bob.incoming(); len(incoming) != 1 || incoming[0].Note != "for the trip" {
			t.Fatalf("note missing: %+v", incoming)
		}
		time.Sleep(1100 * time.Millisecond)
		if len(bob.incoming()) != 0 {
			t.Fatal("an expired share is still listed")
		}
		bob.shareList(share.ID, "/", http.StatusNotFound)
	})
}
