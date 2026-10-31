package search

import (
	"context"
	"slices"
	"sort"
	"strconv"
	"strings"
	"time"
	"unicode"

	"github.com/blevesearch/bleve/v2"
	bleveSearch "github.com/blevesearch/bleve/v2/search"
	"github.com/blevesearch/bleve/v2/search/query"

	"polder-server/internal/files"
	"polder-server/internal/users"
)

const (
	MaxLimit = 200
	// candidateWindow is how many index hits get re-ranked by the name matcher. Text queries page within it.
	candidateWindow = 500
	facetSize       = 30
)

type Match struct {
	Entry          files.Entry `json:"entry"`
	Score          float64     `json:"score"`
	NameMatches    []TextSpan  `json:"nameMatches" doc:"Ranges of the name that matched the query, in UTF-16 code units"`
	Snippet        *string     `json:"snippet" required:"false" doc:"Matching text from inside the file, when the content matched"`
	SnippetMatches []TextSpan  `json:"snippetMatches" doc:"Ranges of the snippet that matched the query, in UTF-16 code units"`
}

type FacetCount struct {
	Value string `json:"value"`
	Count int    `json:"count"`
}

type Facets struct {
	Types []FacetCount `json:"types"`
	Exts  []FacetCount `json:"exts"`
}

type Results struct {
	Query    string         `json:"query"`
	Total    int            `json:"total"`
	Results  []Match        `json:"results"`
	Filters  []QueryFilter  `json:"filters" doc:"The filters the query applied, with aliases resolved"`
	Facets   Facets         `json:"facets" doc:"How many matches each type and extension has"`
	Warnings []QueryWarning `json:"warnings" doc:"Parts of the query that were ignored, and why"`
}

func (s *Service) Search(ctx context.Context, owner users.User, raw string, limit, offset int) (Results, error) {
	limit = min(max(limit, 1), MaxLimit)
	offset = max(offset, 0)
	parsed := Parse(raw, time.Now())
	response := Results{Query: raw, Results: []Match{}, Filters: parsed.Filters, Warnings: parsed.Warnings,
		Facets: Facets{Types: []FacetCount{}, Exts: []FacetCount{}}}
	if !parsed.HasTerms() && len(parsed.Filters) == 0 {
		return response, nil
	}
	if err := s.Sync(ctx, owner.ID); err != nil {
		return Results{}, err
	}
	scope, err := s.scopeOf(ctx, owner, parsed)
	if err != nil {
		return Results{}, err
	}
	if parsed.HasTerms() {
		return s.searchText(ctx, owner, scope, parsed, response, limit, offset)
	}
	return s.searchFilters(ctx, owner, scope, parsed, response, limit, offset)
}

type filterScope struct {
	userID      int64
	notesFolder string
	tagged      map[string][]string
}

func (s *Service) scopeOf(ctx context.Context, owner users.User, parsed Query) (filterScope, error) {
	notesFolder, err := s.users.NotesPath(ctx, owner.ID)
	if err != nil {
		return filterScope{}, err
	}
	scope := filterScope{userID: owner.ID, tagged: map[string][]string{}}
	if notesFolder != nil {
		scope.notesFolder = *notesFolder
	}
	return scope, s.resolveTags(ctx, owner, parsed, scope.tagged)
}

func (s *Service) resolveTags(ctx context.Context, owner users.User, parsed Query, tagged map[string][]string) error {
	for _, filter := range parsed.Filters {
		if filter.Key != KeyTag {
			continue
		}
		for _, key := range filter.Values {
			if _, done := tagged[key]; done {
				continue
			}
			ids, err := s.tagged.FileIDsWithTag(ctx, owner.ID, key)
			if err != nil {
				return err
			}
			tagged[key] = documentIDs(ids)
		}
	}
	return nil
}

func documentIDs(ids []int64) []string {
	documents := make([]string, 0, len(ids))
	for _, id := range ids {
		documents = append(documents, documentID(id))
	}
	return documents
}

