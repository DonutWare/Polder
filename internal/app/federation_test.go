package app_test

import (
	"bytes"
	"context"
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha512"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"sync"
	"testing"
	"time"

	"polder-server/internal/app"
	"polder-server/internal/config"
)

type federatedServer struct {
	*testServer
	remote string
	admin  *client
}

func startFederatedServer(t *testing.T) *federatedServer {
	t.Helper()
	handler := http.NotFoundHandler()
	var mu sync.RWMutex
	tlsServer := httptest.NewUnstartedServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		mu.RLock()
		current := handler
		mu.RUnlock()
		current.ServeHTTP(w, r)
	}))
	tlsServer.StartTLS()
	pool := x509.NewCertPool()
	pool.AddCert(tlsServer.Certificate())
	app.TrustFederationCertificates(pool)

	cfg := config.Default()
	cfg.ConfigDir = t.TempDir()
	cfg.DataDir = t.TempDir()
	cfg.WatchFiles = false
	cfg.RescanInterval = 0
	cfg.TesseractPath = ""
	cfg.PublicURL = tlsServer.URL
	application, err := app.New(cfg)
	if err != nil {
		t.Fatal(err)
	}
	mu.Lock()
	handler = application.Handler
	mu.Unlock()
	ctx, cancel := context.WithCancel(context.Background())
	application.StartBackgroundWork(ctx)
	stop := sync.OnceFunc(func() {
		tlsServer.Close()
		cancel()
		application.Close()
	})
	t.Cleanup(stop)
	server := &testServer{t: t, app: application, server: tlsServer, stop: stop}
	parsed, _ := url.Parse(tlsServer.URL)
	admin := server.setupAdmin()
	admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"federationEnabled": true}, http.StatusOK, nil)
	return &federatedServer{testServer: server, remote: parsed.Host, admin: admin}
}

func (f *federatedServer) trust(other *federatedServer) {
	f.t.Helper()
	f.admin.mustJSON(http.MethodPost, "/admin/federation/servers",
		map[string]any{"remote": other.remote, "allowPrivateNetwork": true}, http.StatusCreated, nil)
}

type outgoingFederated struct {
	ID    int64  `json:"id"`
	State string `json:"state"`
}

type incomingFederated struct {
	ID          int64  `json:"id"`
	Name        string `json:"name"`
	Owner       string `json:"owner"`
	State       string `json:"state"`
	IsDir       bool   `json:"isDir"`
	Permissions struct {
		Create bool `json:"create"`
		Edit   bool `json:"edit"`
	} `json:"permissions"`
}

type remoteListing struct {
	Item    struct{ IsDir bool } `json:"item"`
	Entries []struct {
		Path  string `json:"path"`
		Name  string `json:"name"`
		IsDir bool   `json:"isDir"`
		Size  int64  `json:"size"`
	} `json:"entries"`
}

