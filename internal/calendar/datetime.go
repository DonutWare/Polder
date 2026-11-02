package calendar

import (
	"strconv"
	"strings"
	"time"

	"github.com/emersion/go-ical"
)

const (
	dateLayout        = "20060102"
	localDateLayout   = "20060102T150405"
	utcDateTimeLayout = "20060102T150405Z"
)

type dateTime struct {
	Time     time.Time
	AllDay   bool
	Floating bool
}

type period struct {
	Start    dateTime
	Duration time.Duration
	HasEnd   bool
}

func (z zoneSet) dateTime(prop *ical.Prop) (dateTime, error) {
	return z.parseValue(prop.Value, prop.Params)
}

func (z zoneSet) parseValue(value string, params ical.Params) (dateTime, error) {
	value = strings.TrimSpace(value)
	isDate := strings.EqualFold(params.Get(ical.ParamValue), string(ical.ValueDate)) || len(value) == len(dateLayout)
	switch {
	case isDate:
		parsed, err := time.ParseInLocation(dateLayout, value, z.floating)
		if err != nil {
			return dateTime{}, invalidData("%q is not a date", value)
		}
		return dateTime{Time: parsed, AllDay: true, Floating: true}, nil
	case strings.HasSuffix(value, "Z"):
		parsed, err := time.Parse(utcDateTimeLayout, value)
		if err != nil {
			return dateTime{}, invalidData("%q is not a UTC date-time", value)
		}
		return dateTime{Time: parsed}, nil
	}
	tzid := params.Get(ical.ParamTimezoneID)
	location := z.floating
	if tzid != "" {
		location = z.location(tzid)
	}
	parsed, err := time.ParseInLocation(localDateLayout, value, location)
	if err != nil {
		return dateTime{}, invalidData("%q is not a date-time", value)
	}
	return dateTime{Time: parsed, Floating: tzid == ""}, nil
}

func (z zoneSet) dateTimeList(prop *ical.Prop) ([]period, error) {
	isPeriod := strings.EqualFold(prop.Params.Get(ical.ParamValue), string(ical.ValuePeriod))
	var periods []period
	for _, raw := range strings.Split(prop.Value, ",") {
		if raw = strings.TrimSpace(raw); raw == "" {
			continue
		}
		start, rest, hasRest := strings.Cut(raw, "/")
		parsed, err := z.parseValue(start, prop.Params)
		if err != nil {
			return nil, err
		}
		entry := period{Start: parsed}
		if isPeriod && hasRest {
			duration, err := periodDuration(z, parsed, rest, prop.Params)
			if err != nil {
				return nil, err
			}
			entry.Duration = duration
			entry.HasEnd = true
		}
		periods = append(periods, entry)
	}
	return periods, nil
}

func periodDuration(z zoneSet, start dateTime, rest string, params ical.Params) (time.Duration, error) {
	if strings.HasPrefix(rest, "P") || strings.HasPrefix(rest, "+P") || strings.HasPrefix(rest, "-P") {
		return parseDuration(rest)
	}
	end, err := z.parseValue(rest, params)
	if err != nil {
		return 0, err
	}
	return end.Time.Sub(start.Time), nil
}

func parseDuration(value string) (time.Duration, error) {
	prop := ical.NewProp(ical.PropDuration)
	prop.Value = value
	duration, err := prop.Duration()
	if err != nil {
		return 0, invalidData("%q is not a duration", value)
	}
	return duration, nil
}

func setDateTimeProp(props ical.Props, name string, value dateTime, tzid string) {
	prop := ical.NewProp(name)
	switch {
	case value.AllDay:
		prop.SetValueType(ical.ValueDate)
		prop.Value = value.Time.Format(dateLayout)
	case value.Floating:
		prop.Value = value.Time.Format(localDateLayout)
	case tzid == "" || tzid == "UTC" || tzid == "Etc/UTC":
		prop.Value = value.Time.UTC().Format(utcDateTimeLayout)
	default:
		prop.Params.Set(ical.ParamTimezoneID, tzid)
		prop.Value = value.Time.In(LocationOrUTC(tzid)).Format(localDateLayout)
	}
	props.Set(prop)
}

func recurrenceIDValue(value dateTime) string {
	if value.AllDay {
		return value.Time.Format(dateLayout)
	}
	return value.Time.UTC().Format(utcDateTimeLayout)
}

