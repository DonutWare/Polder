package app_test

import (
	"bytes"
	"encoding/xml"
	"fmt"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
	"time"

	"polder-server/internal/config"
)

type calendarInfo struct {
	ID        int64  `json:"id"`
	URI       string `json:"uri"`
	Name      string `json:"name"`
	Color     string `json:"color"`
	Kind      string `json:"kind"`
	IsDefault bool   `json:"isDefault"`
	Access    string `json:"access"`
	SourceURL string `json:"sourceUrl"`
}

type calendarAttendee struct {
	Email  string `json:"email"`
	Status string `json:"status"`
	Self   bool   `json:"self"`
}

type calendarEvent struct {
	ID           int64              `json:"id"`
	CalendarID   int64              `json:"calendarId"`
	UID          string             `json:"uid"`
	ETag         string             `json:"etag"`
	RecurrenceID string             `json:"recurrenceId"`
	Summary      string             `json:"summary"`
	Start        time.Time          `json:"start"`
	End          time.Time          `json:"end"`
	AllDay       bool               `json:"allDay"`
	RRule        string             `json:"rrule"`
	Override     bool               `json:"override"`
	Status       string             `json:"status"`
	BusyOnly     bool               `json:"busyOnly"`
	Attendees    []calendarAttendee `json:"attendees"`
	Overrides    []calendarEvent    `json:"overrides"`
}

type calendarFeed struct {
	ID        int64  `json:"id"`
	URL       string `json:"url"`
	WebcalURL string `json:"webcalUrl"`
}

func (c *client) calendars() []calendarInfo {
	c.server.t.Helper()
	var list []calendarInfo
	c.mustJSON(http.MethodGet, "/calendars", nil, http.StatusOK, &list)
	return list
}

func (c *client) defaultCalendar() calendarInfo {
	c.server.t.Helper()
	for _, found := range c.calendars() {
		if found.IsDefault {
			return found
		}
	}
	c.server.t.Fatal("no default calendar")
	return calendarInfo{}
}

func (c *client) occurrences(from, to time.Time, calendarIDs ...int64) []calendarEvent {
	c.server.t.Helper()
	query := url.Values{"from": {from.Format(time.RFC3339)}, "to": {to.Format(time.RFC3339)}}
	if len(calendarIDs) > 0 {
		var ids []string
		for _, id := range calendarIDs {
			ids = append(ids, fmt.Sprint(id))
		}
		query.Set("calendarIds", strings.Join(ids, ","))
	}
	var events []calendarEvent
	c.mustJSON(http.MethodGet, "/calendars/events?"+query.Encode(), nil, http.StatusOK, &events)
	return events
}

func (c *client) createEvent(calendarID int64, body map[string]any) calendarEvent {
	c.server.t.Helper()
	var created calendarEvent
	c.mustJSON(http.MethodPost, fmt.Sprintf("/calendars/%d/events", calendarID), body, http.StatusCreated, &created)
	return created
}

func (c *client) setEmail(email string) {
	c.server.t.Helper()
	c.mustJSON(http.MethodPut, "/account/profile", map[string]any{
		"firstName": "", "lastName": "", "displayName": "", "address": "", "email": email,
	}, http.StatusOK, nil)
}

func summaries(events []calendarEvent) string {
	var names []string
	for _, event := range events {
		names = append(names, event.Summary+"@"+event.Start.UTC().Format("01-02T15:04"))
	}
	return strings.Join(names, ",")
}

