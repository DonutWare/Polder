package search

import (
	"strings"
	"unicode"
	"unicode/utf16"
)

// TextSpan is a highlighted range [Start, End) in UTF-16 code units.
type TextSpan struct {
	Start int `json:"start"`
	End   int `json:"end"`
}

type runeSpan struct{ start, end int }

type target struct {
	runes    []rune
	lower    []rune
	boundary []bool
}

func newTarget(text string) target {
	runes := []rune(text)
	t := target{runes: runes, lower: make([]rune, len(runes)), boundary: make([]bool, len(runes))}
	for i, r := range runes {
		t.lower[i] = unicode.ToLower(r)
		if i == 0 {
			t.boundary[i] = true
			continue
		}
		previous := runes[i-1]
		t.boundary[i] = !isWordRune(previous) && isWordRune(r) ||
			unicode.IsLower(previous) && unicode.IsUpper(r) ||
			unicode.IsLetter(previous) && unicode.IsDigit(r) ||
			unicode.IsDigit(previous) && unicode.IsLetter(r)
	}
	return t
}

func isWordRune(r rune) bool { return unicode.IsLetter(r) || unicode.IsDigit(r) }

func (t target) words() []runeSpan {
	var words []runeSpan
	start := -1
	for i, r := range t.runes {
		if !isWordRune(r) {
			if start >= 0 {
				words = append(words, runeSpan{start, i})
				start = -1
			}
			continue
		}
		if t.boundary[i] && start >= 0 {
			words = append(words, runeSpan{start, i})
			start = -1
		}
		if start < 0 {
			start = i
		}
	}
	if start >= 0 {
		words = append(words, runeSpan{start, len(t.runes)})
	}
	return words
}

func (t target) utf16Spans(spans []runeSpan) []TextSpan {
	if len(spans) == 0 {
		return []TextSpan{}
	}
	offsets := make([]int, len(t.runes)+1)
	for i, r := range t.runes {
		offsets[i+1] = offsets[i] + utf16.RuneLen(r)
	}
	result := make([]TextSpan, len(spans))
	for i, span := range spans {
		result[i] = TextSpan{Start: offsets[span.start], End: offsets[span.end]}
	}
	return result
}

type termMatch struct {
	score float64
	spans []runeSpan
}

func matchTerm(term []rune, t target, exact bool) (termMatch, bool) {
	if found, ok := matchSubstring(term, t); ok || exact {
		return found, ok
	}
	best, matched := termMatch{}, false
	if found, ok := matchSubsequence(term, t); ok {
		best, matched = found, true
	}
	if found, ok := matchFuzzyWord(term, t); ok && found.score > best.score {
		best, matched = found, true
	}
	return best, matched
}

func matchSubstring(term []rune, t target) (termMatch, bool) {
	best, matched := termMatch{}, false
	for i := 0; i+len(term) <= len(t.lower); i++ {
		if !runesEqual(t.lower[i:i+len(term)], term) {
			continue
		}
		score := 100 + 10*float64(len(term))
		if t.boundary[i] {
			score += 30
		}
		if i == 0 {
			score += 20
		}
		if score > best.score {
			best, matched = termMatch{score: score, spans: []runeSpan{{i, i + len(term)}}}, true
		}
	}
	return best, matched
}

// matchSubsequence finds the term's characters in order, so "invq3" matches "invoice_q3". It scans forward
// for the first complete match and then backward from its end to make the match as tight as possible. Every
// run of matched characters has to start a word; letters picked from the middles of words are noise.
func matchSubsequence(term []rune, t target) (termMatch, bool) {
	if len(term) < 2 {
		return termMatch{}, false
	}
	next, end := 0, -1
	for i, r := range t.lower {
		if r == term[next] {
			next++
			if next == len(term) {
				end = i
				break
			}
		}
	}
	if end < 0 {
		return termMatch{}, false
	}
	positions := make([]int, len(term))
	next = len(term) - 1
	for i := end; i >= 0 && next >= 0; i-- {
		if t.lower[i] == term[next] {
			positions[next] = i
			next--
		}
	}

	var score float64
	var spans []runeSpan
	for k, position := range positions {
		score += 6
		if t.boundary[position] {
			score += 12
		}
		if k > 0 && positions[k-1] == position-1 {
			score += 8
			spans[len(spans)-1].end = position + 1
			continue
		}
		if k > 0 {
			score -= min(float64(position-positions[k-1]-1), 6)
		}
		spans = append(spans, runeSpan{position, position + 1})
	}
	for _, span := range spans {
		if !t.boundary[span.start] {
			return termMatch{}, false
		}
	}
	return termMatch{score: score, spans: spans}, true
}

