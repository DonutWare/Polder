package webui_test

import (
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"testing/fstest"

	"polder-server/internal/webui"
)

func testHandler(t *testing.T) http.Handler {
	t.Helper()
	handler, err := webui.Handler(fstest.MapFS{
		"index.html":           {Data: []byte("<html>app</html>")},
		"main.dart.js":         {Data: []byte("main()")},
		"assets/fonts/app.otf": {Data: []byte("font")},
	})
	if err != nil {
		t.Fatal(err)
	}
	return handler
}

func get(t *testing.T, handler http.Handler, target string, headers ...string) *http.Response {
	t.Helper()
	request := httptest.NewRequest(http.MethodGet, target, nil)
	for i := 0; i+1 < len(headers); i += 2 {
		request.Header.Set(headers[i], headers[i+1])
	}
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, request)
	return recorder.Result()
}

func body(t *testing.T, response *http.Response) string {
	t.Helper()
	content, err := io.ReadAll(response.Body)
	if err != nil {
		t.Fatal(err)
	}
	return string(content)
}

func TestServesFiles(t *testing.T) {
	handler := testHandler(t)
	for target, want := range map[string]string{
		"/":                     "<html>app</html>",
		"/main.dart.js":         "main()",
		"/assets/fonts/app.otf": "font",
	} {
		response := get(t, handler, target)
		if response.StatusCode != http.StatusOK || body(t, response) != want {
			t.Errorf("GET %s: status %d", target, response.StatusCode)
		}
	}
}

func TestClientRoutesFallBackToIndex(t *testing.T) {
	handler := testHandler(t)
	for _, target := range []string{"/files", "/admin/users", "/files?path=%2Fphotos"} {
		response := get(t, handler, target)
		if response.StatusCode != http.StatusOK || body(t, response) != "<html>app</html>" {
			t.Errorf("GET %s: status %d, want index.html", target, response.StatusCode)
		}
	}
}

func TestMissingAssetsAreNotFound(t *testing.T) {
	response := get(t, testHandler(t), "/missing.js")
	if response.StatusCode != http.StatusNotFound {
		t.Fatalf("status %d, want 404", response.StatusCode)
	}
}

func TestPathTraversalStaysInside(t *testing.T) {
	response := get(t, testHandler(t), "/../../etc/passwd")
	if response.StatusCode != http.StatusOK || body(t, response) != "<html>app</html>" {
		t.Fatalf("status %d, want index.html", response.StatusCode)
	}
}

func TestRevalidatesWithETag(t *testing.T) {
	handler := testHandler(t)
	first := get(t, handler, "/main.dart.js")
	etag := first.Header.Get("ETag")
	if etag == "" || first.Header.Get("Cache-Control") != "no-cache" {
		t.Fatalf("missing caching headers: %v", first.Header)
	}
	second := get(t, handler, "/main.dart.js", "If-None-Match", etag)
	if second.StatusCode != http.StatusNotModified {
		t.Fatalf("status %d, want 304", second.StatusCode)
	}
}

func TestFilesOnDiskRevalidateByTime(t *testing.T) {
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, "index.html"), []byte("v1"), 0o600); err != nil {
		t.Fatal(err)
	}
	handler, err := webui.Handler(os.DirFS(dir))
	if err != nil {
		t.Fatal(err)
	}
	response := get(t, handler, "/")
	if response.Header.Get("ETag") != "" || response.Header.Get("Last-Modified") == "" {
		t.Fatalf("want Last-Modified instead of a startup ETag: %v", response.Header)
	}
}

func TestOnlyReads(t *testing.T) {
	recorder := httptest.NewRecorder()
	testHandler(t).ServeHTTP(recorder, httptest.NewRequest(http.MethodPost, "/", nil))
	if recorder.Code != http.StatusMethodNotAllowed {
		t.Fatalf("status %d, want 405", recorder.Code)
	}
}

func TestRequiresIndex(t *testing.T) {
	if _, err := webui.Handler(fstest.MapFS{"main.dart.js": {Data: []byte("x")}}); err == nil {
		t.Fatal("expected an error without index.html")
	}
}
