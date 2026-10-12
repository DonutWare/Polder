package app_test

import (
	"bytes"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"

	"polder-server/internal/config"
)

const fakeDiscovery = `<?xml version="1.0" encoding="utf-8"?>
<wopi-discovery><net-zone name="external-http">
  <app name="writer">
    <action default="true" ext="docx" name="edit" urlsrc="http://collabora:9980/browser/abc/cool.html?&lt;ui=UI_LLCC&amp;&gt;"/>
    <action ext="odt" name="edit" urlsrc="http://collabora:9980/browser/abc/cool.html?"/>
    <action ext="odt" name="editnew" urlsrc="http://collabora:9980/browser/abc/cool.html?"/>
    <action ext="DOCX" name="editnew" urlsrc="http://collabora:9980/browser/abc/cool.html?"/>
  </app>
  <app name="calc">
    <action ext="xlsx" name="editnew" urlsrc="http://collabora:9980/browser/abc/cool.html?"/>
  </app>
  <app name="draw">
    <action ext="vsdx" name="view" urlsrc="http://collabora:9980/browser/abc/cool.html?"/>
    <action ext="jpg" name="view" urlsrc="http://collabora:9980/browser/abc/cool.html?"/>
    <action ext="pdf" name="view" urlsrc="http://collabora:9980/browser/abc/cool.html?"/>
  </app>
  <app name="image/gif"><action ext="" name="view" urlsrc="http://collabora:9980/browser/abc/cool.html?"/></app>
  <app name="application/pdf"><action ext="" name="view" urlsrc="http://collabora:9980/browser/abc/cool.html?"/></app>
  <app name="application/vnd.visio"><action ext="" name="view" urlsrc="http://collabora:9980/browser/abc/cool.html?"/></app>
  <app name="Capabilities"><action ext="" name="getinfo" urlsrc="http://collabora:9980/hosting/capabilities"/></app>
</net-zone></wopi-discovery>`

func startOfficeServer(t *testing.T) *testServer {
	t.Helper()
	collabora := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/hosting/discovery":
			_, _ = io.WriteString(w, fakeDiscovery)
		default:
			_, _ = io.WriteString(w, "collabora "+r.Host+" "+r.URL.RequestURI())
		}
	}))
	t.Cleanup(collabora.Close)
	return startServer(t, config.DriverSQLite, "", func(cfg *config.Config) { cfg.CollaboraURL = collabora.URL })
}

type officeSession struct {
	EditorURL      string `json:"editorUrl"`
	HostPage       string `json:"hostPage"`
	AccessToken    string `json:"accessToken"`
	AccessTokenTTL int64  `json:"accessTokenTtl"`
	ReadOnly       bool   `json:"readOnly"`
}

func (c *client) startOfficeSession(path string, expectedStatus int) officeSession {
	c.server.t.Helper()
	var session officeSession
	c.mustJSON(http.MethodPost, "/office/sessions", map[string]string{"path": path, "origin": c.server.server.URL}, expectedStatus, &session)
	return session
}

// wopi calls the server the way Collabora does, at the file URL the editor URL names.
func (s *testServer) wopi(session officeSession, method, suffix string, body []byte, headers map[string]string) (*http.Response, string) {
	s.t.Helper()
	editor, err := url.Parse(session.EditorURL)
	if err != nil {
		s.t.Fatal(err)
	}
	source, err := url.Parse(editor.Query().Get("WOPISrc"))
	if err != nil {
		s.t.Fatal(err)
	}
	target := s.server.URL + source.Path + suffix + "?access_token=" + url.QueryEscape(session.AccessToken)
	request, err := http.NewRequest(method, target, bytes.NewReader(body))
	if err != nil {
		s.t.Fatal(err)
	}
	for name, value := range headers {
		request.Header.Set(name, value)
	}
	response, err := http.DefaultClient.Do(request)
	if err != nil {
		s.t.Fatal(err)
	}
	defer response.Body.Close()
	content, _ := io.ReadAll(response.Body)
	return response, string(content)
}

