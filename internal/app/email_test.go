package app_test

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"regexp"
	"strings"
	"sync"
	"testing"
	"time"

	"polder-server/internal/app"
	"polder-server/internal/auth"
	"polder-server/internal/config"
	"polder-server/internal/mail"
)

const mailWait = 5 * time.Second

type capturingMailer struct {
	mu       sync.Mutex
	messages []mail.Message
}

func (m *capturingMailer) Configured(context.Context) bool { return true }
func (m *capturingMailer) Send(_ context.Context, message mail.Message) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.messages = append(m.messages, message)
	return nil
}

func (m *capturingMailer) sent() []mail.Message {
	m.mu.Lock()
	defer m.mu.Unlock()
	return append([]mail.Message(nil), m.messages...)
}

func (m *capturingMailer) waitFor(t *testing.T, subject string) mail.Message {
	t.Helper()
	deadline := time.Now().Add(mailWait)
	for time.Now().Before(deadline) {
		for _, message := range m.sent() {
			if strings.Contains(message.Subject, subject) {
				return message
			}
		}
		time.Sleep(10 * time.Millisecond)
	}
	t.Fatalf("no email with %q in its subject; sent: %v", subject, subjects(m.sent()))
	return mail.Message{}
}

func (m *capturingMailer) expectNone(t *testing.T, subject string) {
	t.Helper()
	time.Sleep(200 * time.Millisecond)
	for _, message := range m.sent() {
		if strings.Contains(message.Subject, subject) {
			t.Fatalf("unexpected email %q to %s", message.Subject, message.To)
		}
	}
}

func subjects(messages []mail.Message) []string {
	var list []string
	for _, message := range messages {
		list = append(list, message.To+": "+message.Subject)
	}
	return list
}

func forEachDatabaseWithMail(t *testing.T, test func(t *testing.T, server *testServer, mailer *capturingMailer)) {
	forEachDatabaseWithMailAt(t, "https://cloud.example.com", test)
}

func forEachDatabaseWithMailAt(t *testing.T, publicURL string, test func(t *testing.T, server *testServer, mailer *capturingMailer)) {
	run := func(t *testing.T, driver, dsn string) {
		mailer := &capturingMailer{}
		t.Cleanup(app.UseMailer(mailer))
		server := startServer(t, driver, dsn, func(cfg *config.Config) {
			cfg.PublicURL = publicURL
			cfg.TrustedProxies = []string{"127.0.0.1/32", "::1/128"}
		})
		test(t, server, mailer)
	}
	t.Run("sqlite-mail", func(t *testing.T) { run(t, config.DriverSQLite, "") })
	if dsn := os.Getenv(postgresEnvironmentVariable); dsn != "" {
		t.Run("postgres-mail", func(t *testing.T) {
			resetPostgres(t, dsn)
			run(t, config.DriverPostgres, dsn)
		})
	}
}

func (s *testServer) createUserWithEmail(admin *client, username, email string, quotaBytes int64) *client {
	admin.mustJSON(http.MethodPost, "/admin/users",
		map[string]any{"username": username, "password": "password1", "role": "user", "quotaBytes": quotaBytes, "email": email}, http.StatusCreated, nil)
	return s.login(username, "password1")
}

func (s *testServer) loginFromAddress(address, username, password string) (int, tokenPair) {
	var tokens tokenPair
	response := s.anonymous().request(http.MethodPost, "/auth/login",
		strings.NewReader(fmt.Sprintf(`{"username":%q,"password":%q,"deviceName":"Test phone"}`, username, password)),
		map[string]string{"Content-Type": "application/json", "X-Forwarded-For": address})
	status := response.StatusCode
	s.anonymous().expect(response, status, &tokens)
	return status, tokens
}

var resetCodePattern = regexp.MustCompile(`Your code: ([A-Z0-9]{4}-[A-Z0-9]{4})`)

func resetCodeIn(t *testing.T, message mail.Message) string {
	t.Helper()
	match := resetCodePattern.FindStringSubmatch(message.Text)
	if match == nil {
		t.Fatalf("no reset code in:\n%s", message.Text)
	}
	return match[1]
}

