package activity

import (
	"cmp"
	"context"
	"errors"
	"io"
	"log/slog"
	"sort"
	"sync"
	"sync/atomic"
	"time"

	"nomad-server/internal/apperr"
	"nomad-server/internal/storage"
	"nomad-server/internal/users"
)

const (
	tickInterval       = 500 * time.Millisecond
	aggregateIdle      = 5 * time.Second
	abandonIdle        = 30 * time.Second
	rateSmoothing      = 0.3
	minimumRate        = 1024
	subscriptionBuffer = 128
)

type EventType string

const (
	EventReady            EventType = "ready"
	EventSnapshot         EventType = "snapshot"
	EventError            EventType = "error"
	EventTransferStarted  EventType = "transfer.started"
	EventTransferProgress EventType = "transfer.progress"
	EventTransferFinished EventType = "transfer.finished"
	EventActivity         EventType = "activity.created"
	EventFilesChanged     EventType = "files.changed"
)

type Event struct {
	Type     EventType     `json:"type"`
	UserID   int64         `json:"userId"`
	Transfer *LiveTransfer `json:"transfer,omitempty"`
	Status   Status        `json:"status,omitempty"`
	LogEntry *LogEntry     `json:"entry,omitempty"`
	Dirs     []string      `json:"dirs,omitempty"`
}

type LiveTransfer struct {
	ID        string    `json:"id"`
	UserID    int64     `json:"userId"`
	Username  string    `json:"username"`
	Direction Direction `json:"direction"`
	Path      string    `json:"path"`
	Device    string    `json:"device"`
	ClientID  string    `json:"clientId,omitempty" required:"false" doc:"The X-Nomad-Transfer-Id the uploader sent"`
	Bytes     int64     `json:"bytes" doc:"Bytes transferred so far"`
	Total     *int64    `json:"total,omitempty" required:"false" doc:"Bytes expected in all; absent when unknown"`
	Rate      int64     `json:"rate" doc:"Current speed in bytes per second"`
	StartedAt time.Time `json:"startedAt"`
}

type TransferSpec struct {
	ID        string
	Owner     users.User
	Direction Direction
	Path      string
	Total     *int64
	ClientID  string
}

// Transfer is an upload or download in progress. Counting bytes is lock-free; the hub's ticker
// turns the count into progress events, so a fast transfer never floods subscribers.
type Transfer struct {
	info      LiveTransfer
	sessionID int64
	aggregate string
	bytes     atomic.Int64
	holds     atomic.Int32

	rate       float64
	lastBytes  int64
	lastTick   time.Time
	lastActive time.Time
	resultSize *int64
}

func (t *Transfer) UserID() int64 {
	return t.info.UserID
}

// Hold keeps a transfer live through quiet stretches, such as assembling a big upload on commit.
func (t *Transfer) Hold() (release func()) {
	t.holds.Add(1)
	var once sync.Once
	return func() { once.Do(func() { t.holds.Add(-1) }) }
}

func (t *Transfer) Add(n int64) {
	t.bytes.Add(n)
}

func (t *Transfer) Reader(source io.Reader) *CountingReader {
	return &CountingReader{source: source, transfer: t}
}

type CountingReader struct {
	source   io.Reader
	transfer *Transfer
	count    int64
}

func (r *CountingReader) Read(p []byte) (int, error) {
	n, err := r.source.Read(p)
	r.count += int64(n)
	r.transfer.Add(int64(n))
	return n, err
}

// Undo takes back what this reader counted, for data the server ended up rejecting.
func (r *CountingReader) Undo() {
	r.transfer.Add(-r.count)
	r.count = 0
}

type Scope struct {
	Self   int64
	All    bool
	UserID int64
}

func (s Scope) Matches(userID int64) bool {
	return userID == s.Self || s.All || (s.UserID != 0 && userID == s.UserID)
}

type Subscription struct {
	hub    *Hub
	events chan Event
	scope  Scope
}

func (s *Subscription) Events() <-chan Event {
	return s.events
}

// SetScope changes whose events arrive and returns the transfers now in scope.
func (s *Subscription) SetScope(scope Scope) []LiveTransfer {
	s.hub.mu.Lock()
	defer s.hub.mu.Unlock()
	s.scope = scope
	return s.hub.snapshotLocked(scope)
}

func (s *Subscription) Close() {
	s.hub.mu.Lock()
	defer s.hub.mu.Unlock()
	s.hub.dropLocked(s)
}

