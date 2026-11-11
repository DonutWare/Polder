package calendar

import (
	"context"
	"slices"
	"strings"
	"time"

	"github.com/danielgtaylor/huma/v2"
	"github.com/emersion/go-ical"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

type ShowAs string

const (
	ShowAsBusy ShowAs = "busy"
	ShowAsFree ShowAs = "free"
)

func (ShowAs) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(ShowAsBusy), string(ShowAsFree)}
	return s
}

type EditScope string

const (
	ScopeThis      EditScope = "this"
	ScopeFollowing EditScope = "following"
	ScopeAll       EditScope = "all"
)

func (EditScope) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(ScopeThis), string(ScopeFollowing), string(ScopeAll)}
	return s
}

type Person struct {
	Email string `json:"email"`
	Name  string `json:"name,omitempty" required:"false"`
	Self  bool   `json:"self" doc:"Whether this is the logged-in user"`
}

type Attendee struct {
	Person
	Status         string `json:"status" doc:"NEEDS-ACTION, ACCEPTED, DECLINED, TENTATIVE or DELEGATED"`
	Role           string `json:"role,omitempty" required:"false" doc:"REQ-PARTICIPANT, OPT-PARTICIPANT, CHAIR or NON-PARTICIPANT"`
	ScheduleStatus string `json:"scheduleStatus,omitempty" required:"false" doc:"How delivering the invitation went, as an iTIP status code"`
}

type AttendeeInput struct {
	Email string `json:"email" minLength:"3" maxLength:"254"`
	Name  string `json:"name,omitempty" required:"false" maxLength:"256"`
	Role  string `json:"role,omitempty" required:"false" doc:"REQ-PARTICIPANT (default), OPT-PARTICIPANT, CHAIR or NON-PARTICIPANT"`
}

type Alarm struct {
	Action        string     `json:"action" doc:"DISPLAY, EMAIL or AUDIO"`
	OffsetMinutes *int       `json:"offsetMinutes,omitempty" required:"false" doc:"Minutes from the start, or the end with relativeToEnd; negative is before"`
	RelativeToEnd bool       `json:"relativeToEnd,omitempty" required:"false"`
	At            *time.Time `json:"at,omitempty" required:"false" doc:"A fixed moment, instead of an offset"`
	Description   string     `json:"description,omitempty" required:"false"`
}

type Event struct {
	ID             int64      `json:"id"`
	CalendarID     int64      `json:"calendarId"`
	UID            string     `json:"uid"`
	ETag           string     `json:"etag"`
	RecurrenceID   string     `json:"recurrenceId,omitempty" required:"false" doc:"Which occurrence this is, as a UTC date-time (or date) to pass back when editing one occurrence"`
	Summary        string     `json:"summary"`
	Description    string     `json:"description,omitempty" required:"false"`
	Location       string     `json:"location,omitempty" required:"false"`
	URL            string     `json:"url,omitempty" required:"false"`
	Start          time.Time  `json:"start"`
	End            time.Time  `json:"end" doc:"Exclusive; for all-day events the day after the last day"`
	AllDay         bool       `json:"allDay"`
	Timezone       string     `json:"timezone,omitempty" required:"false" doc:"IANA timezone the event was planned in"`
	RRule          string     `json:"rrule,omitempty" required:"false"`
	ExceptionDates []string   `json:"exceptionDates,omitempty" required:"false"`
	Recurring      bool       `json:"recurring"`
	Override       bool       `json:"override" doc:"This occurrence differs from the rest of the series"`
	Status         string     `json:"status" doc:"CONFIRMED, TENTATIVE or CANCELLED"`
	ShowAs         ShowAs     `json:"showAs"`
	Categories     []string   `json:"categories,omitempty" required:"false"`
	Organizer      *Person    `json:"organizer,omitempty" required:"false"`
	Attendees      []Attendee `json:"attendees"`
	Alarms         []Alarm    `json:"alarms"`
	Sequence       int        `json:"sequence"`
	BusyOnly       bool       `json:"busyOnly" doc:"Only the time is shown because the calendar is shared as free/busy"`
	UpdatedAt      time.Time  `json:"updatedAt"`
}