func TestOfficeCapabilitiesComeFromDiscovery(t *testing.T) {
	server := startOfficeServer(t)
	alice := server.createUser(server.setupAdmin(), "alice", 0)

	var capabilities struct {
		Enabled            bool     `json:"enabled"`
		EditableExtensions []string `json:"editableExtensions"`
		ViewableExtensions []string `json:"viewableExtensions"`
		ViewableMimes      []string `json:"viewableMimes"`
		Creatable          []struct {
			App        string   `json:"app"`
			Extensions []string `json:"extensions"`
		} `json:"creatable"`
	}
	alice.mustJSON(http.MethodGet, "/office/capabilities", nil, http.StatusOK, &capabilities)
	if !capabilities.Enabled || strings.Join(capabilities.EditableExtensions, ",") != "docx,odt" ||
		strings.Join(capabilities.ViewableExtensions, ",") != "vsdx" ||
		strings.Join(capabilities.ViewableMimes, ",") != "application/vnd.visio" {
		t.Fatalf("unexpected capabilities %+v", capabilities)
	}
	creatable := map[string]string{}
	for _, app := range capabilities.Creatable {
		creatable[app.App] = strings.Join(app.Extensions, ",")
	}
	if len(creatable) != 2 || creatable["writer"] != "odt,docx" || creatable["calc"] != "xlsx" {
		t.Fatalf("unexpected creatable apps %+v", capabilities.Creatable)
	}
}

func TestOfficeIsOffWithoutCollabora(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "")
	alice := server.createUser(server.setupAdmin(), "alice", 0)
	alice.put("/report.docx", 0, []byte("doc"), http.StatusOK, nil)

	var capabilities struct {
		Enabled bool `json:"enabled"`
	}
	alice.mustJSON(http.MethodGet, "/office/capabilities", nil, http.StatusOK, &capabilities)
	if capabilities.Enabled {
		t.Fatal("editor enabled without Collabora")
	}
	alice.startOfficeSession("/report.docx", http.StatusNotFound)
}

func TestOfficeEditsSaveBackToTheFile(t *testing.T) {
	server := startOfficeServer(t)
	alice := server.createUser(server.setupAdmin(), "alice", 0)
	var original fileEntry
	alice.put("/Docs/report.docx", 0, []byte("first draft"), http.StatusOK, &original)

	session := alice.startOfficeSession("/Docs/report.docx", http.StatusCreated)
	if !strings.HasPrefix(session.EditorURL, "/browser/abc/cool.html?WOPISrc=") || session.ReadOnly || session.HostPage == "" {
		t.Fatalf("unexpected session %+v", session)
	}

	response, info := server.wopi(session, http.MethodGet, "", nil, nil)
	if response.StatusCode != http.StatusOK || !strings.Contains(info, `"BaseFileName":"report.docx"`) ||
		!strings.Contains(info, `"UserCanWrite":true`) || !strings.Contains(info, `"PostMessageOrigin":"`+server.server.URL+`"`) {
		t.Fatalf("CheckFileInfo: %d %s", response.StatusCode, info)
	}
	lastModified := between(info, `"LastModifiedTime":"`, `"`)

	response, content := server.wopi(session, http.MethodGet, "/contents", nil, nil)
	if response.StatusCode != http.StatusOK || content != "first draft" {
		t.Fatalf("GetFile: %d %q", response.StatusCode, content)
	}

	response, _ = server.wopi(session, http.MethodPost, "", nil, map[string]string{"X-WOPI-Override": "LOCK", "X-WOPI-Lock": "editor-1"})
	if response.StatusCode != http.StatusOK {
		t.Fatalf("LOCK: %d", response.StatusCode)
	}
	response, _ = server.wopi(session, http.MethodPost, "", nil, map[string]string{"X-WOPI-Override": "LOCK", "X-WOPI-Lock": "editor-2"})
	if response.StatusCode != http.StatusConflict || response.Header.Get("X-WOPI-Lock") != "editor-1" {
		t.Fatalf("second LOCK: %d %q", response.StatusCode, response.Header.Get("X-WOPI-Lock"))
	}
	response, _ = server.wopi(session, http.MethodPost, "/contents", []byte("not mine"), map[string]string{"X-WOPI-Lock": "editor-2"})
	if response.StatusCode != http.StatusConflict {
		t.Fatalf("PutFile under someone else's lock: %d", response.StatusCode)
	}

	response, saved := server.wopi(session, http.MethodPost, "/contents", []byte("second draft"),
		map[string]string{"X-WOPI-Lock": "editor-1", "X-COOL-WOPI-Timestamp": lastModified})
	if response.StatusCode != http.StatusOK || !strings.Contains(saved, "LastModifiedTime") {
		t.Fatalf("PutFile: %d %s", response.StatusCode, saved)
	}
	_, onServer := alice.download("/Docs/report.docx", nil)
	if string(onServer) != "second draft" {
		t.Fatalf("saved content not stored: %q", onServer)
	}
	var current fileEntry
	alice.mustJSON(http.MethodGet, "/files/stat?path=/Docs/report.docx", nil, http.StatusOK, &current)
	if current.Rev <= original.Rev {
		t.Fatalf("revision not bumped: %d -> %d", original.Rev, current.Rev)
	}

	response, _ = server.wopi(session, http.MethodPost, "", nil, map[string]string{"X-WOPI-Override": "UNLOCK", "X-WOPI-Lock": "editor-1"})
	if response.StatusCode != http.StatusOK {
		t.Fatalf("UNLOCK: %d", response.StatusCode)
	}
}

