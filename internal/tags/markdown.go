package tags

import (
	"bytes"
	"regexp"
	"slices"
	"strings"
	"unicode"
	"unicode/utf8"

	"github.com/yuin/goldmark/ast"

	"polder-server/internal/markdown"
)

var tagToken = regexp.MustCompile(`#[\p{L}\p{N}_\-/]+`)

type span struct {
	start, end int
	name       string
}

func (s span) key() string { return Key(s.name) }

func ReadTags(source []byte) []string {
	seen := map[string]bool{}
	var names []string
	for _, found := range tagSpans(source) {
		if !seen[found.key()] {
			seen[found.key()] = true
			names = append(names, found.name)
		}
	}
	return names
}

func tagSpans(source []byte) []span {
	document := markdown.Parse(source)
	offset := len(source) - len(document.Body)
	prose := mergeSegments(proseSegments(document))
	var spans []span
	for _, match := range tagToken.FindAllIndex(document.Body, -1) {
		start, end := match[0], match[1]
		if !startsTag(document.Body, start) || !covered(prose, start, end) {
			continue
		}
		name := strings.TrimRight(string(document.Body[start+1:end]), "/-")
		if !ValidName(name) {
			continue
		}
		spans = append(spans, span{start: offset + start, end: offset + start + 1 + len(name), name: name})
	}
	return spans
}

func startsTag(body []byte, start int) bool {
	if start == 0 {
		return true
	}
	previous, _ := utf8.DecodeLastRune(body[:start])
	return !unicode.IsLetter(previous) && !unicode.IsNumber(previous) && !strings.ContainsRune("_&/#\\", previous)
}

type segment struct{ start, stop int }

func proseSegments(document markdown.Document) []segment {
	var segments []segment
	_ = ast.Walk(document.Root, func(node ast.Node, entering bool) (ast.WalkStatus, error) {
		if !entering {
			return ast.WalkContinue, nil
		}
		switch typed := node.(type) {
		case *ast.CodeSpan, *ast.CodeBlock, *ast.FencedCodeBlock, *ast.Link, *ast.Image, *ast.AutoLink, *ast.RawHTML, *ast.HTMLBlock:
			return ast.WalkSkipChildren, nil
		case *ast.Text:
			segments = append(segments, segment{start: typed.Segment.Start, stop: typed.Segment.Stop})
		}
		return ast.WalkContinue, nil
	})
	return segments
}

func mergeSegments(segments []segment) []segment {
	slices.SortFunc(segments, func(a, b segment) int { return a.start - b.start })
	var merged []segment
	for _, next := range segments {
		if last := len(merged) - 1; last >= 0 && next.start <= merged[last].stop {
			merged[last].stop = max(merged[last].stop, next.stop)
			continue
		}
		merged = append(merged, next)
	}
	return merged
}

func covered(segments []segment, start, end int) bool {
	for _, candidate := range segments {
		if candidate.start <= start && end <= candidate.stop {
			return true
		}
	}
	return false
}

func HasTag(source []byte, key string) bool {
	return slices.ContainsFunc(tagSpans(source), func(found span) bool { return found.key() == key })
}

func AppendTag(source []byte, name string) []byte {
	if HasTag(source, Key(name)) {
		return source
	}
	text := strings.TrimRight(string(source), " \t\r\n")
	lastLine := text[strings.LastIndexByte(text, '\n')+1:]
	switch {
	case text == "":
		return []byte("#" + name + "\n")
	case onlyTags(lastLine):
		return []byte(text + " #" + name + "\n")
	default:
		return []byte(text + "\n\n#" + name + "\n")
	}
}

func onlyTags(line string) bool {
	fields := strings.Fields(line)
	if len(fields) == 0 {
		return false
	}
	for _, field := range fields {
		if !strings.HasPrefix(field, "#") || !ValidName(field[1:]) {
			return false
		}
	}
	return true
}

func RenameTag(source []byte, key, name string) []byte {
	return rewrite(source, key, func(text []byte, found span) ([]byte, int) {
		return append(text, "#"+name...), found.end
	})
}

func RemoveTag(source []byte, key string) []byte {
	removed := rewrite(source, key, func(text []byte, found span) ([]byte, int) {
		end := found.end
		if before := len(text); before > 0 && text[before-1] == ' ' {
			text = text[:before-1]
		} else if end < len(source) && source[end] == ' ' {
			end++
		}
		if atLineStart(text) && end < len(source) && source[end] == '\n' {
			end++
		}
		return text, end
	})
	return withoutTrailingBlankLines(removed, source)
}

func atLineStart(text []byte) bool {
	return len(text) == 0 || text[len(text)-1] == '\n'
}

func withoutTrailingBlankLines(text, original []byte) []byte {
	trimmed := bytes.TrimRight(text, " \t\r\n")
	if len(trimmed) > 0 && bytes.HasSuffix(original, []byte("\n")) {
		trimmed = append(trimmed, '\n')
	}
	return trimmed
}

func rewrite(source []byte, key string, replace func(text []byte, found span) ([]byte, int)) []byte {
	result := make([]byte, 0, len(source))
	position, changed := 0, false
	for _, found := range tagSpans(source) {
		if found.key() != key {
			continue
		}
		result = append(result, source[position:found.start]...)
		result, position = replace(result, found)
		changed = true
	}
	if !changed {
		return source
	}
	return append(result, source[position:]...)
}