func waitUntil(t *testing.T, what string, condition func() bool) {
	t.Helper()
	deadline := time.Now().Add(10 * time.Second)
	for time.Now().Before(deadline) {
		if condition() {
			return
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("timed out waiting until %s", what)
}

func TestFederationBetweenTwoServers(t *testing.T) {
	a := startFederatedServer(t)
	b := startFederatedServer(t)
	a.trust(b)
	b.trust(a)
	alice := a.createUser(a.admin, "alice", 0)
	bob := b.createUser(b.admin, "bob", 0)

	var status struct {
		Enabled bool   `json:"enabled"`
		CloudID string `json:"cloudId"`
	}
	alice.mustJSON(http.MethodGet, "/federation/status", nil, http.StatusOK, &status)
	if !status.Enabled || status.CloudID != "alice@"+a.remote {
		t.Fatalf("status %+v", status)
	}

	var folder fileEntry
	alice.mustJSON(http.MethodPost, "/files/mkdir", map[string]string{"path": "/Docs"}, http.StatusCreated, &folder)
	alice.put("/Docs/readme.txt", 0, []byte("hello bob"), http.StatusOK, nil)

	alice.mustJSON(http.MethodPost, "/federation/shares/outgoing",
		map[string]any{"fileId": folder.ID, "recipient": "bob@nowhere.example", "permissions": map[string]bool{}}, http.StatusForbidden, nil)
	alice.mustJSON(http.MethodPost, "/federation/shares/outgoing",
		map[string]any{"fileId": folder.ID, "recipient": "nobody@" + b.remote, "permissions": map[string]bool{}}, http.StatusServiceUnavailable, nil)

	var share outgoingFederated
	alice.mustJSON(http.MethodPost, "/federation/shares/outgoing", map[string]any{
		"fileId": folder.ID, "recipient": "bob@" + b.remote, "permissions": map[string]bool{"create": true, "edit": true, "delete": true},
	}, http.StatusCreated, &share)
	if share.State != "pending" {
		t.Fatalf("share %+v", share)
	}

	var incoming []incomingFederated
	bob.mustJSON(http.MethodGet, "/federation/shares/incoming", nil, http.StatusOK, &incoming)
	if len(incoming) != 1 || incoming[0].Name != "Docs" || incoming[0].Owner != "alice@"+a.remote || incoming[0].State != "pending" {
		t.Fatalf("incoming %+v", incoming)
	}
	shareID := incoming[0].ID
	bob.mustJSON(http.MethodGet, fmt.Sprintf("/federation/shares/incoming/%d/list", shareID), nil, http.StatusForbidden, nil)

	var accepted incomingFederated
	bob.mustJSON(http.MethodPost, fmt.Sprintf("/federation/shares/incoming/%d/accept", shareID), nil, http.StatusOK, &accepted)
	if !accepted.IsDir || !accepted.Permissions.Create || !accepted.Permissions.Edit {
		t.Fatalf("accepted %+v", accepted)
	}
	waitUntil(t, "alice sees the share accepted", func() bool {
		var outgoing []outgoingFederated
		alice.mustJSON(http.MethodGet, "/federation/shares/outgoing", nil, http.StatusOK, &outgoing)
		return len(outgoing) == 1 && outgoing[0].State == "accepted"
	})

	var listing remoteListing
	bob.mustJSON(http.MethodGet, fmt.Sprintf("/federation/shares/incoming/%d/list?path=/", shareID), nil, http.StatusOK, &listing)
	if !listing.Item.IsDir || len(listing.Entries) != 1 || listing.Entries[0].Path != "/readme.txt" || listing.Entries[0].Size != 9 {
		t.Fatalf("listing %+v", listing)
	}
	response := bob.request(http.MethodGet, fmt.Sprintf("/federation/shares/incoming/%d/content?path=/readme.txt", shareID), nil, nil)
	if content := readBody(t, response); string(content) != "hello bob" || response.Header.Get("X-Content-Type-Options") != "nosniff" ||
		!strings.HasPrefix(response.Header.Get("Content-Disposition"), "attachment") {
		t.Fatalf("download %d %q %v", response.StatusCode, content, response.Header)
	}

	bob.expect(bob.request(http.MethodPut, fmt.Sprintf("/federation/shares/incoming/%d/content?path=/reply.txt", shareID),
		strings.NewReader("hi alice"), nil), http.StatusNoContent, nil)
	bob.mustJSON(http.MethodPost, fmt.Sprintf("/federation/shares/incoming/%d/mkdir", shareID), map[string]string{"path": "/sub"}, http.StatusNoContent, nil)
	bob.mustJSON(http.MethodPost, fmt.Sprintf("/federation/shares/incoming/%d/move", shareID),
		map[string]string{"from": "/reply.txt", "to": "/sub/reply.txt"}, http.StatusNoContent, nil)
	if _, content := alice.download("/Docs/sub/reply.txt", nil); string(content) != "hi alice" {
		t.Fatalf("alice sees %q", content)
	}
	bob.expect(bob.request(http.MethodDelete, fmt.Sprintf("/federation/shares/incoming/%d/files?path=/", shareID), nil, nil), http.StatusBadRequest, nil)

	alice.mustJSON(http.MethodPatch, fmt.Sprintf("/federation/shares/outgoing/%d", share.ID),
		map[string]any{"permissions": map[string]bool{}}, http.StatusOK, nil)
	bob.expect(bob.request(http.MethodPut, fmt.Sprintf("/federation/shares/incoming/%d/content?path=/blocked.txt", shareID),
		strings.NewReader("no"), nil), http.StatusForbidden, nil)

	alice.mustJSON(http.MethodDelete, fmt.Sprintf("/federation/shares/outgoing/%d", share.ID), nil, http.StatusNoContent, nil)
	bob.mustJSON(http.MethodGet, fmt.Sprintf("/federation/shares/incoming/%d/list", shareID), nil, http.StatusForbidden, nil)
	waitUntil(t, "bob's copy of the share is gone", func() bool {
		var list []incomingFederated
		bob.mustJSON(http.MethodGet, "/federation/shares/incoming", nil, http.StatusOK, &list)
		return len(list) == 0
	})
}

func TestFederationDeclineReachesOwner(t *testing.T) {
	a := startFederatedServer(t)
	b := startFederatedServer(t)
	a.trust(b)
	b.trust(a)
	alice := a.createUser(a.admin, "alice", 0)
	bob := b.createUser(b.admin, "bob", 0)
	var file fileEntry
	alice.put("/note.txt", 0, []byte("x"), http.StatusOK, &file)
	alice.mustJSON(http.MethodPost, "/federation/shares/outgoing",
		map[string]any{"fileId": file.ID, "recipient": "bob@" + b.remote, "permissions": map[string]bool{"edit": true}}, http.StatusCreated, nil)
	var incoming []incomingFederated
	bob.mustJSON(http.MethodGet, "/federation/shares/incoming", nil, http.StatusOK, &incoming)
	bob.mustJSON(http.MethodDelete, fmt.Sprintf("/federation/shares/incoming/%d", incoming[0].ID), nil, http.StatusNoContent, nil)
	waitUntil(t, "alice's share is gone after bob declined", func() bool {
		var outgoing []outgoingFederated
		alice.mustJSON(http.MethodGet, "/federation/shares/outgoing", nil, http.StatusOK, &outgoing)
		return len(outgoing) == 0
	})
}

func TestFederationRejectsUntrustedAndForgedRequests(t *testing.T) {
	a := startFederatedServer(t)
	b := startFederatedServer(t)
	a.trust(b)
	a.createUser(a.admin, "alice", 0)
	post := func(body []byte, headers map[string]string) int {
		request, _ := http.NewRequest(http.MethodPost, a.server.URL+"/ocm/shares", bytes.NewReader(body))
		request.Header.Set("Content-Type", "application/json")
		for name, value := range headers {
			request.Header.Set(name, value)
		}
		response, err := a.server.Client().Do(request)
		if err != nil {
			t.Fatal(err)
		}
		response.Body.Close()
		return response.StatusCode
	}
	body, _ := json.Marshal(map[string]any{
		"shareWith": "alice@" + a.remote, "name": "evil", "providerId": "1", "owner": "mallory@" + b.remote,
		"shareType": "user", "resourceType": "file", "protocol": map[string]any{"name": "webdav", "options": map[string]string{"sharedSecret": "x"}},
	})
	if status := post(body, nil); status != http.StatusUnauthorized {
		t.Fatalf("unsigned: %d", status)
	}
	forged := forgeSignature(t, a.server.URL+"/ocm/shares", body, "https://"+b.remote+"/ocm#signature")
	if status := post(body, forged); status != http.StatusBadRequest {
		t.Fatalf("forged: %d", status)
	}
	untrusted := forgeSignature(t, a.server.URL+"/ocm/shares", body, "https://evil.example/ocm#signature")
	if status := post(body, untrusted); status != http.StatusBadRequest {
		t.Fatalf("untrusted: %d", status)
	}

	request, _ := http.NewRequest("PROPFIND", a.server.URL+"/dav/ocm/", nil)
	request.SetBasicAuth("not-a-real-token", "")
	request.Header.Set("Depth", "0")
	response, err := a.server.Client().Do(request)
	if err != nil {
		t.Fatal(err)
	}
	response.Body.Close()
	if response.StatusCode != http.StatusUnauthorized {
		t.Fatalf("bogus share token: %d", response.StatusCode)
	}

	a.admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"federationEnabled": false}, http.StatusOK, nil)
	discovery, err := a.server.Client().Get(a.server.URL + "/.well-known/ocm")
	if err != nil {
		t.Fatal(err)
	}
	discovery.Body.Close()
	if discovery.StatusCode != http.StatusNotFound {
		t.Fatalf("discovery while disabled: %d", discovery.StatusCode)
	}
}