func (s *Service) searchFilters(ctx context.Context, owner users.User, scope filterScope, parsed Query, response Results, limit, offset int) (Results, error) {
	request := bleve.NewSearchRequestOptions(filterQuery(scope, parsed), limit, offset, false)
	request.SortBy([]string{"-" + fieldMtime, "_id"})
	request.AddFacet(fieldKind, bleve.NewFacetRequest(fieldKind, facetSize))
	request.AddFacet(fieldExt, bleve.NewFacetRequest(fieldExt, facetSize))
	result, err := s.searchIndex(request)
	if err != nil {
		return Results{}, err
	}
	ids := make([]int64, 0, len(result.Hits))
	for _, hit := range result.Hits {
		if id, err := strconv.ParseInt(hit.ID, 10, 64); err == nil {
			ids = append(ids, id)
		}
	}
	entries, err := s.files.EntriesByID(ctx, owner.ID, ids)
	if err != nil {
		return Results{}, err
	}
	for _, id := range ids {
		if entry, ok := entries[id]; ok {
			response.Results = append(response.Results, Match{Entry: entry, NameMatches: []TextSpan{}})
		}
	}
	response.Total = int(result.Total)
	for name, facet := range result.Facets {
		counts := []FacetCount{}
		for _, term := range facet.Terms.Terms() {
			if term.Term != "" {
				counts = append(counts, FacetCount{Value: term.Term, Count: term.Count})
			}
		}
		if name == fieldKind {
			response.Facets.Types = counts
		} else {
			response.Facets.Exts = counts
		}
	}
	return response, nil
}

type ranked struct {
	entry     files.Entry
	match     nameMatch
	named     bool
	content   float64
	locations bleveSearch.TermLocationMap
}

func (s *Service) searchText(ctx context.Context, owner users.User, scope filterScope, parsed Query, response Results, limit, offset int) (Results, error) {
	candidates := bleve.NewBooleanQuery()
	candidates.AddFilter(filterQuery(scope, parsed))
	candidates.AddShould(textQuery(parsed.Terms)...)
	candidates.SetMinShould(1)
	nameHits, err := s.searchIndex(bleve.NewSearchRequestOptions(candidates, candidateWindow, 0, false))
	if err != nil {
		return Results{}, err
	}
	var contentHits bleveSearch.DocumentMatchCollection
	if s.contentEnabled(ctx) {
		inText := bleve.NewBooleanQuery()
		inText.AddFilter(filterQuery(scope, parsed))
		inText.AddMust(contentQuery(parsed.Terms))
		request := bleve.NewSearchRequestOptions(inText, candidateWindow, 0, false)
		request.IncludeLocations = true
		result, err := s.searchIndex(request)
		if err != nil {
			return Results{}, err
		}
		contentHits = result.Hits
	}

	ids := make([]int64, 0, len(nameHits.Hits)+len(contentHits))
	for _, hit := range append(nameHits.Hits, contentHits...) {
		if id, err := strconv.ParseInt(hit.ID, 10, 64); err == nil {
			ids = append(ids, id)
		}
	}
	entries, err := s.files.EntriesByID(ctx, owner.ID, ids)
	if err != nil {
		return Results{}, err
	}

	var matches []*ranked
	byID := map[int64]*ranked{}
	for _, id := range ids[:len(nameHits.Hits)] {
		entry, ok := entries[id]
		if !ok || byID[id] != nil {
			continue
		}
		if found, ok := rankEntry(parsed.Terms, entry.Name, entry.Path); ok {
			byID[id] = &ranked{entry: entry, match: found, named: true}
			matches = append(matches, byID[id])
		}
	}
	for i, hit := range contentHits {
		id := ids[len(nameHits.Hits)+i]
		entry, ok := entries[id]
		if !ok {
			continue
		}
		if existing := byID[id]; existing != nil {
			existing.locations = hit.Locations[fieldContent]
			continue
		}
		byID[id] = &ranked{entry: entry, match: nameMatch{spans: []TextSpan{}}, content: hit.Score, locations: hit.Locations[fieldContent]}
		matches = append(matches, byID[id])
	}
	sort.SliceStable(matches, func(i, j int) bool {
		a, b := matches[i], matches[j]
		if a.named != b.named {
			return a.named
		}
		if a.match.score != b.match.score {
			return a.match.score > b.match.score
		}
		if a.content != b.content {
			return a.content > b.content
		}
		return a.entry.Mtime.After(b.entry.Mtime)
	})

	types, exts := map[string]int{}, map[string]int{}
	for _, match := range matches {
		document := newDocument(match.entry)
		types[document[fieldKind].(string)]++
		if extension := document[fieldExt].(string); extension != "" {
			exts[extension]++
		}
	}
	response.Facets = Facets{Types: sortedCounts(types), Exts: sortedCounts(exts)}
	response.Total = len(matches)
	for _, match := range matches[min(offset, len(matches)):min(offset+limit, len(matches))] {
		result := Match{Entry: match.entry, Score: match.match.score, NameMatches: match.match.spans, SnippetMatches: []TextSpan{}}
		if !match.named {
			result.Score = match.content
		}
		if len(match.locations) > 0 {
			if text, ok := s.texts.Text(match.entry); ok {
				if snippet, spans := buildSnippet(text, contentSpans(text, match.locations)); snippet != "" {
					result.Snippet, result.SnippetMatches = &snippet, spans
				}
			}
		}
		response.Results = append(response.Results, result)
	}
	return response, nil
}

