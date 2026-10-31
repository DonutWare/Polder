package search

import (
	"reflect"
	"testing"
	"time"
)

func TestParseTags(t *testing.T) {
	now := time.Date(2026, 10, 6, 12, 0, 0, 0, time.Local)
	tests := []struct {
		query    string
		terms    []Term
		filters  []QueryFilter
		warnings int
	}{
		{query: "vacation", terms: []Term{{Text: "vacation"}}, filters: []QueryFilter{}},
		{query: `"Q3 Report"`, terms: []Term{{Text: "q3 report", Exact: true}}, filters: []QueryFilter{}},
		{query: "type=png,jpg", filters: []QueryFilter{{Key: KeyType, Op: OpIs, Values: []string{"png", "jpg"}, Start: 0, End: 12}}},
		{query: "kind:image", filters: []QueryFilter{{Key: KeyType, Op: OpIs, Values: []string{"image"}, Start: 0, End: 10}}},
		{query: "type!=gif,.WEBP", filters: []QueryFilter{{Key: KeyType, Op: OpIsNot, Values: []string{"gif", "webp"}, Start: 0, End: 15}}},
		{query: "-ext:tmp", filters: []QueryFilter{{Key: KeyExt, Op: OpIsNot, Values: []string{"tmp"}, Start: 0, End: 8}}},
		{query: `cat in="/My Photos/"`, terms: []Term{{Text: "cat"}},
			filters: []QueryFilter{{Key: KeyIn, Op: OpIs, Values: []string{"/My Photos"}, Start: 4, End: 20}}},
		{query: "size>10mb", filters: []QueryFilter{{Key: KeySize, Op: OpGreater, Values: []string{"10mb"}, Start: 0, End: 9}}},
		{query: "size=1mb..5mb", filters: []QueryFilter{{Key: KeySize, Op: OpBetween, Values: []string{"1mb", "5mb"}, Start: 0, End: 13}}},
		{query: "modified>=2024-06", filters: []QueryFilter{{Key: KeyModified, Op: OpGreaterEqual, Values: []string{"2024-06"}, Start: 0, End: 17}}},
		{query: "date=7d", filters: []QueryFilter{{Key: KeyModified, Op: OpIs, Values: []string{"7d"}, Start: 0, End: 7}}},
		{query: "type=", filters: []QueryFilter{}},
		{query: "unknown=thing", terms: []Term{{Text: "unknown=thing"}}, filters: []QueryFilter{}},
		{query: "size>huge", filters: []QueryFilter{}, warnings: 1},
		{query: "modified=someday", filters: []QueryFilter{}, warnings: 1},
		{query: "type>png", filters: []QueryFilter{}, warnings: 1},
		{query: "type=application/zip", filters: []QueryFilter{{Key: KeyType, Op: OpIs, Values: []string{"application/zip"}, Start: 0, End: 20}}},
		{query: "ext=application/zip", filters: []QueryFilter{}, warnings: 1},
		{query: "-size>1mb", filters: []QueryFilter{}, warnings: 1},
		{query: "tag=Work,#home", filters: []QueryFilter{{Key: KeyTag, Op: OpIs, Values: []string{"work", "home"}, Start: 0, End: 14}}},
		{query: "#Work -#home", filters: []QueryFilter{{Key: KeyTag, Op: OpIs, Values: []string{"work"}, Start: 0, End: 5},
			{Key: KeyTag, Op: OpIsNot, Values: []string{"home"}, Start: 6, End: 12}}},
		{query: "#123", terms: []Term{{Text: "#123"}}, filters: []QueryFilter{}},
		{query: "tag=has,1", filters: []QueryFilter{}, warnings: 1},
		{query: "ü type=pdf", terms: []Term{{Text: "ü"}}, filters: []QueryFilter{{Key: KeyType, Op: OpIs, Values: []string{"pdf"}, Start: 2, End: 10}}},
	}
	for _, test := range tests {
		parsed := Parse(test.query, now)
		if !reflect.DeepEqual(parsed.Terms, test.terms) || !reflect.DeepEqual(parsed.Filters, test.filters) || len(parsed.Warnings) != test.warnings {
			t.Errorf("Parse(%q) = terms %+v filters %+v warnings %+v", test.query, parsed.Terms, parsed.Filters, parsed.Warnings)
		}
	}
}

func TestTimeRanges(t *testing.T) {
	now := time.Date(2026, 10, 6, 12, 0, 0, 0, time.Local)
	june := time.Date(2024, 6, 1, 0, 0, 0, 0, time.Local)
	july := time.Date(2024, 7, 1, 0, 0, 0, 0, time.Local)
	weekAgo := now.AddDate(0, 0, -7)
	tests := []struct {
		query    string
		from, to *time.Time
		exclude  bool
	}{
		{query: "modified=2024-06", from: &june, to: &july},
		{query: "modified>2024-06", from: &july},
		{query: "modified>=2024-06", from: &june},
		{query: "modified<2024-06", to: &june},
		{query: "modified<=2024-06", to: &july},
		{query: "modified!=2024-06", from: &june, to: &july, exclude: true},
		{query: "modified>7d", from: &weekAgo},
		{query: "modified<7d", to: &weekAgo},
	}
	for _, test := range tests {
		parsed := Parse(test.query, now)
		got := parsed.timeRange(parsed.Filters[0])
		if !sameTime(got.from, test.from) || !sameTime(got.to, test.to) || got.exclude != test.exclude {
			t.Errorf("%s: got %v..%v exclude=%v", test.query, got.from, got.to, got.exclude)
		}
	}
}

func sameTime(a, b *time.Time) bool {
	if a == nil || b == nil {
		return a == b
	}
	return a.Equal(*b)
}

func TestParseSize(t *testing.T) {
	for input, want := range map[string]int64{"500": 500, "1kb": 1024, "10mb": 10 << 20, "1.5gb": 3 << 29, "2T": 2 << 40} {
		if got, err := parseSize(input); err != nil || got != want {
			t.Errorf("parseSize(%q) = %d, %v; want %d", input, got, err, want)
		}
	}
}

func TestKindOf(t *testing.T) {
	if kindOf(false, "image/heic") != "image" || kindOf(false, "application/pdf") != "application" || kindOf(true, "") != kindFolder {
		t.Error("kind should be the top-level MIME type, or folder for directories")
	}
}