func TestCalendarEventsRepeatAndChangePerOccurrence(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		personal := alice.defaultCalendar()
		if personal.URI != "personal" || personal.Access != "owner" {
			t.Fatalf("default calendar %+v", personal)
		}

		standup := alice.createEvent(personal.ID, map[string]any{
			"summary": "Standup", "start": "2030-03-04T09:00:00+01:00", "end": "2030-03-04T09:15:00+01:00",
			"timezone": "Europe/Amsterdam", "rrule": "FREQ=WEEKLY;BYDAY=MO;COUNT=6",
			"alarms": []map[string]any{{"action": "DISPLAY", "offsetMinutes": -10}},
		})
		from, to := time.Date(2030, 3, 1, 0, 0, 0, 0, time.UTC), time.Date(2030, 5, 1, 0, 0, 0, 0, time.UTC)
		weekly := alice.occurrences(from, to)
		if len(weekly) != 6 || weekly[4].Start.UTC().Hour() != 7 || weekly[0].Start.UTC().Hour() != 8 {
			t.Fatalf("expanded across daylight saving: %s", summaries(weekly))
		}

		second := weekly[1].RecurrenceID
		alice.mustJSON(http.MethodPut, fmt.Sprintf("/calendars/%d/events/%d?scope=this&recurrenceId=%s", personal.ID, standup.ID, second), map[string]any{
			"summary": "Long standup", "start": "2030-03-11T10:00:00+01:00", "end": "2030-03-11T11:00:00+01:00", "timezone": "Europe/Amsterdam",
		}, http.StatusOK, nil)
		alice.mustJSON(http.MethodDelete, fmt.Sprintf("/calendars/%d/events/%d?scope=this&recurrenceId=%s", personal.ID, standup.ID, weekly[2].RecurrenceID), nil, http.StatusNoContent, nil)
		changed := alice.occurrences(from, to)
		if got := summaries(changed); got != "Standup@03-04T08:00,Long standup@03-11T09:00,Standup@03-25T08:00,Standup@04-01T07:00,Standup@04-08T07:00" {
			t.Fatalf("after editing one occurrence: %s", got)
		}

		var details calendarEvent
		alice.mustJSON(http.MethodPut, fmt.Sprintf("/calendars/%d/events/%d?scope=following&recurrenceId=%s", personal.ID, standup.ID, changed[3].RecurrenceID), map[string]any{
			"summary": "Planning", "start": "2030-04-01T13:00:00+02:00", "end": "2030-04-01T14:00:00+02:00",
			"timezone": "Europe/Amsterdam", "rrule": "FREQ=WEEKLY;BYDAY=MO;COUNT=2",
		}, http.StatusOK, &details)
		split := alice.occurrences(from, to)
		if got := summaries(split); got != "Standup@03-04T08:00,Long standup@03-11T09:00,Standup@03-25T08:00,Planning@04-01T11:00,Planning@04-08T11:00" {
			t.Fatalf("after splitting the series: %s", got)
		}
		if details.UID == standup.UID {
			t.Fatal("the following occurrences kept the original UID")
		}

		response := alice.request(http.MethodGet, fmt.Sprintf("/calendars/%d/export", personal.ID), nil, nil)
		exported := string(readBody(t, response))
		if !strings.Contains(exported, "UID:"+standup.UID) || !strings.Contains(exported, "BEGIN:VTIMEZONE") || !strings.Contains(exported, "EXDATE") {
			t.Fatalf("export:\n%s", exported)
		}

		alice.mustJSON(http.MethodPut, fmt.Sprintf("/calendars/%d/events/%d", personal.ID, details.ID), map[string]any{
			"summary": "x", "start": "2030-04-01T13:00:00Z", "end": "2030-04-01T14:00:00Z",
		}, http.StatusOK, nil)
		stale := alice.request(http.MethodPut, fmt.Sprintf("/calendars/%d/events/%d", personal.ID, details.ID),
			bytes.NewReader([]byte(`{"summary":"y","start":"2030-04-01T13:00:00Z","end":"2030-04-01T14:00:00Z"}`)), map[string]string{"If-Match": details.ETag})
		alice.expect(stale, http.StatusPreconditionFailed, nil)
	})
}

func TestCalendarSeriesEditsFromAnOverriddenOccurrence(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		personal := alice.defaultCalendar()
		rule := "FREQ=WEEKLY;BYDAY=MO;COUNT=4"
		standup := alice.createEvent(personal.ID, map[string]any{
			"summary": "Standup", "start": "2030-03-04T09:00:00Z", "end": "2030-03-04T09:15:00Z", "rrule": rule,
		})
		from, to := time.Date(2030, 3, 1, 0, 0, 0, 0, time.UTC), time.Date(2030, 5, 1, 0, 0, 0, 0, time.UTC)
		weekly := alice.occurrences(from, to)
		editPath := func(scope, recurrenceID string) string {
			return fmt.Sprintf("/calendars/%d/events/%d?scope=%s&recurrenceId=%s", personal.ID, standup.ID, scope, recurrenceID)
		}
		alice.mustJSON(http.MethodPut, editPath("this", weekly[1].RecurrenceID), map[string]any{
			"summary": "Standup", "start": "2030-03-11T10:00:00Z", "end": "2030-03-11T10:15:00Z",
		}, http.StatusOK, nil)
		alice.mustJSON(http.MethodPut, editPath("this", weekly[2].RecurrenceID), map[string]any{
			"summary": "Retro", "start": "2030-03-18T09:00:00Z", "end": "2030-03-18T09:15:00Z",
		}, http.StatusOK, nil)

		moved := alice.occurrences(from, to)[1]
		if !moved.Override || moved.RRule != rule {
			t.Fatalf("an overridden occurrence reports the series rule, got %+v", moved)
		}

		alice.mustJSON(http.MethodPut, editPath("all", moved.RecurrenceID), map[string]any{
			"summary": "Daily sync", "start": "2030-03-04T09:00:00Z", "end": "2030-03-04T09:15:00Z", "rrule": moved.RRule,
		}, http.StatusOK, nil)
		renamed := alice.occurrences(from, to)
		if got := summaries(renamed); got != "Daily sync@03-04T09:00,Daily sync@03-11T10:00,Retro@03-18T09:00,Daily sync@03-25T09:00" {
			t.Fatalf("renaming the series from an override: %s", got)
		}

		alice.mustJSON(http.MethodPut, editPath("all", renamed[1].RecurrenceID), map[string]any{
			"summary": "Once", "start": "2030-03-04T09:00:00Z", "end": "2030-03-04T09:15:00Z",
		}, http.StatusOK, nil)
		if got := summaries(alice.occurrences(from, to)); got != "Once@03-04T09:00" {
			t.Fatalf("ending the repeat leaves no stray occurrences: %s", got)
		}
	})
}