func (s *testServer) resetWithCode(login, code, password string, status int) {
	s.t.Helper()
	s.anonymous().mustJSON(http.MethodPost, "/auth/password-reset/code",
		map[string]string{"login": login, "code": code, "password": password}, status, nil)
}

func TestPasswordResetWithCode(t *testing.T) {
	forEachDatabaseWithMailAt(t, "", func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"instanceName": "Acme Cloud", "accentColor": "#3E63DD"}, http.StatusOK, nil)
		server.createUserWithEmail(admin, "alice", "alice@example.com", 0)
		_, other := server.loginFromAddress("203.0.113.5", "alice", "password1")

		var branding struct {
			PasswordReset bool `json:"passwordReset"`
		}
		server.anonymous().mustJSON(http.MethodGet, "/branding", nil, http.StatusOK, &branding)
		if !branding.PasswordReset {
			t.Fatal("branding should offer password reset once mail is set, even without a public URL")
		}

		server.anonymous().mustJSON(http.MethodPost, "/auth/password-reset", map[string]string{"login": "nobody"}, http.StatusAccepted, nil)
		server.anonymous().mustJSON(http.MethodPost, "/auth/password-reset", map[string]string{"login": "ALICE@example.com"}, http.StatusAccepted, nil)
		message := mailer.waitFor(t, "Your Acme Cloud reset code")
		if message.To != "alice@example.com" {
			t.Fatalf("reset went to %s", message.To)
		}
		code := resetCodeIn(t, message)
		if !strings.Contains(message.HTML, code) || !strings.Contains(message.HTML, "#3E63DD") {
			t.Error("the HTML email should show the code in the server's accent color")
		}
		if strings.Contains(message.HTML, "href=") {
			t.Errorf("a reset email must not contain links:\n%s", message.HTML)
		}

		server.resetWithCode("alice", "AAAA-AAAA", "newpassword1", http.StatusBadRequest)
		server.resetWithCode("nobody", code, "newpassword1", http.StatusBadRequest)
		server.resetWithCode("alice", code, "short", http.StatusBadRequest)
		server.resetWithCode("alice", strings.ToLower(strings.ReplaceAll(code, "-", " ")), "newpassword1", http.StatusNoContent)
		mailer.waitFor(t, "password was changed")

		server.resetWithCode("alice", code, "another1pass", http.StatusBadRequest)
		server.anonymous().mustJSON(http.MethodPost, "/auth/refresh", map[string]string{"refreshToken": other.RefreshToken}, http.StatusUnauthorized, nil)
		server.login("alice", "newpassword1")
		for _, sent := range mailer.sent() {
			if strings.Contains(sent.Subject, "reset code") && sent.To != "alice@example.com" {
				t.Fatalf("an unknown login must not get a reset email: %s", sent.To)
			}
		}
	})
}

func TestPasswordResetCodeStopsAfterTooManyWrongGuesses(t *testing.T) {
	forEachDatabaseWithMailAt(t, "", func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		server.createUserWithEmail(admin, "alice", "alice@example.com", 0)
		server.anonymous().mustJSON(http.MethodPost, "/auth/password-reset", map[string]string{"login": "alice"}, http.StatusAccepted, nil)
		code := resetCodeIn(t, mailer.waitFor(t, "reset code"))
		for range auth.MaxResetCodeAttempts {
			server.resetWithCode("alice", "AAAA-AAAA", "newpassword1", http.StatusBadRequest)
		}
		server.resetWithCode("alice", code, "newpassword1", http.StatusBadRequest)
		server.login("alice", "password1")
	})
}

func TestNewSignInAlertsOnlyForUnfamiliarAddresses(t *testing.T) {
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		admin.mustJSON(http.MethodPost, "/admin/users",
			map[string]any{"username": "bob", "password": "password1", "role": "user", "email": "bob@example.com"}, http.StatusCreated, nil)
		mailer.waitFor(t, "Welcome to Polder")

		if status, _ := server.loginFromAddress("203.0.113.5", "bob", "password1"); status != http.StatusOK {
			t.Fatalf("login: %d", status)
		}
		if status, _ := server.loginFromAddress("203.0.113.5", "bob", "password1"); status != http.StatusOK {
			t.Fatalf("login: %d", status)
		}
		mailer.expectNone(t, "New sign-in")

		server.loginFromAddress("198.51.100.7", "bob", "password1")
		message := mailer.waitFor(t, "New sign-in")
		if !strings.Contains(message.Text, "198.51.100.7") || !strings.Contains(message.Text, "Test phone") {
			t.Fatalf("the alert should name the address and device:\n%s", message.Text)
		}
	})
}

