package calendar

import (
	"context"
	"testing"
	"time"

	"polder-server/internal/users"
)

func searchFixture(t *testing.T) (*Service, users.User, time.Time) {
	t.Helper()
	service, _, owner := newTestService(t, Options{})
	now := time.Date(2030, 3, 13, 12, 0, 0, 0, time.UTC)
	service.now = func() time.Time { return now }
	ctx := context.Background()
	personal, err := service.DefaultCalendar(ctx, owner)
	if err != nil {
		t.Fatal(err)
	}
	work, err := service.Create(ctx, owner, NewCalendar{Name: "Work"})
	if err != nil {
		t.Fatal(err)
	}
	create := func(calendarID int64, input EventInput) {
		if _, err := service.CreateEvent(ctx, owner, calendarID, input); err != nil {
			t.Fatal(err)
		}
	}
	monday := time.Date(2030, 1, 7, 9, 0, 0, 0, time.UTC)
	create(work.ID, EventInput{Summary: "Team standup", Location: "Room 4", Start: monday, End: monday.Add(15 * time.Minute), RRule: "FREQ=WEEKLY"})
	create(personal.ID, EventInput{Summary: "Yoga class", Start: monday, End: monday.Add(time.Hour), RRule: "FREQ=WEEKLY;COUNT=3"})
	create(personal.ID, EventInput{Summary: "Dentist", Description: "Bring the standup notes", Start: now.AddDate(0, 0, 3), End: now.AddDate(0, 0, 3).Add(time.Hour)})
	create(personal.ID, EventInput{Summary: "Old standup retro", Start: now.AddDate(0, -1, 0), End: now.AddDate(0, -1, 0).Add(time.Hour)})
	return service, owner, now
}

func summaries(results EventResults) []string {
	names := make([]string, len(results.Results))
	for i, match := range results.Results {
		names[i] = match.Event.Summary
	}
	return names
}

func TestSearchEventsListsRepeatingEventsOnceAtTheirNextOccurrence(t *testing.T) {
	service, owner, now := searchFixture(t)
	results, err := service.SearchEvents(context.Background(), owner, "standup", 50, 0)
	if err != nil {
		t.Fatal(err)
	}
	got := summaries(results)
	want := []string{"Team standup", "Old standup retro", "Dentist"}
	if len(got) != len(want) || got[0] != want[0] || got[1] != want[1] || got[2] != want[2] {
		t.Fatalf("summaries %v, want %v", got, want)
	}
	standup := results.Results[0]
	nextMonday := time.Date(2030, 3, 18, 9, 0, 0, 0, time.UTC)
	if !standup.Upcoming || !standup.Event.Start.Equal(nextMonday) || standup.Event.RecurrenceID == "" {
		t.Fatalf("standup %+v, want the occurrence on %v", standup.Event, nextMonday)
	}
	if len(standup.SummaryMatches) != 1 || standup.SummaryMatches[0].Start != 5 {
		t.Fatalf("summary matches %+v", standup.SummaryMatches)
	}
	if results.Results[1].Upcoming || !results.Results[1].Event.Start.Before(now) {
		t.Fatalf("retro should be past: %+v", results.Results[1])
	}
}

func TestSearchEventsShowsTheLastOccurrenceOfAnEndedSeries(t *testing.T) {
	service, owner, _ := searchFixture(t)
	results, err := service.SearchEvents(context.Background(), owner, "yoga", 50, 0)
	if err != nil {
		t.Fatal(err)
	}
	lastClass := time.Date(2030, 1, 21, 9, 0, 0, 0, time.UTC)
	if len(results.Results) != 1 || results.Results[0].Upcoming || !results.Results[0].Event.Start.Equal(lastClass) {
		t.Fatalf("results %+v, want one past hit on %v", results.Results, lastClass)
	}
}

func TestSearchEventsFilters(t *testing.T) {
	service, owner, _ := searchFixture(t)
	tests := []struct {
		query string
		want  int
	}{
		{"type=event", 4},
		{"type=event repeats=yes", 2},
		{"repeats=no", 2},
		{"repeats=weekly standup", 1},
		{"calendar=work", 1},
		{"-cal:work", 3},
		{"when=upcoming", 2},
		{"when=past", 3},
		{"when=2030-02 yoga", 0},
		{"when=2030-01 yoga", 1},
		{"room", 1},
		{"type=pdf", 0},
		{"in=/Documents standup", 0},
		{"", 0},
	}
	for _, test := range tests {
		results, err := service.SearchEvents(context.Background(), owner, test.query, 50, 0)
		if err != nil {
			t.Fatal(err)
		}
		if results.Total != test.want {
			t.Errorf("%q: %d results %v, want %d", test.query, results.Total, summaries(results), test.want)
		}
	}
}

func TestSearchEventsPages(t *testing.T) {
	service, owner, _ := searchFixture(t)
	results, err := service.SearchEvents(context.Background(), owner, "type=event", 2, 2)
	if err != nil {
		t.Fatal(err)
	}
	if results.Total != 4 || len(results.Results) != 2 {
		t.Fatalf("total %d, page %d", results.Total, len(results.Results))
	}
}
