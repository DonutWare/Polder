package search

import (
	"fmt"
	"math"
	"path"
	"regexp"
	"strconv"
	"strings"
	"time"
	"unicode"
	"unicode/utf16"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/tags"
)

type Op string

const (
	OpIs           Op = "is"
	OpIsNot        Op = "isNot"
	OpGreater      Op = "gt"
	OpGreaterEqual Op = "gte"
	OpLess         Op = "lt"
	OpLessEqual    Op = "lte"
	OpBetween      Op = "between"
)

func (Op) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(OpIs), string(OpIsNot), string(OpGreater), string(OpGreaterEqual), string(OpLess), string(OpLessEqual), string(OpBetween)}
	return s
}

type Key string

const (
	KeyType     Key = "type"
	KeyExt      Key = "ext"
	KeyIn       Key = "in"
	KeyModified Key = "modified"
	KeySize     Key = "size"
	KeyTag      Key = "tag"
)

func (Key) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(KeyType), string(KeyExt), string(KeyIn), string(KeyModified), string(KeySize), string(KeyTag)}
	return s
}

var Keys = []Key{KeyType, KeyExt, KeyIn, KeyModified, KeySize, KeyTag}

var keyAliases = map[string]Key{
	"type": KeyType, "kind": KeyType, "is": KeyType,
	"ext": KeyExt, "extension": KeyExt,
	"in": KeyIn, "folder": KeyIn, "path": KeyIn,
	"modified": KeyModified, "date": KeyModified, "mtime": KeyModified,
	"size": KeySize,
	"tag":  KeyTag, "tags": KeyTag,
}

// Longest operators first so "!=" is not read as "!" followed by "=".
var operators = []struct {
	text string
	op   Op
}{{"!=", OpIsNot}, {">=", OpGreaterEqual}, {"<=", OpLessEqual}, {":", OpIs}, {"=", OpIs}, {">", OpGreater}, {"<", OpLess}}

// Offsets in QueryFilter and QueryWarning count UTF-16 code units, which is what the clients index strings by.
type QueryFilter struct {
	Key    Key      `json:"key"`
	Op     Op       `json:"op"`
	Values []string `json:"values"`
	Start  int      `json:"start"`
	End    int      `json:"end"`
}

type QueryWarning struct {
	Start   int    `json:"start"`
	End     int    `json:"end"`
	Message string `json:"message"`
}

type Term struct {
	Text  string
	Exact bool
}

type Query struct {
	Terms    []Term
	Filters  []QueryFilter
	Warnings []QueryWarning
	now      time.Time
}

type token struct {
	text       string
	start, end int
}

func Parse(raw string, now time.Time) Query {
	query := Query{Filters: []QueryFilter{}, Warnings: []QueryWarning{}, now: now}
	for _, tok := range tokenize(raw) {
		if filter, isFilter, problem := parseFilter(tok, now); isFilter {
			if problem != "" {
				query.Warnings = append(query.Warnings, QueryWarning{Start: tok.start, End: tok.end, Message: problem})
			} else if filter != nil {
				query.Filters = append(query.Filters, *filter)
			}
			continue
		}
		text, quoted := unquote(tok.text)
		text = strings.ToLower(strings.TrimSpace(text))
		if text != "" {
			query.Terms = append(query.Terms, Term{Text: text, Exact: quoted})
		}
	}
	return query
}

func (q Query) HasTerms() bool { return len(q.Terms) > 0 }

func tokenize(raw string) []token {
	var tokens []token
	var current []rune
	start, offset := 0, 0
	inQuotes := false
	flush := func() {
		if len(current) > 0 {
			tokens = append(tokens, token{text: string(current), start: start, end: offset})
			current = current[:0]
		}
	}
	for _, r := range raw {
		width := utf16.RuneLen(r)
		if unicode.IsSpace(r) && !inQuotes {
			flush()
			offset += width
			start = offset
			continue
		}
		if r == '"' {
			inQuotes = !inQuotes
		}
		current = append(current, r)
		offset += width
	}
	flush()
	return tokens
}

