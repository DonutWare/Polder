package calendar

import (
	"strings"
	"testing"
	"time"
)

func mustParse(t *testing.T, lines ...string) *Resource {
	t.Helper()
	data := "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:test\r\n" + strings.Join(lines, "\r\n") + "\r\nEND:VCALENDAR\r\n"
	resource, err := Parse([]byte(data), time.UTC)
	if err != nil {
		t.Fatalf("parse: %v", err)
	}
	return resource
}

func starts(t *testing.T, resource *Resource, from, to time.Time) []string {
	t.Helper()
	occurrences, err := resource.Occurrences(from, to)
	if err != nil {
		t.Fatal(err)
	}
	var list []string
	for _, occurrence := range occurrences {
		list = append(list, occurrence.Start.UTC().Format(time.RFC3339))
	}
	return list
}

func day(year int, month time.Month, date int) time.Time {
	return time.Date(year, month, date, 0, 0, 0, 0, time.UTC)
}

func TestDailyCountWithExceptionAndOverride(t *testing.T) {
	resource := mustParse(t,
		"BEGIN:VEVENT", "UID:a", "DTSTAMP:20250101T000000Z",
		"DTSTART:20250106T090000Z", "DTEND:20250106T100000Z",
		"RRULE:FREQ=DAILY;COUNT=5", "EXDATE:20250107T090000Z",
		"END:VEVENT",
		"BEGIN:VEVENT", "UID:a", "DTSTAMP:20250101T000000Z", "RECURRENCE-ID:20250108T090000Z",
		"DTSTART:20250108T140000Z", "DTEND:20250108T150000Z", "SUMMARY:Moved",
		"END:VEVENT")
	got := strings.Join(starts(t, resource, time.Time{}, time.Time{}), ",")
	want := "2025-01-06T09:00:00Z,2025-01-08T14:00:00Z,2025-01-09T09:00:00Z,2025-01-10T09:00:00Z"
	if got != want {
		t.Fatalf("got %s\nwant %s", got, want)
	}
	bounds, err := resource.Bounds()
	if err != nil {
		t.Fatal(err)
	}
	if bounds.LastEnd == nil || !bounds.LastEnd.Equal(time.Date(2025, 1, 10, 10, 0, 0, 0, time.UTC)) {
		t.Fatalf("last end %v", bounds.LastEnd)
	}
}

func TestWeeklyKeepsWallClockAcrossDaylightSaving(t *testing.T) {
	resource := mustParse(t,
		"BEGIN:VEVENT", "UID:b", "DTSTAMP:20250101T000000Z",
		"DTSTART;TZID=Europe/Amsterdam:20250321T090000", "DURATION:PT1H",
		"RRULE:FREQ=WEEKLY;UNTIL=20250405T000000Z",
		"END:VEVENT")
	got := strings.Join(starts(t, resource, time.Time{}, time.Time{}), ",")
	want := "2025-03-21T08:00:00Z,2025-03-28T08:00:00Z,2025-04-04T07:00:00Z"
	if got != want {
		t.Fatalf("got %s\nwant %s", got, want)
	}
}

func TestWindowsTimezoneNames(t *testing.T) {
	resource := mustParse(t,
		"BEGIN:VEVENT", "UID:c", "DTSTAMP:20250101T000000Z",
		"DTSTART;TZID=W. Europe Standard Time:20250701T120000", "DTEND;TZID=W. Europe Standard Time:20250701T130000",
		"END:VEVENT")
	if got := starts(t, resource, time.Time{}, time.Time{}); got[0] != "2025-07-01T10:00:00Z" {
		t.Fatalf("got %v", got)
	}
}