func TestCalendarImportAllDayEvents(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		holidays := alice.defaultCalendar()
		ics := "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:test\r\nMETHOD:PUBLISH\r\n" +
			"BEGIN:VEVENT\r\nUID:kingsday@example.com\r\nDTSTAMP:20250101T000000Z\r\nDTSTART;VALUE=DATE:20300427\r\nSUMMARY:Kings day\r\nRRULE:FREQ=YEARLY\r\nEND:VEVENT\r\n" +
			"BEGIN:VEVENT\r\nUID:odd uid/with slash\r\nDTSTAMP:20250101T000000Z\r\nDTSTART;VALUE=DATE:20300501\r\nDTEND;VALUE=DATE:20300503\r\nSUMMARY:Long weekend\r\nEND:VEVENT\r\n" +
			"END:VCALENDAR\r\n"
		var result struct {
			Created int      `json:"created"`
			Skipped int      `json:"skipped"`
			Errors  []string `json:"errors"`
		}
		path := fmt.Sprintf("/calendars/%d/import", holidays.ID)
		alice.expect(alice.request(http.MethodPost, path, strings.NewReader(ics), map[string]string{"Content-Type": "text/calendar"}), http.StatusOK, &result)
		if result.Created != 2 || len(result.Errors) != 0 {
			t.Fatalf("import %+v", result)
		}
		alice.expect(alice.request(http.MethodPost, path, strings.NewReader(ics), map[string]string{"Content-Type": "text/calendar"}), http.StatusOK, &result)
		if result.Skipped != 2 {
			t.Fatalf("second import %+v", result)
		}
		events := alice.occurrences(time.Date(2031, 4, 1, 0, 0, 0, 0, time.UTC), time.Date(2031, 5, 1, 0, 0, 0, 0, time.UTC))
		if len(events) != 1 || !events[0].AllDay || events[0].End.Sub(events[0].Start) != 24*time.Hour {
			t.Fatalf("yearly all-day event: %+v", events)
		}
	})
}

type calDAVResponse struct {
	Href      string `xml:"href"`
	Status    string `xml:"status"`
	Propstats []struct {
		Status string `xml:"status"`
		Prop   struct {
			ETag             string `xml:"getetag"`
			DisplayName      string `xml:"displayname"`
			CalendarData     string `xml:"urn:ietf:params:xml:ns:caldav calendar-data"`
			Color            string `xml:"http://apple.com/ns/ical/ calendar-color"`
			CTag             string `xml:"http://calendarserver.org/ns/ getctag"`
			SyncToken        string `xml:"sync-token"`
			CurrentPrincipal struct {
				Href string `xml:"href"`
			} `xml:"current-user-principal"`
			HomeSet struct {
				Href string `xml:"href"`
			} `xml:"urn:ietf:params:xml:ns:caldav calendar-home-set"`
			ResourceType struct {
				Calendar *struct{} `xml:"urn:ietf:params:xml:ns:caldav calendar"`
				Inbox    *struct{} `xml:"urn:ietf:params:xml:ns:caldav schedule-inbox"`
			} `xml:"resourcetype"`
		} `xml:"prop"`
	} `xml:"propstat"`
}

type calDAVMultistatus struct {
	Responses []calDAVResponse `xml:"response"`
	SyncToken string           `xml:"sync-token"`
}

func parseCalDAV(t *testing.T, content string) calDAVMultistatus {
	t.Helper()
	var parsed calDAVMultistatus
	if err := xml.Unmarshal([]byte(content), &parsed); err != nil {
		t.Fatalf("parse multistatus: %v\n%s", err, content)
	}
	return parsed
}

func (m calDAVMultistatus) find(href string) (calDAVResponse, bool) {
	for _, response := range m.Responses {
		if response.Href == href {
			return response, true
		}
	}
	return calDAVResponse{}, false
}

func eventICS(uid, summary, start, end, extra string) string {
	return "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Test//EN\r\nBEGIN:VEVENT\r\nUID:" + uid +
		"\r\nDTSTAMP:20300101T000000Z\r\nDTSTART:" + start + "\r\nDTEND:" + end + "\r\nSUMMARY:" + summary + "\r\n" + extra +
		"END:VEVENT\r\nEND:VCALENDAR\r\n"
}

