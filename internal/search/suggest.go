package search

import (
	"context"
	"sort"
	"strconv"
	"strings"
	"time"
	"unicode/utf16"

	"github.com/blevesearch/bleve/v2"
	"github.com/blevesearch/bleve/v2/search/query"

	"polder-server/internal/tags"
	"polder-server/internal/users"
)

const maxSuggestions = 12

type SuggestionKind string

const (
	SuggestKey   SuggestionKind = "key"
	SuggestValue SuggestionKind = "value"
)

type Suggestion struct {
	Kind   SuggestionKind `json:"kind" enum:"key,value"`
	Value  string         `json:"value"`
	Insert string         `json:"insert" doc:"Text that replaces the range [start, end) of the query"`
	Count  int            `json:"count" doc:"How many of the user's files have this value; 0 when not counted"`
}

type Suggestions struct {
	Start       int          `json:"start" doc:"Start of the range to replace, in UTF-16 code units"`
	End         int          `json:"end"`
	Suggestions []Suggestion `json:"suggestions"`
}

func (s *Service) Suggest(ctx context.Context, owner users.User, raw string, cursor int) (Suggestions, error) {
	empty := Suggestions{Start: cursor, End: cursor, Suggestions: []Suggestion{}}
	var current *token
	for _, tok := range tokenize(raw) {
		if tok.start <= cursor && cursor <= tok.end {
			current = &tok
			break
		}
	}
	if current == nil {
		return empty, nil
	}
	text := current.text
	offset := current.start
	if strings.HasPrefix(text, "-") {
		text, offset = text[1:], offset+1
	}
	if strings.HasPrefix(text, "#") {
		return s.suggestHashTags(ctx, owner, strings.ToLower(text[1:]), offset, current.end)
	}
	keyEnd := 0
	for keyEnd < len(text) && (text[keyEnd] >= 'a' && text[keyEnd] <= 'z' || text[keyEnd] >= 'A' && text[keyEnd] <= 'Z') {
		keyEnd++
	}
	rest := text[keyEnd:]
	if rest == "" {
		return suggestKeys(strings.ToLower(text), offset, current.end), nil
	}
	key, known := keyAliases[strings.ToLower(text[:keyEnd])]
	if !known {
		return empty, nil
	}
	hasOperator := false
	for _, candidate := range operators {
		if strings.HasPrefix(rest, candidate.text) {
			rest = rest[len(candidate.text):]
			offset += keyEnd + len(candidate.text)
			hasOperator = true
			break
		}
	}
	if !hasOperator {
		return empty, nil
	}

	// Only the value after the last comma is being typed; the earlier ones stay.
	fragmentStart := strings.LastIndex(rest, ",") + 1
	existing := splitValues(rest[:fragmentStart])
	fragment := strings.ToLower(strings.Trim(rest[fragmentStart:], `"`))
	start := offset + utf16Len(rest[:fragmentStart])

	s.mu.Lock()
	defer s.mu.Unlock()
	values, err := s.suggestValues(ctx, owner, key, fragment)
	if err != nil {
		return Suggestions{}, err
	}
	taken := map[string]bool{}
	for _, value := range existing {
		taken[strings.ToLower(strings.TrimPrefix(value, "."))] = true
	}
	result := Suggestions{Start: start, End: current.end, Suggestions: []Suggestion{}}
	for _, value := range values {
		if !taken[value.Value] && len(result.Suggestions) < maxSuggestions {
			result.Suggestions = append(result.Suggestions, value)
		}
	}
	return result, nil
}

func suggestKeys(fragment string, start, end int) Suggestions {
	result := Suggestions{Start: start, End: end, Suggestions: []Suggestion{}}
	if fragment == "" {
		return result
	}
	for _, key := range Keys {
		if strings.HasPrefix(string(key), fragment) {
			result.Suggestions = append(result.Suggestions, Suggestion{Kind: SuggestKey, Value: string(key), Insert: string(key) + "="})
		}
	}
	return result
}

func (s *Service) suggestValues(ctx context.Context, owner users.User, key Key, fragment string) ([]Suggestion, error) {
	switch key {
	case KeyType:
		kinds, err := s.facetValues(owner.ID, fieldKind, fragment)
		if err != nil {
			return nil, err
		}
		exts, err := s.facetValues(owner.ID, fieldExt, fragment)
		if err != nil {
			return nil, err
		}
		if strings.HasPrefix(kindFile, fragment) {
			kinds = append(kinds, Suggestion{Kind: SuggestValue, Value: kindFile, Insert: kindFile})
		}
		if strings.HasPrefix(kindNote, fragment) {
			notesFolder, err := s.users.NotesPath(ctx, owner.ID)
			if err != nil {
				return nil, err
			}
			if notesFolder != nil {
				kinds = append(kinds, Suggestion{Kind: SuggestValue, Value: kindNote, Insert: kindNote})
			}
		}
		seen := map[string]bool{}
		var merged []Suggestion
		for _, suggestion := range append(kinds, exts...) {
			if !seen[suggestion.Value] {
				seen[suggestion.Value] = true
				merged = append(merged, suggestion)
			}
		}
		return merged, nil
	case KeyExt:
		return s.facetValues(owner.ID, fieldExt, fragment)
	case KeyIn:
		return s.folderValues(ctx, owner, fragment)
	case KeyModified:
		now := time.Now()
		presets := []string{"today", "yesterday", "7d", "30d", "1y", now.Format("2006"), now.AddDate(-1, 0, 0).Format("2006"),
			now.Format("2006-01"), now.AddDate(0, -1, 0).Format("2006-01")}
		return prefixed(presets, fragment), nil
	case KeySize:
		return prefixed([]string{"1mb", "10mb", "100mb", "1gb"}, fragment), nil
	case KeyTag:
		return s.tagValues(ctx, owner, strings.TrimPrefix(fragment, "#"), "")
	}
	return nil, nil
}

