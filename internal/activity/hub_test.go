package activity

import (
	"context"
	"testing"
	"time"

	"nomad-server/internal/users"
)

func TestProgressIsSmoothedAndSettles(t *testing.T) {
	start := time.Unix(1_000_000, 0)
	hub := NewHub(nil)
	hub.now = func() time.Time { return start }
	subscription, _ := hub.Subscribe(Scope{Self: 1})
	transfer := hub.Start(context.Background(), TransferSpec{Owner: users.User{ID: 1}, Direction: DirectionUpload, Path: "/a"})
	<-subscription.Events()

	transfer.Add(4 << 20)
	hub.Sweep(start.Add(time.Second))
	progress := <-subscription.Events()
	if progress.Type != EventTransferProgress || progress.Transfer.Rate != 4<<20 || progress.Transfer.Bytes != 4<<20 {
		t.Fatalf("first progress = %+v", progress.Transfer)
	}

	hub.Sweep(start.Add(2 * time.Second))
	if slowed := <-subscription.Events(); slowed.Transfer.Rate >= 4<<20 || slowed.Transfer.Rate == 0 {
		t.Fatalf("an idle second should lower the rate: %d", slowed.Transfer.Rate)
	}
	for tick := 5; tick < 40; tick++ {
		hub.Sweep(start.Add(time.Duration(tick) * tickInterval))
	}
	if snapshot := hub.Snapshot(Scope{Self: 1}); len(snapshot) != 1 || snapshot[0].Rate != 0 {
		t.Fatalf("an idle transfer should settle at zero: %+v", snapshot)
	}

	drained := len(subscription.Events())
	for range drained {
		<-subscription.Events()
	}
	hub.Sweep(start.Add(40 * tickInterval))
	if len(subscription.Events()) != 0 {
		t.Fatal("an idle transfer at zero should not publish")
	}
}

func TestOtherUsersEventsStayPrivate(t *testing.T) {
	hub := NewHub(nil)
	own, _ := hub.Subscribe(Scope{Self: 1})
	admin, _ := hub.Subscribe(Scope{Self: 3, All: true})
	hub.Publish(Event{Type: EventFilesChanged, UserID: 2})
	if len(own.Events()) != 0 || len(admin.Events()) != 1 {
		t.Fatalf("own %d, admin %d", len(own.Events()), len(admin.Events()))
	}
	if snapshot := admin.SetScope(Scope{Self: 3, UserID: 1}); len(snapshot) != 0 {
		t.Fatalf("snapshot = %+v", snapshot)
	}
	hub.Publish(Event{Type: EventFilesChanged, UserID: 2})
	if len(admin.Events()) != 1 {
		t.Fatal("a scope narrowed to user 1 should skip user 2")
	}
}

func TestSlowSubscriberIsDropped(t *testing.T) {
	hub := NewHub(nil)
	slow, _ := hub.Subscribe(Scope{Self: 1})
	for range subscriptionBuffer + 1 {
		hub.Publish(Event{Type: EventFilesChanged, UserID: 1})
	}
	received := 0
	for range slow.Events() {
		received++
	}
	if received != subscriptionBuffer {
		t.Fatalf("received %d before the drop", received)
	}
}

func TestAggregatesJoinAndAbandonedTransfersAreDropped(t *testing.T) {
	start := time.Unix(1_000_000, 0)
	hub := NewHub(nil)
	hub.now = func() time.Time { return start }
	ctx := context.Background()
	reads := hub.Aggregate(ctx, "key", TransferSpec{Owner: users.User{ID: 1}, Direction: DirectionDownload, Path: "/a"})
	if again := hub.Aggregate(ctx, "key", TransferSpec{}); again != reads {
		t.Fatal("the same key should join the running transfer")
	}
	hub.Discard(reads)
	stalled := hub.Start(ctx, TransferSpec{Owner: users.User{ID: 1}, Direction: DirectionUpload, Path: "/b"})

	hub.Sweep(start.Add(aggregateIdle))
	if hub.Lookup(stalled.info.ID) == nil {
		t.Fatal("an upload should outlive the aggregate timeout")
	}
	hub.Sweep(start.Add(abandonIdle))
	if len(hub.Snapshot(Scope{All: true})) != 0 {
		t.Fatal("abandoned transfers should be gone")
	}
}

func TestHeldTransferOutlivesQuietStretch(t *testing.T) {
	start := time.Unix(1_000_000, 0)
	hub := NewHub(nil)
	hub.now = func() time.Time { return start }
	ctx := context.Background()
	committing := hub.Start(ctx, TransferSpec{Owner: users.User{ID: 1}, Direction: DirectionUpload, Path: "/big"})
	paused := hub.Start(ctx, TransferSpec{Owner: users.User{ID: 1}, Direction: DirectionUpload, Path: "/paused"})
	release := committing.Hold()

	hub.Sweep(start.Add(abandonIdle))
	if hub.Lookup(committing.info.ID) == nil || hub.Lookup(paused.info.ID) != nil {
		t.Fatal("only the held transfer should survive")
	}
	release()
	hub.Sweep(start.Add(2 * abandonIdle))
	if hub.Lookup(committing.info.ID) != nil {
		t.Fatal("a released transfer goes idle like any other")
	}
}
