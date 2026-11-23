package app_test

import (
	"net/http"
	"testing"
)

type deviceLoginStart struct {
	RequestID string `json:"requestId"`
	PollToken string `json:"pollToken"`
	Number    int    `json:"number"`
}

type deviceLoginResult struct {
	Status string     `json:"status"`
	Tokens *tokenPair `json:"tokens"`
}

func (s *testServer) requestDeviceLogin(body map[string]string) deviceLoginStart {
	s.t.Helper()
	var started deviceLoginStart
	s.anonymous().mustJSON(http.MethodPost, "/auth/device-login", body, http.StatusCreated, &started)
	return started
}

func (s *testServer) pollDeviceLogin(started deviceLoginStart, status int) deviceLoginResult {
	s.t.Helper()
	var result deviceLoginResult
	target := any(&result)
	if status != http.StatusOK {
		target = nil
	}
	s.anonymous().mustJSON(http.MethodPost, "/auth/device-login/"+started.RequestID+"/status", map[string]string{"pollToken": started.PollToken}, status, target)
	return result
}

func wrongNumber(right int) int {
	if right == 999 {
		return right - 1
	}
	return right + 1
}

func TestAnotherDeviceApprovesASignInWithoutPassword(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		socket := alice.openEvents()
		adminSocket := admin.openEvents()
		adminSocket.send(map[string]any{"type": "subscribe", "scope": "all"})
		adminSocket.next("snapshot")

		started := server.requestDeviceLogin(map[string]string{"username": "alice", "deviceName": "New laptop"})
		event := socket.next("login.requested")
		if event.Login == nil || event.Login.ID != started.RequestID || event.Login.Device != "New laptop" || started.Number < 100 || started.Number > 999 {
			t.Fatalf("event = %+v, started = %+v", event.Login, started)
		}
		var pending []struct {
			ID string `json:"id"`
		}
		alice.mustJSON(http.MethodGet, "/account/login-requests", nil, http.StatusOK, &pending)
		if len(pending) != 1 || pending[0].ID != started.RequestID {
			t.Fatalf("pending = %+v", pending)
		}
		if result := server.pollDeviceLogin(started, http.StatusOK); result.Status != "pending" || result.Tokens != nil {
			t.Fatalf("result = %+v", result)
		}

		admin.mustJSON(http.MethodPost, "/account/login-requests/"+started.RequestID+"/approve", map[string]int{"number": started.Number}, http.StatusNotFound, nil)
		alice.mustJSON(http.MethodPost, "/account/login-requests/"+started.RequestID+"/approve", map[string]int{"number": started.Number}, http.StatusNoContent, nil)
		if resolved := socket.next("login.resolved"); resolved.Login.Resolution != "approved" {
			t.Fatalf("resolved = %+v", resolved.Login)
		}
		result := server.pollDeviceLogin(started, http.StatusOK)
		if result.Status != "approved" || result.Tokens == nil || result.Tokens.User.Username != "alice" {
			t.Fatalf("result = %+v", result)
		}
		server.pollDeviceLogin(started, http.StatusNotFound)
		(&client{server: server, token: result.Tokens.AccessToken}).mustJSON(http.MethodGet, "/files/list?path=/", nil, http.StatusOK, nil)

		adminSocket.conn.CloseNow()
	})
}

func TestANewRequestLeavesEarlierOnesPending(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		first := server.requestDeviceLogin(map[string]string{"username": "alice", "deviceName": "Laptop"})
		second := server.requestDeviceLogin(map[string]string{"username": "alice", "deviceName": "Somebody else"})
		var pending []struct {
			ID string `json:"id"`
		}
		alice.mustJSON(http.MethodGet, "/account/login-requests", nil, http.StatusOK, &pending)
		if len(pending) != 2 || pending[0].ID != first.RequestID || pending[1].ID != second.RequestID {
			t.Fatalf("pending = %+v", pending)
		}
		alice.mustJSON(http.MethodPost, "/account/login-requests/"+first.RequestID+"/approve", map[string]int{"number": first.Number}, http.StatusNoContent, nil)
		if result := server.pollDeviceLogin(first, http.StatusOK); result.Status != "approved" || result.Tokens == nil {
			t.Fatalf("result = %+v", result)
		}
	})
}

func TestTypingTheWrongNumberRefusesTheSignIn(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		started := server.requestDeviceLogin(map[string]string{"username": "alice"})
		alice.mustJSON(http.MethodPost, "/account/login-requests/"+started.RequestID+"/approve",
			map[string]int{"number": wrongNumber(started.Number)}, http.StatusForbidden, nil)
		if result := server.pollDeviceLogin(started, http.StatusOK); result.Status != "denied" {
			t.Fatalf("result = %+v", result)
		}
		alice.mustJSON(http.MethodPost, "/account/login-requests/"+started.RequestID+"/approve", map[string]int{"number": started.Number}, http.StatusNotFound, nil)

		denied := server.requestDeviceLogin(map[string]string{"username": "alice"})
		alice.mustJSON(http.MethodPost, "/account/login-requests/"+denied.RequestID+"/deny", nil, http.StatusNoContent, nil)
		if result := server.pollDeviceLogin(denied, http.StatusOK); result.Status != "denied" {
			t.Fatalf("result = %+v", result)
		}

		cancelled := server.requestDeviceLogin(map[string]string{"username": "alice"})
		server.anonymous().mustJSON(http.MethodPost, "/auth/device-login/"+cancelled.RequestID+"/cancel", map[string]string{"pollToken": cancelled.PollToken}, http.StatusNoContent, nil)
		if result := server.pollDeviceLogin(cancelled, http.StatusOK); result.Status != "cancelled" {
			t.Fatalf("result = %+v", result)
		}
	})
}

func TestUnknownAccountsGetARequestThatNeverResolves(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		server.setupAdmin()
		started := server.requestDeviceLogin(map[string]string{"username": "nobody"})
		if started.RequestID == "" || started.PollToken == "" || started.Number < 100 {
			t.Fatalf("started = %+v", started)
		}
		if result := server.pollDeviceLogin(started, http.StatusOK); result.Status != "pending" {
			t.Fatalf("result = %+v", result)
		}
	})
}

func TestApprovalReplacesTheAuthenticatorCode(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		alice.enableTwoFactor("password1")
		challenge := server.passwordStep("alice", "password1")
		started := server.requestDeviceLogin(map[string]string{"challenge": challenge.Current.Challenge, "deviceName": "Tablet"})
		alice.mustJSON(http.MethodPost, "/account/login-requests/"+started.RequestID+"/approve", map[string]int{"number": started.Number}, http.StatusNoContent, nil)
		result := server.pollDeviceLogin(started, http.StatusOK)
		if result.Tokens == nil || result.Tokens.User.Username != "alice" {
			t.Fatalf("result = %+v", result)
		}
		server.secondFactor(challenge.Current.Challenge, map[string]string{"recoveryCode": "AAAAA-AAAAA"}, http.StatusUnauthorized)
	})
}

func TestBlockedSessionsCannotApproveSignIns(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"requireTwoFactor": true, "twoFactorGraceDays": 0}, http.StatusOK, nil)
		started := server.requestDeviceLogin(map[string]string{"username": "alice"})
		alice.mustJSON(http.MethodPost, "/account/login-requests/"+started.RequestID+"/approve", map[string]int{"number": started.Number}, http.StatusForbidden, nil)
		alice.mustJSON(http.MethodPost, "/account/login-requests/"+started.RequestID+"/deny", nil, http.StatusNoContent, nil)
	})
}
