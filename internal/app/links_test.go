package app_test

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"testing"
	"time"

	"polder-server/internal/config"
)

type shareLink struct {
	ID          int64  `json:"id"`
	Code        string `json:"code"`
	Permissions struct {
		View     bool `json:"view"`
		Download bool `json:"download"`
		Upload   bool `json:"upload"`
	} `json:"permissions"`
	HasPassword bool `json:"hasPassword"`
}

type linkInfo struct {
	NeedsPassword bool   `json:"needsPassword"`
	Name          string `json:"name"`
	IsDir         bool   `json:"isDir"`
}

type linkUnlock struct {
	Token string    `json:"token"`
	Info  linkInfo  `json:"info"`
	Root  fileEntry `json:"root"`
}

func (c *client) createLink(fileID int64, options map[string]any) shareLink {
	c.server.t.Helper()
	body := map[string]any{"fileId": fileID}
	for key, value := range options {
		body[key] = value
	}
	var link shareLink
	c.mustJSON(http.MethodPost, "/links", body, http.StatusCreated, &link)
	return link
}

func (c *client) unlock(code, password string, expectedStatus int) linkUnlock {
	c.server.t.Helper()
	var unlocked linkUnlock
	c.mustJSON(http.MethodPost, "/public/links/"+code+"/unlock", map[string]string{"password": password}, expectedStatus, &unlocked)
	return unlocked
}

func (c *client) withShareToken(token string) map[string]string {
	return map[string]string{"X-Polder-Share-Token": token}
}

func TestPasswordProtectedLinks(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		visitor := server.anonymous()
		alice.put("/Trip/photo.txt", 0, []byte("view"), http.StatusOK, nil)
		alice.put("/Other/x.txt", 0, []byte("x"), http.StatusOK, nil)
		link := alice.createLink(alice.stat("/Trip").ID, map[string]any{"password": "hunter22"})
		if !regexp.MustCompile(`^[0-9A-Za-z]{10}$`).MatchString(link.Code) || !link.HasPassword {
			t.Fatalf("unexpected link %+v", link)
		}

		var info linkInfo
		visitor.mustJSON(http.MethodGet, "/public/links/"+link.Code, nil, http.StatusOK, &info)
		if !info.NeedsPassword || info.Name != "" {
			t.Fatalf("locked link reveals its target: %+v", info)
		}
		visitor.unlock(link.Code, "wrong", http.StatusUnauthorized)
		unlocked := visitor.unlock(link.Code, "hunter22", http.StatusOK)
		if unlocked.Info.Name != "Trip" || unlocked.Root.Path != "/" {
			t.Fatalf("unexpected unlock %+v", unlocked)
		}

		visitor.expect(visitor.request(http.MethodGet, "/public/links/"+link.Code+"/list", nil, nil), http.StatusUnauthorized, nil)
		var listed listing
		visitor.expect(visitor.request(http.MethodGet, "/public/links/"+link.Code+"/list?path=/", nil, visitor.withShareToken(unlocked.Token)), http.StatusOK, &listed)
		if len(listed.Entries) != 1 || listed.Entries[0].Path != "/photo.txt" {
			t.Fatalf("unexpected listing %+v", listed)
		}
		response := visitor.request(http.MethodGet, fmt.Sprintf("/public/links/%s/content?path=/photo.txt&download=true&token=%s", link.Code, url.QueryEscape(unlocked.Token)), nil, nil)
		if body := readBody(t, response); string(body) != "view" || response.Header.Get("Content-Disposition") == "" {
			t.Fatalf("download with query token: %d %q", response.StatusCode, body)
		}

		other := alice.createLink(alice.stat("/Other").ID, nil)
		visitor.expect(visitor.request(http.MethodGet, "/public/links/"+other.Code+"/list", nil, visitor.withShareToken(unlocked.Token)), http.StatusUnauthorized, nil)
		visitor.expect(visitor.request(http.MethodGet, "/public/links/"+link.Code+"/list", nil, visitor.withShareToken(unlocked.Token+"x")), http.StatusUnauthorized, nil)

		alice.mustJSON(http.MethodPatch, fmt.Sprintf("/links/%d", link.ID), map[string]any{"password": "newpass99"}, http.StatusOK, nil)
		visitor.expect(visitor.request(http.MethodGet, "/public/links/"+link.Code+"/list", nil, visitor.withShareToken(unlocked.Token)), http.StatusUnauthorized, nil)

		alice.expect(alice.request(http.MethodDelete, fmt.Sprintf("/links/%d", link.ID), nil, nil), http.StatusNoContent, nil)
		visitor.mustJSON(http.MethodGet, "/public/links/"+link.Code, nil, http.StatusNotFound, nil)
		visitor.mustJSON(http.MethodGet, "/public/links/doesnotexist", nil, http.StatusNotFound, nil)
	})
}

