package httpapi

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"reflect"
	"strings"
	"testing"

	"github.com/go-chi/chi/v5"
)

// Every API route must be registered through Huma, or it would be missing from the published spec.
func TestOpenAPIDocumentsEveryRoute(t *testing.T) {
	router := NewRouter(Dependencies{})
	server := httptest.NewServer(router)
	defer server.Close()

	response, err := http.Get(server.URL + apiPrefix + "/openapi.json")
	if err != nil {
		t.Fatal(err)
	}
	defer response.Body.Close()
	var spec struct {
		Paths map[string]map[string]any `json:"paths"`
	}
	if err := json.NewDecoder(response.Body).Decode(&spec); err != nil {
		t.Fatal(err)
	}

	served := map[string]bool{apiPrefix + "/docs": true}
	for _, extension := range []string{".json", ".yaml", "-3.0.json", "-3.0.yaml"} {
		served[apiPrefix+"/openapi"+extension] = true
	}
	walk := func(method, route string, _ http.Handler, _ ...func(http.Handler) http.Handler) error {
		if served[route] || route == "/api/*" || !isAPIRoute(route) {
			return nil
		}
		if _, documented := spec.Paths[route][strings.ToLower(method)]; !documented {
			t.Errorf("%s %s is not in the OpenAPI document; register it with huma", method, route)
		}
		return nil
	}
	if err := chi.Walk(router.(chi.Routes), walk); err != nil {
		t.Fatal(err)
	}
}

func isAPIRoute(route string) bool {
	return route == "/healthz" || strings.HasPrefix(route, apiPrefix+"/")
}

func TestOpenAPIMatchesServedDocument(t *testing.T) {
	recorder := httptest.NewRecorder()
	NewRouter(Dependencies{}).ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, apiPrefix+"/openapi-3.0.json", nil))
	generated, err := OpenAPI()
	if err != nil {
		t.Fatal(err)
	}
	var served, printed any
	if err := json.Unmarshal(recorder.Body.Bytes(), &served); err != nil {
		t.Fatal(err)
	}
	if err := json.Unmarshal(generated, &printed); err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(served, printed) {
		t.Fatal("OpenAPI() differs from the document served at /openapi-3.0.json")
	}
}

func TestDocsPageIsServed(t *testing.T) {
	recorder := httptest.NewRecorder()
	NewRouter(Dependencies{}).ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, apiPrefix+"/docs", nil))
	if recorder.Code != http.StatusOK || !strings.Contains(recorder.Header().Get("Content-Type"), "text/html") {
		t.Fatalf("docs: status %d, content type %q", recorder.Code, recorder.Header().Get("Content-Type"))
	}
}
