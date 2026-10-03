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

		var second tokenPair
		server.anonymous().mustJSON(http.MethodPost, "/auth/refresh", map[string]string{"refreshToken": first.RefreshToken}, http.StatusOK, &second)
		server.anonymous().mustJSON(http.MethodPost, "/auth/refresh", map[string]string{"refreshToken": first.RefreshToken}, http.StatusUnauthorized, nil)

		server.anonymous().mustJSON(http.MethodPost, "/auth/logout", map[string]string{"refreshToken": second.RefreshToken}, http.StatusNoContent, nil)
		server.anonymous().mustJSON(http.MethodPost, "/auth/refresh", map[string]string{"refreshToken": second.RefreshToken}, http.StatusUnauthorized, nil)
	})
}

func TestRequestsWithoutTokenAreRejected(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		server.anonymous().mustJSON(http.MethodGet, "/files/list", nil, http.StatusUnauthorized, nil)
		server.anonymous().mustJSON(http.MethodGet, "/healthz", nil, http.StatusOK, nil)
	})
}
