package calendar

import (
	"bytes"
	"errors"
	"io"
	"strings"
	"time"

	"github.com/emersion/go-ical"
	"github.com/teambition/rrule-go"

	"polder-server/internal/apperr"
)

const (
	ProductID               = "-//Polder//Calendar//EN"
	ComponentEvent          = ical.CompEvent
	DefaultMaxResourceBytes = 1 << 20
	maxComponentsPerObject  = 1000
)

type Resource struct {
	cal       *ical.Calendar
	UID       string
	Master    *ical.Component
	Overrides []*ical.Component
	zones     zoneSet
	original  []byte
	changed   bool
}

func Parse(data []byte, floating *time.Location) (*Resource, error) {
	cal, err := decodeCalendar(data)
	if err != nil {
		return nil, err
	}
	resource, err := fromCalendar(cal, floating, false)
	if err != nil {
		return nil, err
	}
	resource.original = data
	return resource, nil
}

func decodeCalendar(data []byte) (*ical.Calendar, error) {
	decoder := ical.NewDecoder(bytes.NewReader(data))
	cal, err := decoder.Decode()
	if err != nil {
		return nil, invalidData("the calendar data cannot be read: %v", err)
	}
	if _, err := decoder.Decode(); !errors.Is(err, io.EOF) {
		return nil, violation(ConditionValidObject, apperr.KindInvalid, "a calendar object holds exactly one VCALENDAR")
	}
	return cal, nil
}

func FromCalendar(cal *ical.Calendar, floating *time.Location) (*Resource, error) {
	return fromCalendar(cal, floating, true)
}

func fromCalendar(cal *ical.Calendar, floating *time.Location, changed bool) (*Resource, error) {
	resource := &Resource{cal: cal, changed: changed}
	resource.normalizeCalendar()
	resource.zones = newZoneSet(cal, floating)
	if err := resource.collectEvents(); err != nil {
		return nil, err
	}
	for _, component := range resource.Components() {
		if err := resource.validateEvent(component); err != nil {
			return nil, err
		}
	}
	return resource, nil
}

func (r *Resource) normalizeCalendar() {
	if r.cal.Props.Get(ical.PropMethod) != nil {
		r.cal.Props.Del(ical.PropMethod)
		r.changed = true
	}
	if r.cal.Props.Get(ical.PropVersion) == nil {
		r.cal.Props.SetText(ical.PropVersion, "2.0")
		r.changed = true
	}
	if r.cal.Props.Get(ical.PropProductID) == nil {
		r.cal.Props.SetText(ical.PropProductID, ProductID)
		r.changed = true
	}
}

func (r *Resource) collectEvents() error {
	if len(r.cal.Children) > maxComponentsPerObject {
		return invalidData("the calendar object has too many components")
	}
	seenRecurrences := map[string]bool{}
	for _, child := range r.cal.Children {
		switch {
		case child.Name == ical.CompTimezone:
		case child.Name == ical.CompEvent:
			if err := r.addEvent(child, seenRecurrences); err != nil {
				return err
			}
		case strings.HasPrefix(child.Name, "X-"):
		default:
			return violation(ConditionSupportedComponent, apperr.KindInvalid, "%s components are not supported; only VEVENT is", child.Name)
		}
	}
	if r.Master == nil && len(r.Overrides) == 0 {
		return violation(ConditionValidObject, apperr.KindInvalid, "the calendar object has no VEVENT")
	}
	return nil
}

func (r *Resource) addEvent(event *ical.Component, seenRecurrences map[string]bool) error {
	uid := strings.TrimSpace(propText(event, ical.PropUID))
	if uid == "" {
		return violation(ConditionValidObject, apperr.KindInvalid, "every VEVENT needs a UID")
	}
	if r.UID != "" && uid != r.UID {
		return violation(ConditionValidObject, apperr.KindInvalid, "all VEVENTs in a calendar object share one UID")
	}
	r.UID = uid
	recurrenceID := event.Props.Get(ical.PropRecurrenceID)
	if recurrenceID == nil {
		if r.Master != nil {
			return violation(ConditionValidObject, apperr.KindInvalid, "a calendar object has at most one VEVENT without RECURRENCE-ID")
		}
		r.Master = event
		return nil
	}
	if seenRecurrences[recurrenceID.Value] {
		return violation(ConditionValidObject, apperr.KindInvalid, "two VEVENTs override the same RECURRENCE-ID")
	}
	seenRecurrences[recurrenceID.Value] = true
	r.Overrides = append(r.Overrides, event)
	return nil
}

