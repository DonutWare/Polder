package app_test

import (
	"net/http"
	"testing"
)

func TestSetupCreatesAdminOnlyOnce(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		var status struct{ NeedsSetup bool }
		server.anonymous().mustJSON(http.MethodGet, "/setup", nil, http.StatusOK, &status)
		if !status.NeedsSetup {
			t.Fatal("fresh server should need setup")
		}
		admin := server.setupAdmin()

		var me struct{ Role string }
		admin.mustJSON(http.MethodGet, "/auth/me", nil, http.StatusOK, &me)
		if me.Role != "admin" {
			t.Fatalf("setup user role = %s", me.Role)
		}
		server.anonymous().mustJSON(http.MethodPost, "/setup", map[string]string{"username": "evil", "password": "password1"}, http.StatusForbidden, nil)
	})
}

func TestLoginRefreshRotationAndLogout(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		server.setupAdmin()
		server.anonymous().mustJSON(http.MethodPost, "/auth/login", map[string]string{"username": "admin", "password": "wrong-password"}, http.StatusUnauthorized, nil)

		var first tokenPair
		server.anonymous().mustJSON(http.MethodPost, "/auth/login", map[string]string{"username": "admin", "password": "adminpass1", "deviceName": "test"}, http.StatusOK, &first)

		second := server.refresh(first.RefreshToken, http.StatusOK)
		third := server.refresh(second.RefreshToken, http.StatusOK)
		server.refresh(first.RefreshToken, http.StatusUnauthorized)

		server.anonymous().mustJSON(http.MethodPost, "/auth/logout", map[string]string{"refreshToken": third.RefreshToken}, http.StatusNoContent, nil)
		server.refresh(third.RefreshToken, http.StatusUnauthorized)
	})
}

func TestRefreshSurvivesALostResponse(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		first := server.setupAdminTokens()
		server.refresh(first.RefreshToken, http.StatusOK)

		retried := server.refresh(first.RefreshToken, http.StatusOK)
		server.refresh(retried.RefreshToken, http.StatusOK)
		server.refresh(first.RefreshToken, http.StatusUnauthorized)
	})
}

func TestConcurrentRefreshesKeepEveryIssuedTokenUsable(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		first := server.setupAdminTokens()
		winner := server.refresh(first.RefreshToken, http.StatusOK)
		loser := server.refresh(first.RefreshToken, http.StatusOK)

		server.refresh(winner.RefreshToken, http.StatusOK)
		server.refresh(loser.RefreshToken, http.StatusOK)
	})
}

func TestStartedSessionRefreshesIndependently(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		server.setupAdmin()
		var first tokenPair
		server.anonymous().mustJSON(http.MethodPost, "/auth/login", map[string]string{"username": "admin", "password": "adminpass1", "deviceName": "laptop"}, http.StatusOK, &first)
		signedIn := &client{server: server, token: first.AccessToken}

		var started tokenPair
		signedIn.mustJSON(http.MethodPost, "/auth/sessions", map[string]string{"deviceName": "laptop (Finder)"}, http.StatusCreated, &started)
		if started.User.Username != "admin" || started.RefreshToken == first.RefreshToken {
			t.Fatalf("started session = %+v", started)
		}

		server.anonymous().mustJSON(http.MethodPost, "/auth/refresh", map[string]string{"refreshToken": first.RefreshToken}, http.StatusOK, nil)
		server.anonymous().mustJSON(http.MethodPost, "/auth/refresh", map[string]string{"refreshToken": started.RefreshToken}, http.StatusOK, nil)
		server.anonymous().mustJSON(http.MethodPost, "/auth/sessions", map[string]string{}, http.StatusUnauthorized, nil)
	})
}

func TestRequestsWithoutTokenAreRejected(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		server.anonymous().mustJSON(http.MethodGet, "/files/list", nil, http.StatusUnauthorized, nil)
		server.anonymous().mustJSON(http.MethodGet, "/healthz", nil, http.StatusOK, nil)
	})
}

func TestUsersChangeTheirOwnPassword(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		server.createUser(admin, "alice", 0)

		var current, other tokenPair
		server.anonymous().mustJSON(http.MethodPost, "/auth/login", map[string]string{"username": "alice", "password": "password1"}, http.StatusOK, &current)
		server.anonymous().mustJSON(http.MethodPost, "/auth/login", map[string]string{"username": "alice", "password": "password1"}, http.StatusOK, &other)
		alice := &client{server: server, token: current.AccessToken}

		alice.mustJSON(http.MethodPut, "/account/password", map[string]string{"currentPassword": "wrong-password", "newPassword": "password2"}, http.StatusForbidden, nil)
		alice.mustJSON(http.MethodPut, "/account/password", map[string]string{"currentPassword": "password1", "newPassword": "short"}, http.StatusBadRequest, nil)
		alice.mustJSON(http.MethodPut, "/account/password", map[string]string{"currentPassword": "password1", "newPassword": "password2"}, http.StatusNoContent, nil)

		server.anonymous().mustJSON(http.MethodPost, "/auth/login", map[string]string{"username": "alice", "password": "password1"}, http.StatusUnauthorized, nil)
		server.login("alice", "password2")
		server.anonymous().mustJSON(http.MethodPost, "/auth/refresh", map[string]string{"refreshToken": current.RefreshToken}, http.StatusOK, nil)
		server.anonymous().mustJSON(http.MethodPost, "/auth/refresh", map[string]string{"refreshToken": other.RefreshToken}, http.StatusUnauthorized, nil)
	})
}

func (s *testServer) setupAdminTokens() tokenPair {
	s.setupAdmin()
	var tokens tokenPair
	s.anonymous().mustJSON(http.MethodPost, "/auth/login", map[string]string{"username": "admin", "password": "adminpass1", "deviceName": "test"}, http.StatusOK, &tokens)
	return tokens
}

func (s *testServer) refresh(refreshToken string, expectedStatus int) tokenPair {
	var tokens tokenPair
	var target any = &tokens
	if expectedStatus != http.StatusOK {
		target = nil
	}
	s.anonymous().mustJSON(http.MethodPost, "/auth/refresh", map[string]string{"refreshToken": refreshToken}, expectedStatus, target)
	return tokens
}
