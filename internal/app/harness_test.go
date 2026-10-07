package app_test

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"testing"

	_ "github.com/jackc/pgx/v5/stdlib"

	"polder-server/internal/app"
	"polder-server/internal/config"
)

const postgresEnvironmentVariable = "POLDER_TEST_POSTGRES_DSN"

type testServer struct {
	t      *testing.T
	app    *app.App
	server *httptest.Server
}

type client struct {
	server *testServer
	token  string
}

func forEachDatabase(t *testing.T, test func(t *testing.T, server *testServer)) {
	t.Run("sqlite", func(t *testing.T) {
		test(t, startServer(t, config.DriverSQLite, ""))
	})
	dsn := os.Getenv(postgresEnvironmentVariable)
	if dsn == "" {
		return
	}
	t.Run("postgres", func(t *testing.T) {
		resetPostgres(t, dsn)
		test(t, startServer(t, config.DriverPostgres, dsn))
	})
}

func startServer(t *testing.T, driver, dsn string, configure ...func(*config.Config)) *testServer {
	t.Helper()
	cfg := config.Default()
	cfg.ConfigDir = t.TempDir()
	cfg.DataDir = t.TempDir()
	cfg.DatabaseDriver = driver
	cfg.DatabaseDSN = dsn
	cfg.WatchFiles = false
	cfg.RescanInterval = 0
	// Without tesseract OCR stays off, so tests never download models.
	cfg.TesseractPath = ""
	for _, change := range configure {
		change(&cfg)
	}

	application, err := app.New(cfg)
	if err != nil {
		t.Fatal(err)
	}
	ctx, cancel := context.WithCancel(context.Background())
	application.StartBackgroundWork(ctx)
	server := httptest.NewServer(application.Handler)
	t.Cleanup(func() {
		server.Close()
		cancel()
		application.Close()
	})
	return &testServer{t: t, app: application, server: server}
}

func resetPostgres(t *testing.T, dsn string) {
	t.Helper()
	db, err := sql.Open("pgx", dsn)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	if _, err := db.Exec(`DROP SCHEMA public CASCADE; CREATE SCHEMA public`); err != nil {
		t.Fatal(err)
	}
}

func (s *testServer) anonymous() *client {
	return &client{server: s}
}

func (s *testServer) setupAdmin() *client {
	var tokens tokenPair
	s.anonymous().mustJSON(http.MethodPost, "/setup", map[string]string{"username": "admin", "password": "adminpass1"}, http.StatusCreated, &tokens)
	return &client{server: s, token: tokens.AccessToken}
}

func (s *testServer) createUser(admin *client, username string, quotaBytes int64) *client {
	admin.mustJSON(http.MethodPost, "/admin/users",
		map[string]any{"username": username, "password": "password1", "role": "user", "quotaBytes": quotaBytes}, http.StatusCreated, nil)
	return s.login(username, "password1")
}

func (s *testServer) login(username, password string) *client {
	var tokens tokenPair
	s.anonymous().mustJSON(http.MethodPost, "/auth/login", map[string]string{"username": username, "password": password}, http.StatusOK, &tokens)
	return &client{server: s, token: tokens.AccessToken}
}

type tokenPair struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
	User         struct {
		ID       int64  `json:"id"`
		Username string `json:"username"`
		Role     string `json:"role"`
	} `json:"user"`
}

type fileEntry struct {
	Path         string         `json:"path"`
	Name         string         `json:"name"`
	IsDir        bool           `json:"isDir"`
	Size         int64          `json:"size"`
	Rev          int64          `json:"rev"`
	Hash         string         `json:"hash"`
	Mime         string         `json:"mime"`
	Meta         map[string]any `json:"meta"`
	PreviewState string         `json:"previewState"`
}

type errorResponse struct {
	Error struct {
		Code string `json:"code"`
	} `json:"error"`
	Current *fileEntry `json:"current"`
}

func (c *client) request(method, path string, body io.Reader, headers map[string]string) *http.Response {
	c.server.t.Helper()
	target := c.server.server.URL + path
	if path != "/healthz" {
		target = c.server.server.URL + "/api/v1" + path
	}
	request, err := http.NewRequest(method, target, body)
	if err != nil {
		c.server.t.Fatal(err)
	}
	if c.token != "" {
		request.Header.Set("Authorization", "Bearer "+c.token)
	}
	for name, value := range headers {
		request.Header.Set(name, value)
	}
	response, err := http.DefaultClient.Do(request)
	if err != nil {
		c.server.t.Fatal(err)
	}
	return response
}

func (c *client) mustJSON(method, path string, body any, expectedStatus int, target any) {
	c.server.t.Helper()
	var reader io.Reader
	if body != nil {
		encoded, _ := json.Marshal(body)
		reader = bytes.NewReader(encoded)
	}
	c.expect(c.request(method, path, reader, nil), expectedStatus, target)
}

func (c *client) expect(response *http.Response, expectedStatus int, target any) {
	c.server.t.Helper()
	defer response.Body.Close()
	content, _ := io.ReadAll(response.Body)
	if response.StatusCode != expectedStatus {
		c.server.t.Fatalf("%s %s: status %d, want %d: %s", response.Request.Method, response.Request.URL.Path,
			response.StatusCode, expectedStatus, content)
	}
	if target != nil {
		if err := json.Unmarshal(content, target); err != nil {
			c.server.t.Fatalf("decode %s: %v", content, err)
		}
	}
}

func (c *client) put(path string, baseRev int64, content []byte, expectedStatus int, target any) {
	c.server.t.Helper()
	query := fmt.Sprintf("/files/content?path=%s&baseRev=%d", url.QueryEscape(path), baseRev)
	c.expect(c.request(http.MethodPut, query, bytes.NewReader(content), nil), expectedStatus, target)
}

func (c *client) download(path string, headers map[string]string) (*http.Response, []byte) {
	c.server.t.Helper()
	response := c.request(http.MethodGet, "/files/content?path="+url.QueryEscape(path), nil, headers)
	defer response.Body.Close()
	content, _ := io.ReadAll(response.Body)
	return response, content
}
