package logging

import (
	"fmt"
	"io"
	"log/slog"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"testing"
	"time"
)

func writeLog(t *testing.T, dir string, now *time.Time) *slog.Logger {
	t.Helper()
	file, err := newDailyFile(dir, func() time.Time { return *now })
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = file.Close() })
	return slog.New(slog.NewJSONHandler(file, &slog.HandlerOptions{
		Level: slog.LevelDebug,
		ReplaceAttr: func(groups []string, attr slog.Attr) slog.Attr {
			if attr.Key == slog.TimeKey && len(groups) == 0 {
				return slog.Time(slog.TimeKey, *now)
			}
			return attr
		},
	}))
}

func TestDailyFilesRotateAndPurge(t *testing.T) {
	dir := t.TempDir()
	now := time.Date(2026, 3, 1, 23, 59, 0, 0, time.Local)
	logger := writeLog(t, dir, &now)
	logger.Info("first day")
	now = now.Add(2 * time.Minute)
	logger.Info("second day")
	now = now.Add(24 * time.Hour)
	logger.Info("third day")

	files := NewFiles(dir)
	list, err := files.List()
	if err != nil {
		t.Fatal(err)
	}
	names := []string{}
	for _, file := range list {
		names = append(names, file.Name)
	}
	want := []string{"polder-2026-03-03.log", "polder-2026-03-02.log", "polder-2026-03-01.log"}
	if !slices.Equal(names, want) {
		t.Fatalf("files = %v, want %v", names, want)
	}

	onDisk, _ := os.ReadDir(dir)
	if len(onDisk) != 3 || onDisk[2].Name() != "polder.log" {
		t.Fatalf("today should be in polder.log: %v", onDisk)
	}
	current, err := files.Open("polder-2026-03-03.log")
	if err != nil {
		t.Fatal(err)
	}
	content, _ := io.ReadAll(current)
	current.Close()
	if !strings.Contains(string(content), "third day") {
		t.Fatalf("today's name should open polder.log: %s", content)
	}

	removed, err := files.PurgeOlderThan(time.Date(2026, 3, 2, 12, 0, 0, 0, time.Local))
	if err != nil || removed != 1 {
		t.Fatalf("purge removed %d: %v", removed, err)
	}
	if list, _ := files.List(); len(list) != 2 || list[1].Name != "polder-2026-03-02.log" {
		t.Fatalf("after purge: %+v", list)
	}
}

func TestRestartArchivesYesterdayAndContinuesToday(t *testing.T) {
	dir := t.TempDir()
	now := time.Date(2026, 3, 1, 12, 0, 0, 0, time.Local)
	logger := writeLog(t, dir, &now)
	logger.Info("before restart")

	now = now.Add(48 * time.Hour)
	writeLog(t, dir, &now).Info("after restart")
	if content, _ := os.ReadFile(filepath.Join(dir, "polder-2026-03-01.log")); !strings.Contains(string(content), "before restart") {
		t.Fatalf("yesterday's polder.log should be archived: %s", content)
	}

	if err := os.Rename(filepath.Join(dir, "polder.log"), filepath.Join(dir, "polder-2026-03-03.log")); err != nil {
		t.Fatal(err)
	}
	writeLog(t, dir, &now).Info("same day")
	content, _ := os.ReadFile(filepath.Join(dir, "polder.log"))
	if !strings.Contains(string(content), "after restart") || !strings.Contains(string(content), "same day") {
		t.Fatalf("a daily file of today should continue as polder.log: %s", content)
	}
}

