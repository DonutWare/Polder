package app_test

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"sync"
	"testing"
)

type fakeOCMServer struct {
	server        *httptest.Server
	remote        string
	mu            sync.Mutex
	notifications []map[string]any
	authHeaders   []string
}

func startFakeOCMServer(t *testing.T) *fakeOCMServer {
	t.Helper()
	fake := &fakeOCMServer{}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /.well-known/ocm", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(map[string]any{
			"enabled": true, "apiVersion": "1.2.0", "endPoint": fake.server.URL + "/ocm", "provider": "FakeCloud",
			"resourceTypes": []map[string]any{
				{"name": "file", "shareTypes": []string{"user"}, "protocols": map[string]string{"webdav": "/dav/ocm/"}},
				{"name": "folder", "shareTypes": []string{"user"}, "protocols": map[string]string{"webdav": "/dav/ocm/"}},
			},
			"capabilities": []string{"invites", "protocol-object"},
		})
	})
	mux.HandleFunc("POST /ocm/notifications", func(w http.ResponseWriter, r *http.Request) {
		var body map[string]any
		_ = json.NewDecoder(r.Body).Decode(&body)
		fake.mu.Lock()
		fake.notifications = append(fake.notifications, body)
		fake.mu.Unlock()
		w.WriteHeader(http.StatusOK)
	})
	mux.HandleFunc("/dav/ocm/share-1/", func(w http.ResponseWriter, r *http.Request) {
		fake.mu.Lock()
		fake.authHeaders = append(fake.authHeaders, r.Header.Get("Authorization"))
		fake.mu.Unlock()
		if user, password, ok := r.BasicAuth(); !ok || user != "secret-one" || password != "" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		switch {
		case r.Method == "PROPFIND" && r.URL.Path == "/dav/ocm/share-1/":
			w.WriteHeader(http.StatusMultiStatus)
			io.WriteString(w, `<?xml version="1.0"?><d:multistatus xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns">`+
				`<d:response><d:href>/dav/ocm/share-1/</d:href><d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype><oc:permissions>GCK</oc:permissions><d:getetag>"1"</d:getetag></d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat></d:response>`)
			if r.Header.Get("Depth") == "1" {
				io.WriteString(w, `<d:response><d:href>/dav/ocm/share-1/hello.txt</d:href><d:propstat><d:prop><d:resourcetype/><d:getcontentlength>5</d:getcontentlength><d:getetag>"2"</d:getetag></d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat></d:response>`)
			}
			io.WriteString(w, `</d:multistatus>`)
		case r.Method == http.MethodGet && r.URL.Path == "/dav/ocm/share-1/hello.txt":
			io.WriteString(w, "hello")
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	})
	fake.server = httptest.NewTLSServer(mux)
	t.Cleanup(fake.server.Close)
	parsed, _ := url.Parse(fake.server.URL)
	fake.remote = parsed.Host
	return fake
}

func (f *fakeOCMServer) post(t *testing.T, target, path string, body any) int {
	t.Helper()
	encoded, _ := json.Marshal(body)
	request, _ := http.NewRequest(http.MethodPost, target+path, bytes.NewReader(encoded))
	request.Header.Set("Content-Type", "application/json")
	response, err := f.server.Client().Do(request)
	if err != nil {
		t.Fatal(err)
	}
	response.Body.Close()
	return response.StatusCode
}

func TestFederationWithUnsignedProvider(t *testing.T) {
	a := startFederatedServer(t)
	fake := startFakeOCMServer(t)
	a.admin.mustJSON(http.MethodPost, "/admin/federation/servers", map[string]any{"remote": fake.remote, "allowPrivateNetwork": true}, http.StatusCreated, nil)
	alice := a.createUser(a.admin, "alice", 0)

	share := map[string]any{
		"shareWith": "alice@" + a.remote + "@" + a.remote, "name": "Project", "providerId": "p1", "owner": "carol@idp.example@" + fake.remote,
		"sender": "carol@idp.example@" + fake.remote, "senderDisplayName": "Carol", "shareType": "user", "resourceType": "folder",
		"protocol": map[string]any{"name": "multi", "webdav": map[string]any{
			"sharedSecret": "secret-one", "permissions": []string{"read", "write"}, "uri": fake.server.URL + "/dav/ocm/share-1/",
		}},
	}
	if status := fake.post(t, a.server.URL, "/ocm/shares", share); status != http.StatusCreated {
		t.Fatalf("unsigned share from a keyless trusted server: %d", status)
	}
	evil := map[string]any{}
	for key, value := range share {
		evil[key] = value
	}
	evil["providerId"] = "p2"
	evil["protocol"] = map[string]any{"name": "multi", "webdav": map[string]any{"sharedSecret": "x", "uri": "https://evil.example/steal"}}
	if status := fake.post(t, a.server.URL, "/ocm/shares", evil); status != http.StatusBadRequest {
		t.Fatalf("a share pointing at another host must be refused: %d", status)
	}

	var incoming []incomingFederated
	alice.mustJSON(http.MethodGet, "/federation/shares/incoming", nil, http.StatusOK, &incoming)
	if len(incoming) != 1 || !incoming[0].IsDir || incoming[0].Owner != "carol@idp.example@"+fake.remote {
		t.Fatalf("incoming %+v", incoming)
	}
	id := incoming[0].ID
	alice.mustJSON(http.MethodPost, fmt.Sprintf("/federation/shares/incoming/%d/accept", id), nil, http.StatusOK, nil)
	var listing remoteListing
	alice.mustJSON(http.MethodGet, fmt.Sprintf("/federation/shares/incoming/%d/list", id), nil, http.StatusOK, &listing)
	if len(listing.Entries) != 1 || listing.Entries[0].Path != "/hello.txt" {
		t.Fatalf("listing %+v", listing)
	}
	response := alice.request(http.MethodGet, fmt.Sprintf("/federation/shares/incoming/%d/content?path=/hello.txt", id), nil, nil)
	if body := readBody(t, response); string(body) != "hello" {
		t.Fatalf("download %q", body)
	}
	fake.mu.Lock()
	firstAuth := fake.authHeaders[0]
	fake.mu.Unlock()
	if firstAuth != "Bearer secret-one" {
		t.Fatalf("the spec's Bearer auth must be tried first, got %q", firstAuth)
	}

	waitUntil(t, "the provider was told the share was accepted", func() bool {
		fake.mu.Lock()
		defer fake.mu.Unlock()
		return len(fake.notifications) == 1 && fake.notifications[0]["notificationType"] == "SHARE_ACCEPTED"
	})

	unshare := map[string]any{"notificationType": "SHARE_UNSHARED", "resourceType": "folder", "providerId": "p1",
		"notification": map[string]any{"grantee": "alice"}}
	if status := fake.post(t, a.server.URL, "/ocm/notifications", unshare); status != http.StatusCreated {
		t.Fatalf("secret-less unshare: %d", status)
	}
	alice.mustJSON(http.MethodGet, "/federation/shares/incoming", nil, http.StatusOK, &incoming)
	if len(incoming) != 0 {
		t.Fatalf("share should be gone: %+v", incoming)
	}
}

