package calendar

import (
	"strconv"
	"strings"
	"time"

	"github.com/emersion/go-ical"
)

const (
	alarmLookaround = 30 * 24 * time.Hour
	maxAlarmRepeats = 50
	actionNone      = "NONE"
)

type Trigger struct {
	At         time.Time
	Key        string
	Alarm      *ical.Component
	Occurrence Occurrence
}

func (r *Resource) TriggersBetween(from, to time.Time) ([]Trigger, error) {
	occurrences, err := r.Occurrences(from.Add(-alarmLookaround), to.Add(alarmLookaround))
	if err != nil {
		return nil, err
	}
	var triggers []Trigger
	for _, occurrence := range occurrences {
		for _, trigger := range r.occurrenceTriggers(occurrence) {
			if !trigger.At.Before(from) && trigger.At.Before(to) {
				triggers = append(triggers, trigger)
			}
		}
	}
	return triggers, nil
}

func (r *Resource) occurrenceTriggers(occurrence Occurrence) []Trigger {
	var triggers []Trigger
	for index, alarm := range occurrence.Component.Children {
		if alarm.Name != ical.CompAlarm || strings.EqualFold(propText(alarm, ical.PropAction), actionNone) {
			continue
		}
		first, ok := r.firstTrigger(alarm, occurrence)
		if !ok {
			continue
		}
		key := alarmKey(alarm, index)
		acknowledged := r.acknowledgedAt(alarm)
		for repeat, at := range repeatedTriggers(alarm, first) {
			if !acknowledged.IsZero() && !acknowledged.Before(at) {
				continue
			}
			triggers = append(triggers, Trigger{At: at, Key: key + "#" + strconv.Itoa(repeat), Alarm: alarm, Occurrence: occurrence})
		}
	}
	return triggers
}

func (r *Resource) firstTrigger(alarm *ical.Component, occurrence Occurrence) (time.Time, bool) {
	prop := alarm.Props.Get(ical.PropTrigger)
	if prop == nil {
		return time.Time{}, false
	}
	if strings.EqualFold(prop.Params.Get(ical.ParamValue), string(ical.ValueDateTime)) {
		absolute, err := r.zones.dateTime(prop)
		return absolute.Time, err == nil
	}
	offset, err := parseDuration(prop.Value)
	if err != nil {
		return time.Time{}, false
	}
	if strings.EqualFold(prop.Params.Get(ical.ParamRelated), "END") {
		return occurrence.End.Add(offset), true
	}
	return occurrence.Start.Add(offset), true
}

func repeatedTriggers(alarm *ical.Component, first time.Time) []time.Time {
	triggers := []time.Time{first}
	repeatProp := alarm.Props.Get(ical.PropRepeat)
	if repeatProp == nil {
		return triggers
	}
	repeat, err := repeatProp.Int()
	if err != nil || repeat <= 0 {
		return triggers
	}
	durationProp := alarm.Props.Get(ical.PropDuration)
	if durationProp == nil {
		return triggers
	}
	interval, err := parseDuration(durationProp.Value)
	if err != nil || interval <= 0 {
		return triggers
	}
	for i := 1; i <= min(repeat, maxAlarmRepeats); i++ {
		triggers = append(triggers, first.Add(time.Duration(i)*interval))
	}
	return triggers
}

func (r *Resource) acknowledgedAt(alarm *ical.Component) time.Time {
	prop := alarm.Props.Get("ACKNOWLEDGED")
	if prop == nil {
		return time.Time{}
	}
	acknowledged, err := r.zones.dateTime(prop)
	if err != nil {
		return time.Time{}
	}
	return acknowledged.Time
}

func alarmKey(alarm *ical.Component, index int) string {
	for _, name := range []string{ical.PropUID, "X-WR-ALARMUID"} {
		if value := propText(alarm, name); value != "" {
			return value
		}
	}
	trigger := ""
	if prop := alarm.Props.Get(ical.PropTrigger); prop != nil {
		trigger = prop.Value
	}
	return strconv.Itoa(index) + ":" + trigger
}
