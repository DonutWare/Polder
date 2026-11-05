package calendar

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"strings"
	"unicode"

	"github.com/emersion/go-ical"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

const (
	maxObjectURILength = 255
	maxSummaryLength   = 512
)

var ErrSyncTokenExpired = apperr.New(apperr.KindPrecondition, "the sync token is no longer valid; sync from scratch")

type Preconditions struct {
	IfMatch            string
	IfNoneMatch        string
	IfScheduleTagMatch string
}

type PutResult struct {
	Object    Object
	Created   bool
	Rewritten bool
}

func ValidObjectURI(uri string) bool {
	if uri == "" || uri == "." || uri == ".." || len(uri) > maxObjectURILength {
		return false
	}
	return !strings.ContainsFunc(uri, func(r rune) bool { return r == '/' || r == '\\' || unicode.IsControl(r) })
}

func requireReadable(c Calendar) error {
	if !c.Access.CanReadEvents() {
		return apperr.Forbidden("you may only see when this calendar is busy")
	}
	return nil
}

func requireWritable(c Calendar) error {
	if c.Kind == KindSubscription {
		return apperr.Forbidden("a subscribed calendar is read-only")
	}
	if !c.Access.CanEdit() {
		return apperr.Forbidden("this calendar is read-only for you")
	}
	return nil
}

func (s *Service) Object(ctx context.Context, c Calendar, uri string) (Object, error) {
	if err := requireReadable(c); err != nil {
		return Object{}, err
	}
	return s.store.Object(ctx, c.ID, uri)
}

func (s *Service) ObjectByID(ctx context.Context, c Calendar, id int64) (Object, error) {
	if err := requireReadable(c); err != nil {
		return Object{}, err
	}
	object, err := s.store.ObjectByID(ctx, id)
	if err != nil || object.CalendarID != c.ID {
		return Object{}, objectNotFound()
	}
	return object, nil
}

func (s *Service) ObjectMetas(ctx context.Context, c Calendar) ([]Object, error) {
	if err := requireReadable(c); err != nil {
		return nil, err
	}
	return s.store.ObjectMetas(ctx, c.ID)
}

func (s *Service) Objects(ctx context.Context, c Calendar) ([]Object, error) {
	if err := requireReadable(c); err != nil {
		return nil, err
	}
	return s.store.Objects(ctx, c.ID)
}

func (s *Service) ObjectsByURIs(ctx context.Context, c Calendar, uris []string) ([]Object, error) {
	if err := requireReadable(c); err != nil {
		return nil, err
	}
	return s.store.ObjectsByURIs(ctx, c.ID, uris)
}

func (s *Service) Query(ctx context.Context, c Calendar, filter CompFilter) ([]Object, error) {
	if err := requireReadable(c); err != nil {
		return nil, err
	}
	window := TimeRange{}
	if eventRange := filter.EventRange(); eventRange != nil {
		window = *eventRange
	}
	candidates, err := s.store.ObjectsInRange(ctx, []int64{c.ID}, window)
	if err != nil {
		return nil, err
	}
	matches := []Object{}
	for _, object := range candidates {
		resource, err := Parse(object.Data, c.Location())
		if err != nil {
			logger.Warn("stored event cannot be read", "calendar", c.ID, "uri", object.URI, "error", err)
			continue
		}
		matched, err := resource.Matches(filter)
		if err != nil {
			return nil, err
		}
		if matched {
			matches = append(matches, object)
		}
	}
	return matches, nil
}

func (s *Service) Changes(ctx context.Context, c Calendar, since int64) ([]Change, error) {
	if err := requireReadable(c); err != nil {
		return nil, err
	}
	if since < c.PrunedRevision || since > c.SyncRevision {
		return nil, ErrSyncTokenExpired
	}
	return s.store.ChangesSince(ctx, c.ID, since)
}

