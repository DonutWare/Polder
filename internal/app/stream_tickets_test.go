package app_test

import (
	"net/http"
	"net/url"
	"testing"

	"polder-server/internal/config"
)

func TestStreamTickets(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "")
	alice := server.createUser(server.setupAdmin(), "alice", 0)
	alice.put("/Films/harbour.mp4", 0, []byte("moving pictures"), http.StatusOK, nil)
	alice.put("/notes.txt", 0, []byte("private"), http.StatusOK, nil)
	var issued struct {
		Ticket string `json:"ticket"`
	}
	alice.mustJSON(http.MethodPost, "/files/stream-tickets", map[string]string{"path": "/Films/harbour.mp4"}, http.StatusOK, &issued)
	ticket := url.QueryEscape(issued.Ticket)
	visitor := server.anonymous()

	t.Run("a ticket plays its file without a token, with ranges", func(t *testing.T) {
		response := visitor.request(http.MethodGet, "/files/content?path=%2FFilms%2Fharbour.mp4&ticket="+ticket, nil, map[string]string{"Range": "bytes=0-5"})
		if content := readBody(t, response); response.StatusCode != http.StatusPartialContent || string(content) != "moving" {
			t.Fatalf("status %d, body %q", response.StatusCode, content)
		}
	})

	t.Run("a ticket opens no other file", func(t *testing.T) {
		response := visitor.request(http.MethodGet, "/files/content?path=%2Fnotes.txt&ticket="+ticket, nil, nil)
		if readBody(t, response); response.StatusCode != http.StatusUnauthorized {
			t.Fatalf("status %d, want 401", response.StatusCode)
		}
	})

	t.Run("a ticket works on no other endpoint", func(t *testing.T) {
		response := visitor.request(http.MethodGet, "/files/stat?path=%2FFilms%2Fharbour.mp4&ticket="+ticket, nil, nil)
		if readBody(t, response); response.StatusCode != http.StatusUnauthorized {
			t.Fatalf("status %d, want 401", response.StatusCode)
		}
	})

	t.Run("a ticket is not an access token", func(t *testing.T) {
		bearer := &client{server: server, token: issued.Ticket}
		bearer.mustJSON(http.MethodGet, "/files/content?path=%2FFilms%2Fharbour.mp4", nil, http.StatusUnauthorized, nil)
	})

	t.Run("an access token is not a ticket", func(t *testing.T) {
		response := visitor.request(http.MethodGet, "/files/content?path=%2FFilms%2Fharbour.mp4&ticket="+url.QueryEscape(alice.token), nil, nil)
		if readBody(t, response); response.StatusCode != http.StatusUnauthorized {
			t.Fatalf("status %d, want 401", response.StatusCode)
		}
	})
}
