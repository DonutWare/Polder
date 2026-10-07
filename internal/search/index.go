package search

import (
	"errors"
	"fmt"
	"mime"
	"os"
	"strconv"
	"strings"

	"github.com/blevesearch/bleve/v2"
	"github.com/blevesearch/bleve/v2/analysis/analyzer/custom"
	"github.com/blevesearch/bleve/v2/analysis/lang/cjk"
	"github.com/blevesearch/bleve/v2/analysis/token/lowercase"
	"github.com/blevesearch/bleve/v2/analysis/token/ngram"
	"github.com/blevesearch/bleve/v2/analysis/tokenizer/single"
	"github.com/blevesearch/bleve/v2/analysis/tokenizer/whitespace"
	"github.com/blevesearch/bleve/v2/mapping"
	"github.com/blevesearch/bleve/v2/search/query"

	"polder-server/internal/files"
)

// Bump mappingVersion whenever the mapping or the document fields change; the index is then rebuilt.
const mappingVersion = "2"

const (
	fieldUser    = "user"
	fieldPath    = "path"
	fieldFolder  = "folder"
	fieldName    = "name"
	fieldWords   = "words"
	fieldParents = "parents"
	fieldExt     = "ext"
	fieldKind    = "kind"
	fieldMime    = "mime"
	fieldSubtype = "subtype"
	fieldIsDir   = "is_dir"
	fieldSize    = "size"
	fieldMtime   = "mtime"
	fieldContent = "content"

	analyzerNgram   = "name_ngram"
	analyzerWords   = "words"
	analyzerLowered = "lowered_keyword"

	internalVersion  = "mapping_version"
	internalDatabase = "database_id"
	internalCursor   = "cursor/"
)

type index struct {
	dir string
	bleve.Index
}

func openIndex(dir, databaseID string) (*index, error) {
	opened, err := bleve.Open(dir)
	if err == nil {
		version, _ := opened.GetInternal([]byte(internalVersion))
		database, _ := opened.GetInternal([]byte(internalDatabase))
		switch {
		case string(version) != mappingVersion:
			logger.Info("search index is out of date; rebuilding", "dir", dir)
		case string(database) != databaseID:
			logger.Info("search index belongs to another database; rebuilding", "dir", dir)
		default:
			return &index{dir: dir, Index: opened}, nil
		}
		_ = opened.Close()
	} else if !errors.Is(err, bleve.ErrorIndexPathDoesNotExist) {
		logger.Warn("search index unreadable; rebuilding", "dir", dir, "error", err)
	}
	return createIndex(dir, databaseID)
}

func createIndex(dir, databaseID string) (*index, error) {
	if err := os.RemoveAll(dir); err != nil {
		return nil, err
	}
	indexMapping, err := newMapping()
	if err != nil {
		return nil, err
	}
	created, err := bleve.New(dir, indexMapping)
	if err != nil {
		return nil, fmt.Errorf("create search index: %w", err)
	}
	if err := created.SetInternal([]byte(internalVersion), []byte(mappingVersion)); err != nil {
		_ = created.Close()
		return nil, err
	}
	if err := created.SetInternal([]byte(internalDatabase), []byte(databaseID)); err != nil {
		_ = created.Close()
		return nil, err
	}
	return &index{dir: dir, Index: created}, nil
}

