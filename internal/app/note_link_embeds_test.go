package app_test

import (
	"archive/zip"
	"bytes"
	"io"
	"net/http"
	"net/url"
	"strings"
	"testing"

	"polder-server/internal/config"
)

const gyozaNote = `# Gyoza

![Gyoza](attachments/gyoza.jpg?fileId=45)

[Folding them](attachments/folding.mp4)

[Shopping list](attachments/list.txt)

![Up a folder](../private.jpg)

![Elsewhere](/Photos/me.jpg)

[Recipe site](https://example.com/gyoza)

[Back to the top](#gyoza)

![Plated](<attachments/plated gyoza.jpg> "Ready to eat")

[pantry]: ../Private/pantry.md
`

func TestNotesSeenThroughLinksHideTheOwnersPaths(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "")
	alice := server.createUser(server.setupAdmin(), "alice", 0)
	alice.put("/Notes/Gyoza.md", 0, []byte(gyozaNote), http.StatusOK, nil)
	for _, path := range []string{
		"/Notes/attachments/gyoza.jpg", "/Notes/attachments/folding.mp4", "/Notes/attachments/list.txt",
		"/Notes/attachments/plated gyoza.jpg",
		"/private.jpg", "/Photos/me.jpg", "/Private/pantry.md",
	} {
		alice.put(path, 0, []byte("content of "+path), http.StatusOK, nil)
	}
	visitor := server.anonymous()
	get := func(code, token, what, path string) (int, string) {
		response := visitor.request(http.MethodGet, "/public/links/"+code+"/"+what+"?path="+url.QueryEscape(path), nil, visitor.withShareToken(token))
		return response.StatusCode, string(readBody(t, response))
	}
	leaks := []string{"fileId", "attachments/", "private.jpg", "/Photos", "Private", "pantry"}
	expectHidden := func(t *testing.T, note string) {
		t.Helper()
		for _, leak := range leaks {
			if strings.Contains(note, leak) {
				t.Errorf("the shared note shows %q:\n%s", leak, note)
			}
		}
		if !strings.Contains(note, "](https://example.com/gyoza)") || !strings.Contains(note, "Shopping list") ||
			!strings.Contains(note, "[Back to the top](#gyoza)") {
			t.Errorf("the shared note lost its text or web links:\n%s", note)
		}
	}

	t.Run("a note link shows embeds under addresses that reveal nothing", func(t *testing.T) {
		link := alice.createLink(alice.stat("/Notes/Gyoza.md").ID, nil)
		token := visitor.unlock(link.Code, "", http.StatusOK).Token
		status, note := get(link.Code, token, "content", "/")
		if status != http.StatusOK || !strings.Contains(note, "![Gyoza](embedded/1/gyoza.jpg)") ||
			!strings.Contains(note, "[Folding them](embedded/2/folding.mp4)") ||
			!strings.Contains(note, "![Plated](embedded/3/plated%20gyoza.jpg)") {
			t.Fatalf("status %d:\n%s", status, note)
		}
		expectHidden(t, note)
		for path, want := range map[string]int{
			"/embedded/1/gyoza.jpg":        http.StatusOK,
			"/embedded/2/folding.mp4":      http.StatusOK,
			"/embedded/3/plated gyoza.jpg": http.StatusOK,
			"/embedded/1/other.jpg":        http.StatusNotFound,
			"/embedded/4/list.txt":         http.StatusNotFound,
			"/attachments/gyoza.jpg":       http.StatusNotFound,
			"/private.jpg":                 http.StatusNotFound,
		} {
			if got, _ := get(link.Code, token, "content", path); got != want {
				t.Errorf("content of %s: status %d, want %d", path, got, want)
			}
		}
		if _, image := get(link.Code, token, "content", "/embedded/1/gyoza.jpg"); image != "content of /Notes/attachments/gyoza.jpg" {
			t.Errorf("the embedded image is %q", image)
		}
	})

	t.Run("a view-only note link downloads no embeds", func(t *testing.T) {
		link := alice.createLink(alice.stat("/Notes/Gyoza.md").ID, map[string]any{"permissions": map[string]bool{"view": true, "download": false, "upload": false}})
		token := visitor.unlock(link.Code, "", http.StatusOK).Token
		if got, _ := get(link.Code, token, "content", "/embedded/1/gyoza.jpg"); got != http.StatusForbidden {
			t.Errorf("status %d, want 403", got)
		}
	})

	t.Run("a folder link keeps links inside the folder and drops the rest, in the zip too", func(t *testing.T) {
		link := alice.createLink(alice.stat("/Notes").ID, nil)
		token := visitor.unlock(link.Code, "", http.StatusOK).Token
		status, note := get(link.Code, token, "content", "/Gyoza.md")
		if status != http.StatusOK || !strings.Contains(note, "![Gyoza](/attachments/gyoza.jpg)") {
			t.Fatalf("status %d:\n%s", status, note)
		}
		leaks = []string{"fileId", "private.jpg", "/Photos", "Private", "pantry"}
		expectHidden(t, note)

		status, archive := get(link.Code, token, "archive", "/")
		if status != http.StatusOK {
			t.Fatalf("archive status %d", status)
		}
		zipped, err := zip.NewReader(bytes.NewReader([]byte(archive)), int64(len(archive)))
		if err != nil {
			t.Fatal(err)
		}
		for _, file := range zipped.File {
			if file.Name != "Gyoza.md" {
				continue
			}
			opened, _ := file.Open()
			content, _ := io.ReadAll(opened)
			if string(content) != note {
				t.Errorf("the zipped note differs from the shown one:\n%s", content)
			}
		}
	})

	t.Run("the owner still gets the note as written", func(t *testing.T) {
		if _, content := alice.download("/Notes/Gyoza.md", nil); string(content) != gyozaNote {
			t.Errorf("the owner's note changed:\n%s", content)
		}
	})
}