type EventDetails struct {
	Event
	Overrides []Event `json:"overrides" doc:"Occurrences of the series that were changed one by one"`
}

type EventInput struct {
	UID         string          `json:"uid,omitempty" required:"false" maxLength:"255" doc:"Client-chosen UID for a new event; creating again with the same UID returns the existing event"`
	Summary     string          `json:"summary" maxLength:"1024"`
	Description string          `json:"description,omitempty" required:"false" maxLength:"65536"`
	Location    string          `json:"location,omitempty" required:"false" maxLength:"1024"`
	URL         string          `json:"url,omitempty" required:"false" maxLength:"2048"`
	Start       time.Time       `json:"start"`
	End         time.Time       `json:"end,omitzero" required:"false" doc:"Exclusive; for all-day events only the date counts; an hour after the start when empty"`
	AllDay      bool            `json:"allDay,omitempty" required:"false"`
	Timezone    string          `json:"timezone,omitempty" required:"false" doc:"IANA timezone to plan the event in; UTC when empty"`
	RRule       string          `json:"rrule,omitempty" required:"false" doc:"Recurrence rule such as FREQ=WEEKLY;BYDAY=MO,WE"`
	Status      string          `json:"status,omitempty" required:"false" doc:"CONFIRMED, TENTATIVE or CANCELLED"`
	ShowAs      ShowAs          `json:"showAs,omitempty" required:"false"`
	Categories  []string        `json:"categories,omitempty" required:"false" maxItems:"50"`
	Attendees   []AttendeeInput `json:"attendees,omitempty" required:"false" maxItems:"200"`
	Alarms      []Alarm         `json:"alarms,omitempty" required:"false" maxItems:"20"`
}

type EventChange struct {
	Scope        EditScope
	RecurrenceID string
	IfMatch      string
	Input        EventInput
}

func (s *Service) eventCalendar(ctx context.Context, viewer users.User, calendarID int64, write bool) (Calendar, error) {
	c, err := s.Get(ctx, viewer, calendarID)
	if err != nil {
		return Calendar{}, err
	}
	if write {
		return c, requireWritable(c)
	}
	return c, requireReadable(c)
}

func (s *Service) Events(ctx context.Context, viewer users.User, calendarIDs []int64, window TimeRange) ([]Event, error) {
	if err := ValidateWindow(window); err != nil {
		return nil, err
	}
	calendars, err := s.List(ctx, viewer)
	if err != nil {
		return nil, err
	}
	own := addressesOf(viewer)
	events := []Event{}
	for _, c := range calendars {
		if (len(calendarIDs) == 0 && c.Hidden) || (len(calendarIDs) > 0 && !slices.Contains(calendarIDs, c.ID)) {
			continue
		}
		listed, err := s.calendarEvents(ctx, c, own, window)
		if err != nil {
			return nil, err
		}
		events = append(events, listed...)
	}
	slices.SortStableFunc(events, func(a, b Event) int { return a.Start.Compare(b.Start) })
	return events, nil
}

func (s *Service) calendarEvents(ctx context.Context, c Calendar, own addressSet, window TimeRange) ([]Event, error) {
	objects, err := s.store.ObjectsInRange(ctx, []int64{c.ID}, window)
	if err != nil {
		return nil, err
	}
	var events []Event
	for _, object := range objects {
		resource, err := Parse(object.Data, c.Location())
		if err != nil {
			continue
		}
		occurrences, err := resource.Occurrences(window.Start, window.End)
		if err != nil {
			continue
		}
		for _, occurrence := range occurrences {
			event := describeOccurrence(c, object, resource, occurrence, own)
			if !c.Access.CanReadEvents() {
				if !blocksTime(occurrence.Component) {
					continue
				}
				event = busyOnly(event)
			}
			events = append(events, event)
		}
	}
	return events, nil
}