func TestLinkPasswordsAreRateLimitedSeparatelyFromLogin(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "", func(cfg *config.Config) { cfg.LoginRateLimit = 3 })
	alice := server.createUser(server.setupAdmin(), "alice", 0)
	alice.put("/a.txt", 0, []byte("a"), http.StatusOK, nil)
	link := alice.createLink(alice.stat("/a.txt").ID, map[string]any{"password": "hunter22"})
	visitor := server.anonymous()
	for range 3 {
		visitor.unlock(link.Code, "wrong", http.StatusUnauthorized)
	}
	visitor.unlock(link.Code, "hunter22", http.StatusTooManyRequests)
	server.login("alice", "password1")
}

func TestLinkExpiryAndAccessModes(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		visitor := server.anonymous()
		alice.put("/Drop/existing.txt", 0, []byte("old"), http.StatusOK, nil)
		alice.put("/single.txt", 0, []byte("one"), http.StatusOK, nil)
		dropID := alice.stat("/Drop").ID

		uploadOnly := map[string]any{"view": false, "download": false, "upload": true}
		alice.mustJSON(http.MethodPost, "/links", map[string]any{"fileId": alice.stat("/single.txt").ID, "permissions": uploadOnly}, http.StatusBadRequest, nil)
		for _, invalid := range []map[string]any{
			{"view": false, "download": false, "upload": false},
			{"view": false, "download": true, "upload": true},
		} {
			alice.mustJSON(http.MethodPost, "/links", map[string]any{"fileId": dropID, "permissions": invalid}, http.StatusBadRequest, nil)
		}
		alice.mustJSON(http.MethodPost, "/links", map[string]any{"fileId": dropID, "expiresAt": time.Now().Add(-time.Hour)}, http.StatusBadRequest, nil)

		view := alice.createLink(dropID, nil)
		viewToken := visitor.unlock(view.Code, "", http.StatusOK).Token
		upload := func(code, token, name string, status int, target any) {
			visitor.expect(visitor.request(http.MethodPut, fmt.Sprintf("/public/links/%s/content?path=%s", code, url.QueryEscape(name)),
				bytes.NewReader([]byte("new")), visitor.withShareToken(token)), status, target)
		}
		upload(view.Code, viewToken, "/existing.txt", http.StatusForbidden, nil)

		drop := alice.createLink(dropID, map[string]any{"permissions": uploadOnly})
		dropToken := visitor.unlock(drop.Code, "", http.StatusOK).Token
		var stored fileEntry
		upload(drop.Code, dropToken, "/existing.txt", http.StatusOK, &stored)
		if stored.Name != "existing (2).txt" {
			t.Fatalf("file drop should never overwrite: %+v", stored)
		}
		_, content := alice.download("/Drop/existing.txt", nil)
		if string(content) != "old" {
			t.Fatal("file drop overwrote a file")
		}
		visitor.expect(visitor.request(http.MethodGet, "/public/links/"+drop.Code+"/list", nil, visitor.withShareToken(dropToken)), http.StatusForbidden, nil)

		expiring := alice.createLink(dropID, map[string]any{"expiresAt": time.Now().Add(time.Second)})
		visitor.mustJSON(http.MethodGet, "/public/links/"+expiring.Code, nil, http.StatusOK, nil)
		time.Sleep(1100 * time.Millisecond)
		visitor.mustJSON(http.MethodGet, "/public/links/"+expiring.Code, nil, http.StatusNotFound, nil)
	})
}