func (s *Service) PutObject(ctx context.Context, viewer users.User, c Calendar, uri string, data []byte, preconditions Preconditions) (PutResult, error) {
	if err := requireWritable(c); err != nil {
		return PutResult{}, err
	}
	if !ValidObjectURI(uri) {
		return PutResult{}, apperr.Invalid("%q cannot name an event", uri)
	}
	if len(data) > s.options.MaxResourceBytes {
		return PutResult{}, violation(ConditionMaxResourceSize, apperr.KindInvalid, "an event holds at most %d bytes", s.options.MaxResourceBytes)
	}
	existing, exists, err := s.existing(ctx, c.ID, uri)
	if err != nil {
		return PutResult{}, err
	}
	if err := checkPreconditions(existing, exists, preconditions); err != nil {
		return PutResult{}, err
	}
	resource, err := Parse(data, c.Location())
	if err != nil {
		return PutResult{}, err
	}
	if err := s.checkUID(ctx, c, uri, resource.UID, existing, exists); err != nil {
		return PutResult{}, err
	}
	object, err := s.write(ctx, viewer, c, uri, resource, existingResource(existing, exists, c))
	if err != nil {
		return PutResult{}, err
	}
	return PutResult{Object: object, Created: !exists, Rewritten: resource.Changed()}, nil
}

func existingResource(existing Object, exists bool, c Calendar) *Resource {
	if !exists {
		return nil
	}
	resource, err := Parse(existing.Data, c.Location())
	if err != nil {
		return nil
	}
	return resource
}

func (s *Service) existing(ctx context.Context, calendarID int64, uri string) (Object, bool, error) {
	object, err := s.store.Object(ctx, calendarID, uri)
	if apperr.Is(err, apperr.KindNotFound) {
		return Object{}, false, nil
	}
	return object, err == nil, err
}

func (s *Service) checkUID(ctx context.Context, c Calendar, uri, uid string, existing Object, exists bool) error {
	if exists && existing.UID != uid {
		return violation(ConditionNoUIDConflict, apperr.KindConflict, "an event keeps its UID; %s has UID %s", uri, existing.UID)
	}
	other, err := s.store.ObjectByUID(ctx, c.ID, uid)
	switch {
	case err == nil && other.URI != uri:
		return violation(ConditionNoUIDConflict, apperr.KindConflict, "the event %s already has UID %s", other.URI, uid)
	case err != nil && !apperr.Is(err, apperr.KindNotFound):
		return err
	}
	if exists {
		return nil
	}
	count, err := s.store.CountObjects(ctx, c.ID)
	if err != nil {
		return err
	}
	if count >= s.options.MaxObjectsPerCalendar {
		return apperr.New(apperr.KindQuotaExceeded, "a calendar holds at most %d events", s.options.MaxObjectsPerCalendar)
	}
	return nil
}

func (s *Service) write(ctx context.Context, viewer users.User, c Calendar, uri string, resource, previous *Resource) (Object, error) {
	owner, err := s.calendarOwner(ctx, viewer, c)
	if err != nil {
		return Object{}, err
	}
	plan, err := s.planScheduling(ctx, owner, previous, resource)
	if err != nil {
		return Object{}, err
	}
	scheduleTag, err := s.scheduleTag(ctx, c.ID, uri, plan)
	if err != nil {
		return Object{}, err
	}
	object, err := s.save(ctx, c, uri, resource, scheduleTag)
	if err != nil {
		return Object{}, err
	}
	s.deliver(ctx, owner, plan, object.ID)
	return object, nil
}

func (s *Service) calendarOwner(ctx context.Context, viewer users.User, c Calendar) (users.User, error) {
	if c.OwnerID == viewer.ID {
		return viewer, nil
	}
	return s.users.ByID(ctx, c.OwnerID)
}

func (s *Service) scheduleTag(ctx context.Context, calendarID int64, uri string, plan schedulingPlan) (string, error) {
	if plan.role == roleNone {
		return "", nil
	}
	if plan.role == roleAttendee && !plan.fromOrganizer {
		existing, exists, err := s.existing(ctx, calendarID, uri)
		if err != nil || (exists && existing.ScheduleTag != "") {
			return existing.ScheduleTag, err
		}
	}
	return newScheduleTag(), nil
}

func (s *Service) save(ctx context.Context, c Calendar, uri string, resource *Resource, scheduleTag string) (Object, error) {
	if resource.Changed() {
		resource.ensureTimezones()
	}
	data, err := resource.Bytes()
	if err != nil {
		return Object{}, err
	}
	if len(data) > s.options.MaxResourceBytes {
		return Object{}, violation(ConditionMaxResourceSize, apperr.KindInvalid, "an event holds at most %d bytes", s.options.MaxResourceBytes)
	}
	bounds, err := resource.Bounds()
	if err != nil {
		return Object{}, err
	}
	stored, err := s.store.PutObject(ctx, Object{
		CalendarID: c.ID, URI: uri, UID: resource.UID, ETag: etagOf(data), ScheduleTag: scheduleTag, Data: data,
		FirstStart: bounds.FirstStart, LastEnd: bounds.LastEnd, Recurring: resource.Recurring(), HasAlarms: resource.HasAlarms(),
		Summary: truncate(resource.Summary(), maxSummaryLength),
	})
	if err != nil {
		return Object{}, err
	}
	s.publishCalendar(ctx, c)
	return stored, nil
}

