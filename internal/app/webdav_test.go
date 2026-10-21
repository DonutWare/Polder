package app_test

import (
	"encoding/xml"
	"fmt"
	"io"
	"net/http"
	"strings"
	"testing"

	"polder-server/internal/config"
)

type davClient struct {
	server   *testServer
	username string
	password string
	headers  map[string]string
}

type appPasswordResponse struct {
	ID       int64  `json:"id"`
	Name     string `json:"name"`
	ReadOnly bool   `json:"readOnly"`
	Token    string `json:"token"`
}

func (c *client) createAppPassword(name string, readOnly bool, accountPassword string) appPasswordResponse {
	c.server.t.Helper()
	var created appPasswordResponse
	c.mustJSON(http.MethodPost, "/account/app-passwords",
		map[string]any{"name": name, "readOnly": readOnly, "currentPassword": accountPassword}, http.StatusCreated, &created)
	return created
}

func (s *testServer) dav(username, password string) *davClient {
	return &davClient{server: s, username: username, password: password, headers: map[string]string{}}
}

func (d *davClient) do(method, path string, body string, headers map[string]string) (*http.Response, string) {
	d.server.t.Helper()
	request, err := http.NewRequest(method, d.server.server.URL+path, strings.NewReader(body))
	if err != nil {
		d.server.t.Fatal(err)
	}
	if d.username != "" {
		request.SetBasicAuth(d.username, d.password)
	}
	for name, value := range d.headers {
		request.Header.Set(name, value)
	}
	for name, value := range headers {
		request.Header.Set(name, value)
	}
	response, err := http.DefaultClient.Do(request)
	if err != nil {
		d.server.t.Fatal(err)
	}
	content, _ := io.ReadAll(response.Body)
	response.Body.Close()
	return response, string(content)
}

func (d *davClient) expect(method, path, body string, headers map[string]string, status int) (*http.Response, string) {
	d.server.t.Helper()
	response, content := d.do(method, path, body, headers)
	if response.StatusCode != status {
		d.server.t.Fatalf("%s %s: status %d, want %d: %s", method, path, response.StatusCode, status, content)
	}
	return response, content
}

type multistatus struct {
	Responses []struct {
		Href      string `xml:"href"`
		Propstats []struct {
			Status string `xml:"status"`
			Prop   struct {
				ETag         string `xml:"getetag"`
				Length       string `xml:"getcontentlength"`
				Permissions  string `xml:"http://owncloud.org/ns permissions"`
				OCMPerms     string `xml:"http://open-cloud-mesh.org/ns share-permissions"`
				ResourceType struct {
					Collection *struct{} `xml:"collection"`
				} `xml:"resourcetype"`
			} `xml:"prop"`
		} `xml:"propstat"`
	} `xml:"response"`
}

func parseMultistatus(t *testing.T, content string) multistatus {
	t.Helper()
	var parsed multistatus
	if err := xml.Unmarshal([]byte(content), &parsed); err != nil {
		t.Fatalf("parse multistatus: %v\n%s", err, content)
	}
	return parsed
}

const propfindBody = `<?xml version="1.0"?>
<d:propfind xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns" xmlns:ocm="http://open-cloud-mesh.org/ns">
  <d:prop><d:getetag/><d:getcontentlength/><d:resourcetype/><oc:permissions/><ocm:share-permissions/><oc:unknownthing/></d:prop>
</d:propfind>`