func TestCalDAVDiscoveryAndSync(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		password := alice.createAppPassword("phone", false, "password1")
		davClient := server.dav("alice", password.Token)

		noRedirects := &http.Client{CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
		wellKnown, err := noRedirects.Get(server.server.URL + "/.well-known/caldav")
		if err != nil {
			t.Fatal(err)
		}
		wellKnown.Body.Close()
		if wellKnown.StatusCode != http.StatusMovedPermanently || wellKnown.Header.Get("Location") != "/dav/" {
			t.Fatalf("well-known: %d %s", wellKnown.StatusCode, wellKnown.Header.Get("Location"))
		}
		server.dav("alice", "wrong").expect("PROPFIND", "/dav/", "", map[string]string{"Depth": "0"}, http.StatusUnauthorized)

		principalQuery := `<d:propfind xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav"><d:prop><d:current-user-principal/><c:calendar-home-set/></d:prop></d:propfind>`
		_, body := davClient.expect("PROPFIND", "/dav/", principalQuery, map[string]string{"Depth": "0"}, http.StatusMultiStatus)
		root := parseCalDAV(t, body).Responses[0].Propstats[0].Prop
		if root.CurrentPrincipal.Href != "/dav/principals/alice/" || root.HomeSet.Href != "/dav/calendars/alice/" {
			t.Fatalf("discovery: %s", body)
		}

		_, body = davClient.expect("PROPFIND", "/dav/calendars/alice/", "", map[string]string{"Depth": "1"}, http.StatusMultiStatus)
		home := parseCalDAV(t, body)
		if personal, ok := home.find("/dav/calendars/alice/personal/"); !ok || personal.Propstats[0].Prop.ResourceType.Calendar == nil {
			t.Fatalf("home listing: %s", body)
		}
		if inbox, ok := home.find("/dav/calendars/alice/inbox/"); !ok || inbox.Propstats[0].Prop.ResourceType.Inbox == nil {
			t.Fatalf("no inbox: %s", body)
		}

		mkcalendar := `<c:mkcalendar xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav" xmlns:a="http://apple.com/ns/ical/"><d:set><d:prop>
			<d:displayname>Work</d:displayname><a:calendar-color>#12A594FF</a:calendar-color>
			<c:supported-calendar-component-set><c:comp name="VEVENT"/></c:supported-calendar-component-set></d:prop></d:set></c:mkcalendar>`
		davClient.expect("MKCALENDAR", "/dav/calendars/alice/work/", mkcalendar, nil, http.StatusCreated)
		davClient.expect("MKCALENDAR", "/dav/calendars/alice/work/", mkcalendar, nil, http.StatusMethodNotAllowed)
		todo := strings.Replace(mkcalendar, "VEVENT", "VTODO", 1)
		davClient.expect("MKCALENDAR", "/dav/calendars/alice/tasks/", todo, nil, http.StatusForbidden)

		work := "/dav/calendars/alice/work/"
		collectionQuery := `<d:propfind xmlns:d="DAV:" xmlns:cs="http://calendarserver.org/ns/"><d:prop><d:displayname/><cs:getctag/><d:sync-token/></d:prop></d:propfind>`
		_, body = davClient.expect("PROPFIND", work, collectionQuery, map[string]string{"Depth": "0"}, http.StatusMultiStatus)
		initial := parseCalDAV(t, body).Responses[0].Propstats[0].Prop
		if initial.DisplayName != "Work" || initial.CTag == "" || initial.SyncToken == "" {
			t.Fatalf("calendar props: %s", body)
		}

		series := eventICS("series-1", "Review", "20300304T090000Z", "20300304T100000Z", "RRULE:FREQ=DAILY;COUNT=10\r\n")
		created, _ := davClient.expect(http.MethodPut, work+"series-1.ics", series, map[string]string{"If-None-Match": "*", "Content-Type": "text/calendar"}, http.StatusCreated)
		etag := created.Header.Get("ETag")
		if etag == "" {
			t.Fatal("PUT returned no ETag")
		}
		davClient.expect(http.MethodPut, work+"series-1.ics", series, map[string]string{"If-None-Match": "*"}, http.StatusPreconditionFailed)
		davClient.expect(http.MethodPut, work+"other.ics", series, nil, http.StatusConflict)
		davClient.expect(http.MethodPut, work+"bad.ics", "BEGIN:VCALENDAR\r\nEND:VCALENDAR\r\n", nil, http.StatusForbidden)
		davClient.expect(http.MethodPut, work+"series-1.ics", series, map[string]string{"If-Match": `"stale"`}, http.StatusPreconditionFailed)
		single := eventICS("single-1", "Lunch", "20300320T120000Z", "20300320T130000Z", "")
		davClient.expect(http.MethodPut, work+"single-1.ics", single, nil, http.StatusCreated)

		got, content := davClient.expect(http.MethodGet, work+"series-1.ics", "", nil, http.StatusOK)
		if got.Header.Get("ETag") != etag || !strings.Contains(content, "SUMMARY:Review") {
			t.Fatalf("GET: %s %s", got.Header.Get("ETag"), content)
		}

		query := `<c:calendar-query xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav"><d:prop><d:getetag/><c:calendar-data/></d:prop>
			<c:filter><c:comp-filter name="VCALENDAR"><c:comp-filter name="VEVENT"><c:time-range start="20300312T000000Z" end="20300313T000000Z"/></c:comp-filter></c:comp-filter></c:filter></c:calendar-query>`
		_, body = davClient.expect("REPORT", work, query, map[string]string{"Depth": "1"}, http.StatusMultiStatus)
		matched := parseCalDAV(t, body)
		if len(matched.Responses) != 1 || matched.Responses[0].Href != work+"series-1.ics" {
			t.Fatalf("time-range on the 9th day of a daily series: %s", body)
		}
		textQuery := `<c:calendar-query xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav"><d:prop><d:getetag/></d:prop>
			<c:filter><c:comp-filter name="VCALENDAR"><c:comp-filter name="VEVENT"><c:prop-filter name="SUMMARY"><c:text-match>lunch</c:text-match></c:prop-filter></c:comp-filter></c:comp-filter></c:filter></c:calendar-query>`
		_, body = davClient.expect("REPORT", work, textQuery, map[string]string{"Depth": "1"}, http.StatusMultiStatus)
		if matched := parseCalDAV(t, body); len(matched.Responses) != 1 || matched.Responses[0].Href != work+"single-1.ics" {
			t.Fatalf("text-match: %s", body)
		}

		expand := `<c:calendar-query xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav"><d:prop><c:calendar-data><c:expand start="20300305T000000Z" end="20300307T000000Z"/></c:calendar-data></d:prop>
			<c:filter><c:comp-filter name="VCALENDAR"><c:comp-filter name="VEVENT"><c:time-range start="20300305T000000Z" end="20300307T000000Z"/></c:comp-filter></c:comp-filter></c:filter></c:calendar-query>`
		_, body = davClient.expect("REPORT", work, expand, map[string]string{"Depth": "1"}, http.StatusMultiStatus)
		expanded := parseCalDAV(t, body).Responses[0].Propstats[0].Prop.CalendarData
		if strings.Count(expanded, "BEGIN:VEVENT") != 2 || strings.Contains(expanded, "RRULE") || !strings.Contains(expanded, "RECURRENCE-ID:20300305T090000Z") {
			t.Fatalf("expanded data:\n%s", expanded)
		}

		multiget := `<c:calendar-multiget xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav"><d:prop><d:getetag/><c:calendar-data/></d:prop>
			<d:href>` + work + `single-1.ics</d:href><d:href>` + work + `missing.ics</d:href></c:calendar-multiget>`
		_, body = davClient.expect("REPORT", work, multiget, nil, http.StatusMultiStatus)
		fetched := parseCalDAV(t, body)
		if found, ok := fetched.find(work + "single-1.ics"); !ok || !strings.Contains(found.Propstats[0].Prop.CalendarData, "Lunch") {
			t.Fatalf("multiget: %s", body)
		}
		if missing, ok := fetched.find(work + "missing.ics"); !ok || !strings.Contains(missing.Status, "404") {
			t.Fatalf("multiget missing: %s", body)
		}

		syncQuery := func(token string) string {
			return `<d:sync-collection xmlns:d="DAV:"><d:sync-token>` + token + `</d:sync-token><d:sync-level>1</d:sync-level><d:prop><d:getetag/></d:prop></d:sync-collection>`
		}
		_, body = davClient.expect("REPORT", work, syncQuery(""), nil, http.StatusMultiStatus)
		first := parseCalDAV(t, body)
		if len(first.Responses) != 2 || first.SyncToken == "" {
			t.Fatalf("initial sync: %s", body)
		}
		davClient.expect(http.MethodDelete, work+"single-1.ics", "", nil, http.StatusNoContent)
		moved := eventICS("series-1", "Review moved", "20300304T100000Z", "20300304T110000Z", "RRULE:FREQ=DAILY;COUNT=10\r\n")
		davClient.expect(http.MethodPut, work+"series-1.ics", moved, map[string]string{"If-Match": etag}, http.StatusNoContent)
		_, body = davClient.expect("REPORT", work, syncQuery(first.SyncToken), nil, http.StatusMultiStatus)
		delta := parseCalDAV(t, body)
		removed, removedFound := delta.find(work + "single-1.ics")
		_, changedFound := delta.find(work + "series-1.ics")
		if len(delta.Responses) != 2 || !removedFound || !strings.Contains(removed.Status, "404") || !changedFound || delta.SyncToken == first.SyncToken {
			t.Fatalf("delta sync: %s", body)
		}
		davClient.expect("REPORT", work, syncQuery("http://polder.dev/ns/sync/999999"), nil, http.StatusForbidden)

		proppatch := `<d:propertyupdate xmlns:d="DAV:" xmlns:a="http://apple.com/ns/ical/"><d:set><d:prop><a:calendar-color>#E5484D</a:calendar-color><d:displayname>Office</d:displayname></d:prop></d:set></d:propertyupdate>`
		davClient.expect("PROPPATCH", work, proppatch, nil, http.StatusMultiStatus)
		_, body = davClient.expect("PROPFIND", work, collectionQuery, map[string]string{"Depth": "0"}, http.StatusMultiStatus)
		after := parseCalDAV(t, body).Responses[0].Propstats[0].Prop
		if after.DisplayName != "Office" || after.CTag == initial.CTag {
			t.Fatalf("after PROPPATCH: %s", body)
		}
		var listed []calendarInfo
		alice.mustJSON(http.MethodGet, "/calendars", nil, http.StatusOK, &listed)
		for _, found := range listed {
			if found.URI == "work" && found.Color != "#e5484d" {
				t.Fatalf("color after PROPPATCH: %+v", found)
			}
		}

		readOnly := alice.createAppPassword("viewer", true, "password1")
		server.dav("alice", readOnly.Token).expect(http.MethodPut, work+"new.ics", single, nil, http.StatusForbidden)

		davClient.expect(http.MethodDelete, work, "", nil, http.StatusNoContent)
		davClient.expect("PROPFIND", work, "", map[string]string{"Depth": "0"}, http.StatusNotFound)
		server.dav("alice", password.Token).expect("PROPFIND", "/dav/calendars/bob/", "", map[string]string{"Depth": "0"}, http.StatusNotFound)
	})
}

