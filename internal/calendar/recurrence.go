package calendar

import (
	"slices"
	"time"

	"github.com/emersion/go-ical"
	"github.com/teambition/rrule-go"
)

const (
	maxExpandedInstances = 20000
	maxIteratedInstances = 1000000
)

type Occurrence struct {
	Start        time.Time
	End          time.Time
	AllDay       bool
	RecurrenceID string
	Component    *ical.Component
	Override     bool
}

type Bounds struct {
	FirstStart time.Time
	LastEnd    *time.Time
}

type eventTiming struct {
	start    dateTime
	duration time.Duration
}

func (r *Resource) timing(event *ical.Component) (eventTiming, error) {
	start, err := r.zones.dateTime(event.Props.Get(ical.PropDateTimeStart))
	if err != nil {
		return eventTiming{}, err
	}
	timing := eventTiming{start: start}
	switch {
	case event.Props.Get(ical.PropDateTimeEnd) != nil:
		end, err := r.zones.dateTime(event.Props.Get(ical.PropDateTimeEnd))
		if err != nil {
			return eventTiming{}, err
		}
		timing.duration = end.Time.Sub(start.Time)
	case event.Props.Get(ical.PropDuration) != nil:
		duration, err := parseDuration(event.Props.Get(ical.PropDuration).Value)
		if err != nil {
			return eventTiming{}, err
		}
		timing.duration = duration
	case start.AllDay:
		timing.duration = 24 * time.Hour
	}
	return timing, nil
}

type instances struct {
	next      func() (time.Time, bool)
	durations map[int64]time.Duration
	bounded   bool
}

func (r *Resource) instances(timing eventTiming) (instances, error) {
	set := &rrule.Set{}
	set.RDate(timing.start.Time)
	result := instances{durations: map[int64]time.Duration{}, bounded: true}
	if rule := r.Master.Props.Get(ical.PropRecurrenceRule); rule != nil {
		options, err := ruleOptions(rule.Value, timing.start)
		if err != nil {
			return instances{}, err
		}
		compiled, err := rrule.NewRRule(*options)
		if err != nil {
			return instances{}, invalidData("RRULE %q cannot be used: %v", rule.Value, err)
		}
		set.RRule(compiled)
		result.bounded = options.Count > 0 || !options.Until.IsZero()
	}
	if err := r.addDates(set, result.durations); err != nil {
		return instances{}, err
	}
	result.next = set.Iterator()
	return result, nil
}

func (r *Resource) addDates(set *rrule.Set, durations map[int64]time.Duration) error {
	for i := range r.Master.Props[ical.PropRecurrenceDates] {
		periods, err := r.zones.dateTimeList(&r.Master.Props[ical.PropRecurrenceDates][i])
		if err != nil {
			return err
		}
		for _, entry := range periods {
			set.RDate(entry.Start.Time)
			if entry.HasEnd {
				durations[entry.Start.Time.Unix()] = entry.Duration
			}
		}
	}
	for i := range r.Master.Props[ical.PropExceptionDates] {
		periods, err := r.zones.dateTimeList(&r.Master.Props[ical.PropExceptionDates][i])
		if err != nil {
			return err
		}
		for _, entry := range periods {
			set.ExDate(entry.Start.Time)
		}
	}
	return nil
}

func (r *Resource) overridesByInstance() (map[int64]*ical.Component, error) {
	byInstance := make(map[int64]*ical.Component, len(r.Overrides))
	for _, override := range r.Overrides {
		recurrenceID, err := r.zones.dateTime(override.Props.Get(ical.PropRecurrenceID))
		if err != nil {
			return nil, err
		}
		byInstance[recurrenceID.Time.Unix()] = override
	}
	return byInstance, nil
}

func (r *Resource) Occurrences(from, to time.Time) ([]Occurrence, error) {
	overrides, err := r.overridesByInstance()
	if err != nil {
		return nil, err
	}
	var occurrences []Occurrence
	if r.Master != nil {
		occurrences, err = r.masterOccurrences(from, to, overrides)
		if err != nil {
			return nil, err
		}
	}
	for _, override := range r.Overrides {
		occurrence, err := r.overrideOccurrence(override)
		if err != nil {
			return nil, err
		}
		if overlaps(occurrence.Start, occurrence.End, from, to) {
			occurrences = append(occurrences, occurrence)
		}
	}
	slices.SortFunc(occurrences, func(a, b Occurrence) int { return a.Start.Compare(b.Start) })
	return occurrences, nil
}