func newMapping() (*mapping.IndexMappingImpl, error) {
	indexMapping := bleve.NewIndexMapping()
	if err := indexMapping.AddCustomTokenFilter(analyzerNgram, map[string]any{"type": ngram.Name, "min": 2.0, "max": 4.0}); err != nil {
		return nil, err
	}
	analyzers := map[string]map[string]any{
		analyzerNgram:   {"type": custom.Name, "tokenizer": single.Name, "token_filters": []string{lowercase.Name, analyzerNgram}},
		analyzerWords:   {"type": custom.Name, "tokenizer": whitespace.Name, "token_filters": []string{lowercase.Name}},
		analyzerLowered: {"type": custom.Name, "tokenizer": single.Name, "token_filters": []string{lowercase.Name}},
	}
	for name, config := range analyzers {
		if err := indexMapping.AddCustomAnalyzer(name, config); err != nil {
			return nil, err
		}
	}

	text := func(analyzer string) *mapping.FieldMapping {
		field := bleve.NewTextFieldMapping()
		field.Analyzer = analyzer
		field.Store = false
		field.IncludeInAll = false
		field.IncludeTermVectors = false
		field.DocValues = false
		return field
	}
	keyword := func() *mapping.FieldMapping {
		field := bleve.NewKeywordFieldMapping()
		field.Store = false
		field.IncludeInAll = false
		field.IncludeTermVectors = false
		return field
	}
	numeric := bleve.NewNumericFieldMapping()
	numeric.Store = false
	numeric.IncludeInAll = false
	date := bleve.NewDateTimeFieldMapping()
	date.Store = false
	date.IncludeInAll = false
	// The CJK analyzer splits Chinese, Japanese and Korean into overlapping pairs of characters and
	// otherwise behaves like the standard analyzer. Term vectors give the match offsets for snippets.
	content := bleve.NewTextFieldMapping()
	content.Analyzer = cjk.AnalyzerName
	content.Store = false
	content.IncludeInAll = false
	content.IncludeTermVectors = true
	content.DocValues = false
	boolean := bleve.NewBooleanFieldMapping()
	boolean.Store = false
	boolean.IncludeInAll = false

	document := bleve.NewDocumentStaticMapping()
	document.AddFieldMappingsAt(fieldUser, keyword())
	document.AddFieldMappingsAt(fieldPath, keyword())
	document.AddFieldMappingsAt(fieldFolder, text(analyzerLowered))
	document.AddFieldMappingsAt(fieldName, text(analyzerNgram))
	document.AddFieldMappingsAt(fieldWords, text(analyzerWords))
	document.AddFieldMappingsAt(fieldParents, text(analyzerWords))
	document.AddFieldMappingsAt(fieldExt, keyword())
	document.AddFieldMappingsAt(fieldKind, keyword())
	document.AddFieldMappingsAt(fieldMime, keyword())
	document.AddFieldMappingsAt(fieldSubtype, keyword())
	document.AddFieldMappingsAt(fieldIsDir, boolean)
	document.AddFieldMappingsAt(fieldSize, numeric)
	document.AddFieldMappingsAt(fieldMtime, date)
	document.AddFieldMappingsAt(fieldContent, content)
	indexMapping.DefaultMapping = document
	indexMapping.DefaultAnalyzer = analyzerWords
	return indexMapping, nil
}

func documentID(id int64) string { return strconv.FormatInt(id, 10) }

func userTerm(userID int64) string { return strconv.FormatInt(userID, 10) }

func newDocument(entry files.Entry) map[string]any {
	mimeType := entry.Mime
	// Entries indexed before the system MIME database was available still carry the fallback type.
	if mimeType == "" || mimeType == "application/octet-stream" {
		if detected := mime.TypeByExtension("." + extensionOf(entry.Name)); detected != "" {
			mimeType, _, _ = strings.Cut(detected, ";")
		}
	}
	extension, subtype := "", ""
	if entry.IsDir {
		mimeType = ""
	} else {
		extension, subtype = extensionOf(entry.Name), subtypeOf(mimeType)
	}
	return map[string]any{
		fieldUser:    userTerm(entry.UserID),
		fieldPath:    entry.Path,
		fieldFolder:  entry.Path,
		fieldName:    entry.Name,
		fieldWords:   wordsOf(entry.Name),
		fieldParents: wordsOf(parentPath(entry.Path)),
		fieldExt:     extension,
		fieldKind:    kindOf(entry.IsDir, mimeType),
		fieldMime:    mimeType,
		fieldSubtype: subtype,
		fieldIsDir:   entry.IsDir,
		fieldSize:    float64(entry.Size),
		fieldMtime:   entry.Mtime,
	}
}

func wordsOf(text string) string {
	t := newTarget(text)
	words := t.words()
	parts := make([]string, len(words))
	for i, word := range words {
		parts[i] = string(t.lower[word.start:word.end])
	}
	return strings.Join(parts, " ")
}

func (ix *index) cursor(userID int64) (int64, bool) {
	raw, err := ix.GetInternal([]byte(internalCursor + userTerm(userID)))
	if err != nil || raw == nil {
		return 0, false
	}
	cursor, err := strconv.ParseInt(string(raw), 10, 64)
	return cursor, err == nil
}

func setCursor(batch *bleve.Batch, userID, cursor int64) {
	batch.SetInternal([]byte(internalCursor+userTerm(userID)), []byte(strconv.FormatInt(cursor, 10)))
}

const idPageSize = 10000

func (ix *index) matchingIDs(q query.Query) ([]string, error) {
	var ids []string
	for from := 0; ; from += idPageSize {
		request := bleve.NewSearchRequestOptions(q, idPageSize, from, false)
		request.SortBy([]string{"_id"})
		result, err := ix.Search(request)
		if err != nil {
			return nil, err
		}
		for _, hit := range result.Hits {
			ids = append(ids, hit.ID)
		}
		if len(result.Hits) < idPageSize {
			return ids, nil
		}
	}
}

func treeQuery(userID int64, cleanPath string) query.Query {
	exact := bleve.NewTermQuery(cleanPath)
	exact.SetField(fieldPath)
	below := bleve.NewPrefixQuery(strings.TrimSuffix(cleanPath, "/") + "/")
	below.SetField(fieldPath)
	return bleve.NewConjunctionQuery(termQuery(fieldUser, userTerm(userID)), bleve.NewDisjunctionQuery(exact, below))
}

func termQuery(field, value string) *query.TermQuery {
	term := bleve.NewTermQuery(value)
	term.SetField(field)
	return term
}