type Hub struct {
	store *Store
	now   func() time.Time

	mu            sync.Mutex
	transfers     map[string]*Transfer
	aggregates    map[string]*Transfer
	subscriptions map[*Subscription]struct{}
	closed        bool
}

func NewHub(store *Store) *Hub {
	return &Hub{
		store:         store,
		now:           time.Now,
		transfers:     map[string]*Transfer{},
		aggregates:    map[string]*Transfer{},
		subscriptions: map[*Subscription]struct{}{},
	}
}

func (h *Hub) Store() *Store { return h.store }

// Start begins tracking a transfer; starting an ID that is already tracked returns that transfer.
func (h *Hub) Start(ctx context.Context, spec TransferSpec) *Transfer {
	h.mu.Lock()
	defer h.mu.Unlock()
	if existing := h.transfers[spec.ID]; spec.ID != "" && existing != nil {
		return existing
	}
	return h.startLocked(ActorFrom(ctx), spec, "")
}

// Aggregate merges requests sharing a key, such as the range reads of one sync download, into one
// transfer that finishes once the requests stop coming.
func (h *Hub) Aggregate(ctx context.Context, key string, spec TransferSpec) *Transfer {
	h.mu.Lock()
	defer h.mu.Unlock()
	if existing := h.aggregates[key]; existing != nil {
		return existing
	}
	transfer := h.startLocked(ActorFrom(ctx), spec, key)
	h.aggregates[key] = transfer
	return transfer
}

func (h *Hub) startLocked(actor Actor, spec TransferSpec, aggregate string) *Transfer {
	if spec.ID == "" {
		spec.ID = storage.NewID()
	}
	now := h.now()
	transfer := &Transfer{
		info: LiveTransfer{
			ID: spec.ID, UserID: spec.Owner.ID, Username: spec.Owner.Username, Direction: spec.Direction,
			Path: spec.Path, Device: actor.Device, ClientID: spec.ClientID, Total: spec.Total, StartedAt: now.UTC(),
		},
		sessionID:  actor.SessionID,
		aggregate:  aggregate,
		lastTick:   now,
		lastActive: now,
	}
	h.transfers[spec.ID] = transfer
	h.publishLocked(Event{Type: EventTransferStarted, UserID: spec.Owner.ID, Transfer: transfer.snapshot()})
	return transfer
}

func (h *Hub) Lookup(id string) *Transfer {
	h.mu.Lock()
	defer h.mu.Unlock()
	return h.transfers[id]
}

// Finish logs the transfer once; err decides whether it counts as done, failed or cancelled.
func (h *Hub) Finish(ctx context.Context, transfer *Transfer, err error) {
	status, detail := outcome(ctx, err)
	snapshot, resultSize, ok := h.detach(transfer, status)
	if !ok {
		return
	}
	entry := LogEntry{
		UserID: snapshot.UserID, Username: snapshot.Username, Device: snapshot.Device, sessionID: transfer.sessionID,
		Kind: Kind(snapshot.Direction), Path: snapshot.Path, Size: snapshot.Total, Bytes: ptr(snapshot.Bytes),
		DurationMs: ptr(h.now().Sub(snapshot.StartedAt).Milliseconds()), Status: status, Detail: detail,
	}
	if resultSize != nil {
		entry.Size = resultSize
	}
	h.record(ctx, entry)
}

// Discard stops tracking a transfer without logging it.
func (h *Hub) Discard(transfer *Transfer) {
	h.detach(transfer, StatusCancelled)
}

func (h *Hub) detach(transfer *Transfer, status Status) (LiveTransfer, *int64, bool) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if transfer == nil || h.transfers[transfer.info.ID] != transfer {
		return LiveTransfer{}, nil, false
	}
	delete(h.transfers, transfer.info.ID)
	if transfer.aggregate != "" {
		delete(h.aggregates, transfer.aggregate)
	}
	snapshot := transfer.snapshot()
	h.publishLocked(Event{Type: EventTransferFinished, UserID: snapshot.UserID, Transfer: snapshot, Status: status})
	return *snapshot, transfer.resultSize, true
}

func (h *Hub) complete(transfer *Transfer, size int64) {
	h.mu.Lock()
	defer h.mu.Unlock()
	transfer.resultSize = &size
}

func outcome(ctx context.Context, err error) (Status, string) {
	switch {
	case err == nil:
		return StatusOK, ""
	case ctx.Err() != nil, errors.Is(err, context.Canceled), errors.Is(err, context.DeadlineExceeded), errors.Is(err, io.ErrUnexpectedEOF):
		return StatusCancelled, ""
	}
	if appErr, ok := errors.AsType[*apperr.Error](err); ok {
		return StatusFailed, appErr.Message
	}
	return StatusFailed, err.Error()
}

