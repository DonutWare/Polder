package search

import (
	"strings"
	"testing"
	"unicode/utf16"

	bleveSearch "github.com/blevesearch/bleve/v2/search"
)

func highlighted(snippet string, spans []TextSpan) []string {
	units := utf16.Encode([]rune(snippet))
	var parts []string
	for _, span := range spans {
		parts = append(parts, string(utf16.Decode(units[span.Start:span.End])))
	}
	return parts
}

func locationsOf(text string, words ...string) bleveSearch.TermLocationMap {
	locations := bleveSearch.TermLocationMap{}
	for _, word := range words {
		for offset := 0; ; {
			found := strings.Index(text[offset:], word)
			if found < 0 {
				break
			}
			start := offset + found
			locations[word] = append(locations[word], &bleveSearch.Location{Start: uint64(start), End: uint64(start + len(word))})
			offset = start + len(word)
		}
	}
	return locations
}

func TestSnippetPicksTheDensestMatches(t *testing.T) {
	text := "lease mentioned once.\n" + strings.Repeat("filler words go here. ", 40) +
		"The orchard\n\nlease for the 🍍 orchard is renewed." + strings.Repeat(" more filler", 40)
	snippet, spans := buildSnippet(text, contentSpans(text, locationsOf(text, "orchard", "lease")))
	if !strings.HasPrefix(snippet, "…") || !strings.HasSuffix(snippet, "…") {
		t.Fatalf("a cut snippet should show it is cut: %q", snippet)
	}
	if !strings.Contains(snippet, "The orchard lease for the 🍍 orchard is renewed.") {
		t.Fatalf("snippet should fold whitespace around the densest matches: %q", snippet)
	}
	if got := strings.Join(highlighted(snippet, spans), ","); got != "orchard,lease,orchard" {
		t.Fatalf("highlights = %s in %q", got, snippet)
	}
}

func TestSnippetOfShortText(t *testing.T) {
	text := "東京の事務所"
	snippet, spans := buildSnippet(text, contentSpans(text, locationsOf(text, "事務")))
	if snippet != text || strings.Join(highlighted(snippet, spans), ",") != "事務" {
		t.Fatalf("snippet = %q, highlights = %v", snippet, highlighted(snippet, spans))
	}
}
