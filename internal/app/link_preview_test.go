package app_test

import (
	"net/http"
	"net/http/httptest"
	"net/url"
	"testing"
)

func TestLinkPreviewsNeedAUserAndAWebLink(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		server.anonymous().mustJSON(http.MethodGet, "/link-previews?url="+url.QueryEscape("https://example.com"), nil, http.StatusUnauthorized, nil)
		alice.mustJSON(http.MethodGet, "/link-previews?url="+url.QueryEscape("file:///etc/passwd"), nil, http.StatusBadRequest, nil)
	})
}

func TestLinkPreviewsNeverReachThePrivateNetwork(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		internal := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			t.Error("the server fetched a private address")
			w.Header().Set("Content-Type", "text/html")
			_, _ = w.Write([]byte(`<title>Router admin</title><meta property="og:image" content="/secret.png">`))
		}))
		defer internal.Close()
		alice := server.createUser(server.setupAdmin(), "alice", 0)

		var preview struct {
			Title    string `json:"title"`
			SiteName string `json:"siteName"`
			HasImage bool   `json:"hasImage"`
		}
		alice.mustJSON(http.MethodGet, "/link-previews?url="+url.QueryEscape(internal.URL), nil, http.StatusOK, &preview)
		if preview.Title != "" || preview.HasImage || preview.SiteName != "127.0.0.1" {
			t.Fatalf("unexpected preview %+v", preview)
		}
		alice.mustJSON(http.MethodGet, "/link-previews/image?kind=image&url="+url.QueryEscape(internal.URL), nil, http.StatusNotFound, nil)
	})
}