func TestWebDAVOwnFiles(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		password := alice.createAppPassword("laptop", false, "password1")
		if !strings.HasPrefix(password.Token, "polder_") {
			t.Fatalf("token %q", password.Token)
		}
		dav := server.dav("alice", password.Token)
		root := "/dav/files/alice"

		dav.expect(http.MethodOptions, root+"/", "", nil, http.StatusOK)
		dav.expect("MKCOL", root+"/docs", "", nil, http.StatusCreated)
		dav.expect("MKCOL", root+"/docs", "", nil, http.StatusMethodNotAllowed)
		dav.expect("MKCOL", root+"/missing/child", "", nil, http.StatusConflict)

		response, _ := dav.expect(http.MethodPut, root+"/docs/hello%20world.txt", "hello", nil, http.StatusCreated)
		etag := response.Header.Get("ETag")
		if etag == "" {
			t.Fatalf("headers %v", response.Header)
		}
		dav.expect(http.MethodPut, root+"/docs/hello%20world.txt", "stale", map[string]string{"If-Match": `"999999"`}, http.StatusPreconditionFailed)
		dav.expect(http.MethodPut, root+"/docs/hello%20world.txt", "again", map[string]string{"If-None-Match": "*"}, http.StatusPreconditionFailed)
		response, _ = dav.expect(http.MethodPut, root+"/docs/hello%20world.txt", "hello again", map[string]string{"If-Match": etag}, http.StatusNoContent)
		newETag := response.Header.Get("ETag")

		_, body := dav.expect(http.MethodGet, root+"/docs/hello%20world.txt", "", nil, http.StatusOK)
		if body != "hello again" {
			t.Fatalf("content %q", body)
		}
		dav.expect(http.MethodGet, root+"/docs/hello%20world.txt", "", map[string]string{"If-None-Match": newETag}, http.StatusNotModified)
		_, body = dav.expect(http.MethodGet, root+"/docs/hello%20world.txt", "", map[string]string{"Range": "bytes=0-4"}, http.StatusPartialContent)
		if body != "hello" {
			t.Fatalf("range %q", body)
		}

		_, content := dav.expect("PROPFIND", root+"/docs/", propfindBody, map[string]string{"Depth": "1"}, http.StatusMultiStatus)
		listing := parseMultistatus(t, content)
		if len(listing.Responses) != 2 {
			t.Fatalf("responses %+v", listing.Responses)
		}
		if listing.Responses[0].Href != root+"/docs/" || listing.Responses[0].Propstats[0].Prop.ResourceType.Collection == nil {
			t.Fatalf("collection %+v", listing.Responses[0])
		}
		file := listing.Responses[1]
		if file.Href != root+"/docs/hello%20world.txt" || file.Propstats[0].Prop.Length != "11" || file.Propstats[0].Prop.ETag != newETag {
			t.Fatalf("file %+v", file)
		}
		if !strings.Contains(file.Propstats[0].Prop.Permissions, "W") || file.Propstats[0].Prop.OCMPerms != `["read","write"]` {
			t.Fatalf("file props %+v", file.Propstats[0].Prop)
		}
		if len(file.Propstats) != 2 || !strings.Contains(file.Propstats[1].Status, "404") {
			t.Fatalf("unknown prop should be 404: %+v", file.Propstats)
		}
		folderETag := listing.Responses[0].Propstats[0].Prop.ETag

		dav.expect("PROPFIND", root+"/", "", map[string]string{"Depth": "infinity"}, http.StatusForbidden)

		dav.expect("MKCOL", root+"/docs/nested", "", nil, http.StatusCreated)
		dav.expect(http.MethodPut, root+"/docs/nested/deep.txt", "deep", nil, http.StatusCreated)
		_, content = dav.expect("PROPFIND", root+"/docs/", "", map[string]string{"Depth": "0"}, http.StatusMultiStatus)
		if parseMultistatus(t, content).Responses[0].Propstats[0].Prop.ETag == folderETag {
			t.Fatal("folder etag did not change after a change deep inside it")
		}

		dav.expect("COPY", root+"/docs/hello%20world.txt", "", map[string]string{"Destination": server.server.URL + root + "/docs/copy.txt"}, http.StatusCreated)
		dav.expect("MOVE", root+"/docs/copy.txt", "", map[string]string{"Destination": root + "/docs/hello%20world.txt", "Overwrite": "F"}, http.StatusPreconditionFailed)
		dav.expect("MOVE", root+"/docs/copy.txt", "", map[string]string{"Destination": root + "/docs/renamed.txt"}, http.StatusCreated)
		dav.expect("MOVE", root+"/docs/renamed.txt", "", map[string]string{"Destination": root + "/docs/hello%20world.txt"}, http.StatusNoContent)
		dav.expect("MOVE", root+"/docs/hello%20world.txt", "", map[string]string{"Destination": "https://elsewhere.example" + root + "/x.txt"}, http.StatusBadGateway)
		dav.expect("MOVE", root+"/docs/hello%20world.txt", "", map[string]string{"Destination": "/dav/files/bob/x.txt"}, http.StatusBadGateway)

		var stat fileEntry
		alice.mustJSON(http.MethodGet, "/files/stat?path=/docs/hello%20world.txt", nil, http.StatusOK, &stat)
		if stat.Size != 11 {
			t.Fatalf("stat %+v", stat)
		}

		dav.expect(http.MethodDelete, root+"/docs/nested", "", nil, http.StatusNoContent)
		dav.expect(http.MethodDelete, root+"/docs/nested", "", nil, http.StatusNotFound)
		dav.expect(http.MethodDelete, root+"/", "", nil, http.StatusForbidden)
	})
}

