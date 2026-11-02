package calendar

import (
	"context"
	"sync"
	"testing"
	"time"

	"polder-server/internal/activity"
	"polder-server/internal/config"
	"polder-server/internal/database"
	"polder-server/internal/users"
)

type recordingHub struct {
	mu     sync.Mutex
	events []activity.Event
}

func (h *recordingHub) Publish(event activity.Event) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.events = append(h.events, event)
}

func (h *recordingHub) reminders() []activity.Event {
	h.mu.Lock()
	defer h.mu.Unlock()
	var reminders []activity.Event
	for _, event := range h.events {
		if event.Type == activity.EventCalendarReminder {
			reminders = append(reminders, event)
		}
	}
	return reminders
}

func newTestService(t *testing.T, options Options) (*Service, *recordingHub, users.User) {
	t.Helper()
	cfg := config.Default()
	cfg.ConfigDir = t.TempDir()
	db, err := database.Open(cfg)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { db.Close() })
	userStore := users.NewStore(db)
	owner, err := userStore.Insert(context.Background(), users.NewUser{Username: "alice", Role: users.RoleUser}, "hash")
	if err != nil {
		t.Fatal(err)
	}
	if err := userStore.SetProfile(context.Background(), owner.ID, users.Profile{Email: "alice@example.com"}); err != nil {
		t.Fatal(err)
	}
	if owner, err = userStore.ByID(context.Background(), owner.ID); err != nil {
		t.Fatal(err)
	}
	hub := &recordingHub{}
	return NewService(db, userStore, nil, hub, options), hub, owner
}

func TestRemindersFireOncePerOccurrence(t *testing.T) {
	service, hub, owner := newTestService(t, Options{})
	ctx := context.Background()
	personal, err := service.DefaultCalendar(ctx, owner)
	if err != nil {
		t.Fatal(err)
	}
	offset := -10
	start := time.Date(2030, 1, 7, 9, 0, 0, 0, time.UTC)
	if _, err := service.CreateEvent(ctx, owner, personal.ID, EventInput{
		Summary: "Dentist", Start: start, End: start.Add(time.Hour), RRule: "FREQ=DAILY;COUNT=2",
		Alarms: []Alarm{{Action: "DISPLAY", OffsetMinutes: &offset}},
	}); err != nil {
		t.Fatal(err)
	}
	before := start.Add(-11 * time.Minute)
	after := start.Add(-9 * time.Minute)
	for range 2 {
		if err := service.FireReminders(ctx, before, after); err != nil {
			t.Fatal(err)
		}
	}
	reminders := hub.reminders()
	if len(reminders) != 1 || reminders[0].UserID != owner.ID || reminders[0].Reminder.Summary != "Dentist" || !reminders[0].Reminder.Start.Equal(start) {
		t.Fatalf("reminders %+v", reminders)
	}
	if err := service.FireReminders(ctx, before.Add(24*time.Hour), after.Add(24*time.Hour)); err != nil {
		t.Fatal(err)
	}
	if got := len(hub.reminders()); got != 2 {
		t.Fatalf("second occurrence: %d reminders", got)
	}
}