func busyOnly(event Event) Event {
	return Event{
		CalendarID: event.CalendarID, Start: event.Start, End: event.End, AllDay: event.AllDay, Summary: "Busy",
		Status: event.Status, ShowAs: ShowAsBusy, Recurring: event.Recurring, BusyOnly: true,
		Attendees: []Attendee{}, Alarms: []Alarm{},
	}
}

func describeOccurrence(c Calendar, object Object, resource *Resource, occurrence Occurrence, own addressSet) Event {
	event := describeComponent(c, object, resource, occurrence.Component, own)
	event.Start, event.End, event.AllDay = occurrence.Start, occurrence.End, occurrence.AllDay
	event.RecurrenceID, event.Override = occurrence.RecurrenceID, occurrence.Override
	return event
}

func describeComponent(c Calendar, object Object, resource *Resource, component *ical.Component, own addressSet) Event {
	event := Event{
		ID: object.ID, CalendarID: c.ID, UID: resource.UID, ETag: object.ETag, UpdatedAt: object.UpdatedAt,
		Summary:     propText(component, ical.PropSummary),
		Description: propText(component, ical.PropDescription),
		Location:    propText(component, ical.PropLocation),
		URL:         propText(component, ical.PropURL),
		Status:      strings.ToUpper(propText(component, ical.PropStatus)),
		ShowAs:      ShowAsBusy,
		Recurring:   resource.Recurring(),
		Attendees:   []Attendee{},
		Alarms:      []Alarm{},
	}
	if event.Status == "" {
		event.Status = "CONFIRMED"
	}
	if strings.EqualFold(propText(component, ical.PropTransparency), "TRANSPARENT") {
		event.ShowAs = ShowAsFree
	}
	if sequence := component.Props.Get(ical.PropSequence); sequence != nil {
		event.Sequence, _ = sequence.Int()
	}
	if timing, err := resource.timing(component); err == nil {
		event.Start, event.End, event.AllDay = timing.start.Time, timing.start.Time.Add(timing.duration), timing.start.AllDay
	}
	if start := component.Props.Get(ical.PropDateTimeStart); start != nil {
		if tzid := start.Params.Get(ical.ParamTimezoneID); tzid != "" {
			event.Timezone = resource.zones.location(tzid).String()
		}
	}
	if recurrenceID := component.Props.Get(ical.PropRecurrenceID); recurrenceID != nil {
		if value, err := resource.zones.dateTime(recurrenceID); err == nil {
			event.RecurrenceID, event.Override = recurrenceIDValue(value), true
		}
	}
	event.RRule = seriesRule(resource, component)
	event.ExceptionDates = exceptionDates(resource, component)
	event.Categories = categories(component)
	event.Organizer = organizerPerson(component, own)
	event.Attendees = attendeesOf(component, own)
	event.Alarms = alarmsOf(resource, component)
	return event
}

func seriesRule(resource *Resource, component *ical.Component) string {
	rule := component.Props.Get(ical.PropRecurrenceRule)
	if rule == nil && component.Props.Get(ical.PropRecurrenceID) != nil && resource.Master != nil {
		rule = resource.Master.Props.Get(ical.PropRecurrenceRule)
	}
	if rule == nil {
		return ""
	}
	return rule.Value
}

func exceptionDates(resource *Resource, component *ical.Component) []string {
	var dates []string
	for i := range component.Props[ical.PropExceptionDates] {
		periods, err := resource.zones.dateTimeList(&component.Props[ical.PropExceptionDates][i])
		if err != nil {
			continue
		}
		for _, entry := range periods {
			dates = append(dates, recurrenceIDValue(entry.Start))
		}
	}
	return dates
}