func TestAllDayEventsLastADayAndUnboundedSeriesHaveNoEnd(t *testing.T) {
	resource := mustParse(t,
		"BEGIN:VEVENT", "UID:d", "DTSTAMP:20250101T000000Z",
		"DTSTART;VALUE=DATE:20250101", "RRULE:FREQ=YEARLY",
		"END:VEVENT")
	occurrences, err := resource.Occurrences(day(2030, 1, 1), day(2030, 1, 2))
	if err != nil {
		t.Fatal(err)
	}
	if len(occurrences) != 1 || !occurrences[0].AllDay || occurrences[0].End.Sub(occurrences[0].Start) != 24*time.Hour {
		t.Fatalf("occurrences %+v", occurrences)
	}
	if occurrences[0].RecurrenceID != "20300101" {
		t.Fatalf("recurrence id %q", occurrences[0].RecurrenceID)
	}
	bounds, err := resource.Bounds()
	if err != nil {
		t.Fatal(err)
	}
	if bounds.LastEnd != nil {
		t.Fatalf("unbounded series ends at %v", bounds.LastEnd)
	}
}

func TestRecurrenceDatesWithPeriods(t *testing.T) {
	resource := mustParse(t,
		"BEGIN:VEVENT", "UID:e", "DTSTAMP:20250101T000000Z",
		"DTSTART:20250101T100000Z", "DURATION:PT1H",
		"RDATE;VALUE=PERIOD:20250103T100000Z/PT3H,20250105T100000Z/20250105T103000Z",
		"END:VEVENT")
	occurrences, err := resource.Occurrences(time.Time{}, time.Time{})
	if err != nil {
		t.Fatal(err)
	}
	if len(occurrences) != 3 || occurrences[1].End.Sub(occurrences[1].Start) != 3*time.Hour || occurrences[2].End.Sub(occurrences[2].Start) != 30*time.Minute {
		t.Fatalf("occurrences %+v", occurrences)
	}
}

func TestMonthlyLastFridayInWindow(t *testing.T) {
	resource := mustParse(t,
		"BEGIN:VEVENT", "UID:f", "DTSTAMP:20250101T000000Z",
		"DTSTART:20250131T150000Z", "DTEND:20250131T160000Z", "RRULE:FREQ=MONTHLY;BYDAY=-1FR",
		"END:VEVENT")
	got := strings.Join(starts(t, resource, day(2025, 3, 1), day(2025, 5, 1)), ",")
	if got != "2025-03-28T15:00:00Z,2025-04-25T15:00:00Z" {
		t.Fatalf("got %s", got)
	}
}

func TestRejectsMixedUIDsAndUnsupportedComponents(t *testing.T) {
	cases := map[string]string{
		"mixed uids": "BEGIN:VEVENT\r\nUID:a\r\nDTSTART:20250101T100000Z\r\nEND:VEVENT\r\nBEGIN:VEVENT\r\nUID:b\r\nDTSTART:20250101T100000Z\r\nEND:VEVENT",
		"todo":       "BEGIN:VTODO\r\nUID:a\r\nEND:VTODO",
		"no start":   "BEGIN:VEVENT\r\nUID:a\r\nEND:VEVENT",
		"bad rrule":  "BEGIN:VEVENT\r\nUID:a\r\nDTSTART:20250101T100000Z\r\nRRULE:FREQ=SOMETIMES\r\nEND:VEVENT",
	}
	for name, body := range cases {
		data := "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:test\r\n" + body + "\r\nEND:VCALENDAR\r\n"
		if _, err := Parse([]byte(data), time.UTC); err == nil {
			t.Errorf("%s: accepted", name)
		}
	}
}

func TestGeneratedTimezoneDescribesDaylightSaving(t *testing.T) {
	location, _ := time.LoadLocation("Europe/Amsterdam")
	component := timezoneComponent(location, 2025)
	if len(component.Children) != 2 {
		t.Fatalf("observances %d", len(component.Children))
	}
	for _, observance := range component.Children {
		rule := observance.Props.Get("RRULE").Value
		switch observance.Name {
		case "DAYLIGHT":
			if rule != "FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU" || observance.Props.Get("TZOFFSETTO").Value != "+0200" {
				t.Fatalf("daylight %s %s", rule, observance.Props.Get("TZOFFSETTO").Value)
			}
		case "STANDARD":
			if rule != "FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU" || observance.Props.Get("DTSTART").Value != "19701025T030000" {
				t.Fatalf("standard %s %s", rule, observance.Props.Get("DTSTART").Value)
			}
		}
	}
}