func (r *Resource) validateEvent(event *ical.Component) error {
	if event.Props.Get(ical.PropDateTimeStamp) == nil {
		event.Props.SetDateTime(ical.PropDateTimeStamp, time.Now().UTC())
		r.changed = true
	}
	startProp := event.Props.Get(ical.PropDateTimeStart)
	if startProp == nil {
		return invalidData("every VEVENT needs a DTSTART")
	}
	start, err := r.zones.dateTime(startProp)
	if err != nil {
		return err
	}
	if event.Props.Get(ical.PropDateTimeEnd) != nil && event.Props.Get(ical.PropDuration) != nil {
		return invalidData("a VEVENT has DTEND or DURATION, not both")
	}
	if end := event.Props.Get(ical.PropDateTimeEnd); end != nil {
		parsedEnd, err := r.zones.dateTime(end)
		if err != nil {
			return err
		}
		if parsedEnd.Time.Before(start.Time) {
			return invalidData("DTEND is before DTSTART")
		}
	}
	if recurrenceID := event.Props.Get(ical.PropRecurrenceID); recurrenceID != nil {
		if _, err := r.zones.dateTime(recurrenceID); err != nil {
			return err
		}
	}
	return r.validateRecurrence(event, start)
}

func (r *Resource) validateRecurrence(event *ical.Component, start dateTime) error {
	if rule := event.Props.Get(ical.PropRecurrenceRule); rule != nil {
		if _, err := ruleOptions(rule.Value, start); err != nil {
			return err
		}
	}
	for _, name := range []string{ical.PropRecurrenceDates, ical.PropExceptionDates} {
		for i := range event.Props[name] {
			if _, err := r.zones.dateTimeList(&event.Props[name][i]); err != nil {
				return err
			}
		}
	}
	return nil
}

var supportedRuleParts = map[string]bool{
	"FREQ": true, "INTERVAL": true, "WKST": true, "COUNT": true, "UNTIL": true, "BYSETPOS": true,
	"BYMONTH": true, "BYMONTHDAY": true, "BYYEARDAY": true, "BYWEEKNO": true, "BYDAY": true,
	"BYHOUR": true, "BYMINUTE": true, "BYSECOND": true,
}

func ruleOptions(value string, start dateTime) (*rrule.ROption, error) {
	var parts []string
	for _, part := range strings.Split(strings.TrimPrefix(strings.TrimSpace(value), "RRULE:"), ";") {
		key, _, _ := strings.Cut(part, "=")
		if supportedRuleParts[strings.ToUpper(key)] {
			parts = append(parts, part)
		}
	}
	options, err := rrule.StrToROptionInLocation(strings.Join(parts, ";"), start.Time.Location())
	if err != nil {
		return nil, invalidData("RRULE %q cannot be read: %v", value, err)
	}
	if options.Freq == rrule.SECONDLY || options.Freq == rrule.MINUTELY {
		return nil, invalidData("events cannot repeat more often than hourly")
	}
	options.Dtstart = start.Time
	return options, nil
}

func (r *Resource) Components() []*ical.Component {
	components := make([]*ical.Component, 0, len(r.Overrides)+1)
	if r.Master != nil {
		components = append(components, r.Master)
	}
	return append(components, r.Overrides...)
}

func (r *Resource) Calendar() *ical.Calendar {
	return r.cal
}

func (r *Resource) Changed() bool {
	return r.changed
}

func (r *Resource) MarkChanged() {
	r.changed = true
}

func (r *Resource) Bytes() ([]byte, error) {
	if !r.changed && r.original != nil {
		return r.original, nil
	}
	var buffer bytes.Buffer
	if err := ical.NewEncoder(&buffer).Encode(r.cal); err != nil {
		return nil, invalidData("the calendar data cannot be written: %v", err)
	}
	return buffer.Bytes(), nil
}

func (r *Resource) Primary() *ical.Component {
	if r.Master != nil {
		return r.Master
	}
	return r.Overrides[0]
}

func (r *Resource) Summary() string {
	return propText(r.Primary(), ical.PropSummary)
}

func (r *Resource) HasAlarms() bool {
	for _, component := range r.Components() {
		for _, child := range component.Children {
			if child.Name == ical.CompAlarm {
				return true
			}
		}
	}
	return false
}

func (r *Resource) Recurring() bool {
	if r.Master == nil {
		return false
	}
	return r.Master.Props.Get(ical.PropRecurrenceRule) != nil || r.Master.Props.Get(ical.PropRecurrenceDates) != nil
}

func (r *Resource) Floating() *time.Location {
	return r.zones.floating
}

func propText(component *ical.Component, name string) string {
	prop := component.Props.Get(name)
	if prop == nil {
		return ""
	}
	text, err := prop.Text()
	if err != nil {
		return prop.Value
	}
	return text
}
