package webdav

import (
	"crypto/rand"
	"fmt"
	"sync"
	"time"

	"polder-server/internal/storage"
)

const (
	defaultLockTimeout     = 10 * time.Minute
	maxLockTimeout         = time.Hour
	maxLocksPerPrincipal   = 1000
	lockTokenPrefix        = "urn:uuid:"
	maxLockOwnerLength     = 1 << 10
	lockScopeExclusive     = "exclusive"
	lockScopeShared        = "shared"
	lockDepthInfinite      = -1
	lockDepthResourceOnly  = 0
	lockSweepEveryNRequest = 64
)

type lockKey struct {
	ownerID int64
	path    string
}

type Lock struct {
	Token     string
	Principal string
	Root      lockKey
	Scope     string
	Depth     int
	Owner     string
	Timeout   time.Duration
	ExpiresAt time.Time
}

func (l *Lock) covers(key lockKey) bool {
	if l.Root.ownerID != key.ownerID {
		return false
	}
	if l.Root.path == key.path {
		return true
	}
	return l.Depth == lockDepthInfinite && storage.IsSameOrDescendant(key.path, l.Root.path)
}

func (l *Lock) within(key lockKey) bool {
	return l.Root.ownerID == key.ownerID && storage.IsSameOrDescendant(l.Root.path, key.path)
}

type LockManager struct {
	mu       sync.Mutex
	locks    map[string]*Lock
	requests int
	now      func() time.Time
}

func NewLockManager() *LockManager {
	return &LockManager{locks: map[string]*Lock{}, now: time.Now}
}

type lockRequest struct {
	principal string
	key       lockKey
	scope     string
	depth     int
	owner     string
	timeout   time.Duration
}

func (m *LockManager) Create(request lockRequest) (*Lock, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.sweep()
	if m.countFor(request.principal) >= maxLocksPerPrincipal {
		return nil, errTooManyLocks
	}
	for _, existing := range m.locks {
		conflicts := existing.covers(request.key) || (request.depth == lockDepthInfinite && existing.within(request.key))
		if conflicts && (existing.Scope == lockScopeExclusive || request.scope == lockScopeExclusive) {
			return nil, errLocked
		}
	}
	lock := &Lock{
		Token:     newLockToken(),
		Principal: request.principal,
		Root:      request.key,
		Scope:     request.scope,
		Depth:     request.depth,
		Owner:     request.owner,
		Timeout:   request.timeout,
		ExpiresAt: m.now().Add(request.timeout),
	}
	m.locks[lock.Token] = lock
	return lock, nil
}

func (m *LockManager) Refresh(principal string, key lockKey, tokens []string, timeout time.Duration) (*Lock, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.sweep()
	for _, token := range tokens {
		lock, found := m.locks[token]
		if found && lock.Principal == principal && lock.covers(key) {
			lock.Timeout = timeout
			lock.ExpiresAt = m.now().Add(timeout)
			copied := *lock
			return &copied, nil
		}
	}
	return nil, errLockTokenMismatch
}

func (m *LockManager) Unlock(principal string, key lockKey, token string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.sweep()
	lock, found := m.locks[token]
	if !found || !lock.covers(key) {
		return errLockTokenMismatch
	}
	if lock.Principal != principal {
		return errLockForbidden
	}
	delete(m.locks, token)
	return nil
}

func (m *LockManager) Check(principal string, key lockKey, tokens []string, includeDescendants bool) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.requests++
	if m.requests%lockSweepEveryNRequest == 0 {
		m.sweep()
	}
	now := m.now()
	for _, lock := range m.locks {
		if now.After(lock.ExpiresAt) {
			continue
		}
		affected := lock.covers(key) || (includeDescendants && lock.within(key))
		if affected && (lock.Principal != principal || !containsToken(tokens, lock.Token)) {
			return errLocked
		}
	}
	return nil
}

func (m *LockManager) Discover(key lockKey) []Lock {
	m.mu.Lock()
	defer m.mu.Unlock()
	now := m.now()
	var found []Lock
	for _, lock := range m.locks {
		if !now.After(lock.ExpiresAt) && lock.covers(key) {
			found = append(found, *lock)
		}
	}
	return found
}

func (m *LockManager) Release(key lockKey) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for token, lock := range m.locks {
		if lock.within(key) {
			delete(m.locks, token)
		}
	}
}

func (m *LockManager) sweep() {
	now := m.now()
	for token, lock := range m.locks {
		if now.After(lock.ExpiresAt) {
			delete(m.locks, token)
		}
	}
}

func (m *LockManager) countFor(principal string) int {
	count := 0
	for _, lock := range m.locks {
		if lock.Principal == principal {
			count++
		}
	}
	return count
}

func containsToken(tokens []string, token string) bool {
	for _, candidate := range tokens {
		if candidate == token {
			return true
		}
	}
	return false
}

func newLockToken() string {
	b := make([]byte, 16)
	_, _ = rand.Read(b)
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	return fmt.Sprintf("%s%x-%x-%x-%x-%x", lockTokenPrefix, b[0:4], b[4:6], b[6:8], b[8:10], b[10:16])
}
