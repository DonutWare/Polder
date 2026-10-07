package app_test

import (
	"archive/zip"
	"bytes"
	"context"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"slices"
	"strconv"
	"strings"
	"testing"
	"time"
	"unicode/utf16"
)

type searchResponse struct {
	Total   int `json:"total"`
	Results []struct {
		Entry       fileEntry `json:"entry"`
		NameMatches []struct {
			Start int `json:"start"`
			End   int `json:"end"`
		} `json:"nameMatches"`
		Snippet        *string `json:"snippet"`
		SnippetMatches []struct {
			Start int `json:"start"`
			End   int `json:"end"`
		} `json:"snippetMatches"`
	} `json:"results"`
	Filters []struct {
		Key    string   `json:"key"`
		Op     string   `json:"op"`
		Values []string `json:"values"`
	} `json:"filters"`
	Facets struct {
		Exts []struct {
			Value string `json:"value"`
			Count int    `json:"count"`
		} `json:"exts"`
	} `json:"facets"`
	Warnings []struct {
		Message string `json:"message"`
	} `json:"warnings"`
}

func (c *client) search(query string) searchResponse {
	c.server.t.Helper()
	var response searchResponse
	c.mustJSON(http.MethodGet, "/search?q="+url.QueryEscape(query), nil, http.StatusOK, &response)
	return response
}

func (r searchResponse) paths() []string {
	paths := make([]string, len(r.Results))
	for i, result := range r.Results {
		paths[i] = result.Entry.Path
	}
	return paths
}

func expectPaths(t *testing.T, query string, response searchResponse, want ...string) {
	t.Helper()
	got := response.paths()
	slices.Sort(got)
	slices.Sort(want)
	if !slices.Equal(got, want) {
		t.Fatalf("search %q = %v, want %v", query, got, want)
	}
}

func TestSearchFindsFilesByFuzzyName(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/Finance/invoice_q3.pdf", 0, []byte("pdf"), http.StatusOK, nil)
		alice.put("/Finance/receipt.png", 0, []byte("png"), http.StatusOK, nil)
		alice.put("/Photos/cat.jpg", 0, []byte("jpg"), http.StatusOK, nil)

		top := alice.search("invq3")
		if len(top.Results) == 0 || top.Results[0].Entry.Path != "/Finance/invoice_q3.pdf" || len(top.Results[0].NameMatches) == 0 {
			t.Fatalf("abbreviation should find the invoice first: %+v", top)
		}
		expectPaths(t, "recipt", alice.search("recipt"), "/Finance/receipt.png")
		expectPaths(t, "photos cat", alice.search("photos cat"), "/Photos/cat.jpg")
		expectPaths(t, "finance", alice.search("finance"), "/Finance")
		if empty := alice.search(""); len(empty.Results) != 0 {
			t.Fatalf("an empty query should find nothing, got %v", empty.paths())
		}
	})
}

func TestSearchFilters(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/Trip/beach.jpg", 0, []byte("12345"), http.StatusOK, nil)
		alice.put("/Trip/beach.gif", 0, []byte("1"), http.StatusOK, nil)
		alice.put("/Trip/notes.txt", 0, []byte("12"), http.StatusOK, nil)
		alice.put("/My Docs/beach.custom", 0, []byte("123"), http.StatusOK, nil)

		cases := map[string][]string{
			"beach type=jpg,gif":         {"/Trip/beach.jpg", "/Trip/beach.gif"},
			"beach type!=gif,custom":     {"/Trip/beach.jpg"},
			"beach -ext:gif type=file":   {"/Trip/beach.jpg", "/My Docs/beach.custom"},
			"type=custom":                {"/My Docs/beach.custom"},
			"type=image":                 {"/Trip/beach.jpg", "/Trip/beach.gif"},
			"type=folder":                {"/Trip", "/My Docs"},
			`in="/my docs"`:              {"/My Docs/beach.custom"},
			"beach in!=/Trip":            {"/My Docs/beach.custom"},
			"size>2 type=file":           {"/Trip/beach.jpg", "/My Docs/beach.custom"},
			"size=2..3":                  {"/Trip/notes.txt", "/My Docs/beach.custom"},
			"modified=today type=text":   {"/Trip/notes.txt"},
			"modified<2000 type=file":    {},
			"modified>1d beach type=jpg": {"/Trip/beach.jpg"},
		}
		for query, want := range cases {
			expectPaths(t, query, alice.search(query), want...)
		}

		response := alice.search("type=jpg,gif size>huge")
		if len(response.Filters) != 1 || response.Filters[0].Key != "type" || len(response.Warnings) != 1 {
			t.Fatalf("expected one filter and one warning, got %+v", response)
		}
		facets := alice.search("type=file")
		if len(facets.Facets.Exts) != 4 {
			t.Fatalf("expected a facet per extension, got %+v", facets.Facets)
		}
	})
}