func timezoneComponent(location *time.Location, year int) *ical.Component {
	component := ical.NewComponent(ical.CompTimezone)
	component.Props.SetText(ical.PropTimezoneID, location.String())
	transitions := yearTransitions(location, year)
	if len(transitions) == 0 {
		name, offset := time.Date(year, time.January, 1, 0, 0, 0, 0, location).Zone()
		component.Children = append(component.Children, observance(ical.CompTimezoneStandard, name, offset, offset, time.Date(1970, time.January, 1, 0, 0, 0, 0, time.UTC), ""))
		return component
	}
	for _, transition := range transitions {
		component.Children = append(component.Children, transitionObservance(location, transition))
	}
	return component
}

func transitionObservance(location *time.Location, transition time.Time) *ical.Component {
	_, fromOffset := transition.Add(-time.Second).In(location).Zone()
	name, toOffset := transition.In(location).Zone()
	kind := ical.CompTimezoneStandard
	if toOffset > fromOffset {
		kind = ical.CompTimezoneDaylight
	}
	local := transition.In(time.FixedZone("", fromOffset))
	ordinal := (local.Day()-1)/7 + 1
	if local.Day()+7 > daysIn(local.Month(), local.Year()) {
		ordinal = -1
	}
	weekday := strings.ToUpper(local.Weekday().String()[:2])
	rule := "FREQ=YEARLY;BYMONTH=" + strconv.Itoa(int(local.Month())) + ";BYDAY=" + strconv.Itoa(ordinal) + weekday
	start := nthWeekday(1970, local.Month(), local.Weekday(), ordinal)
	start = time.Date(start.Year(), start.Month(), start.Day(), local.Hour(), local.Minute(), local.Second(), 0, time.UTC)
	return observance(kind, name, fromOffset, toOffset, start, rule)
}

func observance(kind, name string, fromOffset, toOffset int, start time.Time, rule string) *ical.Component {
	component := ical.NewComponent(kind)
	startProp := ical.NewProp(ical.PropDateTimeStart)
	startProp.Value = start.Format(localDateLayout)
	component.Props.Set(startProp)
	component.Props.Set(rawProp(ical.PropTimezoneOffsetFrom, formatUTCOffset(fromOffset)))
	component.Props.Set(rawProp(ical.PropTimezoneOffsetTo, formatUTCOffset(toOffset)))
	if name != "" {
		component.Props.SetText(ical.PropTimezoneName, name)
	}
	if rule != "" {
		ruleProp := rawProp(ical.PropRecurrenceRule, rule)
		ruleProp.SetValueType(ical.ValueRecurrence)
		component.Props.Set(ruleProp)
	}
	return component
}

func rawProp(name, value string) *ical.Prop {
	prop := ical.NewProp(name)
	prop.Value = value
	return prop
}

func yearTransitions(location *time.Location, year int) []time.Time {
	var transitions []time.Time
	day := time.Date(year, time.January, 1, 0, 0, 0, 0, time.UTC)
	_, previous := day.In(location).Zone()
	for i := 0; i < 366 && len(transitions) < 2; i++ {
		next := day.Add(24 * time.Hour)
		_, offset := next.In(location).Zone()
		if offset != previous {
			transitions = append(transitions, searchTransition(location, day, next))
			previous = offset
		}
		day = next
	}
	return transitions
}

func searchTransition(location *time.Location, before, after time.Time) time.Time {
	_, startOffset := before.In(location).Zone()
	for after.Sub(before) > time.Second {
		middle := before.Add(after.Sub(before) / 2).Truncate(time.Second)
		if _, offset := middle.In(location).Zone(); offset == startOffset {
			before = middle
		} else {
			after = middle
		}
	}
	return after
}

func daysIn(month time.Month, year int) int {
	return time.Date(year, month+1, 0, 0, 0, 0, 0, time.UTC).Day()
}

func nthWeekday(year int, month time.Month, weekday time.Weekday, ordinal int) time.Time {
	if ordinal < 0 {
		last := time.Date(year, month+1, 0, 0, 0, 0, 0, time.UTC)
		return last.AddDate(0, 0, -((int(last.Weekday()) - int(weekday) + 7) % 7))
	}
	first := time.Date(year, month, 1, 0, 0, 0, 0, time.UTC)
	offset := (int(weekday) - int(first.Weekday()) + 7) % 7
	return first.AddDate(0, 0, offset+(ordinal-1)*7)
}