func parseFilter(tok token, now time.Time) (*QueryFilter, bool, string) {
	text := tok.text
	negated := strings.HasPrefix(text, "-")
	if negated {
		text = text[1:]
	}
	if strings.HasPrefix(text, "#") {
		return parseHashTag(tok, text[1:], negated)
	}
	keyEnd := 0
	for keyEnd < len(text) && (text[keyEnd] >= 'a' && text[keyEnd] <= 'z' || text[keyEnd] >= 'A' && text[keyEnd] <= 'Z') {
		keyEnd++
	}
	key, known := keyAliases[strings.ToLower(text[:keyEnd])]
	if !known {
		return nil, false, ""
	}
	rest := text[keyEnd:]
	var op Op
	for _, candidate := range operators {
		if strings.HasPrefix(rest, candidate.text) {
			op, rest = candidate.op, rest[len(candidate.text):]
			break
		}
	}
	if op == "" {
		return nil, false, ""
	}
	if negated {
		if op != OpIs {
			return nil, true, "use either - or != to exclude, with = or :"
		}
		op = OpIsNot
	}
	values := splitValues(rest)
	if len(values) == 0 {
		return nil, true, ""
	}
	filter := QueryFilter{Key: key, Op: op, Start: tok.start, End: tok.end}
	if problem := normalize(&filter, values, now); problem != "" {
		return nil, true, problem
	}
	return &filter, true, ""
}

func parseHashTag(tok token, name string, negated bool) (*QueryFilter, bool, string) {
	if !tags.ValidName(name) {
		return nil, false, ""
	}
	op := OpIs
	if negated {
		op = OpIsNot
	}
	return &QueryFilter{Key: KeyTag, Op: op, Values: []string{tags.Key(name)}, Start: tok.start, End: tok.end}, true, ""
}

func splitValues(raw string) []string {
	var values []string
	var current strings.Builder
	inQuotes := false
	push := func() {
		if value := strings.TrimSpace(current.String()); value != "" {
			values = append(values, value)
		}
		current.Reset()
	}
	for _, r := range raw {
		switch {
		case r == '"':
			inQuotes = !inQuotes
		case r == ',' && !inQuotes:
			push()
		default:
			current.WriteRune(r)
		}
	}
	push()
	return values
}

func unquote(text string) (string, bool) {
	if len(text) >= 2 && strings.HasPrefix(text, `"`) && strings.HasSuffix(text, `"`) {
		return text[1 : len(text)-1], true
	}
	return strings.ReplaceAll(text, `"`, ""), false
}

// A type value is a kind, an extension, a MIME subtype or a whole MIME type such as application/pdf.
var typePattern = regexp.MustCompile(`^[a-z0-9_+.-]+(/[a-z0-9_+.-]+)?$`)

func normalize(filter *QueryFilter, values []string, now time.Time) string {
	equality := filter.Op == OpIs || filter.Op == OpIsNot
	switch filter.Key {
	case KeyType, KeyExt:
		if !equality {
			return fmt.Sprintf("%s only supports = and !=", filter.Key)
		}
		for _, value := range values {
			value = strings.TrimPrefix(strings.ToLower(value), ".")
			if !typePattern.MatchString(value) || filter.Key == KeyExt && strings.Contains(value, "/") {
				return fmt.Sprintf("%q is not a type or extension", value)
			}
			filter.Values = append(filter.Values, value)
		}
	case KeyIn:
		if !equality {
			return "in only supports = and !="
		}
		for _, value := range values {
			filter.Values = append(filter.Values, cleanFolder(value))
		}
	case KeyTag:
		if !equality {
			return "tag only supports = and !="
		}
		for _, value := range values {
			name := strings.TrimPrefix(value, "#")
			if !tags.ValidName(name) {
				return fmt.Sprintf("%q is not a tag name", value)
			}
			filter.Values = append(filter.Values, tags.Key(name))
		}
	case KeyModified, KeySize:
		parse := func(value string) error {
			if filter.Key == KeySize {
				_, err := parseSize(value)
				return err
			}
			_, err := parseDate(value, now)
			return err
		}
		if len(values) == 1 && strings.Contains(values[0], "..") {
			if filter.Op != OpIs {
				return "a range needs =, such as " + string(filter.Key) + "=a..b"
			}
			low, high, _ := strings.Cut(values[0], "..")
			values = []string{low, high}
			filter.Op = OpBetween
		} else if len(values) > 1 {
			return fmt.Sprintf("%s takes one value or a range a..b", filter.Key)
		}
		for _, value := range values {
			value = strings.ToLower(value)
			if err := parse(value); err != nil {
				return err.Error()
			}
			filter.Values = append(filter.Values, value)
		}
	}
	return ""
}

func cleanFolder(value string) string {
	return path.Clean("/" + strings.Trim(value, "/"))
}

var sizeUnits = map[string]float64{"": 1, "b": 1, "k": 1 << 10, "kb": 1 << 10, "m": 1 << 20, "mb": 1 << 20,
	"g": 1 << 30, "gb": 1 << 30, "t": 1 << 40, "tb": 1 << 40}

