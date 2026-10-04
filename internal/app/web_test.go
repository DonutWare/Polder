package app_test

import (
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"nomad-server/internal/config"
)

func startServerWithWebClient(t *testing.T) *testServer {
	t.Helper()
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, "index.html"), []byte("<html>nomad</html>"), 0o600); err != nil {
		t.Fatal(err)
	}
	return startServer(t, config.DriverSQLite, "", func(cfg *config.Config) { cfg.WebDir = dir })
}

func fetch(t *testing.T, server *testServer, path string) (int, string, string) {
	t.Helper()
	response, err := http.Get(server.server.URL + path)
	if err != nil {
		t.Fatal(err)
	}
	defer response.Body.Close()
	content, err := io.ReadAll(response.Body)
	if err != nil {
		t.Fatal(err)
	}
	return response.StatusCode, response.Header.Get("Content-Type"), string(content)
}

func TestWebClientIsServedOutsideTheAPI(t *testing.T) {
	server := startServerWithWebClient(t)

	for _, path := range []string{"/", "/files", "/admin/users"} {
		status, _, body := fetch(t, server, path)
		if status != http.StatusOK || body != "<html>nomad</html>" {
			t.Errorf("GET %s: %d %q, want the web client", path, status, body)
		}
	}
}

func TestAPIStillAnswersNextToTheWebClient(t *testing.T) {
	server := startServerWithWebClient(t)

	status, _, body := fetch(t, server, "/api/v1/setup")
	if status != http.StatusOK || !strings.Contains(body, "needsSetup") {
		t.Fatalf("setup status: %d %q", status, body)
	}
	for _, path := range []string{"/api/v1/nonexistent", "/api/v2/files"} {
		status, contentType, _ := fetch(t, server, path)
		if status != http.StatusNotFound || !strings.HasPrefix(contentType, "application/json") {
			t.Errorf("GET %s: %d %s, want a JSON 404", path, status, contentType)
		}
	}
	if status, _, _ := fetch(t, server, "/healthz"); status != http.StatusOK {
		t.Errorf("healthz: %d", status)
	}
}

func TestWebClientCanBeTurnedOff(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "", func(cfg *config.Config) { cfg.ServeWeb = false })

	if status, _, _ := fetch(t, server, "/files"); status != http.StatusNotFound {
		t.Fatalf("status %d, want 404 without the web client", status)
	}
}