func TestFederationSharesFoldersWithModernProviders(t *testing.T) {
	a := startFederatedServer(t)
	fake := startFakeOCMServer(t)
	var received map[string]any
	var mu sync.Mutex
	fake.server.Config.Handler = func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if r.Method == http.MethodPost && r.URL.Path == "/ocm/shares" {
				mu.Lock()
				_ = json.NewDecoder(r.Body).Decode(&received)
				mu.Unlock()
				w.WriteHeader(http.StatusOK)
				io.WriteString(w, `{}`)
				return
			}
			next.ServeHTTP(w, r)
		})
	}(fake.server.Config.Handler)
	a.admin.mustJSON(http.MethodPost, "/admin/federation/servers", map[string]any{"remote": fake.remote, "allowPrivateNetwork": true}, http.StatusCreated, nil)
	alice := a.createUser(a.admin, "alice", 0)
	var folder fileEntry
	alice.mustJSON(http.MethodPost, "/files/mkdir", map[string]string{"path": "/Team"}, http.StatusCreated, &folder)
	alice.mustJSON(http.MethodPost, "/federation/shares/outgoing",
		map[string]any{"fileId": folder.ID, "recipient": "dave@" + fake.remote, "permissions": map[string]bool{"edit": true}}, http.StatusCreated, nil)
	mu.Lock()
	defer mu.Unlock()
	protocol := received["protocol"].(map[string]any)
	if received["resourceType"] != "folder" || protocol["name"] != "multi" || protocol["options"] != nil {
		t.Fatalf("payload %v", received)
	}
	webdav := protocol["webdav"].(map[string]any)
	if !strings.HasPrefix(webdav["uri"].(string), "https://") || webdav["sharedSecret"] == "" {
		t.Fatalf("webdav %v", webdav)
	}

	secret := webdav["sharedSecret"].(string)
	propfind := func(authorize func(*http.Request)) int {
		request, _ := http.NewRequest("PROPFIND", webdav["uri"].(string), nil)
		request.Header.Set("Depth", "0")
		authorize(request)
		response, err := a.server.Client().Do(request)
		if err != nil {
			t.Fatal(err)
		}
		response.Body.Close()
		return response.StatusCode
	}
	if status := propfind(func(r *http.Request) { r.Header.Set("Authorization", "Bearer "+secret) }); status != http.StatusMultiStatus {
		t.Fatalf("bearer: %d", status)
	}
	if status := propfind(func(r *http.Request) { r.SetBasicAuth(secret, "") }); status != http.StatusMultiStatus {
		t.Fatalf("basic: %d", status)
	}
}

type invite struct {
	Token    string `json:"token"`
	Provider string `json:"provider"`
}

type contact struct {
	CloudID string `json:"cloudId"`
	Name    string `json:"name"`
}

func TestFederationInvites(t *testing.T) {
	a := startFederatedServer(t)
	b := startFederatedServer(t)
	a.trust(b)
	b.trust(a)
	alice := a.createUser(a.admin, "alice", 0)
	bob := b.createUser(b.admin, "bob", 0)

	var created invite
	alice.mustJSON(http.MethodPost, "/federation/invites", nil, http.StatusCreated, &created)
	if created.Token == "" || created.Provider != a.remote {
		t.Fatalf("invite %+v", created)
	}
	bob.mustJSON(http.MethodPost, "/federation/invites/accept", map[string]string{"token": "wrong-token", "provider": a.remote}, http.StatusBadRequest, nil)
	var accepted contact
	bob.mustJSON(http.MethodPost, "/federation/invites/accept", map[string]string{"token": created.Token, "provider": a.remote}, http.StatusCreated, &accepted)
	if accepted.CloudID != "alice@"+a.remote {
		t.Fatalf("bob's contact %+v", accepted)
	}
	var contacts []contact
	alice.mustJSON(http.MethodGet, "/federation/contacts", nil, http.StatusOK, &contacts)
	if len(contacts) != 1 || contacts[0].CloudID != "bob@"+b.remote {
		t.Fatalf("alice's contacts %+v", contacts)
	}
	bob.mustJSON(http.MethodPost, "/federation/invites/accept", map[string]string{"token": created.Token, "provider": a.remote}, http.StatusBadRequest, nil)
}