func TestCalendarSharingWithUsersAndGroups(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		var bobInfo tokenPair
		server.anonymous().mustJSON(http.MethodPost, "/auth/login", map[string]string{"username": "bob", "password": "password1"}, http.StatusOK, &bobInfo)

		var team calendarInfo
		alice.mustJSON(http.MethodPost, "/calendars", map[string]any{"name": "Team"}, http.StatusCreated, &team)
		alice.createEvent(team.ID, map[string]any{"summary": "Retro", "start": "2030-06-03T14:00:00Z", "end": "2030-06-03T15:00:00Z"})
		window := []time.Time{time.Date(2030, 6, 1, 0, 0, 0, 0, time.UTC), time.Date(2030, 6, 30, 0, 0, 0, 0, time.UTC)}

		var share struct {
			ID     int64  `json:"id"`
			Access string `json:"access"`
		}
		alice.mustJSON(http.MethodPost, fmt.Sprintf("/calendars/%d/shares", team.ID),
			map[string]any{"recipientKind": "user", "recipientId": bobInfo.User.ID, "access": "freebusy"}, http.StatusCreated, &share)
		busy := bob.occurrences(window[0], window[1], team.ID)
		if len(busy) != 1 || !busy[0].BusyOnly || busy[0].Summary != "Busy" {
			t.Fatalf("free/busy share: %+v", busy)
		}
		bob.mustJSON(http.MethodGet, fmt.Sprintf("/calendars/%d/events/%d", team.ID, 1), nil, http.StatusForbidden, nil)

		alice.mustJSON(http.MethodPatch, fmt.Sprintf("/calendars/%d/shares/%d", team.ID, share.ID), map[string]any{"access": "read"}, http.StatusOK, nil)
		if events := bob.occurrences(window[0], window[1], team.ID); len(events) != 1 || events[0].Summary != "Retro" {
			t.Fatalf("read share: %+v", events)
		}
		bob.mustJSON(http.MethodPost, fmt.Sprintf("/calendars/%d/events", team.ID), map[string]any{"summary": "Mine", "start": "2030-06-04T09:00:00Z"}, http.StatusForbidden, nil)

		bob.mustJSON(http.MethodPatch, fmt.Sprintf("/calendars/%d", team.ID), map[string]any{"name": "Alice's team", "color": "#46a758"}, http.StatusOK, nil)
		for _, found := range bob.calendars() {
			if found.ID == team.ID && (found.Name != "Alice's team" || found.Access != "read") {
				t.Fatalf("bob's view of the shared calendar: %+v", found)
			}
		}
		for _, found := range alice.calendars() {
			if found.ID == team.ID && found.Name != "Team" {
				t.Fatalf("bob's rename leaked to alice: %+v", found)
			}
		}

		var group struct {
			ID int64 `json:"id"`
		}
		admin.mustJSON(http.MethodPost, "/groups", map[string]any{"name": "Planners"}, http.StatusCreated, &group)
		admin.mustJSON(http.MethodPost, fmt.Sprintf("/groups/%d/members", group.ID), map[string]any{"userId": bobInfo.User.ID, "role": "member"}, http.StatusCreated, nil)
		alice.mustJSON(http.MethodPost, fmt.Sprintf("/calendars/%d/shares", team.ID),
			map[string]any{"recipientKind": "group", "recipientId": group.ID, "access": "readwrite"}, http.StatusForbidden, nil)
		admin.mustJSON(http.MethodPost, fmt.Sprintf("/groups/%d/members", group.ID), map[string]any{"userId": 2, "role": "member"}, http.StatusCreated, nil)
		alice.mustJSON(http.MethodPost, fmt.Sprintf("/calendars/%d/shares", team.ID),
			map[string]any{"recipientKind": "group", "recipientId": group.ID, "access": "readwrite"}, http.StatusCreated, nil)
		bob.createEvent(team.ID, map[string]any{"summary": "Bob's slot", "start": "2030-06-05T09:00:00Z", "end": "2030-06-05T10:00:00Z"})
		if events := alice.occurrences(window[0], window[1], team.ID); len(events) != 2 {
			t.Fatalf("alice sees bob's event: %+v", events)
		}

		bobPassword := bob.createAppPassword("laptop", false, "password1")
		_, body := server.dav("bob", bobPassword.Token).expect("PROPFIND", "/dav/calendars/bob/", "", map[string]string{"Depth": "1"}, http.StatusMultiStatus)
		if _, ok := parseCalDAV(t, body).find(fmt.Sprintf("/dav/calendars/bob/shared-%d/", team.ID)); !ok {
			t.Fatalf("shared calendar missing from bob's CalDAV home: %s", body)
		}

		bob.mustJSON(http.MethodDelete, fmt.Sprintf("/calendars/%d", team.ID), nil, http.StatusNoContent, nil)
		alice.mustJSON(http.MethodGet, fmt.Sprintf("/calendars/%d", team.ID), nil, http.StatusOK, nil)
	})
}

