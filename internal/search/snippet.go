package search

import (
	"sort"
	"unicode"
	"unicode/utf16"
	"unicode/utf8"

	bleveSearch "github.com/blevesearch/bleve/v2/search"
)

const (
	snippetBytes     = 320
	snippetLeadBytes = 60
	ellipsis         = "…"
)

type byteSpan struct{ start, end int }

func contentSpans(text string, locations bleveSearch.TermLocationMap) []byteSpan {
	var spans []byteSpan
	for _, found := range locations {
		for _, location := range found {
			start, end := int(location.Start), int(location.End)
			if start < end && end <= len(text) {
				spans = append(spans, byteSpan{start, end})
			}
		}
	}
	sort.Slice(spans, func(i, j int) bool { return spans[i].start < spans[j].start })
	merged := spans[:0]
	for _, span := range spans {
		if last := len(merged) - 1; last >= 0 && span.start <= merged[last].end {
			merged[last].end = max(merged[last].end, span.end)
			continue
		}
		merged = append(merged, span)
	}
	return merged
}

func buildSnippet(text string, spans []byteSpan) (string, []TextSpan) {
	if len(spans) == 0 {
		return "", nil
	}
	best, bestCount := 0, 0
	for i := range spans {
		count := 0
		for j := i; j < len(spans) && spans[j].end <= spans[i].start+snippetBytes; j++ {
			count++
		}
		if count > bestCount {
			best, bestCount = i, count
		}
	}
	start := wordStartBefore(text, max(spans[best].start-snippetLeadBytes, 0))
	end := wordEndAfter(text, min(start+snippetBytes, len(text)))
	if end < spans[best].end {
		end = spans[best].end
	}

	var out []rune
	var matches []TextSpan
	units := 0
	if start > 0 {
		out = append(out, []rune(ellipsis)...)
		units += utf16.RuneLen([]rune(ellipsis)[0])
	}
	next := best
	for next > 0 && spans[next-1].end > start {
		next--
	}
	open := -1
	spaced := true
	for offset := start; offset < end; {
		for next < len(spans) && open < 0 && spans[next].start <= offset && spans[next].end > offset {
			open = units
		}
		r, size := utf8.DecodeRuneInString(text[offset:])
		if unicode.IsSpace(r) {
			if !spaced {
				out = append(out, ' ')
				units++
			}
			spaced = true
		} else {
			out = append(out, r)
			units += utf16.RuneLen(r)
			spaced = false
		}
		offset += size
		if open >= 0 && offset >= spans[next].end {
			matches = append(matches, TextSpan{Start: open, End: units})
			open = -1
			next++
		}
	}
	if open >= 0 {
		matches = append(matches, TextSpan{Start: open, End: units})
	}
	if end < len(text) {
		for len(out) > 0 && out[len(out)-1] == ' ' {
			out = out[:len(out)-1]
		}
		out = append(out, []rune(ellipsis)...)
	}
	return string(out), matches
}

func wordStartBefore(text string, offset int) int {
	for offset > 0 && !utf8.RuneStart(text[offset]) {
		offset--
	}
	for steps := 0; offset > 0 && steps < 20; steps++ {
		previous, size := utf8.DecodeLastRuneInString(text[:offset])
		if unicode.IsSpace(previous) {
			break
		}
		offset -= size
	}
	return offset
}

func wordEndAfter(text string, offset int) int {
	for offset < len(text) && !utf8.RuneStart(text[offset]) {
		offset++
	}
	for steps := 0; offset < len(text) && steps < 20; steps++ {
		r, size := utf8.DecodeRuneInString(text[offset:])
		if unicode.IsSpace(r) {
			break
		}
		offset += size
	}
	return offset
}