func categories(component *ical.Component) []string {
	var names []string
	for _, prop := range component.Props.Values(ical.PropCategories) {
		if list, err := prop.TextList(); err == nil {
			names = append(names, list...)
		}
	}
	return names
}

func organizerPerson(component *ical.Component, own addressSet) *Person {
	prop := component.Props.Get(ical.PropOrganizer)
	if prop == nil {
		return nil
	}
	return &Person{Email: emailOf(prop.Value), Name: prop.Params.Get(ical.ParamCommonName), Self: own.has(prop.Value)}
}

func attendeesOf(component *ical.Component, own addressSet) []Attendee {
	attendees := []Attendee{}
	for _, prop := range component.Props.Values(ical.PropAttendee) {
		status := strings.ToUpper(prop.Params.Get(ical.ParamParticipationStatus))
		if status == "" {
			status = PartstatNeedsAction
		}
		attendees = append(attendees, Attendee{
			Person:         Person{Email: emailOf(prop.Value), Name: prop.Params.Get(ical.ParamCommonName), Self: own.has(prop.Value)},
			Status:         status,
			Role:           strings.ToUpper(prop.Params.Get(ical.ParamRole)),
			ScheduleStatus: prop.Params.Get(paramScheduleStatus),
		})
	}
	return attendees
}

func emailOf(address string) string {
	if rest, ok := cutPrefixFold(address, mailtoPrefix); ok {
		return rest
	}
	return address
}

func alarmsOf(resource *Resource, component *ical.Component) []Alarm {
	alarms := []Alarm{}
	for _, child := range component.Children {
		if child.Name != ical.CompAlarm {
			continue
		}
		trigger := child.Props.Get(ical.PropTrigger)
		if trigger == nil {
			continue
		}
		alarm := Alarm{Action: strings.ToUpper(propText(child, ical.PropAction)), Description: propText(child, ical.PropDescription)}
		if strings.EqualFold(trigger.Params.Get(ical.ParamValue), string(ical.ValueDateTime)) {
			if at, err := resource.zones.dateTime(trigger); err == nil {
				alarm.At = &at.Time
			}
		} else if offset, err := parseDuration(trigger.Value); err == nil {
			minutes := int(offset / time.Minute)
			alarm.OffsetMinutes = &minutes
			alarm.RelativeToEnd = strings.EqualFold(trigger.Params.Get(ical.ParamRelated), "END")
		}
		alarms = append(alarms, alarm)
	}
	return alarms
}

func (s *Service) Event(ctx context.Context, viewer users.User, calendarID, eventID int64) (EventDetails, error) {
	c, err := s.eventCalendar(ctx, viewer, calendarID, false)
	if err != nil {
		return EventDetails{}, err
	}
	object, resource, err := s.loadEvent(ctx, c, eventID)
	if err != nil {
		return EventDetails{}, err
	}
	return describeDetails(c, object, resource, addressesOf(viewer)), nil
}

func describeDetails(c Calendar, object Object, resource *Resource, own addressSet) EventDetails {
	details := EventDetails{Event: describeComponent(c, object, resource, resource.Primary(), own), Overrides: []Event{}}
	for _, override := range resource.Overrides {
		if override != resource.Primary() {
			details.Overrides = append(details.Overrides, describeComponent(c, object, resource, override, own))
		}
	}
	return details
}

func (s *Service) loadEvent(ctx context.Context, c Calendar, eventID int64) (Object, *Resource, error) {
	object, err := s.ObjectByID(ctx, c, eventID)
	if err != nil {
		return Object{}, nil, err
	}
	resource, err := Parse(object.Data, c.Location())
	return object, resource, err
}