func matchFuzzyWord(term []rune, t target) (termMatch, bool) {
	allowed := allowedEdits(len(term))
	if allowed == 0 {
		return termMatch{}, false
	}
	best, matched := termMatch{}, false
	for _, word := range t.words() {
		candidate := t.lower[word.start:word.end]
		distance := editDistance(term, candidate)
		if len(candidate) > len(term) {
			unfinished := editDistance(term, candidate[:len(term)])
			if len(term) < freeUnfinishedLength {
				unfinished++
			}
			distance = min(distance, unfinished)
		}
		if distance > allowed {
			continue
		}
		score := 60 + 5*float64(len(term)) - 20*float64(distance)
		if score > best.score {
			best, matched = termMatch{score: score, spans: []runeSpan{word}}, true
		}
	}
	return best, matched
}

const freeUnfinishedLength = 5

func allowedEdits(length int) int {
	switch {
	case length >= 8:
		return 2
	case length >= 4:
		return 1
	}
	return 0
}

func editDistance(a, b []rune) int {
	rows := make([][]int, len(a)+1)
	for i := range rows {
		rows[i] = make([]int, len(b)+1)
		rows[i][0] = i
	}
	for j := range rows[0] {
		rows[0][j] = j
	}
	for i := 1; i <= len(a); i++ {
		for j := 1; j <= len(b); j++ {
			cost := 1
			if a[i-1] == b[j-1] {
				cost = 0
			}
			rows[i][j] = min(rows[i-1][j]+1, rows[i][j-1]+1, rows[i-1][j-1]+cost)
			if i > 1 && j > 1 && a[i-1] == b[j-2] && a[i-2] == b[j-1] {
				rows[i][j] = min(rows[i][j], rows[i-2][j-2]+1)
			}
		}
	}
	return rows[len(a)][len(b)]
}

func runesEqual(a, b []rune) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}

type nameMatch struct {
	score float64
	spans []TextSpan
}

// rankEntry scores a name against every term. A term that misses the name may still match a parent folder,
// so "photos cat" finds /Photos/cat.jpg, but such a match counts for less and is not highlighted. At least
// one term has to match the name, or "photos" alone would list everything inside /Photos.
func rankEntry(terms []Term, name, entryPath string) (nameMatch, bool) {
	nameTarget := newTarget(name)
	var folderTarget *target
	var total float64
	var spans []runeSpan
	nameMatched := false
	for _, term := range terms {
		runes := []rune(term.Text)
		if found, ok := matchTerm(runes, nameTarget, term.Exact); ok {
			total += found.score
			spans = append(spans, found.spans...)
			nameMatched = true
			continue
		}
		if folderTarget == nil {
			folder := newTarget(parentPath(entryPath))
			folderTarget = &folder
		}
		found, ok := matchTerm(runes, *folderTarget, term.Exact)
		if !ok {
			return nameMatch{}, false
		}
		total += found.score * 0.4
	}
	if !nameMatched {
		return nameMatch{}, false
	}
	query := make([]string, len(terms))
	for i, term := range terms {
		query[i] = term.Text
	}
	stem := strings.ToLower(strings.TrimSuffix(name, "."+extensionOf(name)))
	if stem == strings.Join(query, " ") || strings.ToLower(name) == strings.Join(query, " ") {
		total += 80
	}
	total -= 0.3*float64(len(nameTarget.runes)) + 2*float64(strings.Count(entryPath, "/"))
	return nameMatch{score: total, spans: nameTarget.utf16Spans(mergeSpans(spans))}, true
}

func parentPath(entryPath string) string {
	if index := strings.LastIndex(entryPath, "/"); index > 0 {
		return entryPath[:index]
	}
	return ""
}

func mergeSpans(spans []runeSpan) []runeSpan {
	if len(spans) < 2 {
		return spans
	}
	sorted := append([]runeSpan(nil), spans...)
	for i := 1; i < len(sorted); i++ {
		for j := i; j > 0 && sorted[j].start < sorted[j-1].start; j-- {
			sorted[j], sorted[j-1] = sorted[j-1], sorted[j]
		}
	}
	merged := []runeSpan{sorted[0]}
	for _, span := range sorted[1:] {
		last := &merged[len(merged)-1]
		if span.start <= last.end {
			last.end = max(last.end, span.end)
			continue
		}
		merged = append(merged, span)
	}
	return merged
}