func (s *Service) searchIndex(request *bleve.SearchRequest) (*bleve.SearchResult, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.index.Search(request)
}

func sortedCounts(counts map[string]int) []FacetCount {
	result := make([]FacetCount, 0, len(counts))
	for value, count := range counts {
		result = append(result, FacetCount{Value: value, Count: count})
	}
	sort.Slice(result, func(i, j int) bool {
		if result[i].Count != result[j].Count {
			return result[i].Count > result[j].Count
		}
		return result[i].Value < result[j].Value
	})
	return result[:min(len(result), facetSize)]
}

// textQuery only gathers candidates; rankEntry decides what matches. Name n-grams catch substrings and
// abbreviations, fuzzy and prefix word queries catch typos, and folder words catch "photos cat".
func textQuery(terms []Term) []query.Query {
	var should []query.Query
	for _, term := range terms {
		grams := bleve.NewMatchQuery(term.Text)
		grams.SetField(fieldName)
		should = append(should, grams)
		for _, word := range strings.Fields(wordsOf(term.Text)) {
			prefix := bleve.NewPrefixQuery(word)
			prefix.SetField(fieldWords)
			prefix.SetBoost(2)
			should = append(should, prefix)
			if edits := allowedEdits(len([]rune(word))); edits > 0 {
				fuzzy := bleve.NewFuzzyQuery(word)
				fuzzy.SetField(fieldWords)
				fuzzy.SetFuzziness(edits)
				should = append(should, fuzzy)
			}
			parents := bleve.NewMatchQuery(word)
			parents.SetField(fieldParents)
			parents.SetBoost(0.3)
			should = append(should, parents)
		}
	}
	return should
}

const contentFuzzyMinRunes = 6

func contentQuery(terms []Term) query.Query {
	var all []query.Query
	for _, term := range terms {
		if term.Exact {
			phrase := bleve.NewMatchPhraseQuery(term.Text)
			phrase.SetField(fieldContent)
			all = append(all, phrase)
			continue
		}
		words := bleve.NewMatchQuery(term.Text)
		words.SetField(fieldContent)
		words.SetOperator(query.MatchQueryOperatorAnd)
		if runes := []rune(term.Text); len(runes) >= contentFuzzyMinRunes && !slices.ContainsFunc(runes, isCJK) {
			words.SetFuzziness(1)
		}
		all = append(all, words)
	}
	return bleve.NewConjunctionQuery(all...)
}

func isCJK(r rune) bool {
	return unicode.In(r, unicode.Han, unicode.Hiragana, unicode.Katakana, unicode.Hangul)
}