func TestEmailPreferencesSilenceOptionalEmails(t *testing.T) {
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		carol := server.createUserWithEmail(admin, "carol", "carol@example.com", 0)

		var preferences struct {
			Security bool `json:"security"`
			Quota    bool `json:"quota"`
			Shares   bool `json:"shares"`
			HasEmail bool `json:"hasEmail"`
			Enabled  bool `json:"enabled"`
		}
		carol.mustJSON(http.MethodGet, "/account/email-notifications", nil, http.StatusOK, &preferences)
		if !preferences.Security || !preferences.Quota || !preferences.Shares || !preferences.HasEmail || !preferences.Enabled {
			t.Fatalf("everything should start on: %+v", preferences)
		}
		carol.mustJSON(http.MethodPut, "/account/email-notifications", map[string]bool{"security": false, "quota": true, "shares": true}, http.StatusOK, &preferences)
		if preferences.Security {
			t.Fatal("security emails should be off")
		}
		server.loginFromAddress("203.0.113.5", "carol", "password1")
		server.loginFromAddress("198.51.100.7", "carol", "password1")
		mailer.expectNone(t, "New sign-in")

		carol.mustJSON(http.MethodPut, "/account/password", map[string]string{"currentPassword": "password1", "newPassword": "password2"}, http.StatusNoContent, nil)
		mailer.waitFor(t, "password was changed")
	})
}

func TestQuotaWarningsFireOnceAndRearm(t *testing.T) {
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		dave := server.createUserWithEmail(admin, "dave", "dave@example.com", 1000)

		var first fileEntry
		dave.put("/a.bin", 0, make([]byte, 850), http.StatusOK, &first)
		mailer.waitFor(t, "80%")
		dave.put("/b.bin", 0, make([]byte, 20), http.StatusOK, nil)
		mailer.expectNone(t, "storage is full")
		countWarnings := func() int {
			count := 0
			for _, message := range mailer.sent() {
				if strings.Contains(message.Subject, "storage") {
					count++
				}
			}
			return count
		}
		if count := countWarnings(); count != 1 {
			t.Fatalf("one warning per level, got %d: %v", count, subjects(mailer.sent()))
		}
		dave.put("/c.bin", 0, make([]byte, 125), http.StatusOK, nil)
		mailer.waitFor(t, "storage is full")
	})
}

func TestMailSettingsHideThePassword(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		var current map[string]any
		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{
			"smtpHost": "mail.example.com", "smtpPort": 2525, "smtpPassword": "hunter22", "smtpFrom": "Polder <polder@example.com>", "smtpSecurity": "tls",
		}, http.StatusOK, &current)
		if _, leaked := current["smtpPassword"]; leaked {
			t.Fatal("the mail password must never be returned")
		}
		if current["smtpPasswordSet"] != true || current["smtpHost"] != "mail.example.com" || current["smtpSecurity"] != "tls" {
			t.Fatalf("settings: %+v", current)
		}
		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"smtpSecurity": "ssl"}, http.StatusBadRequest, nil)
		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"smtpFrom": "not an address"}, http.StatusBadRequest, nil)
	})
}

func TestMailSettingsFromConfigAreLocked(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "", func(cfg *config.Config) {
		cfg.SMTPHost = "smtp.example.com"
		cfg.SMTPFrom = "polder@example.com"
	})
	admin := server.setupAdmin()
	var current map[string]any
	admin.mustJSON(http.MethodGet, "/admin/settings", nil, http.StatusOK, &current)
	if current["smtpManagedByConfig"] != true || current["smtpHost"] != "smtp.example.com" {
		t.Fatalf("settings: %+v", current)
	}
	admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"smtpHost": "other.example.com"}, http.StatusBadRequest, nil)
}
