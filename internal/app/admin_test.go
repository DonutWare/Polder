package app_test

import (
	"fmt"
	"net/http"
	"testing"
)

type userResponse struct {
	ID         int64  `json:"id"`
	Username   string `json:"username"`
	Role       string `json:"role"`
	QuotaBytes int64  `json:"quotaBytes"`
	UsedBytes  int64  `json:"usedBytes"`
	Disabled   bool   `json:"disabled"`
}

func TestAdminManagesUsers(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 1000)

		alice.mustJSON(http.MethodGet, "/admin/users", nil, http.StatusForbidden, nil)
		admin.mustJSON(http.MethodPost, "/admin/users", map[string]any{"username": "alice", "password": "password1", "role": "user"}, http.StatusConflict, nil)
		admin.mustJSON(http.MethodPost, "/admin/users", map[string]any{"username": "Bad Name", "password": "password1", "role": "user"}, http.StatusBadRequest, nil)

		var list []userResponse
		admin.mustJSON(http.MethodGet, "/admin/users", nil, http.StatusOK, &list)
		if len(list) != 2 {
			t.Fatalf("expected 2 users, got %+v", list)
		}
		aliceID := list[1].ID

		var updated userResponse
		admin.mustJSON(http.MethodPatch, fmt.Sprintf("/admin/users/%d", aliceID), map[string]any{"quotaBytes": 5000, "role": "admin"}, http.StatusOK, &updated)
		if updated.QuotaBytes != 5000 || updated.Role != "admin" {
			t.Fatalf("update not applied: %+v", updated)
		}

		admin.mustJSON(http.MethodPatch, fmt.Sprintf("/admin/users/%d", aliceID), map[string]any{"disabled": true}, http.StatusOK, nil)
		server.anonymous().mustJSON(http.MethodPost, "/auth/login", map[string]string{"username": "alice", "password": "password1"}, http.StatusForbidden, nil)
		alice.mustJSON(http.MethodGet, "/auth/me", nil, http.StatusForbidden, nil)

		admin.mustJSON(http.MethodDelete, fmt.Sprintf("/admin/users/%d", aliceID), nil, http.StatusNoContent, nil)
		admin.mustJSON(http.MethodGet, "/admin/users", nil, http.StatusOK, &list)
		if len(list) != 1 {
			t.Fatalf("user was not deleted: %+v", list)
		}
	})
}

func TestAdminCannotLockThemselvesOut(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		var me userResponse
		admin.mustJSON(http.MethodGet, "/auth/me", nil, http.StatusOK, &me)

		self := fmt.Sprintf("/admin/users/%d", me.ID)
		admin.mustJSON(http.MethodPatch, self, map[string]any{"role": "user"}, http.StatusForbidden, nil)
		admin.mustJSON(http.MethodPatch, self, map[string]any{"disabled": true}, http.StatusForbidden, nil)
		admin.mustJSON(http.MethodDelete, self, nil, http.StatusForbidden, nil)
	})
}