func (s *Service) DeleteObject(ctx context.Context, viewer users.User, c Calendar, uri string, preconditions Preconditions) error {
	if err := requireWritable(c); err != nil {
		return err
	}
	existing, exists, err := s.existing(ctx, c.ID, uri)
	if err != nil {
		return err
	}
	if !exists {
		return objectNotFound()
	}
	if err := checkPreconditions(existing, true, preconditions); err != nil {
		return err
	}
	owner, err := s.calendarOwner(ctx, viewer, c)
	if err != nil {
		return err
	}
	plan, err := s.planScheduling(ctx, owner, existingResource(existing, true, c), nil)
	if err != nil {
		return err
	}
	if err := s.store.DeleteObject(ctx, c.ID, uri); err != nil {
		return err
	}
	s.publishCalendar(ctx, c)
	s.deliver(ctx, owner, plan, 0)
	return nil
}

func checkPreconditions(existing Object, exists bool, preconditions Preconditions) error {
	failed := apperr.New(apperr.KindPrecondition, "the event has changed")
	switch {
	case preconditions.IfNoneMatch == "*" && exists:
		return apperr.New(apperr.KindPrecondition, "the event already exists")
	case preconditions.IfNoneMatch != "" && exists && etagListContains(preconditions.IfNoneMatch, existing.ETag):
		return failed
	case preconditions.IfMatch != "" && !exists:
		return apperr.New(apperr.KindPrecondition, "the event does not exist")
	case preconditions.IfMatch != "" && preconditions.IfMatch != "*" && !etagListContains(preconditions.IfMatch, existing.ETag):
		return failed
	case preconditions.IfScheduleTagMatch != "" && (!exists || !etagListContains(preconditions.IfScheduleTagMatch, existing.ScheduleTag)):
		return failed
	}
	return nil
}

func etagListContains(header, etag string) bool {
	if etag == "" {
		return false
	}
	for _, candidate := range strings.Split(header, ",") {
		candidate = strings.TrimPrefix(strings.TrimSpace(candidate), "W/")
		if candidate == etag || candidate == "*" {
			return true
		}
	}
	return false
}

func etagOf(data []byte) string {
	sum := sha256.Sum256(data)
	return `"` + hex.EncodeToString(sum[:16]) + `"`
}

func newScheduleTag() string {
	return `"` + randomHex(12) + `"`
}

func randomHex(size int) string {
	buffer := make([]byte, size)
	_, _ = rand.Read(buffer)
	return hex.EncodeToString(buffer)
}

func truncate(value string, limit int) string {
	if len(value) <= limit {
		return value
	}
	cut := limit
	for cut > 0 && !utf8RuneStart(value[cut]) {
		cut--
	}
	return value[:cut]
}

func utf8RuneStart(b byte) bool {
	return b&0xC0 != 0x80
}

func (r *Resource) ensureTimezones() {
	defined := map[string]bool{}
	for _, child := range r.cal.Children {
		if child.Name == ical.CompTimezone {
			defined[propText(child, ical.PropTimezoneID)] = true
		}
	}
	year := r.timezoneYear()
	for _, tzid := range r.usedTimezones() {
		if defined[tzid] {
			continue
		}
		location, ok := ianaLocation(tzid)
		if !ok || location == nil {
			continue
		}
		r.cal.Children = append([]*ical.Component{timezoneComponent(location, year)}, r.cal.Children...)
		defined[tzid] = true
	}
}

func (r *Resource) usedTimezones() []string {
	var used []string
	seen := map[string]bool{}
	for _, component := range r.Components() {
		for _, props := range component.Props {
			for _, prop := range props {
				tzid := prop.Params.Get(ical.ParamTimezoneID)
				if tzid != "" && !seen[tzid] {
					seen[tzid] = true
					used = append(used, tzid)
				}
			}
		}
	}
	return used
}

func (r *Resource) timezoneYear() int {
	start, err := r.zones.dateTime(r.Primary().Props.Get(ical.PropDateTimeStart))
	if err != nil {
		return 2025
	}
	return start.Time.Year()
}
