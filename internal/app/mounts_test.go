package app_test

import (
	"fmt"
	"net/http"
	"net/url"
	"testing"
)

func (c *client) list(path string) listing {
	c.server.t.Helper()
	var listed listing
	c.mustJSON(http.MethodGet, "/files/list?path="+url.QueryEscape(path), nil, http.StatusOK, &listed)
	return listed
}

func entryNamed(listed listing, name string) (fileEntry, bool) {
	for _, entry := range listed.Entries {
		if entry.Name == name {
			return entry, true
		}
	}
	return fileEntry{}, false
}

func TestSharesAppearInRecipientFiles(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.put("/Project/plan.txt", 0, []byte("draft"), http.StatusOK, nil)
		alice.put("/notes.md", 0, []byte("# Notes"), http.StatusOK, nil)
		bob.put("/Project/mine.txt", 0, []byte("bob's"), http.StatusOK, nil)
		alice.share(alice.stat("/Project").ID, "user", bob.me(), "write")
		alice.share(alice.stat("/notes.md").ID, "user", bob.me(), "read")
		if project, _ := entryNamed(alice.list("/"), "Project"); !project.Shared || alice.stat("/notes.md").Shared != true {
			t.Fatalf("what alice shares is marked for her: %+v", project)
		}
		if ownProject, _ := entryNamed(bob.list("/"), "Project"); ownProject.Shared {
			t.Fatal("bob's own unshared folder is not marked")
		}

		root := bob.list("/")
		own, _ := entryNamed(root, "Project")
		mounted, found := entryNamed(root, "Project (2)")
		if own.Mount != nil || !found || mounted.Mount == nil || mounted.Mount.Owner != "alice" || mounted.Mount.Kind != "share" ||
			!mounted.IsDir || mounted.Path != "/Project (2)" || !mounted.Mount.Permissions["edit"] || mounted.Size != 5 {
			t.Fatalf("root %+v", root.Entries)
		}
		if notes, found := entryNamed(root, "notes.md"); !found || notes.IsDir || notes.Mount == nil || notes.Mount.Permissions["edit"] {
			t.Fatalf("a shared file sits in the root as a file: %+v", root.Entries)
		}
		for _, share := range bob.incoming() {
			if share.MountPath == "" {
				t.Fatalf("incoming shares carry where they sit: %+v", share)
			}
		}

		inside := bob.list("/Project (2)")
		if inside.Mount == nil || inside.Mount.Path != "/Project (2)" || !mounted.Mount.CanLeave {
			t.Fatalf("a listing inside a share says which share: %+v", inside)
		}
		if plan, found := entryNamed(inside, "plan.txt"); inside.Path != "/Project (2)" || !found || plan.Path != "/Project (2)/plan.txt" || plan.Mount == nil {
			t.Fatalf("inside %+v", inside)
		}
		if _, body := bob.download("/Project (2)/plan.txt", nil); string(body) != "draft" {
			t.Fatalf("download %q", body)
		}
		if _, body := bob.download("/notes.md", nil); string(body) != "# Notes" {
			t.Fatalf("download of a shared file %q", body)
		}

		bob.put("/Project (2)/new.txt", 0, []byte("from bob"), http.StatusOK, nil)
		if _, body := alice.download("/Project/new.txt", nil); string(body) != "from bob" {
			t.Fatalf("an upload lands in the owner's folder: %q", body)
		}
		bob.mustJSON(http.MethodPost, "/files/mkdir", map[string]string{"path": "/Project (2)/Sub"}, http.StatusCreated, nil)
		bob.mustJSON(http.MethodPost, "/files/move", map[string]string{"from": "/Project (2)/new.txt", "to": "/Project (2)/Sub/new.txt"}, http.StatusOK, nil)
		alice.stat("/Project/Sub/new.txt")
		bob.mustJSON(http.MethodDelete, "/files?path="+url.QueryEscape("/Project (2)/Sub/new.txt"), nil, http.StatusNoContent, nil)
		alice.mustJSON(http.MethodGet, "/files/stat?path="+url.QueryEscape("/Project/Sub/new.txt"), nil, http.StatusNotFound, nil)

		bob.mustJSON(http.MethodPost, "/files/move", map[string]string{"from": "/Project (2)/plan.txt", "to": "/plan.txt"}, http.StatusBadRequest, nil)
		bob.mustJSON(http.MethodPost, "/files/copy", map[string]string{"from": "/Project/mine.txt", "to": "/Project (2)/mine.txt"}, http.StatusBadRequest, nil)
		bob.mustJSON(http.MethodDelete, "/files?path="+url.QueryEscape("/Project (2)"), nil, http.StatusBadRequest, nil)
		bob.put("/notes.md", -1, []byte("changed"), http.StatusForbidden, nil)
		alice.stat("/Project/plan.txt")
	})
}

