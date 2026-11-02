package calendar

import (
	"context"
	"slices"
	"strings"
	"time"

	"github.com/emersion/go-ical"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

const (
	MaxWindow       = 366 * 24 * time.Hour
	maxFreeBusyUser = 50
)

type BusyPeriod struct {
	Start     time.Time `json:"start"`
	End       time.Time `json:"end"`
	Tentative bool      `json:"tentative"`
}

type UserBusy struct {
	User users.UserSummary `json:"user"`
	Busy []BusyPeriod      `json:"busy"`
}

func ValidateWindow(window TimeRange) error {
	if window.Start.IsZero() || window.End.IsZero() || !window.End.After(window.Start) {
		return apperr.Invalid("a time range needs a start before its end")
	}
	if window.End.Sub(window.Start) > MaxWindow {
		return apperr.Invalid("a time range spans at most 366 days")
	}
	return nil
}

func (s *Service) FreeBusy(ctx context.Context, viewer users.User, userIDs []int64, window TimeRange) ([]UserBusy, error) {
	if err := ValidateWindow(window); err != nil {
		return nil, err
	}
	if len(userIDs) > maxFreeBusyUser {
		return nil, apperr.Invalid("ask for at most %d people at once", maxFreeBusyUser)
	}
	result := []UserBusy{}
	for _, userID := range userIDs {
		user, err := s.users.ByID(ctx, userID)
		if err != nil {
			return nil, err
		}
		busy, err := s.userBusy(ctx, user, window)
		if err != nil {
			return nil, err
		}
		result = append(result, UserBusy{User: user.Summary(), Busy: busy})
	}
	return result, nil
}

func (s *Service) userBusy(ctx context.Context, user users.User, window TimeRange) ([]BusyPeriod, error) {
	owned, err := s.store.OwnedCalendars(ctx, user.ID)
	if err != nil {
		return nil, err
	}
	var local []Calendar
	for _, c := range owned {
		if c.Kind == KindLocal {
			local = append(local, c)
		}
	}
	return s.busyPeriods(ctx, local, addressesOf(user), window)
}

func (s *Service) CalendarBusy(ctx context.Context, viewer users.User, c Calendar, window TimeRange) ([]BusyPeriod, error) {
	if !c.Access.CanSeeBusy() {
		return nil, apperr.Forbidden("you may not see this calendar")
	}
	owner, err := s.calendarOwner(ctx, viewer, c)
	if err != nil {
		return nil, err
	}
	return s.busyPeriods(ctx, []Calendar{c}, addressesOf(owner), window)
}

func (s *Service) AddressBusy(ctx context.Context, address string, window TimeRange) ([]BusyPeriod, bool, error) {
	user, found := s.userByAddress(ctx, address)
	if !found {
		return nil, false, nil
	}
	busy, err := s.userBusy(ctx, user, window)
	return busy, true, err
}

func (s *Service) busyPeriods(ctx context.Context, calendars []Calendar, own addressSet, window TimeRange) ([]BusyPeriod, error) {
	ids := make([]int64, 0, len(calendars))
	locations := map[int64]*time.Location{}
	for _, c := range calendars {
		ids = append(ids, c.ID)
		locations[c.ID] = c.Location()
	}
	objects, err := s.store.ObjectsInRange(ctx, ids, window)
	if err != nil {
		return nil, err
	}
	var periods []BusyPeriod
	for _, object := range objects {
		resource, err := Parse(object.Data, locations[object.CalendarID])
		if err != nil {
			continue
		}
		occurrences, err := resource.Occurrences(window.Start, window.End)
		if err != nil {
			continue
		}
		for _, occurrence := range occurrences {
			if period, busy := busyPeriod(occurrence, own, window); busy {
				periods = append(periods, period)
			}
		}
	}
	return mergeBusy(periods), nil
}

func busyPeriod(occurrence Occurrence, own addressSet, window TimeRange) (BusyPeriod, bool) {
	component := occurrence.Component
	if !blocksTime(component) || !occurrence.End.After(occurrence.Start) {
		return BusyPeriod{}, false
	}
	partstat := ownPartstat(own, component)
	if partstat == PartstatDeclined {
		return BusyPeriod{}, false
	}
	invited := hasOwnAttendee(component, own)
	tentative := strings.EqualFold(propText(component, ical.PropStatus), "TENTATIVE") ||
		(invited && (partstat == PartstatTentative || partstat == PartstatNeedsAction))
	start, end := occurrence.Start, occurrence.End
	if start.Before(window.Start) {
		start = window.Start
	}
	if end.After(window.End) {
		end = window.End
	}
	return BusyPeriod{Start: start.UTC(), End: end.UTC(), Tentative: tentative}, true
}

func hasOwnAttendee(component *ical.Component, own addressSet) bool {
	for _, attendee := range component.Props.Values(ical.PropAttendee) {
		if own.has(attendee.Value) {
			return true
		}
	}
	return false
}

func mergeBusy(periods []BusyPeriod) []BusyPeriod {
	slices.SortFunc(periods, func(a, b BusyPeriod) int { return a.Start.Compare(b.Start) })
	merged := []BusyPeriod{}
	for _, period := range periods {
		last := len(merged) - 1
		if last >= 0 && merged[last].Tentative == period.Tentative && !period.Start.After(merged[last].End) {
			if period.End.After(merged[last].End) {
				merged[last].End = period.End
			}
			continue
		}
		merged = append(merged, period)
	}
	return merged
}

func FreeBusyCalendar(method string, window TimeRange, periods []BusyPeriod, organizer, attendee string, uid string) ([]byte, error) {
	cal := ical.NewCalendar()
	cal.Props.SetText(ical.PropVersion, "2.0")
	cal.Props.SetText(ical.PropProductID, ProductID)
	if method != "" {
		cal.Props.SetText(ical.PropMethod, method)
	}
	component := ical.NewComponent(ical.CompFreeBusy)
	component.Props.SetDateTime(ical.PropDateTimeStamp, time.Now().UTC())
	component.Props.SetDateTime(ical.PropDateTimeStart, window.Start.UTC())
	component.Props.SetDateTime(ical.PropDateTimeEnd, window.End.UTC())
	if uid == "" {
		uid = randomHex(16) + "@polder"
	}
	component.Props.SetText(ical.PropUID, uid)
	if organizer != "" {
		component.Props.Set(rawProp(ical.PropOrganizer, organizer))
	}
	if attendee != "" {
		component.Props.Set(rawProp(ical.PropAttendee, attendee))
	}
	for _, period := range periods {
		prop := rawProp(ical.PropFreeBusy, period.Start.UTC().Format(utcDateTimeLayout)+"/"+period.End.UTC().Format(utcDateTimeLayout))
		if period.Tentative {
			prop.Params.Set(ical.ParamFreeBusyType, "BUSY-TENTATIVE")
		}
		component.Props.Add(prop)
	}
	cal.Children = append(cal.Children, component)
	return encodeCalendar(cal)
}