func TestSearchFollowsChanges(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.put("/Photos/sunset.jpg", 0, []byte("jpg"), http.StatusOK, nil)
		bob.put("/sunset-bob.jpg", 0, []byte("jpg"), http.StatusOK, nil)

		expectPaths(t, "sunset", alice.search("sunset"), "/Photos/sunset.jpg")
		expectPaths(t, "sunset", bob.search("sunset"), "/sunset-bob.jpg")

		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/Photos", "to": "/Pictures"}, http.StatusOK, nil)
		expectPaths(t, "sunset", alice.search("sunset"), "/Pictures/sunset.jpg")

		alice.mustJSON(http.MethodDelete, "/files?path="+url.QueryEscape("/Pictures"), nil, http.StatusNoContent, nil)
		expectPaths(t, "sunset", alice.search("sunset"))

		root := filepath.Join(server.app.Config.DataDir, "alice")
		if err := os.WriteFile(filepath.Join(root, "sunrise.png"), []byte("png"), 0o640); err != nil {
			t.Fatal(err)
		}
		owner, err := server.app.Users.ByID(context.Background(), 2)
		if err != nil {
			t.Fatal(err)
		}
		if err := server.app.Files.Rescan(context.Background(), owner); err != nil {
			t.Fatal(err)
		}
		expectPaths(t, "sunrise", alice.search("sunrise"), "/sunrise.png")

		admin.mustJSON(http.MethodPost, "/admin/search/rebuild", nil, http.StatusAccepted, nil)
		deadline := time.Now().Add(5 * time.Second)
		for {
			var status struct {
				Documents int `json:"documents"`
			}
			admin.mustJSON(http.MethodGet, "/admin/search", nil, http.StatusOK, &status)
			if status.Documents == 2 {
				break
			}
			if time.Now().After(deadline) {
				t.Fatalf("rebuilt index has %d documents, want 2", status.Documents)
			}
			time.Sleep(20 * time.Millisecond)
		}
		expectPaths(t, "sunrise", alice.search("sunrise"), "/sunrise.png")
	})
}

func TestSearchSuggestions(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		alice := server.createUser(server.setupAdmin(), "alice", 0)
		alice.put("/Work Stuff/a.png", 0, []byte("x"), http.StatusOK, nil)
		alice.put("/b.png", 0, []byte("x"), http.StatusOK, nil)
		alice.put("/c.pdf", 0, []byte("x"), http.StatusOK, nil)

		type suggestions struct {
			Start       int `json:"start"`
			End         int `json:"end"`
			Suggestions []struct {
				Value  string `json:"value"`
				Insert string `json:"insert"`
				Count  int    `json:"count"`
			} `json:"suggestions"`
		}
		suggest := func(query string) suggestions {
			var result suggestions
			alice.mustJSON(http.MethodGet, "/search/suggest?q="+url.QueryEscape(query)+"&cursor="+strconv.Itoa(len(query)), nil, http.StatusOK, &result)
			return result
		}

		keys := suggest("cat ty")
		if keys.Start != 4 || len(keys.Suggestions) != 1 || keys.Suggestions[0].Insert != "type=" {
			t.Fatalf("key suggestion: %+v", keys)
		}
		values := suggest("type=pdf,p")
		if values.Start != 9 || values.End != 10 {
			t.Fatalf("should replace only the value being typed: %+v", values)
		}
		var found []string
		for _, suggestion := range values.Suggestions {
			found = append(found, suggestion.Value)
			if suggestion.Value == "png" && suggestion.Count != 2 {
				t.Fatalf("png should be counted twice: %+v", suggestion)
			}
		}
		if !slices.Contains(found, "png") || slices.Contains(found, "pdf") {
			t.Fatalf("values = %v, want png but not the already chosen pdf", found)
		}
		folders := suggest("in=work")
		if len(folders.Suggestions) != 1 || folders.Suggestions[0].Insert != `"/Work Stuff"` {
			t.Fatalf("folder suggestion: %+v", folders)
		}
	})
}

