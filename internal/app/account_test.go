package app_test

import (
	"bytes"
	"io"
	"net/http"
	"strconv"
	"testing"
)

type accountResponse struct {
	ID      int64 `json:"id"`
	Profile struct {
		FirstName   string `json:"firstName"`
		LastName    string `json:"lastName"`
		DisplayName string `json:"displayName"`
		Email       string `json:"email"`
		Age         *int   `json:"age"`
		Address     string `json:"address"`
	} `json:"profile"`
	Avatar     *brandingImage `json:"avatar"`
	Appearance struct {
		Theme       *string `json:"theme"`
		AccentColor *string `json:"accentColor"`
	} `json:"appearance"`
}

func TestUsersKeepTheirOwnProfileAndAppearance(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)

		var me accountResponse
		alice.mustJSON(http.MethodGet, "/auth/me", nil, http.StatusOK, &me)
		if me.Profile.FirstName != "" || me.Avatar != nil || me.Appearance.Theme != nil || me.Appearance.AccentColor != nil {
			t.Fatalf("a new user should have an empty profile: %+v", me)
		}

		alice.mustJSON(http.MethodPut, "/account/profile", map[string]any{
			"firstName": "  Alice ", "lastName": "Example", "displayName": "", "email": "alice@example.com", "age": 31, "address": "1 Main St",
		}, http.StatusOK, &me)
		if me.Profile.FirstName != "Alice" || me.Profile.Email != "alice@example.com" || me.Profile.Age == nil || *me.Profile.Age != 31 {
			t.Fatalf("profile not saved: %+v", me.Profile)
		}
		alice.mustJSON(http.MethodPut, "/account/profile", map[string]any{"email": "Alice <alice@example.com>"}, http.StatusBadRequest, nil)
		alice.mustJSON(http.MethodPut, "/account/profile", map[string]any{"age": -1}, http.StatusBadRequest, nil)

		alice.mustJSON(http.MethodPut, "/account/appearance", map[string]any{"theme": "dark", "accentColor": "#12ab34"}, http.StatusOK, &me)
		if me.Appearance.Theme == nil || *me.Appearance.Theme != "dark" || me.Appearance.AccentColor == nil || *me.Appearance.AccentColor != "#12AB34" {
			t.Fatalf("appearance not saved: %+v", me.Appearance)
		}
		alice.mustJSON(http.MethodPut, "/account/appearance", map[string]any{"theme": "sepia"}, http.StatusBadRequest, nil)
		alice.mustJSON(http.MethodPut, "/account/appearance", map[string]any{"accentColor": "teal"}, http.StatusBadRequest, nil)

		var other accountResponse
		bob.mustJSON(http.MethodGet, "/auth/me", nil, http.StatusOK, &other)
		if other.Profile.FirstName != "" || other.Appearance.Theme != nil {
			t.Fatalf("another user's profile changed: %+v", other)
		}

		alice.expect(alice.request(http.MethodPut, "/account/avatar", bytes.NewReader([]byte("not an image")), nil), http.StatusBadRequest, nil)
		alice.expect(alice.request(http.MethodPut, "/account/avatar", bytes.NewReader(pngHeader), nil), http.StatusOK, &me)
		if me.Avatar == nil || me.Avatar.ContentType != "image/png" {
			t.Fatalf("the icon should be described once set: %+v", me.Avatar)
		}
		avatarURL := "/users/" + strconv.FormatInt(me.ID, 10) + "/avatar/" + me.Avatar.ID
		response := server.anonymous().request(http.MethodGet, avatarURL, nil, nil)
		content, _ := io.ReadAll(response.Body)
		response.Body.Close()
		if response.StatusCode != http.StatusOK || !bytes.Equal(content, pngHeader) {
			t.Fatalf("icon served as %d", response.StatusCode)
		}
		server.anonymous().mustJSON(http.MethodGet, "/users/"+strconv.FormatInt(other.ID, 10)+"/avatar/"+me.Avatar.ID, nil, http.StatusNotFound, nil)

		var removed accountResponse
		alice.mustJSON(http.MethodDelete, "/account/avatar", nil, http.StatusOK, &removed)
		if removed.Avatar != nil {
			t.Fatalf("the icon should be gone: %+v", removed.Avatar)
		}
		server.anonymous().mustJSON(http.MethodGet, avatarURL, nil, http.StatusNotFound, nil)
	})
}