func (s *Service) CreateEvent(ctx context.Context, viewer users.User, calendarID int64, input EventInput) (EventDetails, error) {
	c, err := s.eventCalendar(ctx, viewer, calendarID, true)
	if err != nil {
		return EventDetails{}, err
	}
	owner, err := s.calendarOwner(ctx, viewer, c)
	if err != nil {
		return EventDetails{}, err
	}
	uid, err := newEventUID(input.UID)
	if err != nil {
		return EventDetails{}, err
	}
	if existing, found, err := s.eventWithUID(ctx, c, uid, viewer); found || err != nil {
		return existing, err
	}
	event := ical.NewComponent(ical.CompEvent)
	event.Props.SetText(ical.PropUID, uid)
	event.Props.SetDateTime(ical.PropCreated, s.now().UTC())
	if err := applyInput(event, input, owner, true); err != nil {
		return EventDetails{}, err
	}
	cal := ical.NewCalendar()
	cal.Props.SetText(ical.PropVersion, "2.0")
	cal.Props.SetText(ical.PropProductID, ProductID)
	cal.Children = append(cal.Children, event)
	resource, err := FromCalendar(cal, c.Location())
	if err != nil {
		return EventDetails{}, err
	}
	uri := ObjectURIForUID(uid)
	if err := s.checkUID(ctx, c, uri, uid, Object{}, false); err != nil {
		return EventDetails{}, err
	}
	object, err := s.write(ctx, viewer, c, uri, resource, nil)
	if err != nil {
		return EventDetails{}, err
	}
	return describeDetails(c, object, resource, addressesOf(viewer)), nil
}

func newEventUID(requested string) (string, error) {
	if requested == "" {
		return randomHex(16) + "@polder", nil
	}
	if strings.ContainsAny(requested, "\r\n") || strings.TrimSpace(requested) != requested {
		return "", apperr.Invalid("the event UID may not contain line breaks or surrounding spaces")
	}
	return requested, nil
}

func (s *Service) eventWithUID(ctx context.Context, c Calendar, uid string, viewer users.User) (EventDetails, bool, error) {
	object, err := s.store.ObjectByUID(ctx, c.ID, uid)
	if apperr.Is(err, apperr.KindNotFound) {
		return EventDetails{}, false, nil
	}
	if err != nil {
		return EventDetails{}, false, err
	}
	resource, err := Parse(object.Data, c.Location())
	if err != nil {
		return EventDetails{}, false, err
	}
	return describeDetails(c, object, resource, addressesOf(viewer)), true, nil
}

func (s *Service) UpdateEvent(ctx context.Context, viewer users.User, calendarID, eventID int64, change EventChange) (EventDetails, error) {
	c, err := s.eventCalendar(ctx, viewer, calendarID, true)
	if err != nil {
		return EventDetails{}, err
	}
	object, resource, err := s.loadEvent(ctx, c, eventID)
	if err != nil {
		return EventDetails{}, err
	}
	if change.IfMatch != "" && !etagListContains(change.IfMatch, object.ETag) {
		return EventDetails{}, apperr.New(apperr.KindPrecondition, "the event has changed")
	}
	owner, err := s.calendarOwner(ctx, viewer, c)
	if err != nil {
		return EventDetails{}, err
	}
	previous, _ := Parse(object.Data, c.Location())
	scope := effectiveScope(resource, change.Scope, change.RecurrenceID)
	switch scope {
	case ScopeThis:
		err = s.editOccurrence(resource, change, owner)
	case ScopeFollowing:
		return s.splitSeries(ctx, viewer, c, object, resource, previous, change, owner)
	default:
		err = editSeries(resource, change, owner)
	}
	if err != nil {
		return EventDetails{}, err
	}
	resource.MarkChanged()
	saved, err := s.write(ctx, viewer, c, object.URI, resource, previous)
	if err != nil {
		return EventDetails{}, err
	}
	return describeDetails(c, saved, resource, addressesOf(viewer)), nil
}

func effectiveScope(resource *Resource, scope EditScope, recurrenceID string) EditScope {
	if !resource.Recurring() || recurrenceID == "" {
		return ScopeAll
	}
	if scope == "" {
		return ScopeAll
	}
	return scope
}

