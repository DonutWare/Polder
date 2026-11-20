package storage

import (
	"errors"
	"io/fs"
	"os"
	"path/filepath"
	"testing"
	"time"
)

func TestCopyTreeReproducesFoldersFilesAndTimes(t *testing.T) {
	root := t.TempDir()
	source := filepath.Join(root, "source")
	mtime := time.Date(2024, 3, 1, 12, 0, 0, 0, time.UTC)
	if err := os.MkdirAll(filepath.Join(source, "nested"), 0o750); err != nil {
		t.Fatal(err)
	}
	file := filepath.Join(source, "nested", "note.txt")
	if err := os.WriteFile(file, []byte("hello"), 0o640); err != nil {
		t.Fatal(err)
	}
	if err := os.Chtimes(file, mtime, mtime); err != nil {
		t.Fatal(err)
	}
	target := filepath.Join(root, "new folder", "source")
	if err := os.Mkdir(filepath.Dir(target), 0o750); err != nil {
		t.Fatal(err)
	}

	if err := copyTree(source, target); err != nil {
		t.Fatalf("copyTree: %v", err)
	}

	copied := filepath.Join(target, "nested", "note.txt")
	content, err := os.ReadFile(copied)
	if err != nil || string(content) != "hello" {
		t.Fatalf("copied content = %q, %v", content, err)
	}
	info, err := os.Stat(copied)
	if err != nil {
		t.Fatal(err)
	}
	if !info.ModTime().Equal(mtime) {
		t.Errorf("mtime = %v, want %v", info.ModTime(), mtime)
	}
}

func TestCopyTreeRefusesExistingTarget(t *testing.T) {
	root := t.TempDir()
	source := filepath.Join(root, "source")
	target := filepath.Join(root, "target")
	for _, dir := range []string{source, target} {
		if err := os.Mkdir(dir, 0o750); err != nil {
			t.Fatal(err)
		}
	}
	if err := copyTree(source, target); err == nil {
		t.Fatal("copyTree into an existing folder succeeded")
	}
}

func TestMoveRenamesWithinOneFilesystem(t *testing.T) {
	root := t.TempDir()
	source := filepath.Join(root, "a")
	if err := os.Mkdir(source, 0o750); err != nil {
		t.Fatal(err)
	}
	target := filepath.Join(root, "b")
	if err := Move(source, target); err != nil {
		t.Fatalf("Move: %v", err)
	}
	if _, err := os.Stat(target); err != nil {
		t.Errorf("target missing: %v", err)
	}
	if _, err := os.Stat(source); !os.IsNotExist(err) {
		t.Errorf("source still present: %v", err)
	}
}

func TestMoveAcrossFilesystemsLeavesAnExistingTargetAlone(t *testing.T) {
	root := t.TempDir()
	source := filepath.Join(root, "source")
	target := filepath.Join(root, "target")
	if err := os.WriteFile(source, []byte("new"), 0o640); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(target, []byte("existing"), 0o640); err != nil {
		t.Fatal(err)
	}

	if err := moveAcrossFilesystems(source, target); !errors.Is(err, fs.ErrExist) {
		t.Fatalf("moveAcrossFilesystems = %v, want an already-exists error", err)
	}

	for path, want := range map[string]string{source: "new", target: "existing"} {
		content, err := os.ReadFile(path)
		if err != nil || string(content) != want {
			t.Errorf("%s = %q, %v; want %q", path, content, err, want)
		}
	}
}

func TestMoveAcrossFilesystemsMovesATree(t *testing.T) {
	root := t.TempDir()
	source := filepath.Join(root, "source")
	if err := os.MkdirAll(filepath.Join(source, "nested"), 0o750); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(source, "nested", "note.txt"), []byte("hello"), 0o640); err != nil {
		t.Fatal(err)
	}
	target := filepath.Join(root, "target")

	if err := moveAcrossFilesystems(source, target); err != nil {
		t.Fatalf("moveAcrossFilesystems: %v", err)
	}

	if _, err := os.Stat(source); !errors.Is(err, fs.ErrNotExist) {
		t.Errorf("source still exists: %v", err)
	}
	if content, err := os.ReadFile(filepath.Join(target, "nested", "note.txt")); err != nil || string(content) != "hello" {
		t.Errorf("moved content = %q, %v", content, err)
	}
}