var sizePattern = regexp.MustCompile(`^(\d+(?:\.\d+)?)([a-z]*)$`)

func parseSize(value string) (int64, error) {
	match := sizePattern.FindStringSubmatch(strings.ToLower(value))
	if match == nil {
		return 0, fmt.Errorf("%q is not a size, try 10mb or 500kb", value)
	}
	unit, ok := sizeUnits[match[2]]
	if !ok {
		return 0, fmt.Errorf("unknown size unit %q, use kb, mb, gb or tb", match[2])
	}
	number, _ := strconv.ParseFloat(match[1], 64)
	return int64(math.Round(number * unit)), nil
}

type period struct {
	start, end time.Time
	relative   bool
}

var relativePattern = regexp.MustCompile(`^(\d+)([dwmy])$`)

func parseDate(value string, now time.Time) (period, error) {
	local := now.In(time.Local)
	today := time.Date(local.Year(), local.Month(), local.Day(), 0, 0, 0, 0, time.Local)
	switch value {
	case "today":
		return period{start: today, end: today.AddDate(0, 0, 1)}, nil
	case "yesterday":
		return period{start: today.AddDate(0, 0, -1), end: today}, nil
	}
	if match := relativePattern.FindStringSubmatch(value); match != nil {
		amount, _ := strconv.Atoi(match[1])
		var since time.Time
		switch match[2] {
		case "d":
			since = local.AddDate(0, 0, -amount)
		case "w":
			since = local.AddDate(0, 0, -7*amount)
		case "m":
			since = local.AddDate(0, -amount, 0)
		case "y":
			since = local.AddDate(-amount, 0, 0)
		}
		return period{start: since, end: local, relative: true}, nil
	}
	for _, layout := range []struct {
		format string
		step   func(time.Time) time.Time
	}{
		{"2006-01-02", func(t time.Time) time.Time { return t.AddDate(0, 0, 1) }},
		{"2006-01", func(t time.Time) time.Time { return t.AddDate(0, 1, 0) }},
		{"2006", func(t time.Time) time.Time { return t.AddDate(1, 0, 0) }},
	} {
		if start, err := time.ParseInLocation(layout.format, value, time.Local); err == nil {
			return period{start: start, end: layout.step(start)}, nil
		}
	}
	return period{}, fmt.Errorf("%q is not a date, try 2024-06-15, 2024-06, 2024, today or 7d", value)
}

type timeRange struct {
	from, to *time.Time
	exclude  bool
}

// timeRange turns a modified filter into a half-open range [from, to). A relative value such as 7d is a
// moment: modified>7d is newer than a week ago, modified<7d is older, and modified=7d is within the week.
func (q Query) timeRange(filter QueryFilter) timeRange {
	first, _ := parseDate(filter.Values[0], q.now)
	switch filter.Op {
	case OpBetween:
		last, _ := parseDate(filter.Values[1], q.now)
		return timeRange{from: &first.start, to: &last.end}
	case OpGreater:
		if first.relative {
			return timeRange{from: &first.start}
		}
		return timeRange{from: &first.end}
	case OpGreaterEqual:
		return timeRange{from: &first.start}
	case OpLess, OpLessEqual:
		if first.relative || filter.Op == OpLess {
			return timeRange{to: &first.start}
		}
		return timeRange{to: &first.end}
	case OpIsNot:
		return timeRange{from: &first.start, to: &first.end, exclude: true}
	}
	return timeRange{from: &first.start, to: &first.end}
}

type sizeRange struct {
	min, max                   *float64
	minInclusive, maxInclusive bool
	exclude                    bool
}

func (q Query) sizeRange(filter QueryFilter) sizeRange {
	first, _ := parseSize(filter.Values[0])
	low := float64(first)
	switch filter.Op {
	case OpBetween:
		last, _ := parseSize(filter.Values[1])
		high := float64(last)
		return sizeRange{min: &low, max: &high, minInclusive: true, maxInclusive: true}
	case OpGreater:
		return sizeRange{min: &low}
	case OpGreaterEqual:
		return sizeRange{min: &low, minInclusive: true}
	case OpLess:
		return sizeRange{max: &low}
	case OpLessEqual:
		return sizeRange{max: &low, maxInclusive: true}
	case OpIsNot:
		return sizeRange{min: &low, max: &low, minInclusive: true, maxInclusive: true, exclude: true}
	}
	return sizeRange{min: &low, max: &low, minInclusive: true, maxInclusive: true}
}