func docx(paragraphs ...string) []byte {
	var body bytes.Buffer
	for _, paragraph := range paragraphs {
		fmt.Fprintf(&body, "<w:p><w:r><w:t>%s</w:t></w:r></w:p>", paragraph)
	}
	var archive bytes.Buffer
	writer := zip.NewWriter(&archive)
	for name, content := range map[string]string{
		"[Content_Types].xml": `<?xml version="1.0"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"/>`,
		"word/document.xml": `<?xml version="1.0"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>` +
			body.String() + `</w:body></w:document>`,
		"word/styles.xml": `<?xml version="1.0"?><w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:style w:styleId="Heading"/></w:styles>`,
	} {
		part, _ := writer.Create(name)
		part.Write([]byte(content))
	}
	writer.Close()
	return archive.Bytes()
}

func (c *client) searchUntil(query string, ready func(searchResponse) bool) searchResponse {
	c.server.t.Helper()
	var response searchResponse
	eventually(c.server.t, func() error {
		response = c.search(query)
		if !ready(response) {
			return fmt.Errorf("search %q = %v", query, response.paths())
		}
		return nil
	})
	return response
}

func TestSearchFindsTextInsideFiles(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.put("/notes.md", 0, []byte("# Groceries\n\nRemember the  ubiquitous\n\npineapple for Saturday."), http.StatusOK, nil)
		alice.put("/Letters/offer.docx", 0, docx("Dear tenant,", "the pineapple orchard lease is renewed."), http.StatusOK, nil)
		alice.put("/pineapple.txt", 0, []byte("nothing to see"), http.StatusOK, nil)
		alice.put("/blob.bin", 0, []byte{0, 1, 2, 'p', 'i', 'n', 'e', 'a', 'p', 'p', 'l', 'e'}, http.StatusOK, nil)
		bob.put("/secret.txt", 0, []byte("pineapple"), http.StatusOK, nil)

		found := alice.searchUntil("pineapple", func(r searchResponse) bool { return len(r.Results) == 3 })
		expectPaths(t, "pineapple", found, "/pineapple.txt", "/notes.md", "/Letters/offer.docx")
		if found.Results[0].Entry.Path != "/pineapple.txt" {
			t.Fatalf("a name match should come before text matches: %v", found.paths())
		}
		for _, result := range found.Results[1:] {
			if result.Snippet == nil || len(result.SnippetMatches) != 1 {
				t.Fatalf("%s should have a snippet with one match: %+v", result.Entry.Path, result)
			}
			match := result.SnippetMatches[0]
			if got := string(utf16.Decode(utf16.Encode([]rune(*result.Snippet))[match.Start:match.End])); got != "pineapple" {
				t.Fatalf("%s snippet %q highlights %q", result.Entry.Path, *result.Snippet, got)
			}
		}

		expectPaths(t, "every word", alice.search("pineapple saturday"), "/notes.md")
		expectPaths(t, "typo", alice.search("ubiquitus"), "/notes.md")
		expectPaths(t, "phrase", alice.search(`"orchard lease"`), "/Letters/offer.docx")
		expectPaths(t, "phrase out of order", alice.search(`"lease orchard"`))
		expectPaths(t, "filters", alice.search("pineapple type=md"), "/notes.md")
		expectPaths(t, "styles are not text", alice.search("heading"))

		alice.put("/tokyo.txt", 0, []byte("請求書の番号を確認してください\n東京都の新しい事務所について"), http.StatusOK, nil)
		japanese := alice.searchUntil("事務所", func(r searchResponse) bool { return len(r.Results) == 1 })
		if snippet := japanese.Results[0].Snippet; snippet == nil || !strings.Contains(*snippet, "東京都の新しい事務所") {
			t.Fatalf("snippet should show the Japanese text: %+v", japanese.Results[0])
		}
		expectPaths(t, "japanese word", alice.search("請求書"), "/tokyo.txt")

		alice.put("/seoul.txt", 0, []byte("안녕하세요 세계"), http.StatusOK, nil)
		alice.searchUntil(`"안녕하세요 세계"`, func(r searchResponse) bool { return len(r.Results) == 1 })

		alice.put("/notes.md", -1, []byte("now about mangoes"), http.StatusOK, nil)
		alice.searchUntil("mangoes", func(r searchResponse) bool { return len(r.Results) == 1 })
		expectPaths(t, "replaced text", alice.search("saturday"))

		alice.mustJSON(http.MethodPost, "/files/mkdir", map[string]string{"path": "/Archive"}, http.StatusCreated, nil)
		alice.mustJSON(http.MethodPost, "/files/move", map[string]any{"from": "/notes.md", "to": "/Archive/old.md"}, http.StatusOK, nil)
		expectPaths(t, "moved file keeps its text", alice.search("mangoes"), "/Archive/old.md")

		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"searchContentEnabled": false}, http.StatusOK, nil)
		expectPaths(t, "content search off", alice.search("mangoes"))
	})
}