var seriesTextProps = []string{ical.PropSummary, ical.PropDescription, ical.PropLocation, ical.PropURL}

func editSeries(resource *Resource, change EventChange, owner users.User) error {
	primary := resource.Primary()
	before := textValues(primary)
	edited := resource.editedOverride(change.RecurrenceID)
	if err := applyInput(primary, change.Input, owner, resource.Master != nil); err != nil {
		return err
	}
	if resource.Master == nil {
		return nil
	}
	if !resource.Recurring() {
		resource.dropOverrides()
		return nil
	}
	after := textValues(primary)
	for _, override := range resource.Overrides {
		followSeries(override, before, after, override == edited)
	}
	return nil
}

func textValues(component *ical.Component) map[string]string {
	values := make(map[string]string, len(seriesTextProps))
	for _, name := range seriesTextProps {
		values[name] = propText(component, name)
	}
	return values
}

func followSeries(override *ical.Component, before, after map[string]string, edited bool) {
	changed := false
	for _, name := range seriesTextProps {
		current := propText(override, name)
		if current == after[name] || (!edited && current != before[name]) {
			continue
		}
		if name == ical.PropURL {
			setRaw(override, name, after[name])
		} else {
			setText(override, name, after[name])
		}
		changed = true
	}
	if changed {
		override.Props.SetDateTime(ical.PropLastModified, time.Now().UTC())
		bumpSequence(override)
	}
}

func (s *Service) editOccurrence(resource *Resource, change EventChange, owner users.User) error {
	instant, err := resource.parseInstance(change.RecurrenceID)
	if err != nil {
		return err
	}
	override := resource.override(instant)
	if override == nil {
		override, err = resource.addOverride(instant)
		if err != nil {
			return err
		}
	}
	input := change.Input
	input.RRule = ""
	return applyInput(override, input, owner, false)
}

func (s *Service) splitSeries(ctx context.Context, viewer users.User, c Calendar, object Object, resource, previous *Resource, change EventChange, owner users.User) (EventDetails, error) {
	instant, err := resource.parseInstance(change.RecurrenceID)
	if err != nil {
		return EventDetails{}, err
	}
	remaining, err := resource.remainingCount(instant)
	if err != nil {
		return EventDetails{}, err
	}
	continuation, err := resource.continuation(instant, remaining)
	if err != nil {
		return EventDetails{}, err
	}
	if err := applyInput(continuation.Master, change.Input, owner, true); err != nil {
		return EventDetails{}, err
	}
	if resource.endBefore(instant) {
		resource.MarkChanged()
		if _, err := s.write(ctx, viewer, c, object.URI, resource, previous); err != nil {
			return EventDetails{}, err
		}
	} else if err := s.DeleteObject(ctx, viewer, c, object.URI, Preconditions{}); err != nil {
		return EventDetails{}, err
	}
	uri := ObjectURIForUID(continuation.UID)
	saved, err := s.write(ctx, viewer, c, uri, continuation, nil)
	if err != nil {
		return EventDetails{}, err
	}
	return describeDetails(c, saved, continuation, addressesOf(viewer)), nil
}

func (s *Service) DeleteEvent(ctx context.Context, viewer users.User, calendarID, eventID int64, scope EditScope, recurrenceID, ifMatch string) error {
	c, err := s.eventCalendar(ctx, viewer, calendarID, true)
	if err != nil {
		return err
	}
	object, resource, err := s.loadEvent(ctx, c, eventID)
	if err != nil {
		return err
	}
	if ifMatch != "" && !etagListContains(ifMatch, object.ETag) {
		return apperr.New(apperr.KindPrecondition, "the event has changed")
	}
	scope = effectiveScope(resource, scope, recurrenceID)
	if scope == ScopeAll {
		return s.DeleteObject(ctx, viewer, c, object.URI, Preconditions{})
	}
	instant, err := resource.parseInstance(recurrenceID)
	if err != nil {
		return err
	}
	previous, _ := Parse(object.Data, c.Location())
	remains := true
	if scope == ScopeThis {
		resource.excludeInstance(instant)
	} else {
		remains = resource.endBefore(instant)
	}
	if !remains {
		return s.DeleteObject(ctx, viewer, c, object.URI, Preconditions{})
	}
	resource.MarkChanged()
	_, err = s.write(ctx, viewer, c, object.URI, resource, previous)
	return err
}