func (s *Service) suggestHashTags(ctx context.Context, owner users.User, fragment string, start, end int) (Suggestions, error) {
	values, err := s.tagValues(ctx, owner, fragment, "#")
	if err != nil {
		return Suggestions{}, err
	}
	return Suggestions{Start: start, End: end, Suggestions: append([]Suggestion{}, values[:min(len(values), maxSuggestions)]...)}, nil
}

func (s *Service) tagValues(ctx context.Context, owner users.User, fragment, prefix string) ([]Suggestion, error) {
	list, err := s.tagged.List(ctx, owner.ID)
	if err != nil {
		return nil, err
	}
	var suggestions []Suggestion
	for _, tag := range list {
		if strings.Contains(tags.Key(tag.Name), fragment) {
			suggestions = append(suggestions, Suggestion{Kind: SuggestValue, Value: tags.Key(tag.Name), Insert: prefix + tag.Name, Count: tag.Count})
		}
	}
	sort.SliceStable(suggestions, func(i, j int) bool {
		return strings.HasPrefix(suggestions[i].Value, fragment) && !strings.HasPrefix(suggestions[j].Value, fragment)
	})
	return suggestions, nil
}

func prefixed(values []string, fragment string) []Suggestion {
	var result []Suggestion
	for _, value := range values {
		if strings.HasPrefix(value, fragment) {
			result = append(result, Suggestion{Kind: SuggestValue, Value: value, Insert: value})
		}
	}
	return result
}

func (s *Service) facetValues(userID int64, field, fragment string) ([]Suggestion, error) {
	var q query.Query = termQuery(fieldUser, userTerm(userID))
	if fragment != "" {
		prefix := bleve.NewPrefixQuery(fragment)
		prefix.SetField(field)
		q = bleve.NewConjunctionQuery(q, prefix)
	}
	request := bleve.NewSearchRequestOptions(q, 0, 0, false)
	request.AddFacet(field, bleve.NewFacetRequest(field, maxSuggestions*2))
	result, err := s.index.Search(request)
	if err != nil {
		return nil, err
	}
	var suggestions []Suggestion
	for _, term := range result.Facets[field].Terms.Terms() {
		if term.Term != "" && strings.HasPrefix(term.Term, fragment) {
			suggestions = append(suggestions, Suggestion{Kind: SuggestValue, Value: term.Term, Insert: term.Term, Count: term.Count})
		}
	}
	return suggestions, nil
}

func (s *Service) folderValues(ctx context.Context, owner users.User, fragment string) ([]Suggestion, error) {
	isDir := bleve.NewBoolFieldQuery(true)
	isDir.SetField(fieldIsDir)
	folders := bleve.NewBooleanQuery()
	folders.AddFilter(bleve.NewConjunctionQuery(termQuery(fieldUser, userTerm(owner.ID)), isDir))
	if fragment != "" {
		if strings.HasPrefix(fragment, "/") {
			prefix := bleve.NewPrefixQuery(fragment)
			prefix.SetField(fieldFolder)
			folders.AddShould(prefix)
		} else {
			folders.AddShould(textQuery([]Term{{Text: fragment}})...)
		}
		folders.SetMinShould(1)
	} else {
		folders.AddMust(bleve.NewMatchAllQuery())
	}
	result, err := s.index.Search(bleve.NewSearchRequestOptions(folders, 100, 0, false))
	if err != nil {
		return nil, err
	}
	ids := make([]int64, 0, len(result.Hits))
	for _, hit := range result.Hits {
		if id, err := strconv.ParseInt(hit.ID, 10, 64); err == nil {
			ids = append(ids, id)
		}
	}
	entries, err := s.files.EntriesByID(ctx, owner.ID, ids)
	if err != nil {
		return nil, err
	}
	type scored struct {
		path  string
		score float64
	}
	var matches []scored
	for _, entry := range entries {
		score := -float64(len(entry.Path))
		if fragment != "" && !strings.HasPrefix(strings.ToLower(entry.Path), fragment) {
			found, ok := rankEntry([]Term{{Text: fragment}}, entry.Name, entry.Path)
			if !ok {
				continue
			}
			score = found.score
		}
		matches = append(matches, scored{entry.Path, score})
	}
	sort.Slice(matches, func(i, j int) bool { return matches[i].score > matches[j].score })
	suggestions := make([]Suggestion, 0, len(matches))
	for _, match := range matches {
		insert := match.path
		if strings.ContainsAny(insert, " ,\"") {
			insert = `"` + insert + `"`
		}
		suggestions = append(suggestions, Suggestion{Kind: SuggestValue, Value: match.path, Insert: insert})
	}
	return suggestions, nil
}

func utf16Len(text string) int {
	length := 0
	for _, r := range text {
		length += utf16.RuneLen(r)
	}
	return length
}
