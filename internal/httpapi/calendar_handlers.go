package httpapi

import (
	"context"
	"io"
	"strings"
	"time"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/caldav"
	"polder-server/internal/calendar"
)

const calendarImportLimit = 20 << 20

type calendarPath struct {
	CalendarID int64 `path:"calendarID"`
}

type updateCalendarInput struct {
	CalendarID int64 `path:"calendarID"`
	Body       calendar.CalendarChange
}

type eventsQuery struct {
	From        time.Time `query:"from" required:"true" doc:"Start of the window, RFC 3339"`
	To          time.Time `query:"to" required:"true" doc:"End of the window, RFC 3339; at most 366 days after from"`
	CalendarIDs []int64   `query:"calendarIds" required:"false" doc:"Calendars to include; all visible calendars when empty"`
}

type eventPath struct {
	CalendarID int64 `path:"calendarID"`
	EventID    int64 `path:"eventID"`
}

type createEventInput struct {
	CalendarID int64 `path:"calendarID"`
	Body       calendar.EventInput
}

type updateEventInput struct {
	CalendarID   int64              `path:"calendarID"`
	EventID      int64              `path:"eventID"`
	Scope        calendar.EditScope `query:"scope" required:"false" doc:"For repeating events: this occurrence, this and following, or all (default)"`
	RecurrenceID string             `query:"recurrenceId" required:"false" doc:"The occurrence to change, from an event's recurrenceId"`
	IfMatch      string             `header:"If-Match" required:"false" doc:"The event's etag, to refuse the change if someone else changed it first"`
	Body         calendar.EventInput
}

type deleteEventInput struct {
	CalendarID   int64              `path:"calendarID"`
	EventID      int64              `path:"eventID"`
	Scope        calendar.EditScope `query:"scope" required:"false"`
	RecurrenceID string             `query:"recurrenceId" required:"false"`
	IfMatch      string             `header:"If-Match" required:"false"`
}

type moveEventInput struct {
	CalendarID int64 `path:"calendarID"`
	EventID    int64 `path:"eventID"`
	Body       struct {
		CalendarID int64 `json:"calendarId" doc:"The calendar to move the event to"`
	}
}

type rsvpEventInput struct {
	CalendarID int64 `path:"calendarID"`
	EventID    int64 `path:"eventID"`
	Body       struct {
		Status       string `json:"status" doc:"ACCEPTED, DECLINED or TENTATIVE"`
		RecurrenceID string `json:"recurrenceId,omitempty" required:"false" doc:"Answer for one occurrence only"`
	}
}

type calendarShareInput struct {
	CalendarID int64 `path:"calendarID"`
	Body       calendar.NewCalendarShare
}

type calendarSharePath struct {
	CalendarID int64 `path:"calendarID"`
	ShareID    int64 `path:"shareID"`
}

type updateCalendarShareInput struct {
	CalendarID int64 `path:"calendarID"`
	ShareID    int64 `path:"shareID"`
	Body       struct {
		Access calendar.Access `json:"access"`
	}
}

type createFeedInput struct {
	CalendarID int64 `path:"calendarID"`
	Body       calendar.NewFeed
}

type feedPath struct {
	CalendarID int64 `path:"calendarID"`
	FeedID     int64 `path:"feedID"`
}

type importCalendarInput struct {
	CalendarID int64 `path:"calendarID"`
	content    io.Reader
}

func (i *importCalendarInput) Resolve(ctx huma.Context) []error {
	i.content = ctx.BodyReader()
	return nil
}

type freeBusyQuery struct {
	UserIDs []int64   `query:"userIds" required:"true" doc:"The people to look up"`
	From    time.Time `query:"from" required:"true"`
	To      time.Time `query:"to" required:"true"`
}

type inboxItemPath struct {
	URI string `path:"uri"`
}

type calDAVInfo struct {
	ServerURL    string `json:"serverUrl" doc:"The address to add to calendar apps; they discover the rest"`
	PrincipalURL string `json:"principalUrl"`
	HomeURL      string `json:"homeUrl" doc:"Where the user's calendars are"`
	Username     string `json:"username"`
	Hint         string `json:"hint"`
}

func (a *API) listCalendars(ctx context.Context, _ *struct{}) (*jsonBody[[]calendar.Calendar], error) {
	list, err := a.calendar.List(ctx, currentUser(ctx))
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) createCalendar(ctx context.Context, input *jsonBody[calendar.NewCalendar]) (*jsonBody[calendar.Calendar], error) {
	created, err := a.calendar.Create(ctx, currentUser(ctx), input.Body)
	if err != nil {
		return nil, err
	}
	return respond(created), nil
}

