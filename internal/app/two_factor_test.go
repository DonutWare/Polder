package app_test

import (
	"net/http"
	"strconv"
	"strings"
	"testing"
	"time"

	"polder-server/internal/auth"
)

type twoFactorChallengeResponse struct {
	Error struct {
		Code string `json:"code"`
	} `json:"error"`
	Current struct {
		Challenge      string `json:"challenge"`
		ExpiresIn      int    `json:"expiresIn"`
		DeviceApproval bool   `json:"deviceApproval"`
	} `json:"current"`
}

type twoFactorUser struct {
	ID          int64 `json:"id"`
	HasPassword bool  `json:"hasPassword"`
	TwoFactor   struct {
		Enabled       bool       `json:"enabled"`
		Deadline      *time.Time `json:"deadline"`
		SetupRequired bool       `json:"setupRequired"`
	} `json:"twoFactor"`
}

type enabledTwoFactor struct {
	secret        string
	recoveryCodes []string
}

func (c *client) enableTwoFactor(password string) enabledTwoFactor {
	c.server.t.Helper()
	var setup struct {
		Secret string `json:"secret"`
		URL    string `json:"url"`
	}
	c.mustJSON(http.MethodPost, "/account/two-factor/setup", map[string]string{"password": password}, http.StatusOK, &setup)
	var codes struct {
		Codes []string `json:"codes"`
	}
	c.mustJSON(http.MethodPost, "/account/two-factor/confirm", map[string]string{"code": codeAt(c.server.t, setup.Secret, 0)}, http.StatusOK, &codes)
	return enabledTwoFactor{secret: setup.Secret, recoveryCodes: codes.Codes}
}

func (c *client) account() twoFactorUser {
	c.server.t.Helper()
	var user twoFactorUser
	c.mustJSON(http.MethodGet, "/auth/me", nil, http.StatusOK, &user)
	return user
}

func codeAt(t *testing.T, secret string, steps int) string {
	t.Helper()
	code, err := auth.TOTPCode(secret, time.Now().Add(time.Duration(steps)*30*time.Second))
	if err != nil {
		t.Fatal(err)
	}
	return code
}

func (s *testServer) passwordStep(username, password string) twoFactorChallengeResponse {
	s.t.Helper()
	var challenge twoFactorChallengeResponse
	s.anonymous().mustJSON(http.MethodPost, "/auth/login", map[string]string{"username": username, "password": password},
		http.StatusUnauthorized, &challenge)
	if challenge.Error.Code != "two_factor_required" || challenge.Current.Challenge == "" {
		s.t.Fatalf("login answered %+v, want a two-factor challenge", challenge)
	}
	return challenge
}

func (s *testServer) secondFactor(challenge string, body map[string]string, status int) tokenPair {
	s.t.Helper()
	body["challenge"] = challenge
	var tokens tokenPair
	target := any(&tokens)
	if status != http.StatusOK {
		target = nil
	}
	s.anonymous().mustJSON(http.MethodPost, "/auth/two-factor", body, status, target)
	return tokens
}

func TestTwoFactorLoginNeedsCodeFromApp(t *testing.T) {
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		alice := server.createUserWithEmail(admin, "alice", "alice@example.com", 0)
		enabled := alice.enableTwoFactor("password1")
		if len(enabled.recoveryCodes) != auth.RecoveryCodeCount {
			t.Fatalf("got %d recovery codes", len(enabled.recoveryCodes))
		}
		mailer.waitFor(t, "Two-factor authentication is on")
		if !alice.account().TwoFactor.Enabled {
			t.Fatal("me doesn't report two-factor authentication as on")
		}

		challenge := server.passwordStep("alice", "password1")
		if !challenge.Current.DeviceApproval {
			t.Fatal("alice has a signed-in device, so another device could approve")
		}
		server.secondFactor(challenge.Current.Challenge, map[string]string{"code": "000000"}, http.StatusUnauthorized)
		tokens := server.secondFactor(challenge.Current.Challenge, map[string]string{"code": codeAt(t, enabled.secret, 1)}, http.StatusOK)
		if tokens.User.Username != "alice" || tokens.AccessToken == "" {
			t.Fatalf("unexpected tokens %+v", tokens)
		}
		server.secondFactor(challenge.Current.Challenge, map[string]string{"code": codeAt(t, enabled.secret, 1)}, http.StatusUnauthorized)

		replay := server.passwordStep("alice", "password1")
		server.secondFactor(replay.Current.Challenge, map[string]string{"code": codeAt(t, enabled.secret, 1)}, http.StatusUnauthorized)
		server.secondFactor(replay.Current.Challenge, map[string]string{"recoveryCode": enabled.recoveryCodes[0]}, http.StatusOK)
		mailer.waitFor(t, "recovery code was used")

		again := server.passwordStep("alice", "password1")
		server.secondFactor(again.Current.Challenge, map[string]string{"recoveryCode": enabled.recoveryCodes[0]}, http.StatusUnauthorized)
	})
}

func TestTwoFactorChallengeStopsAfterTooManyWrongCodes(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		enabled := alice.enableTwoFactor("password1")
		challenge := server.passwordStep("alice", "password1")
		for range auth.MaxChallengeAttempts {
			server.secondFactor(challenge.Current.Challenge, map[string]string{"code": "000000"}, http.StatusUnauthorized)
		}
		server.secondFactor(challenge.Current.Challenge, map[string]string{"code": codeAt(t, enabled.secret, 1)}, http.StatusUnauthorized)
	})
}

