package app_test

import (
	"context"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"slices"
	"strconv"
	"testing"
	"time"
)

type searchResponse struct {
	Total   int `json:"total"`
	Results []struct {
		Entry       fileEntry `json:"entry"`
		NameMatches []struct {
			Start int `json:"start"`
			End   int `json:"end"`
		} `json:"nameMatches"`
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