func TestCalendarFeedsForOtherApps(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		personal := alice.defaultCalendar()
		alice.createEvent(personal.ID, map[string]any{"summary": "Dentist", "start": "2030-07-01T08:00:00Z", "end": "2030-07-01T09:00:00Z"})
		alice.createEvent(personal.ID, map[string]any{"summary": "Reading", "start": "2030-07-02T08:00:00Z", "end": "2030-07-02T09:00:00Z", "showAs": "free"})

		var full, busy calendarFeed
		alice.mustJSON(http.MethodPost, fmt.Sprintf("/calendars/%d/feeds", personal.ID), map[string]any{"mode": "full"}, http.StatusCreated, &full)
		alice.mustJSON(http.MethodPost, fmt.Sprintf("/calendars/%d/feeds", personal.ID), map[string]any{"mode": "busy"}, http.StatusCreated, &busy)
		if !strings.HasPrefix(full.URL, "/ical/") || !strings.HasSuffix(full.URL, ".ics") {
			t.Fatalf("feed url %q", full.URL)
		}

		get := func(path string, headers map[string]string) (*http.Response, string) {
			request, _ := http.NewRequest(http.MethodGet, server.server.URL+path, nil)
			for name, value := range headers {
				request.Header.Set(name, value)
			}
			response, err := http.DefaultClient.Do(request)
			if err != nil {
				t.Fatal(err)
			}
			return response, string(readBody(t, response))
		}
		response, content := get(full.URL, nil)
		if response.StatusCode != http.StatusOK || !strings.Contains(content, "SUMMARY:Dentist") || !strings.Contains(content, "SUMMARY:Reading") ||
			!strings.HasPrefix(response.Header.Get("Content-Type"), "text/calendar") {
			t.Fatalf("full feed %d:\n%s", response.StatusCode, content)
		}
		if again, _ := get(full.URL, map[string]string{"If-None-Match": response.Header.Get("ETag")}); again.StatusCode != http.StatusNotModified {
			t.Fatalf("conditional feed request: %d", again.StatusCode)
		}
		_, content = get(busy.URL, nil)
		if strings.Contains(content, "Dentist") || strings.Contains(content, "Reading") || strings.Count(content, "SUMMARY:Busy") != 1 {
			t.Fatalf("busy feed:\n%s", content)
		}

		alice.mustJSON(http.MethodDelete, fmt.Sprintf("/calendars/%d/feeds/%d", personal.ID, full.ID), nil, http.StatusNoContent, nil)
		if gone, _ := get(full.URL, nil); gone.StatusCode != http.StatusNotFound {
			t.Fatalf("revoked feed: %d", gone.StatusCode)
		}
		if guessed, _ := get("/ical/not-a-real-token.ics", nil); guessed.StatusCode != http.StatusNotFound {
			t.Fatalf("guessed feed: %d", guessed.StatusCode)
		}
	})
}