func TestHiddenSharesStillOpenByPath(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.put("/Shared/a.txt", 0, []byte("a"), http.StatusOK, nil)
		alice.share(alice.stat("/Shared").ID, "user", bob.me(), "read")

		var settings struct {
			ShowInFiles bool `json:"showInFiles"`
		}
		bob.mustJSON(http.MethodGet, "/shares/settings", nil, http.StatusOK, &settings)
		if !settings.ShowInFiles {
			t.Fatal("shares show in files by default")
		}
		bob.mustJSON(http.MethodPut, "/shares/settings", map[string]bool{"showInFiles": false}, http.StatusOK, &settings)
		if _, found := entryNamed(bob.list("/"), "Shared"); found {
			t.Fatal("hidden shares stay out of the files root")
		}
		mountPath := bob.incoming()[0].MountPath
		if listed := bob.list(mountPath); len(listed.Entries) != 1 || listed.Entries[0].Name != "a.txt" {
			t.Fatalf("a hidden share still opens at %s: %+v", mountPath, listed)
		}
		bob.mustJSON(http.MethodPut, "/shares/settings", map[string]bool{"showInFiles": true}, http.StatusOK, nil)
		if _, found := entryNamed(bob.list("/"), "Shared"); !found {
			t.Fatal("shares come back when shown again")
		}
	})
}

func TestFederatedSharesAppearInFiles(t *testing.T) {
	a := startFederatedServer(t)
	fake := startFakeOCMServer(t)
	a.admin.mustJSON(http.MethodPost, "/admin/federation/servers", map[string]any{"remote": fake.remote, "allowPrivateNetwork": true}, http.StatusCreated, nil)
	alice := a.createUser(a.admin, "alice", 0)
	share := map[string]any{
		"shareWith": "alice@" + a.remote, "name": "Project", "providerId": "p1", "owner": "carol@" + fake.remote,
		"sender": "carol@" + fake.remote, "shareType": "user", "resourceType": "folder",
		"protocol": map[string]any{"name": "multi", "webdav": map[string]any{
			"sharedSecret": "secret-one", "permissions": []string{"read"}, "uri": fake.server.URL + "/dav/ocm/share-1/",
		}},
	}
	if status := fake.post(t, a.server.URL, "/ocm/shares", share); status != http.StatusCreated {
		t.Fatalf("share: %d", status)
	}
	if _, found := entryNamed(alice.list("/"), "Project"); found {
		t.Fatal("a pending share stays out of files")
	}
	var incoming []incomingFederated
	alice.mustJSON(http.MethodGet, "/federation/shares/incoming", nil, http.StatusOK, &incoming)
	alice.mustJSON(http.MethodPost, fmt.Sprintf("/federation/shares/incoming/%d/accept", incoming[0].ID), nil, http.StatusOK, nil)

	project, found := entryNamed(alice.list("/"), "Project")
	if !found || project.Mount == nil || project.Mount.Kind != "federated" || project.Mount.Owner != "carol@"+fake.remote || !project.IsDir {
		t.Fatalf("the accepted share sits in files: %+v", project)
	}
	inside := alice.list("/Project")
	if hello, found := entryNamed(inside, "hello.txt"); !found || hello.Path != "/Project/hello.txt" || hello.Mount == nil {
		t.Fatalf("inside %+v", inside)
	}
	if _, body := alice.download("/Project/hello.txt", nil); string(body) != "hello" {
		t.Fatalf("download %q", body)
	}

	hello, _ := entryNamed(inside, "hello.txt")
	if hello.Rev <= 0 || hello.Rev >= 1<<53 || hello.Hash != "2" {
		t.Fatalf("a remote file has a revision to save against: %+v", hello)
	}
	alice.put("/Project/hello.txt", hello.Rev+2, []byte("stale"), http.StatusConflict, nil)
	alice.put("/Project/hello.txt", hello.Rev, []byte("edited"), http.StatusOK, nil)
	if written := fake.content("hello.txt"); written != "edited" {
		t.Fatalf("the save reached the remote server: %q", written)
	}
}