func TestMatchingLinksForSignedInUsers(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		carol := server.createUser(admin, "carol", 0)
		alice.put("/Shared/Deep/file.txt", 0, []byte("f"), http.StatusOK, nil)
		share := alice.share(alice.stat("/Shared").ID, "user", bob.me(), "read")
		link := alice.createLink(alice.stat("/Shared/Deep").ID, nil)

		var match struct {
			OwnPath *string `json:"ownPath"`
			ShareID *int64  `json:"shareId"`
			Path    *string `json:"path"`
		}
		alice.mustJSON(http.MethodGet, "/links/match/"+link.Code, nil, http.StatusOK, &match)
		if match.OwnPath == nil || *match.OwnPath != "/Shared/Deep" {
			t.Fatalf("owner match %+v", match)
		}
		match.OwnPath = nil
		bob.mustJSON(http.MethodGet, "/links/match/"+link.Code, nil, http.StatusOK, &match)
		if match.ShareID == nil || *match.ShareID != share.ID || *match.Path != "/Deep" {
			t.Fatalf("recipient match %+v", match)
		}
		carol.mustJSON(http.MethodGet, "/links/match/"+link.Code, nil, http.StatusNotFound, nil)
	})
}

func TestViewOnlyLinksRefuseDownloads(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		visitor := server.anonymous()
		alice.put("/Gallery/a.txt", 0, []byte("a"), http.StatusOK, nil)
		link := alice.createLink(alice.stat("/Gallery").ID, map[string]any{"permissions": map[string]any{"view": true, "download": false, "upload": false}})
		if !link.Permissions.View || link.Permissions.Download || link.Permissions.Upload {
			t.Fatalf("unexpected permissions %+v", link.Permissions)
		}
		token := visitor.unlock(link.Code, "", http.StatusOK).Token
		headers := visitor.withShareToken(token)
		visitor.expect(visitor.request(http.MethodGet, "/public/links/"+link.Code+"/list", nil, headers), http.StatusOK, nil)
		visitor.expect(visitor.request(http.MethodGet, "/public/links/"+link.Code+"/content?path=/a.txt", nil, headers), http.StatusForbidden, nil)
		visitor.expect(visitor.request(http.MethodGet, "/public/links/"+link.Code+"/archive", nil, headers), http.StatusForbidden, nil)

		alice.mustJSON(http.MethodPatch, fmt.Sprintf("/links/%d", link.ID), map[string]any{"permissions": map[string]any{"download": true}}, http.StatusOK, nil)
		visitor.expect(visitor.request(http.MethodGet, "/public/links/"+link.Code+"/list", nil, headers), http.StatusUnauthorized, nil)
		token = visitor.unlock(link.Code, "", http.StatusOK).Token
		visitor.expect(visitor.request(http.MethodGet, "/public/links/"+link.Code+"/content?path=/a.txt", nil, visitor.withShareToken(token)), http.StatusOK, nil)
	})
}

func TestLinkErrorsHideTheOwnersPaths(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		visitor := server.anonymous()
		alice.put("/Clients/Acme/a.txt", 0, []byte("a"), http.StatusOK, nil)
		link := alice.createLink(alice.stat("/Clients/Acme").ID, nil)
		headers := visitor.withShareToken(visitor.unlock(link.Code, "", http.StatusOK).Token)
		for _, path := range []string{"/missing.txt", "/a.txt/inside"} {
			response := visitor.request(http.MethodGet, "/public/links/"+link.Code+"/content?path="+url.QueryEscape(path), nil, headers)
			body, _ := io.ReadAll(response.Body)
			response.Body.Close()
			if response.StatusCode < 400 || strings.Contains(string(body), "Clients") {
				t.Fatalf("%s: %d %s", path, response.StatusCode, body)
			}
		}
	})
}