func TestTurningTwoFactorOffNeedsThePassword(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		enabled := alice.enableTwoFactor("password1")
		var codes struct {
			Codes []string `json:"codes"`
		}
		alice.mustJSON(http.MethodPost, "/account/two-factor/recovery-codes", map[string]string{"password": "wrong-password"}, http.StatusForbidden, nil)
		alice.mustJSON(http.MethodPost, "/account/two-factor/recovery-codes", map[string]string{"password": "password1"}, http.StatusOK, &codes)
		if len(codes.Codes) != auth.RecoveryCodeCount || codes.Codes[0] == enabled.recoveryCodes[0] {
			t.Fatalf("expected a fresh set of recovery codes, got %v", codes.Codes)
		}
		alice.mustJSON(http.MethodPost, "/account/two-factor/disable", map[string]string{"password": "wrong-password"}, http.StatusForbidden, nil)
		alice.mustJSON(http.MethodPost, "/account/two-factor/disable", map[string]string{"password": "password1"}, http.StatusNoContent, nil)
		server.login("alice", "password1")
	})
}

func TestRequiredTwoFactorGivesAGracePeriodAndReminds(t *testing.T) {
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		alice := server.createUserWithEmail(admin, "alice", "alice@example.com", 0)
		before := time.Now()
		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"requireTwoFactor": true, "twoFactorGraceDays": 14}, http.StatusOK, nil)
		mailer.waitFor(t, "Set up two-factor authentication")

		status := alice.account().TwoFactor
		if status.Deadline == nil || status.SetupRequired {
			t.Fatalf("status = %+v, want a deadline that hasn't passed", status)
		}
		if days := status.Deadline.Sub(before).Hours() / 24; days < 13.9 || days > 14.1 {
			t.Fatalf("deadline is %.1f days away, want 14", days)
		}
		alice.mustJSON(http.MethodGet, "/files/list?path=/", nil, http.StatusOK, nil)

		if err := server.app.SendTwoFactorReminders(t.Context(), before.Add(5*24*time.Hour)); err != nil {
			t.Fatal(err)
		}
		mailer.expectNone(t, "Reminder")
		if err := server.app.SendTwoFactorReminders(t.Context(), before.Add(12*24*time.Hour)); err != nil {
			t.Fatal(err)
		}
		mailer.waitFor(t, "Reminder")
		if err := server.app.SendTwoFactorReminders(t.Context(), before.Add(13*24*time.Hour)); err != nil {
			t.Fatal(err)
		}
		time.Sleep(200 * time.Millisecond)
		reminders := 0
		for _, message := range mailer.sent() {
			if message.To == "alice@example.com" && strings.Contains(message.Subject, "Reminder") {
				reminders++
			}
		}
		if reminders != 1 {
			t.Fatalf("sent %d reminders, want 1", reminders)
		}

		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"requireTwoFactor": false}, http.StatusOK, nil)
		if alice.account().TwoFactor.Deadline != nil {
			t.Fatal("turning the requirement off should clear the deadline")
		}
	})
}

func TestExpiredGracePeriodAllowsOnlyTwoFactorSetup(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		appPassword := alice.createAppPassword("laptop", false, "password1")
		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"requireTwoFactor": true, "twoFactorGraceDays": 0}, http.StatusOK, nil)

		if !alice.account().TwoFactor.SetupRequired {
			t.Fatal("a grace period of 0 days should require setup at once")
		}
		var refused errorResponse
		alice.mustJSON(http.MethodGet, "/files/list?path=/", nil, http.StatusForbidden, &refused)
		if refused.Error.Code != "two_factor_setup_required" {
			t.Fatalf("code = %q", refused.Error.Code)
		}
		server.dav("alice", appPassword.Token).expect("PROPFIND", "/dav/files/alice/", "", map[string]string{"Depth": "0"}, http.StatusForbidden)
		admin.mustJSON(http.MethodGet, "/admin/users", nil, http.StatusForbidden, nil)

		alice.enableTwoFactor("password1")
		alice.mustJSON(http.MethodGet, "/files/list?path=/", nil, http.StatusOK, nil)
		alice.mustJSON(http.MethodPost, "/account/two-factor/disable", map[string]string{"password": "password1"}, http.StatusForbidden, nil)

		admin.enableTwoFactor("adminpass1")
		var reset twoFactorUser
		admin.mustJSON(http.MethodPost, "/admin/users/"+strconv.FormatInt(alice.account().ID, 10)+"/two-factor/reset", nil, http.StatusOK, &reset)
		if reset.TwoFactor.Enabled || reset.TwoFactor.Deadline == nil {
			t.Fatalf("after a reset alice should have no second factor and a new deadline: %+v", reset.TwoFactor)
		}
		relogged := server.login("alice", "password1")
		if !relogged.account().TwoFactor.SetupRequired {
			t.Fatal("alice should have to set it up again")
		}

		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"twoFactorGraceDays": 7}, http.StatusOK, nil)
		var extended twoFactorUser
		admin.mustJSON(http.MethodPost, "/admin/users/"+strconv.FormatInt(reset.ID, 10)+"/two-factor/extend", nil, http.StatusOK, &extended)
		if extended.TwoFactor.SetupRequired || extended.TwoFactor.Deadline == nil {
			t.Fatalf("extending should give alice time again: %+v", extended.TwoFactor)
		}
		relogged.mustJSON(http.MethodGet, "/files/list?path=/", nil, http.StatusOK, nil)
	})
}
