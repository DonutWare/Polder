package files

import (
	"testing"
	"time"
)

const lockWait = 50 * time.Millisecond

func acquires(locks *pathLocks, userID int64, paths ...string) <-chan func() {
	acquired := make(chan func(), 1)
	go func() { acquired <- locks.lock(userID, paths...) }()
	return acquired
}

func expectAcquired(t *testing.T, acquired <-chan func()) func() {
	t.Helper()
	select {
	case unlock := <-acquired:
		return unlock
	case <-time.After(time.Second):
		t.Fatal("lock was not granted")
		return nil
	}
}

func expectWaiting(t *testing.T, acquired <-chan func()) {
	t.Helper()
	select {
	case <-acquired:
		t.Fatal("lock was granted while a conflicting lock is held")
	case <-time.After(lockWait):
	}
}

func TestPathLocksLetUnrelatedPathsThrough(t *testing.T) {
	var locks pathLocks
	unlockMove := locks.lock(1, "/photos", "/archive/photos")
	defer unlockMove()

	expectAcquired(t, acquires(&locks, 1, "/documents/report.md"))()
	expectAcquired(t, acquires(&locks, 2, "/photos"))()
}

func TestPathLocksMakeOverlappingPathsWait(t *testing.T) {
	for _, path := range []string{"/photos", "/photos/2024/beach.jpg", "/archive", "/"} {
		t.Run(path, func(t *testing.T) {
			var locks pathLocks
			unlockMove := locks.lock(1, "/photos", "/archive/photos")
			waiting := acquires(&locks, 1, path)
			expectWaiting(t, waiting)
			unlockMove()
			expectAcquired(t, waiting)()
		})
	}
}

func TestPathLocksGrantConflictingRequestsInOrder(t *testing.T) {
	var locks pathLocks
	unlockFirst := locks.lock(1, "/a")
	whole := acquires(&locks, 1, "/")
	expectWaiting(t, whole)
	later := acquires(&locks, 1, "/b")
	expectWaiting(t, later)

	unlockFirst()
	unlockWhole := expectAcquired(t, whole)
	expectWaiting(t, later)
	unlockWhole()
	expectAcquired(t, later)()
}

func TestPathLocksReleaseTwiceIsHarmless(t *testing.T) {
	var locks pathLocks
	unlock := locks.lock(1, "/a")
	unlock()
	unlock()
	expectAcquired(t, acquires(&locks, 1, "/a"))()
}

func TestPathLocksLockFreeSkipsBusyPathsWithoutWaiting(t *testing.T) {
	var locks pathLocks
	unlockMove := locks.lock(1, "/photos")
	defer unlockMove()

	free, unlockFree := locks.lockFree(1, "/photos/beach.jpg", "/documents/report.md")
	if len(free) != 1 || free[0] != "/documents/report.md" {
		t.Fatalf("free paths = %v, want only the one outside the move", free)
	}
	waiting := acquires(&locks, 1, "/documents")
	expectWaiting(t, waiting)
	unlockFree()
	expectAcquired(t, waiting)()

	none, unlockNone := locks.lockFree(1, "/photos")
	unlockNone()
	if len(none) != 0 {
		t.Fatalf("free paths = %v, want none", none)
	}
}