func (a *API) getCalendar(ctx context.Context, input *calendarPath) (*jsonBody[calendar.Calendar], error) {
	found, err := a.calendar.Get(ctx, currentUser(ctx), input.CalendarID)
	if err != nil {
		return nil, err
	}
	return respond(found), nil
}

func (a *API) updateCalendar(ctx context.Context, input *updateCalendarInput) (*jsonBody[calendar.Calendar], error) {
	updated, err := a.calendar.Update(ctx, currentUser(ctx), input.CalendarID, input.Body)
	if err != nil {
		return nil, err
	}
	return respond(updated), nil
}

func (a *API) deleteCalendar(ctx context.Context, input *calendarPath) (*struct{}, error) {
	return nil, a.calendar.Delete(ctx, currentUser(ctx), input.CalendarID)
}

func (a *API) setDefaultCalendar(ctx context.Context, input *calendarPath) (*jsonBody[calendar.Calendar], error) {
	updated, err := a.calendar.SetDefault(ctx, currentUser(ctx), input.CalendarID)
	if err != nil {
		return nil, err
	}
	return respond(updated), nil
}

func (a *API) listEvents(ctx context.Context, input *eventsQuery) (*jsonBody[[]calendar.Event], error) {
	events, err := a.calendar.Events(ctx, currentUser(ctx), input.CalendarIDs, calendar.TimeRange{Start: input.From, End: input.To})
	if err != nil {
		return nil, err
	}
	return respond(events), nil
}

func (a *API) getEvent(ctx context.Context, input *eventPath) (*jsonBody[calendar.EventDetails], error) {
	event, err := a.calendar.Event(ctx, currentUser(ctx), input.CalendarID, input.EventID)
	if err != nil {
		return nil, err
	}
	return respond(event), nil
}

func (a *API) createEvent(ctx context.Context, input *createEventInput) (*jsonBody[calendar.EventDetails], error) {
	event, err := a.calendar.CreateEvent(ctx, currentUser(ctx), input.CalendarID, input.Body)
	if err != nil {
		return nil, err
	}
	return respond(event), nil
}

func (a *API) updateEvent(ctx context.Context, input *updateEventInput) (*jsonBody[calendar.EventDetails], error) {
	event, err := a.calendar.UpdateEvent(ctx, currentUser(ctx), input.CalendarID, input.EventID, calendar.EventChange{
		Scope: input.Scope, RecurrenceID: input.RecurrenceID, IfMatch: input.IfMatch, Input: input.Body,
	})
	if err != nil {
		return nil, err
	}
	return respond(event), nil
}

func (a *API) deleteEvent(ctx context.Context, input *deleteEventInput) (*struct{}, error) {
	return nil, a.calendar.DeleteEvent(ctx, currentUser(ctx), input.CalendarID, input.EventID, input.Scope, input.RecurrenceID, input.IfMatch)
}

func (a *API) moveEvent(ctx context.Context, input *moveEventInput) (*jsonBody[calendar.EventDetails], error) {
	event, err := a.calendar.MoveEvent(ctx, currentUser(ctx), input.CalendarID, input.EventID, input.Body.CalendarID)
	if err != nil {
		return nil, err
	}
	return respond(event), nil
}

func (a *API) respondToEvent(ctx context.Context, input *rsvpEventInput) (*jsonBody[calendar.EventDetails], error) {
	event, err := a.calendar.RespondToEvent(ctx, currentUser(ctx), input.CalendarID, input.EventID, input.Body.RecurrenceID, input.Body.Status)
	if err != nil {
		return nil, err
	}
	return respond(event), nil
}

func (a *API) listCalendarShares(ctx context.Context, input *calendarPath) (*jsonBody[[]calendar.CalendarShare], error) {
	shares, err := a.calendar.Shares(ctx, currentUser(ctx), input.CalendarID)
	if err != nil {
		return nil, err
	}
	return respond(shares), nil
}

func (a *API) shareCalendar(ctx context.Context, input *calendarShareInput) (*jsonBody[calendar.CalendarShare], error) {
	share, err := a.calendar.Share(ctx, currentUser(ctx), input.CalendarID, input.Body)
	if err != nil {
		return nil, err
	}
	return respond(share), nil
}

