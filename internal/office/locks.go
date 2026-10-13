package office

import (
	"sync"
	"time"
)

// WOPI locks only live as long as the editing session, and the editor locks again after a restart,
// so they are kept in memory.
const lockLifetime = 30 * time.Minute

type heldLock struct {
	id      string
	expires time.Time
}

type locks struct {
	mu   sync.Mutex
	held map[int64]heldLock
	now  func() time.Time
}

func newLocks(now func() time.Time) *locks {
	return &locks{held: map[int64]heldLock{}, now: now}
}

func (l *locks) currentLocked(fileID int64) string {
	held, ok := l.held[fileID]
	if !ok {
		return ""
	}
	if l.now().After(held.expires) {
		delete(l.held, fileID)
		return ""
	}
	return held.id
}

func (l *locks) current(fileID int64) string {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.currentLocked(fileID)
}

// lock takes or renews the lock, or swaps it when oldID is the lock held now. On a conflict it
// returns false and the lock that is held.
func (l *locks) lock(fileID int64, id, oldID string) (string, bool) {
	l.mu.Lock()
	defer l.mu.Unlock()
	current := l.currentLocked(fileID)
	expected := id
	if oldID != "" {
		expected = oldID
	}
	if current != "" && current != expected {
		return current, false
	}
	l.held[fileID] = heldLock{id: id, expires: l.now().Add(lockLifetime)}
	return id, true
}

func (l *locks) refresh(fileID int64, id string) (string, bool) {
	l.mu.Lock()
	defer l.mu.Unlock()
	current := l.currentLocked(fileID)
	if current != id {
		return current, false
	}
	l.held[fileID] = heldLock{id: id, expires: l.now().Add(lockLifetime)}
	return id, true
}

func (l *locks) unlock(fileID int64, id string) (string, bool) {
	l.mu.Lock()
	defer l.mu.Unlock()
	current := l.currentLocked(fileID)
	if current != id {
		return current, false
	}
	delete(l.held, fileID)
	return "", true
}
