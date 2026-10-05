package storage

import (
	"os"
	"path/filepath"
	"testing"

	"polder-server/internal/apperr"
)

func TestCleanPathAcceptsNormalPaths(t *testing.T) {
	cases := map[string]string{"": "/", "/": "/", "a": "/a", "/a/b.txt": "/a/b.txt", "/a/b/": "/a/b", "/über/ñ": "/über/ñ"}
	for input, expected := range cases {
		cleaned, err := CleanPath(input)
		if err != nil || cleaned != expected {
			t.Errorf("CleanPath(%q) = %q, %v; want %q", input, cleaned, err, expected)
		}
	}
}

func TestCleanPathRejectsTraversalAndReservedNames(t *testing.T) {
	for _, input := range []string{"/../etc", "/a/../../b", "/a//b", "/a/./b", "/a\\b", "/.polder/x", "/a/.polder-tmp-1", "/a\x00b"} {
		if _, err := CleanPath(input); !apperr.Is(err, apperr.KindInvalid) {
			t.Errorf("CleanPath(%q) should be rejected, got %v", input, err)
		}
	}
}

func TestResolveRejectsSymlinks(t *testing.T) {
	disk, err := NewDisk(t.TempDir())
	if err != nil {
		t.Fatal(err)
	}
	if err := disk.EnsureUserRoot("alice"); err != nil {
		t.Fatal(err)
	}
	outside := t.TempDir()
	if err := os.Symlink(outside, filepath.Join(disk.UserRoot("alice"), "escape")); err != nil {
		t.Fatal(err)
	}
	if _, err := disk.Resolve("alice", "/escape/secret"); !apperr.Is(err, apperr.KindForbidden) {
		t.Fatalf("expected symlink to be rejected, got %v", err)
	}
	resolved, err := disk.Resolve("alice", "/docs/a.txt")
	if err != nil || resolved != filepath.Join(disk.UserRoot("alice"), "docs", "a.txt") {
		t.Fatalf("unexpected resolve result %q, %v", resolved, err)
	}
}

func TestIsSameOrDescendant(t *testing.T) {
	if !IsSameOrDescendant("/a/b", "/a") || IsSameOrDescendant("/ab", "/a") || !IsSameOrDescendant("/x", "/") {
		t.Fatal("descendant check is wrong")
	}
}