func (s *Service) MoveEvent(ctx context.Context, viewer users.User, calendarID, eventID, targetID int64) (EventDetails, error) {
	source, err := s.eventCalendar(ctx, viewer, calendarID, true)
	if err != nil {
		return EventDetails{}, err
	}
	target, err := s.eventCalendar(ctx, viewer, targetID, true)
	if err != nil {
		return EventDetails{}, err
	}
	if source.ID == target.ID {
		return s.Event(ctx, viewer, calendarID, eventID)
	}
	object, resource, err := s.loadEvent(ctx, source, eventID)
	if err != nil {
		return EventDetails{}, err
	}
	if err := s.checkUID(ctx, target, object.URI, object.UID, Object{}, false); err != nil {
		return EventDetails{}, err
	}
	if _, exists, err := s.existing(ctx, target.ID, object.URI); err != nil || exists {
		if err == nil {
			err = apperr.AlreadyExists("the target calendar already has %s", object.URI)
		}
		return EventDetails{}, err
	}
	saved, err := s.save(ctx, target, object.URI, resource, object.ScheduleTag)
	if err != nil {
		return EventDetails{}, err
	}
	if err := s.store.DeleteObject(ctx, source.ID, object.URI); err != nil {
		return EventDetails{}, err
	}
	s.publishCalendar(ctx, source)
	return describeDetails(target, saved, resource, addressesOf(viewer)), nil
}

func (s *Service) RespondToEvent(ctx context.Context, viewer users.User, calendarID, eventID int64, recurrenceID, partstat string) (EventDetails, error) {
	partstat = strings.ToUpper(strings.TrimSpace(partstat))
	if partstat != PartstatAccepted && partstat != PartstatDeclined && partstat != PartstatTentative {
		return EventDetails{}, apperr.Invalid("answer with ACCEPTED, DECLINED or TENTATIVE")
	}
	c, err := s.eventCalendar(ctx, viewer, calendarID, true)
	if err != nil {
		return EventDetails{}, err
	}
	object, resource, err := s.loadEvent(ctx, c, eventID)
	if err != nil {
		return EventDetails{}, err
	}
	owner, err := s.calendarOwner(ctx, viewer, c)
	if err != nil {
		return EventDetails{}, err
	}
	previous, _ := Parse(object.Data, c.Location())
	targets := resource.Components()
	if recurrenceID != "" && resource.Recurring() {
		instant, err := resource.parseInstance(recurrenceID)
		if err != nil {
			return EventDetails{}, err
		}
		override := resource.override(instant)
		if override == nil {
			if override, err = resource.addOverride(instant); err != nil {
				return EventDetails{}, err
			}
		}
		targets = []*ical.Component{override}
	}
	own := addressesOf(owner)
	answered := false
	for _, component := range targets {
		for i := range component.Props[ical.PropAttendee] {
			if own.has(component.Props[ical.PropAttendee][i].Value) {
				component.Props[ical.PropAttendee][i].Params.Set(ical.ParamParticipationStatus, partstat)
				component.Props[ical.PropAttendee][i].Params.Del(ical.ParamRSVP)
				answered = true
			}
		}
	}
	if !answered {
		return EventDetails{}, apperr.Invalid("you are not invited to this event")
	}
	resource.MarkChanged()
	saved, err := s.write(ctx, viewer, c, object.URI, resource, previous)
	if err != nil {
		return EventDetails{}, err
	}
	return describeDetails(c, saved, resource, addressesOf(viewer)), nil
}
