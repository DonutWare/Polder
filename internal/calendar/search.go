package calendar

import (
	"context"
	"slices"
	"strconv"
	"strings"
	"time"

	"github.com/emersion/go-ical"

	"polder-server/internal/search"
	"polder-server/internal/users"
)

const MaxSearchLimit = 200

type EventMatch struct {
	Event          Event             `json:"event"`
	Upcoming       bool              `json:"upcoming" doc:"Whether the shown occurrence has not ended yet; a repeating event shows its next occurrence, or its last one when the series is over"`
	SummaryMatches []search.TextSpan `json:"summaryMatches" doc:"Ranges of the summary that matched the query, in UTF-16 code units"`
	titleMatched   bool
}

type EventResults struct {
	Query   string       `json:"query"`
	Total   int          `json:"total"`
	Results []EventMatch `json:"results"`
}

func (s *Service) SearchEvents(ctx context.Context, viewer users.User, raw string, limit, offset int) (EventResults, error) {
	limit = min(max(limit, 1), MaxSearchLimit)
	offset = max(offset, 0)
	parsed := search.Parse(raw, s.now())
	response := EventResults{Query: raw, Results: []EventMatch{}}
	if parsed.IsEmpty() || !parsed.WantsEvents() {
		return response, nil
	}
	calendars, err := s.List(ctx, viewer)
	if err != nil {
		return EventResults{}, err
	}
	own := addressesOf(viewer)
	var matches []EventMatch
	for _, c := range calendars {
		if !searchable(c, parsed) {
			continue
		}
		found, err := s.searchCalendar(ctx, c, own, parsed)
		if err != nil {
			return EventResults{}, err
		}
		matches = append(matches, found...)
	}
	sortMatches(matches)
	response.Total = len(matches)
	response.Results = append(response.Results, matches[min(offset, len(matches)):min(offset+limit, len(matches))]...)
	return response, nil
}

func searchable(c Calendar, parsed search.Query) bool {
	if !c.Access.CanReadEvents() {
		return false
	}
	filters := parsed.FiltersFor(search.KeyCalendar)
	named := false
	for _, filter := range filters {
		matches := slices.ContainsFunc(filter.Values, func(value string) bool { return calendarNamed(c, value) })
		if filter.Op == search.OpIsNot && matches || filter.Op == search.OpIs && !matches {
			return false
		}
		named = named || filter.Op == search.OpIs
	}
	return named || !c.Hidden
}

func calendarNamed(c Calendar, value string) bool {
	return strings.EqualFold(c.Name, value) || strconv.FormatInt(c.ID, 10) == value
}

func (s *Service) searchCalendar(ctx context.Context, c Calendar, own addressSet, parsed search.Query) ([]EventMatch, error) {
	objects, err := s.store.Objects(ctx, c.ID)
	if err != nil {
		return nil, err
	}
	var matches []EventMatch
	for _, object := range objects {
		resource, err := Parse(object.Data, c.Location())
		if err != nil || !repeatsMatch(resource, parsed) {
			continue
		}
		if match, ok := matchResource(c, object, resource, own, parsed); ok {
			matches = append(matches, match)
		}
	}
	return matches, nil
}

func repeatsMatch(resource *Resource, parsed search.Query) bool {
	frequency := ""
	if resource.Recurring() && resource.Master != nil {
		frequency = ruleFrequency(resource.Master)
	}
	for _, filter := range parsed.FiltersFor(search.KeyRepeats) {
		matches := slices.ContainsFunc(filter.Values, func(value string) bool { return repeatMatches(value, resource.Recurring(), frequency) })
		if filter.Op == search.OpIsNot && matches || filter.Op == search.OpIs && !matches {
			return false
		}
	}
	return true
}

func repeatMatches(value string, recurring bool, frequency string) bool {
	switch value {
	case "yes":
		return recurring
	case "no":
		return !recurring
	}
	return recurring && frequency == value
}

func ruleFrequency(component *ical.Component) string {
	rule := component.Props.Get(ical.PropRecurrenceRule)
	if rule == nil {
		return ""
	}
	for part := range strings.SplitSeq(rule.Value, ";") {
		if name, value, ok := strings.Cut(part, "="); ok && strings.EqualFold(name, "FREQ") {
			return strings.ToLower(value)
		}
	}
	return ""
}

type componentMatch struct {
	match search.FieldMatch
	ok    bool
}