func TestCalendarSubscriptionsFollowRemoteFeeds(t *testing.T) {
	feed := eventICS("remote-1", "Match day", "20300810T150000Z", "20300810T170000Z", "")
	remote := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/calendar")
		w.Header().Set("ETag", `"v1"`)
		if r.Header.Get("If-None-Match") == `"v1"` {
			w.WriteHeader(http.StatusNotModified)
			return
		}
		_, _ = w.Write([]byte(feed))
	}))
	defer remote.Close()
	server := startServer(t, config.DriverSQLite, "", func(cfg *config.Config) { cfg.CalendarSubscriptionsAllowPrivate = true })
	admin := server.setupAdmin()
	alice := server.createUser(admin, "alice", 0)

	var subscribed calendarInfo
	alice.mustJSON(http.MethodPost, "/calendars/subscriptions", map[string]any{"url": "ftp://example.com/feed.ics"}, http.StatusBadRequest, nil)
	alice.mustJSON(http.MethodPost, "/calendars/subscriptions", map[string]any{"url": remote.URL, "name": "Football"}, http.StatusCreated, &subscribed)
	if subscribed.Kind != "subscription" || subscribed.SourceURL != remote.URL {
		t.Fatalf("subscription %+v", subscribed)
	}
	events := alice.occurrences(time.Date(2030, 8, 1, 0, 0, 0, 0, time.UTC), time.Date(2030, 9, 1, 0, 0, 0, 0, time.UTC), subscribed.ID)
	if len(events) != 1 || events[0].Summary != "Match day" {
		t.Fatalf("subscribed events: %+v", events)
	}
	alice.mustJSON(http.MethodPost, fmt.Sprintf("/calendars/%d/events", subscribed.ID), map[string]any{"summary": "x", "start": "2030-08-01T10:00:00Z"}, http.StatusForbidden, nil)
	alice.mustJSON(http.MethodPost, fmt.Sprintf("/calendars/%d/refresh", subscribed.ID), nil, http.StatusOK, nil)

	named := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/calendar")
		_, _ = w.Write([]byte(strings.Replace(feed, "BEGIN:VEVENT", "X-WR-CALNAME:Holidays in the Netherlands\r\nBEGIN:VEVENT", 1)))
	}))
	defer named.Close()
	var unnamed calendarInfo
	alice.mustJSON(http.MethodPost, "/calendars/subscriptions", map[string]any{"url": named.URL}, http.StatusCreated, &unnamed)
	if unnamed.Name != "Holidays in the Netherlands" {
		t.Fatalf("a subscription without a name is called %q", unnamed.Name)
	}

	password := alice.createAppPassword("phone", false, "password1")
	path := "/dav/calendars/alice/" + subscribed.URI + "/remote-1.ics"
	server.dav("alice", password.Token).expect(http.MethodPut, path, feed, nil, http.StatusForbidden)
	server.dav("alice", password.Token).expect(http.MethodGet, path, "", nil, http.StatusOK)
}

