package recipes

import (
	"bytes"
	"context"
	"image"
	"image/png"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/linkpreview"
	"polder-server/internal/users"
)

type memoryFiles struct {
	contents map[string][]byte
}

func (m *memoryFiles) Write(_ context.Context, _ users.User, request files.WriteRequest) (files.Entry, error) {
	if _, exists := m.contents[request.Path]; exists {
		return files.Entry{}, apperr.Conflict(nil, "%s already exists", request.Path)
	}
	body, err := io.ReadAll(request.Content)
	if err != nil {
		return files.Entry{}, err
	}
	m.contents[request.Path] = body
	return files.Entry{ID: int64(len(m.contents)), Path: request.Path}, nil
}

func pngBytes(t *testing.T) []byte {
	t.Helper()
	var buffer bytes.Buffer
	if err := png.Encode(&buffer, image.NewRGBA(image.Rect(0, 0, 1, 1))); err != nil {
		t.Fatal(err)
	}
	return buffer.Bytes()
}

func TestImportWritesANoteWithItsImages(t *testing.T) {
	picture := pngBytes(t)
	site := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/recipe":
			w.Header().Set("Content-Type", "text/html")
			_, _ = w.Write([]byte(`<script type="application/ld+json">{"@type":"Recipe","name":"Pasta / Pesto",
"image":"/hero.png","recipeYield":4,
"recipeIngredient":["200 g pasta","1 jar *green* pesto"],
"recipeInstructions":[{"@type":"HowToStep","text":"Boil the pasta for 8 minutes.","image":"/step.png"},{"@type":"HowToStep","text":"Stir in the pesto.","image":"/missing.png"}]}</script>`))
		case "/hero.png", "/step.png":
			w.Header().Set("Content-Type", "image/png")
			_, _ = w.Write(picture)
		default:
			http.NotFound(w, r)
		}
	}))
	defer site.Close()
	store := &memoryFiles{contents: map[string][]byte{"/Notes/Pasta Pesto.md": []byte("taken")}}
	service := NewService(linkpreview.New(linkpreview.Options{AllowPrivate: true}), store)

	entry, err := service.Import(context.Background(), users.User{ID: 1}, Request{Source: site.URL + "/recipe", Folder: "/Notes"})
	if err != nil {
		t.Fatal(err)
	}
	if entry.Path != "/Notes/Pasta Pesto 2.md" {
		t.Fatalf("note path %q", entry.Path)
	}
	if !bytes.Equal(store.contents["/Notes/attachments/pasta-pesto.png"], picture) || store.contents["/Notes/attachments/pasta-pesto-1.png"] == nil {
		t.Fatalf("images not saved: %v", keys(store.contents))
	}
	note := string(store.contents[entry.Path])
	for _, expected := range []string{
		"![Pasta / Pesto](attachments/pasta-pesto.png?fileId=2)",
		"**Servings:** 4",
		"## Ingredients\n- [ ] 200 g pasta\n- [ ] 1 jar \\*green\\* pesto",
		"## Steps\n1. Boil the pasta for 8 minutes.\n   ![](attachments/pasta-pesto-1.png?fileId=3)\n2. Stir in the pesto.\n",
	} {
		if !strings.Contains(note, expected) {
			t.Fatalf("note misses %q:\n%s", expected, note)
		}
	}
}

func keys(contents map[string][]byte) []string {
	var names []string
	for name := range contents {
		names = append(names, name)
	}
	return names
}

func TestPastedSourceNeedsNoFetch(t *testing.T) {
	store := &memoryFiles{contents: map[string][]byte{}}
	service := NewService(linkpreview.New(linkpreview.Options{}), store)

	entry, err := service.Import(context.Background(), users.User{ID: 1}, Request{
		Source:  "https://shop.example.com/recept/stew",
		Content: "Stew\n\nIngredients\n- 2 onions\n\nMethod\n1. Cook the onions.",
		Folder:  "/Notes",
	})
	if err != nil {
		t.Fatal(err)
	}
	note := string(store.contents[entry.Path])
	if entry.Path != "/Notes/Stew.md" || !strings.Contains(note, "Source: [shop.example.com](https://shop.example.com/recept/stew)") || !strings.Contains(note, "1. Cook the onions.") {
		t.Fatalf("note %s:\n%s", entry.Path, note)
	}
}

func TestSitesThatRefuseAskForAPaste(t *testing.T) {
	site := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		http.Error(w, "Access Denied", http.StatusForbidden)
	}))
	defer site.Close()
	service := NewService(linkpreview.New(linkpreview.Options{AllowPrivate: true}), &memoryFiles{contents: map[string][]byte{}})

	_, err := service.Import(context.Background(), users.User{ID: 1}, Request{Source: site.URL, Folder: "/Notes"})
	if !apperr.Is(err, apperr.KindForbidden) {
		t.Fatalf("expected forbidden, got %v", err)
	}
}