func matchResource(c Calendar, object Object, resource *Resource, own addressSet, parsed search.Query) (EventMatch, bool) {
	matched := map[*ical.Component]componentMatch{}
	matchOf := func(component *ical.Component) componentMatch {
		if found, done := matched[component]; done {
			return found
		}
		found := componentMatch{match: search.FieldMatch{TitleSpans: []search.TextSpan{}}, ok: true}
		if parsed.HasTerms() {
			found.match, found.ok = search.MatchFields(parsed.Terms, propText(component, ical.PropSummary),
				propText(component, ical.PropLocation), strings.Join(categories(component), " "), propText(component, ical.PropDescription))
		}
		matched[component] = found
		return found
	}
	candidates := []*ical.Component{}
	if resource.Master != nil {
		candidates = append(candidates, resource.Master)
	}
	candidates = append(candidates, resource.Overrides...)
	if !slices.ContainsFunc(candidates, func(component *ical.Component) bool { return matchOf(component).ok }) {
		return EventMatch{}, false
	}
	occurrence, upcoming, found := chooseOccurrence(resource, parsed, func(o Occurrence) bool { return matchOf(o.Component).ok })
	if !found {
		return EventMatch{}, false
	}
	chosen := matchOf(occurrence.Component).match
	return EventMatch{
		Event:          describeOccurrence(c, object, resource, occurrence, own),
		Upcoming:       upcoming,
		SummaryMatches: chosen.TitleSpans,
		titleMatched:   chosen.TitleMatched,
	}, true
}

func chooseOccurrence(resource *Resource, parsed search.Query, wanted func(Occurrence) bool) (Occurrence, bool, bool) {
	now := parsed.Now()
	whens := parsed.FiltersFor(search.KeyWhen)
	if len(whens) == 0 {
		if occurrence, ok := nextOccurrence(resource, now, wanted); ok {
			return occurrence, true, true
		}
		occurrence, ok := lastOccurrence(resource, now, wanted)
		return occurrence, false, ok
	}
	for _, filter := range whens {
		for _, value := range filter.Values {
			if occurrence, ok := occurrenceWhen(resource, parsed, value, wanted); ok {
				return occurrence, occurrence.End.After(now) || !occurrence.Start.Before(now), true
			}
		}
	}
	return Occurrence{}, false, false
}

func occurrenceWhen(resource *Resource, parsed search.Query, value string, wanted func(Occurrence) bool) (Occurrence, bool) {
	now := parsed.Now()
	switch value {
	case "upcoming":
		return nextOccurrence(resource, now, wanted)
	case "past":
		return lastOccurrence(resource, now, wanted)
	}
	period, ok := parsed.WhenPeriod(value)
	if !ok {
		return Occurrence{}, false
	}
	if period.End.After(now) {
		return firstOccurrence(resource, period.Start, period.End, wanted)
	}
	return lastOccurrence(resource, period.End, func(o Occurrence) bool { return o.End.After(period.Start) && wanted(o) })
}

func nextOccurrence(resource *Resource, now time.Time, wanted func(Occurrence) bool) (Occurrence, bool) {
	if occurrence, ok := firstOccurrence(resource, now, now.Add(MaxWindow), wanted); ok {
		return occurrence, true
	}
	return firstOccurrence(resource, now.Add(MaxWindow), time.Time{}, wanted)
}

func firstOccurrence(resource *Resource, from, to time.Time, wanted func(Occurrence) bool) (Occurrence, bool) {
	occurrences, err := resource.Occurrences(from, to)
	if err != nil {
		return Occurrence{}, false
	}
	for _, occurrence := range occurrences {
		if wanted(occurrence) {
			return occurrence, true
		}
	}
	return Occurrence{}, false
}

func lastOccurrence(resource *Resource, before time.Time, wanted func(Occurrence) bool) (Occurrence, bool) {
	occurrences, err := resource.Occurrences(time.Time{}, before)
	if err != nil {
		return Occurrence{}, false
	}
	for i := len(occurrences) - 1; i >= 0; i-- {
		if wanted(occurrences[i]) {
			return occurrences[i], true
		}
	}
	return Occurrence{}, false
}

func sortMatches(matches []EventMatch) {
	slices.SortStableFunc(matches, func(a, b EventMatch) int {
		if a.titleMatched != b.titleMatched {
			if a.titleMatched {
				return -1
			}
			return 1
		}
		if a.Upcoming != b.Upcoming {
			if a.Upcoming {
				return -1
			}
			return 1
		}
		if a.Upcoming {
			return a.Event.Start.Compare(b.Event.Start)
		}
		return b.Event.Start.Compare(a.Event.Start)
	})
}

func (s *Service) CalendarNames(ctx context.Context, viewer users.User) ([]string, error) {
	calendars, err := s.List(ctx, viewer)
	if err != nil {
		return nil, err
	}
	names := []string{}
	for _, c := range calendars {
		if c.Access.CanReadEvents() {
			names = append(names, c.Name)
		}
	}
	return names, nil
}
