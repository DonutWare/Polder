package calendar

import (
	"testing"

	"github.com/emersion/go-ical"
)

func TestGooglePublicCalendarsKeepOnlyTheHolidayType(t *testing.T) {
	split, err := splitByUID(feedLines(
		"BEGIN:VCALENDAR", "VERSION:2.0",
		"BEGIN:VEVENT", "UID:a", "DTSTART;VALUE=DATE:20260214", "SUMMARY:Valentijnsdag",
		"DESCRIPTION:Viering\\nAls je vieringen wilt verbergen\\, ga je naar de instellingen van Google Agenda > Feestdagen in Nederland",
		"END:VEVENT",
		"BEGIN:VEVENT", "UID:b", "DTSTART;VALUE=DATE:20261225", "SUMMARY:Eerste Kerstdag", "DESCRIPTION:Officiële feestdag", "END:VEVENT",
		"END:VCALENDAR",
	))
	if err != nil {
		t.Fatal(err)
	}
	tidyFeed("https://example.com/holidays.ics", split)
	if got := propText(split.byUID["a"][0], ical.PropDescription); got == "Viering" {
		t.Fatal("another feed had its description shortened")
	}
	tidyFeed("https://calendar.google.com/calendar/ical/nl.dutch%23holiday%40group.v.calendar.google.com/public/basic.ics", split)
	for uid, want := range map[string]string{"a": "Viering", "b": "Officiële feestdag"} {
		if got := propText(split.byUID[uid][0], ical.PropDescription); got != want {
			t.Errorf("%s: description %q, want %q", uid, got, want)
		}
	}
}

func TestOnlyGooglePublicCalendarsAreTidied(t *testing.T) {
	google := "https://calendar.google.com/calendar/ical/nl.dutch%23holiday%40group.v.calendar.google.com/public/basic.ics"
	stored := "https://calendar.google.com/calendar/ical/nl.dutch%23holiday@group.v.calendar.google.com/public/basic.ics"
	private := "https://calendar.google.com/calendar/ical/alice%40gmail.com/private-abc/basic.ics"
	if !isGooglePublicCalendar(google) || !isGooglePublicCalendar(stored) {
		t.Fatal("a Google holiday calendar was not recognised")
	}
	if isGooglePublicCalendar(private) || isGooglePublicCalendar("https://example.com/group.v.calendar.google.com.ics") {
		t.Fatal("another feed was treated as a Google public calendar")
	}
}
