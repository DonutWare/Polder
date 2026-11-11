package calendar

import (
	"context"
	"testing"
	"time"
)

func TestCreateEventWithClientUIDIsIdempotent(t *testing.T) {
	service, _, owner := newTestService(t, Options{})
	ctx := context.Background()
	personal, err := service.DefaultCalendar(ctx, owner)
	if err != nil {
		t.Fatal(err)
	}
	start := time.Date(2030, 1, 7, 9, 0, 0, 0, time.UTC)
	input := EventInput{UID: "offline-1234@polder-client", Summary: "Dentist", Start: start, End: start.Add(time.Hour)}
	first, err := service.CreateEvent(ctx, owner, personal.ID, input)
	if err != nil {
		t.Fatal(err)
	}
	if first.UID != input.UID {
		t.Fatalf("uid = %q, want %q", first.UID, input.UID)
	}
	again, err := service.CreateEvent(ctx, owner, personal.ID, input)
	if err != nil {
		t.Fatalf("replaying the create failed: %v", err)
	}
	if again.ID != first.ID || again.ETag != first.ETag {
		t.Fatalf("replay created %d/%s, want %d/%s", again.ID, again.ETag, first.ID, first.ETag)
	}
}

func TestCreateEventRejectsMultilineUID(t *testing.T) {
	service, _, owner := newTestService(t, Options{})
	ctx := context.Background()
	personal, err := service.DefaultCalendar(ctx, owner)
	if err != nil {
		t.Fatal(err)
	}
	start := time.Date(2030, 1, 7, 9, 0, 0, 0, time.UTC)
	if _, err := service.CreateEvent(ctx, owner, personal.ID, EventInput{UID: "a\nb", Summary: "x", Start: start}); err == nil {
		t.Fatal("expected an error")
	}
}