func TestCalendarInvitationsBetweenUsers(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.setEmail("alice@example.com")
		bob.setEmail("bob@example.com")
		window := []time.Time{time.Date(2030, 9, 1, 0, 0, 0, 0, time.UTC), time.Date(2030, 9, 30, 0, 0, 0, 0, time.UTC)}

		meeting := alice.createEvent(alice.defaultCalendar().ID, map[string]any{
			"summary": "Kick-off", "start": "2030-09-02T10:00:00Z", "end": "2030-09-02T11:00:00Z",
			"attendees": []map[string]any{{"email": "Bob@Example.com", "name": "Bob"}, {"email": "carol@elsewhere.example"}},
		})
		statuses := map[string]calendarAttendee{}
		for _, attendee := range meeting.Attendees {
			statuses[attendee.Email] = attendee
		}
		if !statuses["alice@example.com"].Self || statuses["alice@example.com"].Status != "ACCEPTED" || statuses["bob@example.com"].Status != "NEEDS-ACTION" {
			t.Fatalf("organizer's attendees: %+v", meeting.Attendees)
		}

		invited := bob.occurrences(window[0], window[1])
		if len(invited) != 1 || invited[0].UID != meeting.UID {
			t.Fatalf("bob's copy: %+v", invited)
		}
		var inbox []struct {
			Method string `json:"method"`
			UID    string `json:"uid"`
		}
		bob.mustJSON(http.MethodGet, "/calendars/inbox", nil, http.StatusOK, &inbox)
		if len(inbox) != 1 || inbox[0].Method != "REQUEST" || inbox[0].UID != meeting.UID {
			t.Fatalf("bob's inbox: %+v", inbox)
		}

		bob.mustJSON(http.MethodPost, fmt.Sprintf("/calendars/%d/events/%d/rsvp", invited[0].CalendarID, invited[0].ID), map[string]any{"status": "ACCEPTED"}, http.StatusOK, nil)
		var organizerView calendarEvent
		alice.mustJSON(http.MethodGet, fmt.Sprintf("/calendars/%d/events/%d", meeting.CalendarID, meeting.ID), nil, http.StatusOK, &organizerView)
		for _, attendee := range organizerView.Attendees {
			if attendee.Email == "bob@example.com" && attendee.Status != "ACCEPTED" {
				t.Fatalf("organizer did not get bob's answer: %+v", organizerView.Attendees)
			}
		}

		alice.mustJSON(http.MethodPut, fmt.Sprintf("/calendars/%d/events/%d", meeting.CalendarID, meeting.ID), map[string]any{
			"summary": "Kick-off (moved)", "start": "2030-09-03T10:00:00Z", "end": "2030-09-03T11:00:00Z",
		}, http.StatusOK, nil)
		moved := bob.occurrences(window[0], window[1])
		if len(moved) != 1 || moved[0].Summary != "Kick-off (moved)" {
			t.Fatalf("bob's copy after the organizer moved it: %+v", moved)
		}
		for _, attendee := range moved[0].Attendees {
			if attendee.Self && attendee.Status != "ACCEPTED" {
				t.Fatalf("bob's answer was lost: %+v", moved[0].Attendees)
			}
		}

		alice.mustJSON(http.MethodDelete, fmt.Sprintf("/calendars/%d/events/%d", meeting.CalendarID, meeting.ID), nil, http.StatusNoContent, nil)
		cancelled := bob.occurrences(window[0], window[1])
		if len(cancelled) != 1 || cancelled[0].Status != "CANCELLED" {
			t.Fatalf("bob's copy after cancelling: %+v", cancelled)
		}

		var busy []struct {
			Busy []struct {
				Start time.Time `json:"start"`
			} `json:"busy"`
		}
		var bobInfo tokenPair
		server.anonymous().mustJSON(http.MethodPost, "/auth/login", map[string]string{"username": "bob", "password": "password1"}, http.StatusOK, &bobInfo)
		bob.createEvent(bob.defaultCalendar().ID, map[string]any{"summary": "Gym", "start": "2030-09-10T07:00:00Z", "end": "2030-09-10T08:00:00Z"})
		query := url.Values{"userIds": {fmt.Sprint(bobInfo.User.ID)}, "from": {window[0].Format(time.RFC3339)}, "to": {window[1].Format(time.RFC3339)}}
		alice.mustJSON(http.MethodGet, "/calendars/freebusy?"+query.Encode(), nil, http.StatusOK, &busy)
		if len(busy) != 1 || len(busy[0].Busy) != 1 || busy[0].Busy[0].Start.Day() != 10 {
			t.Fatalf("bob's free/busy: %+v", busy)
		}
	})
}

func TestAppPasswordsAcceptTheProfileEmailAsLogin(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.setEmail("alice@example.com")
		bob.setEmail("bob@example.com")
		password := alice.createAppPassword("phone", false, "password1")

		principalQuery := `<d:propfind xmlns:d="DAV:"><d:prop><d:current-user-principal/></d:prop></d:propfind>`
		_, body := server.dav("Alice@Example.com", password.Token).expect("PROPFIND", "/dav/", principalQuery, map[string]string{"Depth": "0"}, http.StatusMultiStatus)
		if principal := parseCalDAV(t, body).Responses[0].Propstats[0].Prop.CurrentPrincipal.Href; principal != "/dav/principals/alice/" {
			t.Fatalf("principal for an email login: %s", body)
		}
		server.dav("alice@example.com", password.Token).expect("PROPFIND", "/dav/files/alice/", "", map[string]string{"Depth": "0"}, http.StatusMultiStatus)
		server.dav("bob@example.com", password.Token).expect("PROPFIND", "/dav/", principalQuery, map[string]string{"Depth": "0"}, http.StatusUnauthorized)
		server.dav("someone@example.com", password.Token).expect("PROPFIND", "/dav/", principalQuery, map[string]string{"Depth": "0"}, http.StatusUnauthorized)
	})
}