func (a *API) updateCalendarShare(ctx context.Context, input *updateCalendarShareInput) (*jsonBody[calendar.CalendarShare], error) {
	share, err := a.calendar.UpdateShare(ctx, currentUser(ctx), input.CalendarID, input.ShareID, input.Body.Access)
	if err != nil {
		return nil, err
	}
	return respond(share), nil
}

func (a *API) removeCalendarShare(ctx context.Context, input *calendarSharePath) (*struct{}, error) {
	return nil, a.calendar.RemoveShare(ctx, currentUser(ctx), input.CalendarID, input.ShareID)
}

func (a *API) listCalendarFeeds(ctx context.Context, input *calendarPath) (*jsonBody[[]calendar.Feed], error) {
	feeds, err := a.calendar.Feeds(ctx, currentUser(ctx), input.CalendarID)
	if err != nil {
		return nil, err
	}
	return respond(feeds), nil
}

func (a *API) createCalendarFeed(ctx context.Context, input *createFeedInput) (*jsonBody[calendar.Feed], error) {
	feed, err := a.calendar.CreateFeed(ctx, currentUser(ctx), input.CalendarID, input.Body)
	if err != nil {
		return nil, err
	}
	return respond(feed), nil
}

func (a *API) deleteCalendarFeed(ctx context.Context, input *feedPath) (*struct{}, error) {
	return nil, a.calendar.DeleteFeed(ctx, currentUser(ctx), input.CalendarID, input.FeedID)
}

func (a *API) subscribeCalendar(ctx context.Context, input *jsonBody[calendar.NewSubscription]) (*jsonBody[calendar.Calendar], error) {
	subscribed, err := a.calendar.Subscribe(ctx, currentUser(ctx), input.Body)
	if err != nil {
		return nil, err
	}
	return respond(subscribed), nil
}

func (a *API) refreshCalendar(ctx context.Context, input *calendarPath) (*jsonBody[calendar.Calendar], error) {
	refreshed, err := a.calendar.Refresh(ctx, currentUser(ctx), input.CalendarID)
	if err != nil {
		return nil, err
	}
	return respond(refreshed), nil
}

func (a *API) importCalendar(ctx context.Context, input *importCalendarInput) (*jsonBody[calendar.ImportResult], error) {
	content, err := io.ReadAll(io.LimitReader(input.content, calendarImportLimit+1))
	if err != nil {
		return nil, err
	}
	if len(content) > calendarImportLimit {
		return nil, apperr.Invalid("a calendar file is at most %d MiB", calendarImportLimit>>20)
	}
	result, err := a.calendar.Import(ctx, currentUser(ctx), input.CalendarID, content)
	if err != nil {
		return nil, err
	}
	return respond(result), nil
}

func (a *API) exportCalendar(ctx context.Context, input *calendarPath) (*attachmentOutput, error) {
	exported, data, err := a.calendar.Export(ctx, currentUser(ctx), input.CalendarID)
	if err != nil {
		return nil, err
	}
	return &attachmentOutput{
		ContentType:        "text/calendar; charset=utf-8",
		ContentDisposition: attachment(exported.URI + ".ics"),
		Body:               func(hc huma.Context) { _, _ = hc.BodyWriter().Write(data) },
	}, nil
}

func (a *API) freeBusy(ctx context.Context, input *freeBusyQuery) (*jsonBody[[]calendar.UserBusy], error) {
	busy, err := a.calendar.FreeBusy(ctx, currentUser(ctx), input.UserIDs, calendar.TimeRange{Start: input.From, End: input.To})
	if err != nil {
		return nil, err
	}
	return respond(busy), nil
}

func (a *API) calendarInbox(ctx context.Context, _ *struct{}) (*jsonBody[[]calendar.InboxItem], error) {
	items, err := a.calendar.Inbox(ctx, currentUser(ctx))
	if err != nil {
		return nil, err
	}
	return respond(items), nil
}

func (a *API) deleteCalendarInboxItem(ctx context.Context, input *inboxItemPath) (*struct{}, error) {
	return nil, a.calendar.DeleteInboxItem(ctx, currentUser(ctx), input.URI)
}

func (a *API) calDAVInfo(ctx context.Context, _ *struct{}) (*jsonBody[calDAVInfo], error) {
	user := currentUser(ctx)
	base := strings.TrimSuffix(a.publicURL, "/")
	return respond(calDAVInfo{
		ServerURL:    base + caldav.Root,
		PrincipalURL: base + calendar.PrincipalHref(user.Username),
		HomeURL:      base + caldav.CalendarsPath + user.Username + "/",
		Username:     user.Username,
		Hint:         "Log in with your username and an app password from your account settings.",
	}), nil
}