func TestWebDAVAuthentication(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		server.createUser(admin, "bob", 0)
		alice.mustJSON(http.MethodPost, "/account/app-passwords",
			map[string]any{"name": "x", "currentPassword": "wrong-password"}, http.StatusForbidden, nil)
		password := alice.createAppPassword("phone", false, "password1")
		readOnly := alice.createAppPassword("viewer", true, "password1")

		response, _ := server.dav("", "").expect("PROPFIND", "/dav/files/alice/", "", map[string]string{"Depth": "0"}, http.StatusUnauthorized)
		if !strings.HasPrefix(response.Header.Get("WWW-Authenticate"), "Basic") {
			t.Fatalf("challenge %v", response.Header)
		}
		server.dav("alice", "password1").expect("PROPFIND", "/dav/files/alice/", "", map[string]string{"Depth": "0"}, http.StatusUnauthorized)
		server.dav("bob", password.Token).expect("PROPFIND", "/dav/files/bob/", "", map[string]string{"Depth": "0"}, http.StatusUnauthorized)
		server.dav("alice", password.Token).expect("PROPFIND", "/dav/files/bob/", "", map[string]string{"Depth": "0"}, http.StatusNotFound)

		viewer := server.dav("alice", readOnly.Token)
		viewer.expect("PROPFIND", "/dav/files/alice/", "", map[string]string{"Depth": "1"}, http.StatusMultiStatus)
		viewer.expect(http.MethodPut, "/dav/files/alice/x.txt", "x", nil, http.StatusForbidden)
		viewer.expect("MKCOL", "/dav/files/alice/dir", "", nil, http.StatusForbidden)
		viewer.expect("LOCK", "/dav/files/alice/x.txt", lockBody, nil, http.StatusForbidden)

		var list []appPasswordResponse
		alice.mustJSON(http.MethodGet, "/account/app-passwords", nil, http.StatusOK, &list)
		if len(list) != 2 || list[0].Token != "" {
			t.Fatalf("list %+v", list)
		}
		alice.mustJSON(http.MethodDelete, fmt.Sprintf("/account/app-passwords/%d", readOnly.ID), nil, http.StatusNoContent, nil)
		viewer.expect("PROPFIND", "/dav/files/alice/", "", map[string]string{"Depth": "0"}, http.StatusUnauthorized)

		alice.mustJSON(http.MethodPut, "/account/password", map[string]string{"currentPassword": "password1", "newPassword": "password2"}, http.StatusNoContent, nil)
		server.dav("alice", password.Token).expect("PROPFIND", "/dav/files/alice/", "", map[string]string{"Depth": "0"}, http.StatusUnauthorized)
	})
}

func TestWebDAVRateLimit(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "", func(cfg *config.Config) { cfg.LoginRateLimit = 3 })
	admin := server.setupAdmin()
	alice := server.createUser(admin, "alice", 0)
	password := alice.createAppPassword("laptop", false, "password1")
	wrong := server.dav("alice", "polder_000000000000_AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
	for range 3 {
		wrong.expect("PROPFIND", "/dav/files/alice/", "", map[string]string{"Depth": "0"}, http.StatusUnauthorized)
	}
	server.dav("alice", password.Token).expect("PROPFIND", "/dav/files/alice/", "", map[string]string{"Depth": "0"}, http.StatusTooManyRequests)
}

