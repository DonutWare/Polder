package search

import (
	"reflect"
	"testing"
)

func terms(texts ...string) []Term {
	result := make([]Term, len(texts))
	for i, text := range texts {
		result[i] = Term{Text: text}
	}
	return result
}

func TestRankEntryMatches(t *testing.T) {
	tests := []struct {
		query []Term
		name  string
		path  string
		spans []TextSpan
	}{
		{query: terms("voice"), name: "invoice_q3.pdf", path: "/invoice_q3.pdf", spans: []TextSpan{{2, 7}}},
		{query: terms("invq3"), name: "invoice_q3.pdf", path: "/invoice_q3.pdf", spans: []TextSpan{{0, 3}, {8, 10}}},
		{query: terms("recipt"), name: "receipt.pdf", path: "/receipt.pdf", spans: []TextSpan{{0, 7}}},
		{query: terms("mbp"), name: "MacBookPro.png", path: "/MacBookPro.png", spans: []TextSpan{{0, 1}, {3, 4}, {7, 8}}},
		{query: terms("recieved"), name: "received.pdf", path: "/received.pdf", spans: []TextSpan{{0, 8}}}, //nolint:misspell
		{query: terms("invocie"), name: "invoice.pdf", path: "/invoice.pdf", spans: []TextSpan{{0, 7}}},
		{query: terms("photos", "cat"), name: "cat.jpg", path: "/Photos/cat.jpg", spans: []TextSpan{{0, 3}}},
		{query: terms("😀b"), name: "a😀b.txt", path: "/a😀b.txt", spans: []TextSpan{{1, 4}}},
		{query: terms("brievl"), name: "brieven.txt", path: "/brieven.txt", spans: []TextSpan{{0, 7}}},
	}
	for _, test := range tests {
		found, ok := rankEntry(test.query, test.name, test.path)
		if !ok || !reflect.DeepEqual(found.spans, test.spans) {
			t.Errorf("rankEntry(%v, %q) = %+v, %v; want spans %+v", test.query, test.name, found, ok, test.spans)
		}
	}
}

func TestRankEntryRejects(t *testing.T) {
	for _, test := range []struct {
		query []Term
		name  string
	}{
		{terms("zebra"), "invoice.pdf"},
		{terms("cat", "dog"), "cat.jpg"},
		{terms("rabo"), "Renteaanbod - SVn.pdf"},
		{terms("beheer"), "koper De heer J. Knaapen.pdf"},
		{[]Term{{Text: "invq3", Exact: true}}, "invoice_q3.pdf"},
		{terms("brel"), "brieven.txt"},
	} {
		if found, ok := rankEntry(test.query, test.name, "/"+test.name); ok {
			t.Errorf("rankEntry(%v, %q) matched with %+v", test.query, test.name, found)
		}
	}
}

func TestRankingPrefersCloserMatches(t *testing.T) {
	score := func(query, name string) float64 {
		found, ok := rankEntry(terms(query), name, "/"+name)
		if !ok {
			t.Fatalf("%q should match %q", query, name)
		}
		return found.score
	}
	if score("report", "report.pdf") <= score("report", "annual_reporting_draft_v2.pdf") {
		t.Error("exact name should outrank a longer name")
	}
	if score("rep", "report.pdf") <= score("rep", "prepare.txt") {
		t.Error("word start should outrank a match inside a word")
	}
	if score("invoice", "invoice.pdf") <= score("invoce", "invoice.pdf") {
		t.Error("exact should outrank a typo")
	}
}
