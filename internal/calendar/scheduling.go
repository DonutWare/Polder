package calendar

import (
	"bytes"
	"context"
	"net/url"
	"slices"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/emersion/go-ical"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

type schedulingRole int

const (
	roleNone schedulingRole = iota
	roleOrganizer
	roleAttendee
)

const (
	PrincipalsPath = "/dav/principals/"

	methodRequest = "REQUEST"
	methodCancel  = "CANCEL"
	methodReply   = "REPLY"

	PartstatNeedsAction = "NEEDS-ACTION"
	PartstatAccepted    = "ACCEPTED"
	PartstatDeclined    = "DECLINED"
	PartstatTentative   = "TENTATIVE"

	paramScheduleAgent     = "SCHEDULE-AGENT"
	paramScheduleStatus    = "SCHEDULE-STATUS"
	paramScheduleForceSend = "SCHEDULE-FORCE-SEND"

	statusSent          = "1.1"
	statusDelivered     = "1.2"
	statusReplied       = "2.0"
	statusUndeliverable = "5.1"

	statusCancelled = "CANCELLED"
	mailtoPrefix    = "mailto:"
)

type itipMessage struct {
	method    string
	sender    string
	recipient string
	calendar  *ical.Calendar
	uid       string
	summary   string
}

type schedulingPlan struct {
	role          schedulingRole
	fromOrganizer bool
	messages      []itipMessage
}

func PrincipalHref(username string) string {
	return PrincipalsPath + url.PathEscape(username) + "/"
}

func Addresses(user users.User) []string {
	var addresses []string
	if user.Profile.Email != "" {
		addresses = append(addresses, mailtoPrefix+user.Profile.Email)
	}
	return append(addresses, PrincipalHref(user.Username))
}

func normalizeAddress(address string) string {
	address = strings.TrimSpace(address)
	if rest, ok := cutPrefixFold(address, mailtoPrefix); ok {
		return mailtoPrefix + strings.ToLower(rest)
	}
	if parsed, err := url.Parse(address); err == nil && parsed.Path != "" {
		return strings.TrimSuffix(parsed.Path, "/") + "/"
	}
	return address
}

func cutPrefixFold(value, prefix string) (string, bool) {
	if len(value) >= len(prefix) && strings.EqualFold(value[:len(prefix)], prefix) {
		return value[len(prefix):], true
	}
	return value, false
}

type addressSet map[string]bool

func addressesOf(user users.User) addressSet {
	set := addressSet{}
	for _, address := range Addresses(user) {
		set[normalizeAddress(address)] = true
	}
	return set
}

func (a addressSet) has(address string) bool {
	return a[normalizeAddress(address)]
}

func (s *Service) userByAddress(ctx context.Context, address string) (users.User, bool) {
	normalized := normalizeAddress(address)
	if email, ok := strings.CutPrefix(normalized, mailtoPrefix); ok {
		user, err := s.users.ByEmail(ctx, email)
		return user, err == nil && !user.Disabled
	}
	if rest, ok := strings.CutPrefix(normalized, PrincipalsPath); ok {
		username, err := url.PathUnescape(strings.TrimSuffix(rest, "/"))
		if err != nil {
			return users.User{}, false
		}
		user, err := s.users.ByUsername(ctx, username)
		return user, err == nil && !user.Disabled
	}
	return users.User{}, false
}

func organizerOf(resource *Resource) *ical.Prop {
	return resource.Primary().Props.Get(ical.PropOrganizer)
}

func (s *Service) planScheduling(ctx context.Context, owner users.User, previous, current *Resource) (schedulingPlan, error) {
	reference := current
	if reference == nil {
		reference = previous
	}
	if reference == nil {
		return schedulingPlan{}, nil
	}
	organizer := organizerOf(reference)
	if organizer == nil && previous != nil {
		organizer = organizerOf(previous)
	}
	if organizer == nil {
		return schedulingPlan{}, nil
	}
	own := addressesOf(owner)
	if own.has(organizer.Value) {
		if current != nil {
			if err := sameOrganizer(current, organizer.Value); err != nil {
				return schedulingPlan{}, err
			}
		}
		return s.organizerPlan(ctx, own, organizer.Value, previous, current), nil
	}
	if len(ownAttendees(reference, own)) > 0 {
		return attendeePlan(own, organizer, previous, current), nil
	}
	return schedulingPlan{}, nil
}

func sameOrganizer(resource *Resource, organizer string) error {
	for _, component := range resource.Components() {
		if prop := component.Props.Get(ical.PropOrganizer); prop != nil && normalizeAddress(prop.Value) != normalizeAddress(organizer) {
			return violation(ConditionSameOrganizer, apperr.KindInvalid, "every VEVENT of an event has the same ORGANIZER")
		}
	}
	return nil
}

func (s *Service) organizerPlan(ctx context.Context, own addressSet, organizer string, previous, current *Resource) schedulingPlan {
	plan := schedulingPlan{role: roleOrganizer}
	previousAttendees := scheduledAttendees(previous, own)
	if current == nil {
		for _, address := range previousAttendees {
			plan.messages = append(plan.messages, cancelMessage(organizer, address, previous))
		}
		return plan
	}
	changed := previous == nil || fingerprint(previous) != fingerprint(current)
	currentAttendees := scheduledAttendees(current, own)
	for _, address := range currentAttendees {
		forced := clearForceSend(current, address)
		if !changed && !forced && slices.Contains(previousAttendees, address) {
			continue
		}
		setScheduleStatus(current, address, s.deliveryStatus(ctx, address))
		plan.messages = append(plan.messages, itipMessage{
			method: methodRequest, sender: organizer, recipient: address, calendar: requestCalendar(current),
			uid: current.UID, summary: current.Summary(),
		})
	}
	for _, address := range previousAttendees {
		if !slices.Contains(currentAttendees, address) {
			plan.messages = append(plan.messages, cancelMessage(organizer, address, previous))
		}
	}
	return plan
}

func cancelMessage(organizer, address string, previous *Resource) itipMessage {
	return itipMessage{
		method: methodCancel, sender: organizer, recipient: address, calendar: cancelCalendar(previous, address),
		uid: previous.UID, summary: previous.Summary(),
	}
}

func (s *Service) deliveryStatus(ctx context.Context, address string) string {
	if _, internal := s.userByAddress(ctx, address); internal {
		return statusDelivered
	}
	if strings.HasPrefix(normalizeAddress(address), mailtoPrefix) && s.options.Mailer != nil && s.options.Mailer.Configured() {
		return statusSent
	}
	return statusUndeliverable
}

func scheduledAttendees(resource *Resource, own addressSet) []string {
	if resource == nil {
		return nil
	}
	seen := map[string]bool{}
	var addresses []string
	for _, component := range resource.Components() {
		for _, attendee := range component.Props.Values(ical.PropAttendee) {
			normalized := normalizeAddress(attendee.Value)
			agent := strings.ToUpper(attendee.Params.Get(paramScheduleAgent))
			if own.has(attendee.Value) || seen[normalized] || (agent != "" && agent != "SERVER") {
				continue
			}
			seen[normalized] = true
			addresses = append(addresses, attendee.Value)
		}
	}
	return addresses
}

func ownAttendees(resource *Resource, own addressSet) []*ical.Prop {
	var props []*ical.Prop
	for _, component := range resource.Components() {
		for i := range component.Props[ical.PropAttendee] {
			if own.has(component.Props[ical.PropAttendee][i].Value) {
				props = append(props, &component.Props[ical.PropAttendee][i])
			}
		}
	}
	return props
}

func forEachAttendee(resource *Resource, address string, change func(*ical.Prop)) {
	normalized := normalizeAddress(address)
	for _, component := range resource.Components() {
		for i := range component.Props[ical.PropAttendee] {
			if normalizeAddress(component.Props[ical.PropAttendee][i].Value) == normalized {
				change(&component.Props[ical.PropAttendee][i])
			}
		}
	}
}

func setScheduleStatus(resource *Resource, address, status string) {
	forEachAttendee(resource, address, func(attendee *ical.Prop) {
		if attendee.Params.Get(paramScheduleStatus) != status {
			attendee.Params.Set(paramScheduleStatus, status)
			resource.MarkChanged()
		}
	})
}

func clearForceSend(resource *Resource, address string) bool {
	forced := false
	forEachAttendee(resource, address, func(attendee *ical.Prop) {
		if attendee.Params.Get(paramScheduleForceSend) != "" {
			attendee.Params.Del(paramScheduleForceSend)
			resource.MarkChanged()
			forced = true
		}
	})
	return forced
}

func attendeePlan(own addressSet, organizer *ical.Prop, previous, current *Resource) schedulingPlan {
	plan := schedulingPlan{role: roleAttendee}
	if strings.EqualFold(organizer.Params.Get(paramScheduleAgent), "CLIENT") || strings.EqualFold(organizer.Params.Get(paramScheduleAgent), "NONE") {
		return plan
	}
	if current == nil {
		if ownPartstat(own, previous.Primary()) != PartstatDeclined {
			plan.messages = append(plan.messages, replyMessage(own, organizer.Value, previous, previous.Components(), PartstatDeclined))
		}
		return plan
	}
	var changed []*ical.Component
	for _, component := range current.Components() {
		before := PartstatNeedsAction
		if previous != nil {
			if counterpart := matchingComponent(previous, component); counterpart != nil {
				before = ownPartstat(own, counterpart)
			}
		}
		if ownPartstat(own, component) != before {
			changed = append(changed, component)
		}
	}
	if len(changed) > 0 {
		plan.messages = append(plan.messages, replyMessage(own, organizer.Value, current, changed, ""))
	}
	return plan
}

func ownPartstat(own addressSet, component *ical.Component) string {
	for _, attendee := range component.Props.Values(ical.PropAttendee) {
		if own.has(attendee.Value) {
			if partstat := strings.ToUpper(attendee.Params.Get(ical.ParamParticipationStatus)); partstat != "" {
				return partstat
			}
			return PartstatNeedsAction
		}
	}
	return PartstatNeedsAction
}

func matchingComponent(resource *Resource, component *ical.Component) *ical.Component {
	key := recurrenceKey(component)
	for _, candidate := range resource.Components() {
		if recurrenceKey(candidate) == key {
			return candidate
		}
	}
	return nil
}

func recurrenceKey(component *ical.Component) string {
	if prop := component.Props.Get(ical.PropRecurrenceID); prop != nil {
		return prop.Value
	}
	return ""
}

func replyMessage(own addressSet, organizer string, resource *Resource, components []*ical.Component, partstat string) itipMessage {
	reply := itipCalendar(methodReply, resource)
	var sender string
	for _, component := range components {
		trimmed := ical.NewComponent(ical.CompEvent)
		for _, name := range []string{ical.PropUID, ical.PropOrganizer, ical.PropRecurrenceID, ical.PropSequence,
			ical.PropDateTimeStart, ical.PropDateTimeEnd, ical.PropDuration, ical.PropSummary} {
			if prop := component.Props.Get(name); prop != nil {
				trimmed.Props.Set(cloneProp(prop))
			}
		}
		trimmed.Props.SetDateTime(ical.PropDateTimeStamp, time.Now().UTC())
		for _, attendee := range component.Props.Values(ical.PropAttendee) {
			if !own.has(attendee.Value) {
				continue
			}
			copied := cloneProp(&attendee)
			if partstat != "" {
				copied.Params.Set(ical.ParamParticipationStatus, partstat)
			}
			copied.Params.Del(paramScheduleStatus)
			trimmed.Props.Add(copied)
			sender = attendee.Value
		}
		reply.Children = append(reply.Children, trimmed)
	}
	return itipMessage{method: methodReply, sender: sender, recipient: organizer, calendar: reply, uid: resource.UID, summary: resource.Summary()}
}

func itipCalendar(method string, source *Resource) *ical.Calendar {
	cal := ical.NewCalendar()
	cal.Props.SetText(ical.PropVersion, "2.0")
	cal.Props.SetText(ical.PropProductID, ProductID)
	cal.Props.SetText(ical.PropMethod, method)
	for _, child := range source.cal.Children {
		if child.Name == ical.CompTimezone {
			cal.Children = append(cal.Children, child)
		}
	}
	return cal
}

func requestCalendar(resource *Resource) *ical.Calendar {
	request := itipCalendar(methodRequest, resource)
	for _, component := range resource.Components() {
		copied := cloneComponent(component)
		copied.Children = withoutAlarms(copied.Children)
		for i := range copied.Props[ical.PropAttendee] {
			copied.Props[ical.PropAttendee][i].Params.Del(paramScheduleStatus)
		}
		request.Children = append(request.Children, copied)
	}
	return request
}

func cancelCalendar(resource *Resource, address string) *ical.Calendar {
	cancel := itipCalendar(methodCancel, resource)
	copied := cloneComponent(resource.Primary())
	copied.Children = nil
	copied.Props.SetText(ical.PropStatus, statusCancelled)
	copied.Props.Del(ical.PropAttendee)
	normalized := normalizeAddress(address)
	for _, attendee := range resource.Primary().Props.Values(ical.PropAttendee) {
		if normalizeAddress(attendee.Value) == normalized {
			kept := cloneProp(&attendee)
			kept.Params.Del(paramScheduleStatus)
			copied.Props.Add(kept)
		}
	}
	bumpSequence(copied)
	cancel.Children = append(cancel.Children, copied)
	return cancel
}

func withoutAlarms(children []*ical.Component) []*ical.Component {
	var kept []*ical.Component
	for _, child := range children {
		if child.Name != ical.CompAlarm {
			kept = append(kept, child)
		}
	}
	return kept
}

func bumpSequence(component *ical.Component) {
	sequence := 0
	if prop := component.Props.Get(ical.PropSequence); prop != nil {
		if value, err := prop.Int(); err == nil {
			sequence = value
		}
	}
	component.Props.Set(rawProp(ical.PropSequence, strconv.Itoa(sequence+1)))
}

func cloneComponent(component *ical.Component) *ical.Component {
	copied := ical.NewComponent(component.Name)
	for name, props := range component.Props {
		for i := range props {
			copied.Props[name] = append(copied.Props[name], *cloneProp(&props[i]))
		}
	}
	for _, child := range component.Children {
		copied.Children = append(copied.Children, cloneComponent(child))
	}
	return copied
}

func cloneProp(prop *ical.Prop) *ical.Prop {
	copied := &ical.Prop{Name: prop.Name, Value: prop.Value, Params: ical.Params{}}
	for name, values := range prop.Params {
		copied.Params[name] = append([]string(nil), values...)
	}
	return copied
}

var fingerprintIgnoredProps = map[string]bool{
	ical.PropDateTimeStamp: true, ical.PropLastModified: true, ical.PropSequence: true, ical.PropCreated: true,
}

var fingerprintIgnoredParams = map[string]bool{
	ical.ParamParticipationStatus: true, paramScheduleStatus: true, ical.ParamRSVP: true, paramScheduleForceSend: true,
}

func fingerprint(resource *Resource) string {
	var parts []string
	for _, component := range resource.Components() {
		parts = append(parts, componentFingerprint(component))
	}
	sort.Strings(parts)
	return strings.Join(parts, "\n--\n")
}

func componentFingerprint(component *ical.Component) string {
	var lines []string
	for name, props := range component.Props {
		if fingerprintIgnoredProps[name] || strings.HasPrefix(name, "X-") {
			continue
		}
		for _, prop := range props {
			lines = append(lines, name+paramsFingerprint(prop.Params)+":"+prop.Value)
		}
	}
	sort.Strings(lines)
	return strings.Join(lines, "\n")
}

func paramsFingerprint(params ical.Params) string {
	var parts []string
	for name, values := range params {
		if !fingerprintIgnoredParams[name] {
			parts = append(parts, name+"="+strings.Join(values, ","))
		}
	}
	sort.Strings(parts)
	return ";" + strings.Join(parts, ";")
}

func (s *Service) deliver(ctx context.Context, owner users.User, plan schedulingPlan, objectID int64) {
	for _, message := range plan.messages {
		if err := s.deliverMessage(ctx, owner, message, objectID); err != nil {
			logger.Warn("deliver a calendar invitation", "method", message.method, "uid", message.uid, "recipient", message.recipient, "error", err)
		}
	}
}

func (s *Service) deliverMessage(ctx context.Context, owner users.User, message itipMessage, objectID int64) error {
	data, err := encodeCalendar(message.calendar)
	if err != nil {
		return err
	}
	recipient, internal := s.userByAddress(ctx, message.recipient)
	if internal {
		if recipient.ID == owner.ID {
			return nil
		}
		if err := s.store.AddInbox(ctx, recipient.ID, message, data); err != nil {
			return err
		}
		return s.applyMessage(ctx, recipient, message)
	}
	return s.sendInvitationMail(ctx, owner, message, data, objectID)
}

func (s *Service) applyMessage(ctx context.Context, recipient users.User, message itipMessage) error {
	switch message.method {
	case methodRequest:
		return s.applyRequest(ctx, recipient, message)
	case methodCancel:
		return s.applyCancel(ctx, recipient, message)
	case methodReply:
		return s.applyReply(ctx, recipient, message)
	}
	return nil
}

func (s *Service) scheduledCopy(ctx context.Context, recipient users.User, uid string) (Calendar, Object, bool, error) {
	objects, err := s.store.ObjectsByUIDForOwner(ctx, recipient.ID, uid)
	if err != nil || len(objects) == 0 {
		return Calendar{}, Object{}, false, err
	}
	c, err := s.store.CalendarByID(ctx, objects[0].CalendarID)
	c.Access = AccessOwner
	return c, objects[0], err == nil, err
}

func (s *Service) applyRequest(ctx context.Context, recipient users.User, message itipMessage) error {
	c, existing, found, err := s.scheduledCopy(ctx, recipient, message.uid)
	if err != nil {
		return err
	}
	uri := ObjectURIForUID(message.uid)
	if found {
		uri = existing.URI
	} else if c, err = s.DefaultCalendar(ctx, recipient); err != nil {
		return err
	}
	incoming, err := FromCalendar(copyWithoutMethod(message.calendar), c.Location())
	if err != nil {
		return err
	}
	if found {
		if previous, err := Parse(existing.Data, c.Location()); err == nil {
			keepAttendeeState(incoming, previous, addressesOf(recipient))
		}
	}
	_, err = s.save(ctx, c, uri, incoming, newScheduleTag())
	return err
}

func keepAttendeeState(incoming, previous *Resource, own addressSet) {
	for _, component := range incoming.Components() {
		counterpart := matchingComponent(previous, component)
		if counterpart == nil {
			continue
		}
		partstat := ownPartstat(own, counterpart)
		for i := range component.Props[ical.PropAttendee] {
			if own.has(component.Props[ical.PropAttendee][i].Value) {
				component.Props[ical.PropAttendee][i].Params.Set(ical.ParamParticipationStatus, partstat)
			}
		}
		for _, child := range counterpart.Children {
			if child.Name == ical.CompAlarm {
				component.Children = append(component.Children, child)
			}
		}
	}
}

func (s *Service) applyCancel(ctx context.Context, recipient users.User, message itipMessage) error {
	c, existing, found, err := s.scheduledCopy(ctx, recipient, message.uid)
	if err != nil || !found {
		return err
	}
	resource, err := Parse(existing.Data, c.Location())
	if err != nil {
		return err
	}
	for _, component := range resource.Components() {
		component.Props.SetText(ical.PropStatus, statusCancelled)
	}
	resource.MarkChanged()
	_, err = s.save(ctx, c, existing.URI, resource, newScheduleTag())
	return err
}

func (s *Service) applyReply(ctx context.Context, organizer users.User, message itipMessage) error {
	c, existing, found, err := s.scheduledCopy(ctx, organizer, message.uid)
	if err != nil || !found {
		return err
	}
	resource, err := Parse(existing.Data, c.Location())
	if err != nil {
		return err
	}
	if !applyReplyComponents(resource, message.calendar) {
		return nil
	}
	_, err = s.save(ctx, c, existing.URI, resource, existing.ScheduleTag)
	return err
}

func applyReplyComponents(resource *Resource, reply *ical.Calendar) bool {
	changed := false
	for _, replied := range reply.Children {
		if replied.Name != ical.CompEvent {
			continue
		}
		target := matchingComponent(resource, replied)
		if target == nil {
			target = resource.Master
		}
		if target == nil {
			continue
		}
		for _, attendee := range replied.Props.Values(ical.PropAttendee) {
			partstat := attendee.Params.Get(ical.ParamParticipationStatus)
			normalized := normalizeAddress(attendee.Value)
			for i := range target.Props[ical.PropAttendee] {
				existing := &target.Props[ical.PropAttendee][i]
				if normalizeAddress(existing.Value) == normalized {
					existing.Params.Set(ical.ParamParticipationStatus, partstat)
					existing.Params.Set(paramScheduleStatus, statusReplied)
					changed = true
				}
			}
		}
	}
	if changed {
		resource.MarkChanged()
	}
	return changed
}

func copyWithoutMethod(cal *ical.Calendar) *ical.Calendar {
	copied := ical.NewCalendar()
	for name, props := range cal.Props {
		if name != ical.PropMethod {
			copied.Props[name] = props
		}
	}
	for _, child := range cal.Children {
		copied.Children = append(copied.Children, cloneComponent(child))
	}
	return copied
}

func encodeCalendar(cal *ical.Calendar) ([]byte, error) {
	var buffer bytes.Buffer
	if err := ical.NewEncoder(&buffer).Encode(cal); err != nil {
		return nil, err
	}
	return buffer.Bytes(), nil
}