func TestReadPagesNewestFirstAcrossFiles(t *testing.T) {
	dir := t.TempDir()
	now := time.Date(2026, 3, 1, 12, 0, 0, 0, time.Local)
	logger := writeLog(t, dir, &now)
	for day := range 3 {
		for i := range 40 {
			logger.Info(fmt.Sprintf("day %d line %d", day, i), "padding", strings.Repeat("x", 3000))
		}
		now = now.Add(24 * time.Hour)
	}

	files := NewFiles(dir)
	var messages []string
	before := ""
	for {
		page, err := files.Read(Query{Before: before, Limit: 7})
		if err != nil {
			t.Fatal(err)
		}
		for _, entry := range page.Entries {
			messages = append(messages, entry.Message)
		}
		if page.NextCursor == "" {
			break
		}
		before = page.NextCursor
	}
	if len(messages) != 120 {
		t.Fatalf("read %d entries, want 120", len(messages))
	}
	if messages[0] != "day 2 line 39" || messages[40] != "day 1 line 39" || messages[119] != "day 0 line 0" {
		t.Fatalf("wrong order: %q, %q, %q", messages[0], messages[40], messages[119])
	}
}

func TestReadFilters(t *testing.T) {
	dir := t.TempDir()
	now := time.Date(2026, 3, 1, 12, 0, 0, 0, time.Local)
	logger := writeLog(t, dir, &now)
	logger.Debug("chatter", "component", "scanner")
	logger.Warn("index failed", "component", "search", "user", "alice")
	logger.Error("disk full", "component", "scanner")
	logger.Info("login", "component", "auth", "user", "Bob")

	files := NewFiles(dir)
	cases := []struct {
		query Query
		want  []string
	}{
		{Query{MinLevel: slog.LevelWarn}, []string{"disk full", "index failed"}},
		{Query{MinLevel: slog.LevelDebug, Component: "scanner"}, []string{"disk full", "chatter"}},
		{Query{Text: "BOB"}, []string{"login"}},
		{Query{Text: "alice", Component: "search"}, []string{"index failed"}},
	}
	for _, c := range cases {
		page, err := files.Read(c.query)
		if err != nil {
			t.Fatal(err)
		}
		var got []string
		for _, entry := range page.Entries {
			got = append(got, entry.Message)
		}
		if !slices.Equal(got, c.want) {
			t.Errorf("%+v: got %v, want %v", c.query, got, c.want)
		}
	}

	components, err := files.Components()
	if err != nil || !slices.Equal(components, []string{"auth", "scanner", "search"}) {
		t.Fatalf("components = %v, %v", components, err)
	}
}

func TestReadKeepsUnparsedLinesAndSkipsPartialLast(t *testing.T) {
	dir := t.TempDir()
	content := `{"time":"2026-03-01T12:00:00Z","level":"INFO","msg":"started","port":6060}` + "\n" +
		"panic: something broke\n" +
		`{"time":"2026-03-01T12:00:01Z","level":"INFO","msg":"half`
	if err := os.WriteFile(filepath.Join(dir, "polder-2026-03-01.log"), []byte(content), 0o600); err != nil {
		t.Fatal(err)
	}
	page, err := NewFiles(dir).Read(Query{})
	if err != nil {
		t.Fatal(err)
	}
	if len(page.Entries) != 2 {
		t.Fatalf("entries = %+v", page.Entries)
	}
	if raw := page.Entries[0]; raw.Message != "panic: something broke" || raw.Time != nil || raw.Level != "" {
		t.Fatalf("raw line = %+v", raw)
	}
	if parsed := page.Entries[1]; parsed.Message != "started" || parsed.Attrs["port"] != "6060" || parsed.Time == nil {
		t.Fatalf("parsed line = %+v", parsed)
	}
}

func TestOpenRejectsOtherNames(t *testing.T) {
	files := NewFiles(t.TempDir())
	for _, name := range []string{"../polder.db", "polder-2026-03-01.log/../../x", "notes.txt"} {
		if _, err := files.Open(name); !os.IsNotExist(err) {
			t.Errorf("Open(%q) = %v", name, err)
		}
	}
}

func TestForTagsTheDefaultLogger(t *testing.T) {
	previous := slog.Default()
	t.Cleanup(func() { slog.SetDefault(previous) })
	logger := For("scanner")

	var out strings.Builder
	slog.SetDefault(slog.New(slog.NewTextHandler(&out, nil)))
	logger.Info("rescan", "user", "alice")
	if !strings.Contains(out.String(), "component=scanner") || !strings.Contains(out.String(), "user=alice") {
		t.Fatalf("output = %q", out.String())
	}
}