func filterQuery(scope filterScope, parsed Query) query.Query {
	must := []query.Query{termQuery(fieldUser, userTerm(scope.userID))}
	var mustNot []query.Query
	include := map[Key][]string{}
	exclude := map[Key][]string{}
	for _, filter := range parsed.Filters {
		switch filter.Key {
		case KeyType, KeyExt, KeyIn:
			if filter.Op == OpIsNot {
				exclude[filter.Key] = append(exclude[filter.Key], filter.Values...)
			} else {
				include[filter.Key] = append(include[filter.Key], filter.Values...)
			}
		case KeyModified:
			span := parsed.timeRange(filter)
			var from, to time.Time
			if span.from != nil {
				from = *span.from
			}
			if span.to != nil {
				to = *span.to
			}
			inclusive, exclusive := true, false
			dates := bleve.NewDateRangeInclusiveQuery(from, to, &inclusive, &exclusive)
			dates.SetField(fieldMtime)
			if span.exclude {
				mustNot = append(mustNot, dates)
			} else {
				must = append(must, dates)
			}
		case KeyTag:
			if filter.Op == OpIsNot {
				mustNot = append(mustNot, taggedQuery(scope, filter.Values))
			} else {
				must = append(must, taggedQuery(scope, filter.Values))
			}
		case KeySize:
			span := parsed.sizeRange(filter)
			sizes := bleve.NewNumericRangeInclusiveQuery(span.min, span.max, &span.minInclusive, &span.maxInclusive)
			sizes.SetField(fieldSize)
			if span.exclude {
				mustNot = append(mustNot, sizes)
			} else {
				must = append(must, sizes)
			}
		}
	}
	for key, values := range include {
		must = append(must, bleve.NewDisjunctionQuery(valueQueries(scope, key, values)...))
	}
	for key, values := range exclude {
		mustNot = append(mustNot, valueQueries(scope, key, values)...)
		if key == KeyIn {
			for _, folder := range values {
				mustNot = append(mustNot, termQuery(fieldFolder, strings.ToLower(folder)))
			}
		}
	}
	combined := bleve.NewBooleanQuery()
	combined.AddMust(must...)
	combined.AddMustNot(mustNot...)
	return combined
}

func valueQueries(scope filterScope, key Key, values []string) []query.Query {
	var queries []query.Query
	for _, value := range values {
		switch key {
		case KeyType:
			switch {
			case isNoteKind(value):
				queries = append(queries, notesQuery(scope.notesFolder))
			case value == kindFile || value == kindFolder:
				isDir := bleve.NewBoolFieldQuery(value == kindFolder)
				isDir.SetField(fieldIsDir)
				queries = append(queries, isDir)
			case strings.Contains(value, "/"):
				queries = append(queries, termQuery(fieldMime, value))
			default:
				queries = append(queries, termQuery(fieldKind, value), termQuery(fieldExt, value), termQuery(fieldSubtype, value))
			}
		case KeyExt:
			queries = append(queries, termQuery(fieldExt, value))
		case KeyIn:
			folder := strings.ToLower(value)
			if folder == "/" {
				queries = append(queries, bleve.NewMatchAllQuery())
				continue
			}
			below := bleve.NewPrefixQuery(folder + "/")
			below.SetField(fieldFolder)
			queries = append(queries, below)
		}
	}
	return queries
}

func taggedQuery(scope filterScope, keys []string) query.Query {
	var ids []string
	for _, key := range keys {
		ids = append(ids, scope.tagged[key]...)
	}
	if len(ids) == 0 {
		return bleve.NewMatchNoneQuery()
	}
	return bleve.NewDocIDQuery(ids)
}

func notesQuery(notesFolder string) query.Query {
	if notesFolder == "" {
		return bleve.NewMatchNoneQuery()
	}
	markdown := termQuery(fieldMime, files.MarkdownMime)
	if notesFolder == "/" {
		return markdown
	}
	inside := bleve.NewPrefixQuery(strings.ToLower(notesFolder) + "/")
	inside.SetField(fieldFolder)
	return bleve.NewConjunctionQuery(markdown, inside)
}