func TestOfficeRefusesToSaveOverNewerContent(t *testing.T) {
	server := startOfficeServer(t)
	alice := server.createUser(server.setupAdmin(), "alice", 0)
	alice.put("/report.odt", 0, []byte("v1"), http.StatusOK, nil)
	session := alice.startOfficeSession("/report.odt", http.StatusCreated)
	_, info := server.wopi(session, http.MethodGet, "", nil, nil)
	lastModified := between(info, `"LastModifiedTime":"`, `"`)

	alice.put("/report.odt", -1, []byte("changed elsewhere"), http.StatusOK, nil)

	response, body := server.wopi(session, http.MethodPost, "/contents", []byte("v2"), map[string]string{"X-COOL-WOPI-Timestamp": lastModified})
	if response.StatusCode != http.StatusConflict || !strings.Contains(body, "1010") {
		t.Fatalf("expected a document-changed conflict, got %d %s", response.StatusCode, body)
	}
	_, onServer := alice.download("/report.odt", nil)
	if string(onServer) != "changed elsewhere" {
		t.Fatalf("newer content overwritten: %q", onServer)
	}
}

func TestOfficeAccessIsLimitedToTheGrantedFile(t *testing.T) {
	server := startOfficeServer(t)
	admin := server.setupAdmin()
	alice := server.createUser(admin, "alice", 0)
	bob := server.createUser(admin, "bob", 0)
	alice.put("/alice.docx", 0, []byte("alice"), http.StatusOK, nil)
	bob.put("/bob.docx", 0, []byte("bob"), http.StatusOK, nil)
	alice.put("/drawing.vsdx", 0, []byte("shapes"), http.StatusOK, nil)

	aliceSession := alice.startOfficeSession("/alice.docx", http.StatusCreated)
	bobSession := bob.startOfficeSession("/bob.docx", http.StatusCreated)

	stolen := aliceSession
	stolen.AccessToken = bobSession.AccessToken
	if response, _ := server.wopi(stolen, http.MethodGet, "/contents", nil, nil); response.StatusCode != http.StatusUnauthorized {
		t.Fatalf("token for another file accepted: %d", response.StatusCode)
	}
	if response, _ := server.wopi(aliceSession, http.MethodGet, "", nil, map[string]string{}); response.StatusCode != http.StatusOK {
		t.Fatalf("own token refused: %d", response.StatusCode)
	}

	apiWithWOPIToken := &client{server: server, token: aliceSession.AccessToken}
	apiWithWOPIToken.mustJSON(http.MethodGet, "/auth/me", nil, http.StatusUnauthorized, nil)

	viewOnly := alice.startOfficeSession("/drawing.vsdx", http.StatusCreated)
	if !viewOnly.ReadOnly {
		t.Fatal("view-only type opened for editing")
	}
	if response, _ := server.wopi(viewOnly, http.MethodPost, "/contents", []byte("changed"), nil); response.StatusCode != http.StatusUnauthorized {
		t.Fatalf("read-only session saved: %d", response.StatusCode)
	}

	alice.put("/notes.unknownext", 0, []byte("?"), http.StatusOK, nil)
	alice.startOfficeSession("/notes.unknownext", http.StatusBadRequest)
}

func TestOfficeProxiesCollabora(t *testing.T) {
	server := startOfficeServer(t)
	response, err := http.Get(server.server.URL + "/browser/abc/cool.html?WOPISrc=x")
	if err != nil {
		t.Fatal(err)
	}
	defer response.Body.Close()
	body, _ := io.ReadAll(response.Body)
	host := strings.TrimPrefix(server.server.URL, "http://")
	if response.StatusCode != http.StatusOK || string(body) != "collabora "+host+" /browser/abc/cool.html?WOPISrc=x" {
		t.Fatalf("proxy: %d %q", response.StatusCode, body)
	}

	page, err := http.Get(server.server.URL + "/office/editor")
	if err != nil {
		t.Fatal(err)
	}
	defer page.Body.Close()
	if page.StatusCode != http.StatusOK || !strings.HasPrefix(page.Header.Get("Content-Type"), "text/html") {
		t.Fatalf("editor page: %d %s", page.StatusCode, page.Header.Get("Content-Type"))
	}
}

func between(text, start, end string) string {
	_, after, _ := strings.Cut(text, start)
	value, _, _ := strings.Cut(after, end)
	return value
}
