package webdav

import (
	"errors"
	"testing"
	"time"
)

func TestLocksConflictByScopeAndDepth(t *testing.T) {
	manager := NewLockManager()
	folder := lockKey{ownerID: 1, path: "/docs"}
	file := lockKey{ownerID: 1, path: "/docs/a.txt"}
	shared, err := manager.Create(lockRequest{principal: "p1", key: folder, scope: lockScopeShared, depth: lockDepthInfinite, timeout: time.Minute})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := manager.Create(lockRequest{principal: "p2", key: file, scope: lockScopeShared, depth: 0, timeout: time.Minute}); err != nil {
		t.Fatalf("shared locks should coexist: %v", err)
	}
	if _, err := manager.Create(lockRequest{principal: "p2", key: file, scope: lockScopeExclusive, depth: 0, timeout: time.Minute}); !errors.Is(err, errLocked) {
		t.Fatalf("exclusive under a shared depth-infinity lock: %v", err)
	}
	if err := manager.Check("p1", file, nil, false); !errors.Is(err, errLocked) {
		t.Fatalf("write without tokens: %v", err)
	}
	if err := manager.Check("p3", lockKey{ownerID: 2, path: "/docs/a.txt"}, nil, false); err != nil {
		t.Fatalf("other owner is unaffected: %v", err)
	}
	if err := manager.Unlock("p2", folder, shared.Token); !errors.Is(err, errLockForbidden) {
		t.Fatalf("someone else's lock: %v", err)
	}
	if err := manager.Unlock("p1", folder, shared.Token); err != nil {
		t.Fatal(err)
	}
}

func TestLocksTokenMustBelongToPrincipal(t *testing.T) {
	manager := NewLockManager()
	key := lockKey{ownerID: 1, path: "/a.txt"}
	lock, err := manager.Create(lockRequest{principal: "p1", key: key, scope: lockScopeExclusive, timeout: time.Minute})
	if err != nil {
		t.Fatal(err)
	}
	if err := manager.Check("p2", key, []string{lock.Token}, false); !errors.Is(err, errLocked) {
		t.Fatalf("stolen token accepted: %v", err)
	}
	if err := manager.Check("p1", key, []string{lock.Token}, false); err != nil {
		t.Fatal(err)
	}
	if err := manager.Check("p1", lockKey{ownerID: 1, path: "/"}, nil, true); !errors.Is(err, errLocked) {
		t.Fatalf("deleting the parent folder must respect the lock: %v", err)
	}
}

func TestLocksExpire(t *testing.T) {
	now := time.Now()
	manager := NewLockManager()
	manager.now = func() time.Time { return now }
	key := lockKey{ownerID: 1, path: "/a.txt"}
	if _, err := manager.Create(lockRequest{principal: "p1", key: key, scope: lockScopeExclusive, timeout: time.Minute}); err != nil {
		t.Fatal(err)
	}
	now = now.Add(2 * time.Minute)
	if err := manager.Check("p2", key, nil, false); err != nil {
		t.Fatalf("expired lock still blocks: %v", err)
	}
}

func TestLocksPerPrincipalLimit(t *testing.T) {
	manager := NewLockManager()
	for i := range maxLocksPerPrincipal {
		key := lockKey{ownerID: 1, path: "/f" + string(rune('a'+i%26)) + string(rune('a'+i/26%26)) + string(rune('a'+i/676))}
		if _, err := manager.Create(lockRequest{principal: "p1", key: key, scope: lockScopeShared, timeout: time.Minute}); err != nil {
			t.Fatal(err)
		}
	}
	if _, err := manager.Create(lockRequest{principal: "p1", key: lockKey{ownerID: 1, path: "/last"}, scope: lockScopeShared, timeout: time.Minute}); !errors.Is(err, errTooManyLocks) {
		t.Fatalf("limit: %v", err)
	}
}

func TestHeaderParsing(t *testing.T) {
	tokens := submittedLockTokens(`</dav/files/a/x> (<urn:uuid:1234> ["etag"]) (Not <opaquelocktoken:abcd>)`)
	if len(tokens) != 2 || tokens[0] != "urn:uuid:1234" || tokens[1] != "opaquelocktoken:abcd" {
		t.Fatalf("tokens %v", tokens)
	}
	for header, want := range map[string]time.Duration{
		"":                       defaultLockTimeout,
		"Second-30":              30 * time.Second,
		"Infinite, Second-4100":  maxLockTimeout,
		"Second-999999999999999": maxLockTimeout,
		"Second-x, Second-5":     5 * time.Second,
	} {
		if got := lockTimeout(header); got != want {
			t.Errorf("timeout %q: %v, want %v", header, got, want)
		}
	}
	for value, want := range map[string]int64{`"12"`: 12, `W/"7"`: 7, `12`: 0, `"x"`: 0, `"-3"`: 0} {
		got, _ := parseETag(value)
		if got != want {
			t.Errorf("etag %q: %d, want %d", value, got, want)
		}
	}
}

func TestSpacePaths(t *testing.T) {
	space := Space{Root: "/dav/files/alice"}
	for urlPath, want := range map[string]string{
		"/dav/files/alice":           "/",
		"/dav/files/alice/":          "/",
		"/dav/files/alice/a b/c.txt": "/a b/c.txt",
		"/dav/files/alice/dir/":      "/dir",
	} {
		got, ok := space.relativePath(urlPath)
		if !ok || got != want {
			t.Errorf("relative %q: %q %v, want %q", urlPath, got, ok, want)
		}
	}
	if _, ok := space.relativePath("/dav/files/alicex/a"); ok {
		t.Error("a sibling prefix must not match")
	}
	if got := space.href("/a b/ü#?.txt", false); got != "/dav/files/alice/a%20b/%C3%BC%23%3F.txt" {
		t.Errorf("href %q", got)
	}
}
