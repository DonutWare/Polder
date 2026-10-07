package app_test

import (
	"io"
	"log/slog"
	"maps"
	"net/http"
	"slices"
	"strings"
	"testing"

	"polder-server/internal/config"
	"polder-server/internal/logging"
)

type logPage struct {
	Entries []struct {
		ID        string            `json:"id"`
		Level     string            `json:"level"`
		Component string            `json:"component"`
		Message   string            `json:"message"`
		Attrs     map[string]string `json:"attrs"`
	} `json:"entries"`
	NextCursor string `json:"nextCursor"`
}

func (p logPage) find(message string) (map[string]string, bool) {
	for _, entry := range p.Entries {
		if entry.Message == message {
			return entry.Attrs, true
		}
	}
	return nil, false
}

func startLoggingServer(t *testing.T, configure ...func(*config.Config)) *testServer {
	t.Helper()
	var logDir string
	configure = append(configure, func(cfg *config.Config) { logDir = cfg.LogDir() })
	server := startServer(t, config.DriverSQLite, "", configure...)
	previous := slog.Default()
	logFiles, err := logging.Setup(logDir, slog.LevelDebug, io.Discard)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		slog.SetDefault(previous)
		logFiles.Close()
	})
	return server
}

func TestAdminReadsServerLogs(t *testing.T) {
	server := startLoggingServer(t)

	admin := server.setupAdmin()
	alice := server.createUser(admin, "alice", 0)
	alice.mustJSON(http.MethodGet, "/admin/logs", nil, http.StatusForbidden, nil)
	server.anonymous().mustJSON(http.MethodPost, "/auth/login", map[string]string{"username": "bob", "password": "wrong-password"},
		http.StatusUnauthorized, nil)

	var users logPage
	admin.mustJSON(http.MethodGet, "/admin/logs?component=users", nil, http.StatusOK, &users)
	if attrs, ok := users.find("user created"); !ok || attrs["user"] != "alice" || attrs["by"] != "admin" {
		t.Fatalf("user creation not logged: %+v", users)
	}

	var failures logPage
	admin.mustJSON(http.MethodGet, "/admin/logs?component=auth&level=warn", nil, http.StatusOK, &failures)
	if len(failures.Entries) != 1 || failures.Entries[0].Message != "login failed" || failures.Entries[0].Attrs["user"] != "bob" {
		t.Fatalf("failed login not logged: %+v", failures)
	}
	for _, entry := range failures.Entries {
		for _, value := range entry.Attrs {
			if strings.Contains(value, "wrong-password") {
				t.Fatalf("password logged: %+v", entry)
			}
		}
	}

	var requests logPage
	admin.mustJSON(http.MethodGet, "/admin/logs?component=http&q=/admin/users", nil, http.StatusOK, &requests)
	if attrs, ok := requests.find("request"); !ok || attrs["method"] != "POST" || attrs["status"] != "201" || attrs["user"] != "admin" {
		t.Fatalf("request not logged: %+v", requests)
	}

	var all []string
	before := ""
	for range 1000 {
		var page logPage
		admin.mustJSON(http.MethodGet, "/admin/logs?limit=2&before="+before, nil, http.StatusOK, &page)
		for _, entry := range page.Entries {
			all = append(all, entry.ID)
		}
		if page.NextCursor == "" {
			break
		}
		before = page.NextCursor
	}
	var whole logPage
	admin.mustJSON(http.MethodGet, "/admin/logs?limit=500", nil, http.StatusOK, &whole)
	unique := slices.Clone(all)
	slices.Sort(unique)
	if len(slices.Compact(unique)) != len(all) || all[len(all)-1] != whole.Entries[len(whole.Entries)-1].ID {
		t.Fatalf("paging gave %v, one page %d entries", all, len(whole.Entries))
	}
	admin.mustJSON(http.MethodGet, "/admin/logs?before=nonsense", nil, http.StatusBadRequest, nil)

	var components struct {
		Components []string `json:"components"`
	}
	admin.mustJSON(http.MethodGet, "/admin/logs/components", nil, http.StatusOK, &components)
	for _, want := range []string{"auth", "http", "users"} {
		if !slices.Contains(components.Components, want) {
			t.Fatalf("components = %v, missing %s", components.Components, want)
		}
	}

	var files struct {
		Files []struct {
			Name string `json:"name"`
		} `json:"files"`
	}
	admin.mustJSON(http.MethodGet, "/admin/logs/files", nil, http.StatusOK, &files)
	if len(files.Files) != 1 {
		t.Fatalf("files = %+v", files)
	}
	response := admin.request(http.MethodGet, "/admin/logs/files/"+files.Files[0].Name, nil, nil)
	content, _ := io.ReadAll(response.Body)
	response.Body.Close()
	if response.StatusCode != http.StatusOK || !strings.Contains(string(content), `"msg":"user created"`) {
		t.Fatalf("download: %d %.200s", response.StatusCode, content)
	}
	for _, name := range []string{"polder.db", "..%2Fjwt.key", "polder-2026-01-01.log"} {
		admin.mustJSON(http.MethodGet, "/admin/logs/files/"+name, nil, http.StatusNotFound, nil)
	}
}

func TestTrustedProxyNamesTheClient(t *testing.T) {
	server := startLoggingServer(t, func(cfg *config.Config) { cfg.TrustedProxies = []string{"127.0.0.1"} })
	admin := server.setupAdmin()

	failLogin := func(client string, expectedStatus int) {
		t.Helper()
		body := strings.NewReader(`{"username":"bob","password":"wrong-password"}`)
		response := server.anonymous().request(http.MethodPost, "/auth/login", body,
			map[string]string{"Content-Type": "application/json", "X-Forwarded-For": "192.0.2.1, " + client})
		server.anonymous().expect(response, expectedStatus, nil)
	}
	for range 10 {
		failLogin("198.51.100.7", http.StatusUnauthorized)
	}
	failLogin("198.51.100.7", http.StatusTooManyRequests)
	failLogin("198.51.100.8", http.StatusUnauthorized)

	var failures logPage
	admin.mustJSON(http.MethodGet, "/admin/logs?component=auth&level=warn&limit=500", nil, http.StatusOK, &failures)
	addresses := map[string]int{}
	for _, entry := range failures.Entries {
		addresses[entry.Message+" "+entry.Attrs["address"]]++
	}
	want := map[string]int{
		"login failed 198.51.100.7":                            10,
		"login refused: too many failed attempts 198.51.100.7": 1,
		"login failed 198.51.100.8":                            1,
	}
	if !maps.Equal(addresses, want) {
		t.Fatalf("logged %v, want %v", addresses, want)
	}
}
