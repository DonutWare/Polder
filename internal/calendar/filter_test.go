package calendar

import (
	"testing"
	"time"
)

func eventFilter(child CompFilter) CompFilter {
	return CompFilter{Name: "VCALENDAR", Comps: []CompFilter{child}}
}

func TestFiltersMatchTextParametersAndMissingProperties(t *testing.T) {
	resource := mustParse(t,
		"BEGIN:VEVENT", "UID:a", "DTSTAMP:20250101T000000Z", "DTSTART:20250106T090000Z", "DURATION:PT1H",
		"SUMMARY:Quarterly Review", "ATTENDEE;PARTSTAT=ACCEPTED:mailto:bob@example.com",
		"END:VEVENT")
	cases := []struct {
		name   string
		filter CompFilter
		want   bool
	}{
		{"case-insensitive by default", eventFilter(CompFilter{Name: "VEVENT", Props: []PropFilter{{Name: "SUMMARY", TextMatch: &TextMatch{Text: "quarterly"}}}}), true},
		{"octet is case-sensitive", eventFilter(CompFilter{Name: "VEVENT", Props: []PropFilter{{Name: "SUMMARY", TextMatch: &TextMatch{Text: "quarterly", Collation: CollationOctet}}}}), false},
		{"negated", eventFilter(CompFilter{Name: "VEVENT", Props: []PropFilter{{Name: "SUMMARY", TextMatch: &TextMatch{Text: "review", Negate: true}}}}), false},
		{"missing property", eventFilter(CompFilter{Name: "VEVENT", Props: []PropFilter{{Name: "LOCATION", IsNotDefined: true}}}), true},
		{"parameter", eventFilter(CompFilter{Name: "VEVENT", Props: []PropFilter{{Name: "ATTENDEE", Params: []ParamFilter{{Name: "PARTSTAT", TextMatch: &TextMatch{Text: "ACCEPTED"}}}}}}), true},
		{"no todos", eventFilter(CompFilter{Name: "VTODO", IsNotDefined: true}), true},
		{"wrong component", eventFilter(CompFilter{Name: "VTODO"}), false},
		{"time range overlap", eventFilter(CompFilter{Name: "VEVENT", TimeRange: &TimeRange{Start: time.Date(2025, 1, 6, 9, 30, 0, 0, time.UTC), End: time.Date(2025, 1, 6, 9, 45, 0, 0, time.UTC)}}), true},
		{"end is exclusive", eventFilter(CompFilter{Name: "VEVENT", TimeRange: &TimeRange{Start: time.Date(2025, 1, 6, 10, 0, 0, 0, time.UTC), End: time.Date(2025, 1, 6, 11, 0, 0, 0, time.UTC)}}), false},
	}
	for _, c := range cases {
		got, err := resource.Matches(c.filter)
		if err != nil {
			t.Fatal(err)
		}
		if got != c.want {
			t.Errorf("%s: got %v", c.name, got)
		}
	}
}

func TestAlarmTriggersRepeatRelateToEndAndRespectAcknowledgement(t *testing.T) {
	resource := mustParse(t,
		"BEGIN:VEVENT", "UID:a", "DTSTAMP:20250101T000000Z", "DTSTART:20250106T090000Z", "DTEND:20250106T100000Z",
		"RRULE:FREQ=DAILY;COUNT=3",
		"BEGIN:VALARM", "ACTION:DISPLAY", "TRIGGER:-PT15M", "REPEAT:2", "DURATION:PT5M", "ACKNOWLEDGED:20250106T085000Z", "END:VALARM",
		"BEGIN:VALARM", "ACTION:DISPLAY", "TRIGGER;RELATED=END:PT0S", "END:VALARM",
		"BEGIN:VALARM", "ACTION:NONE", "TRIGGER:-PT1H", "END:VALARM",
		"END:VEVENT")
	triggers, err := resource.TriggersBetween(time.Date(2025, 1, 6, 0, 0, 0, 0, time.UTC), time.Date(2025, 1, 7, 0, 0, 0, 0, time.UTC))
	if err != nil {
		t.Fatal(err)
	}
	var moments []string
	for _, trigger := range triggers {
		moments = append(moments, trigger.At.Format("15:04"))
	}
	if got := len(moments); got != 2 || moments[0] != "08:55" || moments[1] != "10:00" {
		t.Fatalf("triggers %v", moments)
	}
	next, err := resource.TriggersBetween(time.Date(2025, 1, 7, 0, 0, 0, 0, time.UTC), time.Date(2025, 1, 8, 0, 0, 0, 0, time.UTC))
	if err != nil {
		t.Fatal(err)
	}
	if len(next) != 4 {
		t.Fatalf("second day triggers %d", len(next))
	}
}

func TestRSVPTokensRejectTampering(t *testing.T) {
	service := &Service{options: Options{RSVPKey: []byte("secret")}}
	token := service.rsvpToken(rsvpClaims{ObjectID: 7, Attendee: "mailto:carol@example.com", UID: "x"})
	claims, err := service.parseRSVPToken(token)
	if err != nil || claims.ObjectID != 7 || claims.Attendee != "mailto:carol@example.com" {
		t.Fatalf("round trip %+v %v", claims, err)
	}
	other := &Service{options: Options{RSVPKey: []byte("other")}}
	if _, err := other.parseRSVPToken(token); err == nil {
		t.Fatal("a token signed with another key was accepted")
	}
	if _, err := service.parseRSVPToken(token[:len(token)-2] + "AA"); err == nil {
		t.Fatal("a changed signature was accepted")
	}
}