func (r *Resource) masterOccurrences(from, to time.Time, overrides map[int64]*ical.Component) ([]Occurrence, error) {
	timing, err := r.timing(r.Master)
	if err != nil {
		return nil, err
	}
	if !r.Recurring() {
		occurrence := Occurrence{Start: timing.start.Time, End: timing.start.Time.Add(timing.duration), AllDay: timing.start.AllDay, Component: r.Master}
		if !overlaps(occurrence.Start, occurrence.End, from, to) {
			return nil, nil
		}
		return []Occurrence{occurrence}, nil
	}
	set, err := r.instances(timing)
	if err != nil {
		return nil, err
	}
	var occurrences []Occurrence
	for steps := 0; steps < maxIteratedInstances && len(occurrences) < maxExpandedInstances; steps++ {
		start, ok := set.next()
		if !ok || (!to.IsZero() && !start.Before(to)) {
			break
		}
		if _, overridden := overrides[start.Unix()]; overridden {
			continue
		}
		duration := timing.duration
		if custom, found := set.durations[start.Unix()]; found {
			duration = custom
		}
		end := start.Add(duration)
		if overlaps(start, end, from, to) {
			occurrences = append(occurrences, Occurrence{
				Start: start, End: end, AllDay: timing.start.AllDay, Component: r.Master,
				RecurrenceID: recurrenceIDValue(dateTime{Time: start, AllDay: timing.start.AllDay}),
			})
		}
	}
	return occurrences, nil
}

func (r *Resource) overrideOccurrence(override *ical.Component) (Occurrence, error) {
	timing, err := r.timing(override)
	if err != nil {
		return Occurrence{}, err
	}
	if override.Props.Get(ical.PropDateTimeEnd) == nil && override.Props.Get(ical.PropDuration) == nil && r.Master != nil {
		if masterTiming, err := r.timing(r.Master); err == nil {
			timing.duration = masterTiming.duration
		}
	}
	recurrenceID, err := r.zones.dateTime(override.Props.Get(ical.PropRecurrenceID))
	if err != nil {
		return Occurrence{}, err
	}
	return Occurrence{
		Start: timing.start.Time, End: timing.start.Time.Add(timing.duration), AllDay: timing.start.AllDay,
		RecurrenceID: recurrenceIDValue(recurrenceID), Component: override, Override: true,
	}, nil
}

func overlaps(start, end, from, to time.Time) bool {
	if end.After(start) {
		return (to.IsZero() || start.Before(to)) && (from.IsZero() || end.After(from))
	}
	return (from.IsZero() || !start.Before(from)) && (to.IsZero() || start.Before(to))
}

func (r *Resource) Bounds() (Bounds, error) {
	occurrences, unbounded, err := r.allOccurrences()
	if err != nil {
		return Bounds{}, err
	}
	bounds := Bounds{}
	var lastEnd time.Time
	for i, occurrence := range occurrences {
		if i == 0 || occurrence.Start.Before(bounds.FirstStart) {
			bounds.FirstStart = occurrence.Start
		}
		end := occurrence.End
		if !end.After(occurrence.Start) {
			end = occurrence.Start
		}
		if end.After(lastEnd) {
			lastEnd = end
		}
	}
	if bounds.FirstStart.IsZero() {
		start, err := r.zones.dateTime(r.Primary().Props.Get(ical.PropDateTimeStart))
		if err != nil {
			return Bounds{}, err
		}
		bounds.FirstStart, lastEnd = start.Time, start.Time
	}
	if !unbounded {
		bounds.LastEnd = &lastEnd
	}
	return bounds, nil
}

func (r *Resource) allOccurrences() ([]Occurrence, bool, error) {
	if r.Master == nil || !r.Recurring() {
		occurrences, err := r.Occurrences(time.Time{}, time.Time{})
		return occurrences, false, err
	}
	timing, err := r.timing(r.Master)
	if err != nil {
		return nil, false, err
	}
	set, err := r.instances(timing)
	if err != nil {
		return nil, false, err
	}
	if !set.bounded {
		occurrences, err := r.Occurrences(timing.start.Time, timing.start.Time.Add(timing.duration+time.Second))
		return occurrences, true, err
	}
	occurrences, err := r.Occurrences(time.Time{}, time.Time{})
	return occurrences, len(occurrences) >= maxExpandedInstances, err
}