func TestWebDAVNeedsHTTPS(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "", func(cfg *config.Config) { cfg.TrustedProxies = []string{"127.0.0.1", "::1"} })
	admin := server.setupAdmin()
	alice := server.createUser(admin, "alice", 0)
	password := alice.createAppPassword("laptop", false, "password1")
	dav := server.dav("alice", password.Token)
	proxied := map[string]string{"Depth": "0", "X-Forwarded-For": "203.0.113.7", "X-Forwarded-Proto": "http"}
	dav.expect("PROPFIND", "/dav/files/alice/", "", proxied, http.StatusForbidden)
	proxied["X-Forwarded-Proto"] = "https"
	dav.expect("PROPFIND", "/dav/files/alice/", "", proxied, http.StatusMultiStatus)
}

func TestWebDAVRefusesPlainHTTPBehindUntrustedProxy(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "")
	admin := server.setupAdmin()
	alice := server.createUser(admin, "alice", 0)
	dav := server.dav("alice", alice.createAppPassword("laptop", false, "password1").Token)
	dav.expect("PROPFIND", "/dav/files/alice/", "", map[string]string{"Depth": "0", "X-Forwarded-Proto": "http"}, http.StatusForbidden)
	dav.expect("PROPFIND", "/dav/files/alice/", "", map[string]string{"Depth": "0"}, http.StatusMultiStatus)
}

const lockBody = `<?xml version="1.0"?>
<d:lockinfo xmlns:d="DAV:"><d:lockscope><d:exclusive/></d:lockscope><d:locktype><d:write/></d:locktype><d:owner><d:href>finder</d:href></d:owner></d:lockinfo>`

func TestWebDAVLocks(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		first := server.dav("alice", alice.createAppPassword("finder", false, "password1").Token)
		root := "/dav/files/alice"

		response, content := first.expect("LOCK", root+"/new.txt", lockBody, map[string]string{"Timeout": "Second-600"}, http.StatusCreated)
		token := response.Header.Get("Lock-Token")
		if !strings.HasPrefix(token, "<urn:uuid:") || !strings.Contains(content, "finder") {
			t.Fatalf("lock %q %s", token, content)
		}
		first.expect(http.MethodPut, root+"/new.txt", "no token", nil, http.StatusLocked)
		first.expect(http.MethodPut, root+"/new.txt", "with token", map[string]string{"If": "(" + token + ")"}, http.StatusNoContent)
		first.expect("LOCK", root+"/new.txt", lockBody, nil, http.StatusLocked)
		first.expect("LOCK", root+"/new.txt", "", map[string]string{"If": "(" + token + ")", "Timeout": "Second-60"}, http.StatusOK)
		first.expect(http.MethodDelete, root+"/new.txt", "", nil, http.StatusLocked)
		first.expect("UNLOCK", root+"/new.txt", "", map[string]string{"Lock-Token": "<urn:uuid:00000000-0000-4000-8000-000000000000>"}, http.StatusConflict)
		first.expect("UNLOCK", root+"/new.txt", "", map[string]string{"Lock-Token": token}, http.StatusNoContent)
		first.expect(http.MethodDelete, root+"/new.txt", "", nil, http.StatusNoContent)
	})
}

func TestWebDAVRejectsHostileXML(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "")
	admin := server.setupAdmin()
	alice := server.createUser(admin, "alice", 0)
	dav := server.dav("alice", alice.createAppPassword("x", false, "password1").Token)
	entity := `<?xml version="1.0"?><!DOCTYPE d [<!ENTITY x SYSTEM "file:///etc/passwd">]><d:propfind xmlns:d="DAV:"><d:prop><d:getetag/></d:prop></d:propfind>`
	dav.expect("PROPFIND", "/dav/files/alice/", entity, map[string]string{"Depth": "0"}, http.StatusBadRequest)
	deep := strings.Repeat("<a>", 100) + strings.Repeat("</a>", 100)
	dav.expect("PROPFIND", "/dav/files/alice/", deep, map[string]string{"Depth": "0"}, http.StatusBadRequest)
	huge := `<d:propfind xmlns:d="DAV:"><d:prop>` + strings.Repeat("<d:getetag/>", 200000) + `</d:prop></d:propfind>`
	dav.expect("PROPFIND", "/dav/files/alice/", huge, map[string]string{"Depth": "0"}, http.StatusRequestEntityTooLarge)
}