func (h *Hub) record(ctx context.Context, entry LogEntry) {
	entry.Status = cmp.Or(entry.Status, StatusOK)
	saved, err := h.store.Insert(context.WithoutCancel(ctx), entry)
	if err != nil {
		slog.Warn("record activity", "kind", entry.Kind, "path", entry.Path, "error", err)
		return
	}
	h.Publish(Event{Type: EventActivity, UserID: saved.UserID, LogEntry: &saved})
}

func (h *Hub) Snapshot(scope Scope) []LiveTransfer {
	h.mu.Lock()
	defer h.mu.Unlock()
	return h.snapshotLocked(scope)
}

func (h *Hub) snapshotLocked(scope Scope) []LiveTransfer {
	transfers := []LiveTransfer{}
	for _, transfer := range h.transfers {
		if scope.Matches(transfer.info.UserID) {
			transfers = append(transfers, *transfer.snapshot())
		}
	}
	sort.Slice(transfers, func(i, j int) bool { return transfers[i].StartedAt.Before(transfers[j].StartedAt) })
	return transfers
}

func (t *Transfer) snapshot() *LiveTransfer {
	info := t.info
	info.Bytes = max(t.bytes.Load(), 0)
	info.Rate = int64(t.rate)
	return &info
}

// Subscribe returns a subscription and the transfers in its scope at that moment.
func (h *Hub) Subscribe(scope Scope) (*Subscription, []LiveTransfer) {
	h.mu.Lock()
	defer h.mu.Unlock()
	subscription := &Subscription{hub: h, events: make(chan Event, subscriptionBuffer), scope: scope}
	if h.closed {
		close(subscription.events)
		return subscription, nil
	}
	h.subscriptions[subscription] = struct{}{}
	return subscription, h.snapshotLocked(scope)
}

func (h *Hub) Publish(event Event) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.publishLocked(event)
}

// publishLocked never blocks: a subscriber too slow to keep up is dropped, and reconnects to a
// fresh snapshot.
func (h *Hub) publishLocked(event Event) {
	for subscription := range h.subscriptions {
		if !subscription.scope.Matches(event.UserID) {
			continue
		}
		select {
		case subscription.events <- event:
		default:
			h.dropLocked(subscription)
		}
	}
}

func (h *Hub) dropLocked(subscription *Subscription) {
	if _, ok := h.subscriptions[subscription]; ok {
		delete(h.subscriptions, subscription)
		close(subscription.events)
	}
}

func (h *Hub) Run(ctx context.Context) {
	ticker := time.NewTicker(tickInterval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			h.Close()
			return
		case <-ticker.C:
			h.Sweep(h.now())
		}
	}
}

func (h *Hub) Close() {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.closed = true
	for subscription := range h.subscriptions {
		h.dropLocked(subscription)
	}
}

// Sweep updates every transfer's speed, publishes progress, and ends transfers that went quiet.
func (h *Hub) Sweep(now time.Time) {
	var settled, abandoned []*Transfer
	h.mu.Lock()
	for _, transfer := range h.transfers {
		if transfer.tick(now) {
			h.publishLocked(Event{Type: EventTransferProgress, UserID: transfer.info.UserID, Transfer: transfer.snapshot()})
		}
		idle := now.Sub(transfer.lastActive)
		switch {
		case transfer.aggregate != "" && idle >= aggregateIdle:
			settled = append(settled, transfer)
		case idle >= abandonIdle && transfer.holds.Load() == 0:
			abandoned = append(abandoned, transfer)
		}
	}
	h.mu.Unlock()

	for _, transfer := range settled {
		h.Finish(context.Background(), transfer, nil)
	}
	for _, transfer := range abandoned {
		h.Discard(transfer)
	}
}

func (t *Transfer) tick(now time.Time) bool {
	elapsed := now.Sub(t.lastTick).Seconds()
	if elapsed <= 0 {
		return false
	}
	bytes := t.bytes.Load()
	moved := bytes != t.lastBytes
	instant := max(float64(bytes-t.lastBytes)/elapsed, 0)
	previous := t.rate
	switch {
	case moved && t.rate == 0:
		t.rate = instant
	default:
		t.rate = rateSmoothing*instant + (1-rateSmoothing)*t.rate
	}
	if !moved && t.rate < minimumRate {
		t.rate = 0
	}
	t.lastTick = now
	t.lastBytes = bytes
	if moved {
		t.lastActive = now
	}
	return moved || previous != t.rate
}