func TestFederationNeedsPublicURL(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "")
	admin := server.setupAdmin()
	admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"federationEnabled": true}, http.StatusBadRequest, nil)
}

func forgeSignature(t *testing.T, target string, body []byte, keyID string) map[string]string {
	t.Helper()
	key, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	parsed, _ := url.Parse(target)
	digest := sha512.Sum512(body)
	headers := map[string]string{
		"Date":   time.Now().UTC().Format(http.TimeFormat),
		"Digest": "SHA-512=" + base64.StdEncoding.EncodeToString(digest[:]),
	}
	signing := strings.Join([]string{
		"(request-target): post " + parsed.RequestURI(),
		fmt.Sprintf("content-length: %d", len(body)),
		"date: " + headers["Date"],
		"digest: " + headers["Digest"],
		"host: " + parsed.Host,
	}, "\n")
	hashed := sha512.Sum512([]byte(signing))
	signature, err := rsa.SignPKCS1v15(rand.Reader, key, crypto.SHA512, hashed[:])
	if err != nil {
		t.Fatal(err)
	}
	headers["Signature"] = fmt.Sprintf(`keyId="%s",algorithm="rsa-sha512",headers="(request-target) content-length date digest host",signature="%s"`,
		keyID, base64.StdEncoding.EncodeToString(signature))
	return headers
}
