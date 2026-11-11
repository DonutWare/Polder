package httpapi

import (
	"errors"
	"os"
	"syscall"
	"testing"
	"time"
)

func TestStorageProbeReportsFullDisk(t *testing.T) {
	probe := newStorageProbe(func() error { return &os.PathError{Op: "write", Path: "/x", Err: syscall.ENOSPC} })
	if got := probe.status(); got != storageFull {
		t.Fatalf("status = %q, want %q", got, storageFull)
	}
}

func TestStorageProbeReportsOtherFailuresAsReadOnly(t *testing.T) {
	probe := newStorageProbe(func() error { return errors.New("read-only file system") })
	if got := probe.status(); got != storageReadOnly {
		t.Fatalf("status = %q, want %q", got, storageReadOnly)
	}
}

func TestStorageProbeCachesResult(t *testing.T) {
	calls := 0
	now := time.Unix(0, 0)
	probe := newStorageProbe(func() error { calls++; return nil })
	probe.now = func() time.Time { return now }
	probe.status()
	probe.status()
	now = now.Add(storageProbeInterval)
	probe.status()
	if calls != 2 {
		t.Fatalf("probe ran %d times, want 2", calls)
	}
}
