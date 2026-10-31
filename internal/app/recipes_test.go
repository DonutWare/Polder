package app_test

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestRecipeImportNeedsAUserAndAPublicPage(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		internal := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			t.Error("the server fetched a private address")
		}))
		defer internal.Close()
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		request := map[string]string{"url": internal.URL, "folder": "/Notes"}

		server.anonymous().mustJSON(http.MethodPost, "/recipes/import", request, http.StatusUnauthorized, nil)
		alice.mustJSON(http.MethodPost, "/recipes/import", map[string]string{"url": "file:///etc/passwd", "folder": "/Notes"}, http.StatusBadRequest, nil)
		alice.mustJSON(http.MethodPost, "/recipes/import", request, http.StatusBadRequest, nil)
	})
}
