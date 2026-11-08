package calendar

import (
	netmail "net/mail"
	"strconv"
	"strings"
	"time"

	"github.com/emersion/go-ical"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

const (
	defaultEventLength = time.Hour
)

var validStatuses = map[string]bool{"CONFIRMED": true, "TENTATIVE": true, "CANCELLED": true}

var validRoles = map[string]bool{"REQ-PARTICIPANT": true, "OPT-PARTICIPANT": true, "CHAIR": true, "NON-PARTICIPANT": true}

var validActions = map[string]bool{"DISPLAY": true, "EMAIL": true, "AUDIO": true}

func applyInput(component *ical.Component, input EventInput, owner users.User, allowRule bool) error {
	start, end, tzid, err := inputTimes(input)
	if err != nil {
		return err
	}
	setText(component, ical.PropSummary, strings.TrimSpace(input.Summary))
	setText(component, ical.PropDescription, input.Description)
	setText(component, ical.PropLocation, strings.TrimSpace(input.Location))
	setRaw(component, ical.PropURL, strings.TrimSpace(input.URL))
	setDateTimeProp(component.Props, ical.PropDateTimeStart, start, tzid)
	setDateTimeProp(component.Props, ical.PropDateTimeEnd, end, tzid)
	component.Props.Del(ical.PropDuration)
	if allowRule {
		if err := applyRule(component, input.RRule, start); err != nil {
			return err
		}
	}
	if err := applyDetails(component, input); err != nil {
		return err
	}
	if input.Attendees != nil {
		if err := applyAttendees(component, input.Attendees, owner); err != nil {
			return err
		}
	}
	if input.Alarms != nil {
		if err := applyAlarms(component, input.Alarms); err != nil {
			return err
		}
	}
	now := time.Now().UTC()
	component.Props.SetDateTime(ical.PropDateTimeStamp, now)
	component.Props.SetDateTime(ical.PropLastModified, now)
	bumpSequence(component)
	return nil
}

func inputTimes(input EventInput) (dateTime, dateTime, string, error) {
	if input.Start.IsZero() {
		return dateTime{}, dateTime{}, "", apperr.Invalid("an event needs a start")
	}
	if input.AllDay {
		startDate := time.Date(input.Start.Year(), input.Start.Month(), input.Start.Day(), 0, 0, 0, 0, time.UTC)
		endDate := time.Date(input.End.Year(), input.End.Month(), input.End.Day(), 0, 0, 0, 0, time.UTC)
		if input.End.IsZero() || !endDate.After(startDate) {
			endDate = startDate.AddDate(0, 0, 1)
		}
		return dateTime{Time: startDate, AllDay: true}, dateTime{Time: endDate, AllDay: true}, "", nil
	}
	tzid := strings.TrimSpace(input.Timezone)
	if !ValidTimezone(tzid) {
		return dateTime{}, dateTime{}, "", apperr.Invalid("%q is not a timezone such as Europe/Amsterdam", tzid)
	}
	end := input.End
	if end.IsZero() {
		end = input.Start.Add(defaultEventLength)
	}
	if end.Before(input.Start) {
		return dateTime{}, dateTime{}, "", apperr.Invalid("an event ends after it starts")
	}
	return dateTime{Time: input.Start}, dateTime{Time: end}, tzid, nil
}

func applyRule(component *ical.Component, rule string, start dateTime) error {
	rule = strings.TrimPrefix(strings.TrimSpace(rule), "RRULE:")
	if rule == "" {
		component.Props.Del(ical.PropRecurrenceRule)
		return nil
	}
	if _, err := ruleOptions(rule, start); err != nil {
		return err
	}
	prop := rawProp(ical.PropRecurrenceRule, strings.ToUpper(rule))
	prop.SetValueType(ical.ValueRecurrence)
	component.Props.Set(prop)
	return nil
}

func applyDetails(component *ical.Component, input EventInput) error {
	status := strings.ToUpper(strings.TrimSpace(input.Status))
	if status != "" && !validStatuses[status] {
		return apperr.Invalid("status is CONFIRMED, TENTATIVE or CANCELLED")
	}
	setText(component, ical.PropStatus, status)
	switch input.ShowAs {
	case ShowAsFree:
		component.Props.SetText(ical.PropTransparency, "TRANSPARENT")
	case ShowAsBusy, "":
		component.Props.SetText(ical.PropTransparency, "OPAQUE")
	default:
		return apperr.Invalid("showAs is busy or free")
	}
	component.Props.Del(ical.PropCategories)
	if len(input.Categories) > 0 {
		prop := ical.NewProp(ical.PropCategories)
		prop.SetTextList(input.Categories)
		component.Props.Set(prop)
	}
	return nil
}

func setText(component *ical.Component, name, value string) {
	if value == "" {
		component.Props.Del(name)
		return
	}
	component.Props.SetText(name, value)
}

func setRaw(component *ical.Component, name, value string) {
	if value == "" {
		component.Props.Del(name)
		return
	}
	prop := rawProp(name, value)
	prop.SetValueType(ical.ValueURI)
	component.Props.Set(prop)
}

func applyAttendees(component *ical.Component, inputs []AttendeeInput, owner users.User) error {
	existing := map[string]ical.Prop{}
	for _, prop := range component.Props.Values(ical.PropAttendee) {
		existing[normalizeAddress(prop.Value)] = prop
	}
	component.Props.Del(ical.PropAttendee)
	if len(inputs) == 0 {
		component.Props.Del(ical.PropOrganizer)
		return nil
	}
	organizer := ensureOrganizer(component, owner)
	own := addressesOf(owner)
	for _, input := range inputs {
		prop, err := attendeeProp(input, existing)
		if err != nil {
			return err
		}
		if own.has(prop.Value) {
			continue
		}
		component.Props.Add(prop)
	}
	chair := existing[normalizeAddress(organizer.Value)]
	if chair.Value == "" {
		chair = *rawProp(ical.PropAttendee, organizer.Value)
		chair.Params.Set(ical.ParamCommonName, owner.ShownName())
		chair.Params.Set(ical.ParamRole, "CHAIR")
		chair.Params.Set(ical.ParamParticipationStatus, PartstatAccepted)
	}
	component.Props.Add(&chair)
	return nil
}

func ensureOrganizer(component *ical.Component, owner users.User) *ical.Prop {
	if prop := component.Props.Get(ical.PropOrganizer); prop != nil {
		return prop
	}
	prop := rawProp(ical.PropOrganizer, Addresses(owner)[0])
	prop.Params.Set(ical.ParamCommonName, owner.ShownName())
	component.Props.Set(prop)
	return component.Props.Get(ical.PropOrganizer)
}

func attendeeProp(input AttendeeInput, existing map[string]ical.Prop) (*ical.Prop, error) {
	parsed, err := netmail.ParseAddress(strings.TrimSpace(input.Email))
	if err != nil {
		return nil, apperr.Invalid("%q is not an email address", input.Email)
	}
	address := mailtoPrefix + strings.ToLower(parsed.Address)
	role := strings.ToUpper(strings.TrimSpace(input.Role))
	if role == "" {
		role = "REQ-PARTICIPANT"
	}
	if !validRoles[role] {
		return nil, apperr.Invalid("role is REQ-PARTICIPANT, OPT-PARTICIPANT, CHAIR or NON-PARTICIPANT")
	}
	prop := rawProp(ical.PropAttendee, address)
	if previous, found := existing[address]; found {
		prop = cloneProp(&previous)
	} else {
		prop.Params.Set(ical.ParamParticipationStatus, PartstatNeedsAction)
		prop.Params.Set(ical.ParamRSVP, "TRUE")
		prop.Params.Set(ical.ParamCalendarUserType, "INDIVIDUAL")
	}
	prop.Params.Set(ical.ParamRole, role)
	name := strings.TrimSpace(input.Name)
	if name == "" {
		name = parsed.Name
	}
	if name != "" {
		prop.Params.Set(ical.ParamCommonName, strings.ReplaceAll(name, `"`, "'"))
	}
	return prop, nil
}

func applyAlarms(component *ical.Component, alarms []Alarm) error {
	component.Children = withoutAlarms(component.Children)
	for _, alarm := range alarms {
		built, err := alarmComponent(alarm, propText(component, ical.PropSummary))
		if err != nil {
			return err
		}
		component.Children = append(component.Children, built)
	}
	return nil
}

func alarmComponent(alarm Alarm, summary string) (*ical.Component, error) {
	action := strings.ToUpper(strings.TrimSpace(alarm.Action))
	if action == "" {
		action = "DISPLAY"
	}
	if !validActions[action] {
		return nil, apperr.Invalid("an alarm's action is DISPLAY, EMAIL or AUDIO")
	}
	component := ical.NewComponent(ical.CompAlarm)
	component.Props.SetText(ical.PropUID, randomHex(12))
	component.Props.SetText(ical.PropAction, action)
	trigger := ical.NewProp(ical.PropTrigger)
	switch {
	case alarm.At != nil:
		trigger.SetDateTime(alarm.At.UTC())
	case alarm.OffsetMinutes != nil:
		trigger.SetDuration(time.Duration(*alarm.OffsetMinutes) * time.Minute)
		if alarm.RelativeToEnd {
			trigger.Params.Set(ical.ParamRelated, "END")
		}
	default:
		return nil, apperr.Invalid("an alarm needs offsetMinutes or at")
	}
	component.Props.Set(trigger)
	description := alarm.Description
	if description == "" {
		description = summary
	}
	if description == "" {
		description = "Reminder"
	}
	if action != "AUDIO" {
		component.Props.SetText(ical.PropDescription, description)
	}
	if action == "EMAIL" {
		component.Props.SetText(ical.PropSummary, description)
	}
	return component, nil
}

func (r *Resource) parseInstance(value string) (dateTime, error) {
	instant, err := r.instantFrom(strings.TrimSpace(value))
	if err != nil {
		return dateTime{}, err
	}
	if r.override(instant) != nil {
		return instant, nil
	}
	occurrences, err := r.Occurrences(instant.Time, instant.Time.Add(time.Second))
	if err != nil {
		return dateTime{}, err
	}
	wanted := recurrenceIDValue(instant)
	for _, occurrence := range occurrences {
		if occurrence.RecurrenceID == wanted {
			return instant, nil
		}
	}
	return dateTime{}, apperr.NotFound("the event has no occurrence at %s", value)
}

func (r *Resource) instantFrom(value string) (dateTime, error) {
	if parsed, err := time.Parse(time.RFC3339, value); err == nil {
		return dateTime{Time: parsed.UTC()}, nil
	}
	if len(value) == len(dateLayout) {
		parsed, err := time.ParseInLocation(dateLayout, value, r.zones.floating)
		if err == nil {
			return dateTime{Time: parsed, AllDay: true, Floating: true}, nil
		}
	}
	if parsed, err := time.Parse(utcDateTimeLayout, value); err == nil {
		return dateTime{Time: parsed}, nil
	}
	return dateTime{}, apperr.Invalid("%q is not an occurrence such as 20250131T090000Z", value)
}

func (r *Resource) override(instant dateTime) *ical.Component {
	for _, override := range r.Overrides {
		recurrenceID, err := r.zones.dateTime(override.Props.Get(ical.PropRecurrenceID))
		if err == nil && recurrenceID.Time.Equal(instant.Time) {
			return override
		}
	}
	return nil
}

func (r *Resource) editedOverride(recurrenceID string) *ical.Component {
	if recurrenceID == "" {
		return nil
	}
	instant, err := r.instantFrom(strings.TrimSpace(recurrenceID))
	if err != nil {
		return nil
	}
	return r.override(instant)
}

func (r *Resource) dropOverrides() {
	for _, override := range append([]*ical.Component(nil), r.Overrides...) {
		r.removeComponent(override)
	}
}

func (r *Resource) instanceProp(name string, instant time.Time) *ical.Prop {
	startProp := r.Master.Props.Get(ical.PropDateTimeStart)
	start, _ := r.zones.dateTime(startProp)
	prop := ical.NewProp(name)
	tzid := startProp.Params.Get(ical.ParamTimezoneID)
	switch {
	case start.AllDay:
		prop.SetValueType(ical.ValueDate)
		prop.Value = instant.In(r.zones.floating).Format(dateLayout)
	case start.Floating:
		prop.Value = instant.In(r.zones.floating).Format(localDateLayout)
	case tzid != "":
		prop.Params.Set(ical.ParamTimezoneID, tzid)
		prop.Value = instant.In(r.zones.location(tzid)).Format(localDateLayout)
	default:
		prop.Value = instant.UTC().Format(utcDateTimeLayout)
	}
	return prop
}

func (r *Resource) addOverride(instant dateTime) (*ical.Component, error) {
	if r.Master == nil {
		return nil, apperr.NotFound("the series of this occurrence is not in the calendar")
	}
	timing, err := r.timing(r.Master)
	if err != nil {
		return nil, err
	}
	override := cloneComponent(r.Master)
	for _, name := range []string{ical.PropRecurrenceRule, ical.PropRecurrenceDates, ical.PropExceptionDates, ical.PropDuration} {
		override.Props.Del(name)
	}
	override.Props.Set(r.instanceProp(ical.PropDateTimeStart, instant.Time))
	override.Props.Set(r.instanceProp(ical.PropDateTimeEnd, instant.Time.Add(timing.duration)))
	override.Props.Set(r.instanceProp(ical.PropRecurrenceID, instant.Time))
	r.Overrides = append(r.Overrides, override)
	r.cal.Children = append(r.cal.Children, override)
	r.MarkChanged()
	return override, nil
}

func (r *Resource) removeComponent(component *ical.Component) {
	r.Overrides = removed(r.Overrides, component)
	r.cal.Children = removed(r.cal.Children, component)
}

func removed(components []*ical.Component, target *ical.Component) []*ical.Component {
	kept := components[:0]
	for _, component := range components {
		if component != target {
			kept = append(kept, component)
		}
	}
	return kept
}

func (r *Resource) excludeInstance(instant dateTime) {
	if override := r.override(instant); override != nil {
		r.removeComponent(override)
	}
	if r.Master != nil {
		r.Master.Props.Add(r.instanceProp(ical.PropExceptionDates, instant.Time))
	}
	r.MarkChanged()
}

func (r *Resource) endBefore(instant dateTime) bool {
	timing, err := r.timing(r.Master)
	if err != nil || !instant.Time.After(timing.start.Time) {
		return false
	}
	if rule := r.Master.Props.Get(ical.PropRecurrenceRule); rule != nil {
		until := instant.Time.Add(-time.Second).UTC().Format(utcDateTimeLayout)
		if timing.start.AllDay {
			until = instant.Time.AddDate(0, 0, -1).Format(dateLayout)
		}
		rule.Value = strings.Join(append(ruleParts(rule.Value, "COUNT", "UNTIL"), "UNTIL="+until), ";")
	}
	r.trimRecurrenceDates(instant.Time)
	for _, override := range append([]*ical.Component(nil), r.Overrides...) {
		if recurrenceID, err := r.zones.dateTime(override.Props.Get(ical.PropRecurrenceID)); err == nil && !recurrenceID.Time.Before(instant.Time) {
			r.removeComponent(override)
		}
	}
	r.MarkChanged()
	return true
}

func (r *Resource) trimRecurrenceDates(before time.Time) {
	var kept []ical.Prop
	for i := range r.Master.Props[ical.PropRecurrenceDates] {
		periods, err := r.zones.dateTimeList(&r.Master.Props[ical.PropRecurrenceDates][i])
		if err != nil {
			continue
		}
		for _, entry := range periods {
			if entry.Start.Time.Before(before) {
				kept = append(kept, *r.instanceProp(ical.PropRecurrenceDates, entry.Start.Time))
			}
		}
	}
	r.Master.Props.Del(ical.PropRecurrenceDates)
	if len(kept) > 0 {
		r.Master.Props[ical.PropRecurrenceDates] = kept
	}
}

func ruleParts(rule string, without ...string) []string {
	var parts []string
	for _, part := range strings.Split(rule, ";") {
		key, _, _ := strings.Cut(part, "=")
		skip := false
		for _, name := range without {
			if strings.EqualFold(key, name) {
				skip = true
			}
		}
		if !skip && part != "" {
			parts = append(parts, part)
		}
	}
	return parts
}

func (r *Resource) remainingCount(instant dateTime) (int, error) {
	rule := r.Master.Props.Get(ical.PropRecurrenceRule)
	if rule == nil {
		return 0, nil
	}
	timing, err := r.timing(r.Master)
	if err != nil {
		return 0, err
	}
	options, err := ruleOptions(rule.Value, timing.start)
	if err != nil || options.Count == 0 {
		return 0, err
	}
	set, err := r.instances(timing)
	if err != nil {
		return 0, err
	}
	before := 0
	for steps := 0; steps < maxIteratedInstances; steps++ {
		start, ok := set.next()
		if !ok || !start.Before(instant.Time) {
			break
		}
		before++
	}
	return max(options.Count-before, 1), nil
}

func (r *Resource) continuation(instant dateTime, remaining int) (*Resource, error) {
	timing, err := r.timing(r.Master)
	if err != nil {
		return nil, err
	}
	master := cloneComponent(r.Master)
	for _, name := range []string{ical.PropRecurrenceID, ical.PropExceptionDates, ical.PropRecurrenceDates, ical.PropDuration} {
		master.Props.Del(name)
	}
	master.Props.SetText(ical.PropUID, randomHex(16)+"@polder")
	master.Props.Set(r.instanceProp(ical.PropDateTimeStart, instant.Time))
	master.Props.Set(r.instanceProp(ical.PropDateTimeEnd, instant.Time.Add(timing.duration)))
	if rule := master.Props.Get(ical.PropRecurrenceRule); rule != nil && remaining > 0 {
		rule.Value = strings.Join(append(ruleParts(rule.Value, "COUNT", "UNTIL"), "COUNT="+strconv.Itoa(remaining)), ";")
	}
	cal := ical.NewCalendar()
	cal.Props.SetText(ical.PropVersion, "2.0")
	cal.Props.SetText(ical.PropProductID, ProductID)
	for _, child := range r.cal.Children {
		if child.Name == ical.CompTimezone {
			cal.Children = append(cal.Children, child)
		}
	}
	cal.Children = append(cal.Children, master)
	return FromCalendar(cal, r.zones.floating)
}
