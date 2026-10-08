package app_test

import (
	"bytes"
	"io"
	"net/http"
	"slices"
	"strings"
	"testing"
)

type brandingImage struct {
	ID          string `json:"id"`
	ContentType string `json:"contentType"`
}

type brandingResponse struct {
	Name        string          `json:"name"`
	Message     string          `json:"message"`
	AccentColor string          `json:"accentColor"`
	Icon        *brandingImage  `json:"icon"`
	Backgrounds []brandingImage `json:"backgrounds"`
}

func (b brandingResponse) backgroundIDs() []string {
	var ids []string
	for _, background := range b.Backgrounds {
		ids = append(ids, background.ID)
	}
	return ids
}

var pngHeader = []byte("\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR")

func TestBrandingIsPublicAndAdminControlled(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		anonymous := server.anonymous()

		var current brandingResponse
		anonymous.mustJSON(http.MethodGet, "/branding", nil, http.StatusOK, &current)
		if current.Name != "" || current.Icon != nil || current.Backgrounds == nil || len(current.Backgrounds) != 0 {
			t.Fatalf("a new server should have no branding: %+v", current)
		}

		admin.mustJSON(http.MethodPatch, "/admin/settings",
			map[string]any{"instanceName": "  Family files ", "welcomeMessage": "Hello", "accentColor": "#12ab34"}, http.StatusOK, nil)
		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"accentColor": "teal"}, http.StatusBadRequest, nil)
		alice.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"instanceName": "Mine"}, http.StatusForbidden, nil)
		anonymous.mustJSON(http.MethodGet, "/branding", nil, http.StatusOK, &current)
		if current.Name != "Family files" || current.Message != "Hello" || current.AccentColor != "#12AB34" {
			t.Fatalf("branding not applied: %+v", current)
		}

		upload := func(c *client, method, path string, content []byte, status int, target any) {
			t.Helper()
			c.expect(c.request(method, path, bytes.NewReader(content), nil), status, target)
		}
		upload(alice, http.MethodPut, "/admin/branding/icon", pngHeader, http.StatusForbidden, nil)
		upload(admin, http.MethodPut, "/admin/branding/icon", []byte("not an image"), http.StatusBadRequest, nil)
		upload(admin, http.MethodPut, "/admin/branding/icon", pngHeader, http.StatusOK, &current)
		if current.Icon == nil || current.Icon.ContentType != "image/png" {
			t.Fatalf("the icon should be described once set: %+v", current.Icon)
		}
		iconURL := "/branding/icon/" + current.Icon.ID
		response := anonymous.request(http.MethodGet, iconURL, nil, nil)
		content, _ := io.ReadAll(response.Body)
		response.Body.Close()
		if response.StatusCode != http.StatusOK || !bytes.Equal(content, pngHeader) || response.Header.Get("Content-Type") != "image/png" {
			t.Fatalf("icon served as %d %q", response.StatusCode, response.Header.Get("Content-Type"))
		}
		if !strings.Contains(response.Header.Get("Cache-Control"), "immutable") {
			t.Fatalf("an image under its hash should be cached for good, got %q", response.Header.Get("Cache-Control"))
		}
		admin.mustJSON(http.MethodDelete, "/admin/branding/icon", nil, http.StatusNoContent, nil)
		anonymous.mustJSON(http.MethodGet, iconURL, nil, http.StatusNotFound, nil)

		svg := []byte(`<svg xmlns="http://www.w3.org/2000/svg"/>`)
		upload(admin, http.MethodPost, "/admin/branding/backgrounds", pngHeader, http.StatusCreated, nil)
		upload(admin, http.MethodPost, "/admin/branding/backgrounds", svg, http.StatusCreated, nil)
		upload(admin, http.MethodPost, "/admin/branding/backgrounds", pngHeader, http.StatusCreated, &current)
		if len(current.Backgrounds) != 2 || current.Backgrounds[1].ContentType != "image/svg+xml" {
			t.Fatalf("the same image twice should be one background: %+v", current.Backgrounds)
		}
		first := current.Backgrounds[0].ID
		response = anonymous.request(http.MethodGet, "/branding/backgrounds/"+current.Backgrounds[1].ID, nil, nil)
		response.Body.Close()
		if response.Header.Get("Content-Type") != "image/svg+xml" {
			t.Fatalf("SVG background served as %q", response.Header.Get("Content-Type"))
		}

		admin.mustJSON(http.MethodDelete, "/admin/branding/backgrounds/"+first, nil, http.StatusNoContent, nil)
		anonymous.mustJSON(http.MethodGet, "/branding/backgrounds/"+first, nil, http.StatusNotFound, nil)
		anonymous.mustJSON(http.MethodGet, "/branding", nil, http.StatusOK, &current)
		if slices.Contains(current.backgroundIDs(), first) || len(current.Backgrounds) != 1 {
			t.Fatalf("background not removed: %+v", current.Backgrounds)
		}
	})
}
