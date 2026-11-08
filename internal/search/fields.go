package search

type FieldMatch struct {
	Score        float64
	TitleSpans   []TextSpan
	TitleMatched bool
}

func MatchFields(terms []Term, title string, others ...string) (FieldMatch, bool) {
	titleTarget := newTarget(title)
	var otherTargets []target
	result := FieldMatch{TitleSpans: []TextSpan{}}
	var spans []runeSpan
	for _, term := range terms {
		runes := []rune(term.Text)
		if found, ok := matchTerm(runes, titleTarget, term.Exact); ok {
			result.Score += found.score
			spans = append(spans, found.spans...)
			result.TitleMatched = true
			continue
		}
		if otherTargets == nil {
			otherTargets = make([]target, 0, len(others))
			for _, other := range others {
				otherTargets = append(otherTargets, newTarget(other))
			}
		}
		found, ok := matchInAny(runes, otherTargets)
		if !ok {
			return FieldMatch{}, false
		}
		result.Score += found.score * 0.4
	}
	result.TitleSpans = titleTarget.utf16Spans(mergeSpans(spans))
	return result, true
}

func matchInAny(term []rune, targets []target) (termMatch, bool) {
	for _, candidate := range targets {
		if found, ok := matchSubstring(term, candidate); ok {
			return found, true
		}
	}
	return termMatch{}, false
}
