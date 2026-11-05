package calendar

import (
	"strings"
	"time"

	"github.com/emersion/go-ical"
)

const (
	CollationOctet          = "i;octet"
	CollationASCIICasemap   = "i;ascii-casemap"
	CollationUnicodeCasemap = "i;unicode-casemap"
)

type TimeRange struct {
	Start time.Time
	End   time.Time
}

type TextMatch struct {
	Text      string
	Collation string
	Negate    bool
}

type ParamFilter struct {
	Name         string
	IsNotDefined bool
	TextMatch    *TextMatch
}

type PropFilter struct {
	Name         string
	IsNotDefined bool
	TimeRange    *TimeRange
	TextMatch    *TextMatch
	Params       []ParamFilter
}

type CompFilter struct {
	Name         string
	IsNotDefined bool
	TimeRange    *TimeRange
	Props        []PropFilter
	Comps        []CompFilter
}

func SupportedCollation(collation string) bool {
	switch collation {
	case "", CollationOctet, CollationASCIICasemap, CollationUnicodeCasemap:
		return true
	}
	return false
}

func (f CompFilter) EventRange() *TimeRange {
	for _, child := range f.Comps {
		if child.Name == ical.CompEvent && !child.IsNotDefined {
			return child.TimeRange
		}
	}
	return nil
}

func (r *Resource) Matches(filter CompFilter) (bool, error) {
	if !strings.EqualFold(filter.Name, ical.CompCalendar) {
		return false, nil
	}
	if filter.IsNotDefined {
		return false, nil
	}
	return r.matchComponent(r.cal.Component, filter, nil)
}

func (r *Resource) matchComponent(component *ical.Component, filter CompFilter, parent *ical.Component) (bool, error) {
	if filter.TimeRange != nil {
		inRange, err := r.componentInRange(component, *filter.TimeRange, parent)
		if err != nil || !inRange {
			return false, err
		}
	}
	for _, propFilter := range filter.Props {
		matched, err := r.matchProps(component, propFilter)
		if err != nil || !matched {
			return false, err
		}
	}
	for _, child := range filter.Comps {
		matched, err := r.matchChildren(component, child)
		if err != nil || !matched {
			return false, err
		}
	}
	return true, nil
}

func (r *Resource) matchChildren(component *ical.Component, filter CompFilter) (bool, error) {
	var candidates []*ical.Component
	for _, child := range component.Children {
		if strings.EqualFold(child.Name, filter.Name) {
			candidates = append(candidates, child)
		}
	}
	if filter.IsNotDefined {
		return len(candidates) == 0, nil
	}
	for _, candidate := range candidates {
		matched, err := r.matchComponent(candidate, filter, component)
		if err != nil || matched {
			return matched, err
		}
	}
	return false, nil
}

func (r *Resource) componentInRange(component *ical.Component, window TimeRange, parent *ical.Component) (bool, error) {
	switch component.Name {
	case ical.CompEvent:
		occurrences, err := r.Occurrences(window.Start, window.End)
		return len(occurrences) > 0, err
	case ical.CompAlarm:
		triggers, err := r.TriggersBetween(openStart(window.Start), openEnd(window.End))
		if err != nil {
			return false, err
		}
		for _, trigger := range triggers {
			if trigger.Alarm == component && (parent == nil || trigger.Occurrence.Component == parent) {
				return true, nil
			}
		}
	}
	return false, nil
}

func openStart(value time.Time) time.Time {
	if value.IsZero() {
		return time.Unix(0, 0)
	}
	return value
}

func openEnd(value time.Time) time.Time {
	if value.IsZero() {
		return time.Date(9999, time.January, 1, 0, 0, 0, 0, time.UTC)
	}
	return value
}

func (r *Resource) matchProps(component *ical.Component, filter PropFilter) (bool, error) {
	props := component.Props.Values(strings.ToUpper(filter.Name))
	if filter.IsNotDefined {
		return len(props) == 0, nil
	}
	for i := range props {
		if r.matchProp(&props[i], filter) {
			return true, nil
		}
	}
	return false, nil
}

func (r *Resource) matchProp(prop *ical.Prop, filter PropFilter) bool {
	if filter.TimeRange != nil {
		value, err := r.zones.dateTime(prop)
		if err != nil || !overlaps(value.Time, value.Time, filter.TimeRange.Start, filter.TimeRange.End) {
			return false
		}
	}
	if filter.TextMatch != nil && !filter.TextMatch.Matches(propValueText(prop)) {
		return false
	}
	for _, paramFilter := range filter.Params {
		if !matchParam(prop, paramFilter) {
			return false
		}
	}
	return true
}

func matchParam(prop *ical.Prop, filter ParamFilter) bool {
	values := prop.Params.Values(strings.ToUpper(filter.Name))
	if filter.IsNotDefined {
		return len(values) == 0
	}
	if len(values) == 0 {
		return false
	}
	if filter.TextMatch == nil {
		return true
	}
	for _, value := range values {
		if filter.TextMatch.Matches(value) {
			return true
		}
	}
	return false
}

func propValueText(prop *ical.Prop) string {
	if text, err := prop.Text(); err == nil {
		return text
	}
	return prop.Value
}

func (m TextMatch) Matches(value string) bool {
	var found bool
	switch m.Collation {
	case CollationOctet:
		found = strings.Contains(value, m.Text)
	case CollationUnicodeCasemap:
		found = strings.Contains(strings.ToLower(value), strings.ToLower(m.Text))
	default:
		found = strings.Contains(asciiLower(value), asciiLower(m.Text))
	}
	return found != m.Negate
}

func asciiLower(value string) string {
	return strings.Map(func(r rune) rune {
		if r >= 'A' && r <= 'Z' {
			return r + ('a' - 'A')
		}
		return r
	}, value)
}
