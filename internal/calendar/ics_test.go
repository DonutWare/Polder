package calendar

import (
	"archive/zip"
	"bytes"
	"strings"
	"testing"
)

func feedLines(lines ...string) []byte {
	return []byte(strings.Join(lines, "\r\n") + "\r\n")
}

func TestTruncatedFeedKeepsCompleteEvents(t *testing.T) {
	feed := feedLines(
		"BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//test//EN",
		"BEGIN:VEVENT", "UID:one", "DTSTAMP:20261105T000000Z", "DTSTART:20261110T070000", "DTEND:20261110T080000", "SUMMARY:Papier",
		"BEGIN:VALARM", "ACTION:DISPLAY", "DESCRIPTION:Vandaag wordt papier opgehaald vóór 9", " .00 uur.", "TRIGGER:P0D", "END:VALARM",
		"END:VEVENT",
		"BEGIN:VEVENT", "UID:two", "DTSTAMP:20261105T000000Z", "DTSTART:20261124T070000", "SUMMARY:Restafval",
		"BEGIN:VALARM", "ACTION:DISPLAY", "DESCRIPTION:Vandaag wordt restafval opgehaald vó",
	)
	if split, err := splitByUID(feed); err == nil && len(split.order) != 0 {
		t.Fatalf("a cut-off feed kept events without repair: %v", split.order)
	}
	closed, truncated := closeTruncated(feed)
	if !truncated {
		t.Fatal("the cut-off feed was not recognised")
	}
	split, err := splitByUID(closed)
	if err != nil {
		t.Fatalf("repaired feed: %v", err)
	}
	if len(split.order) != 1 || split.order[0] != "one" {
		t.Fatalf("kept events: %v", split.order)
	}
}

func TestCompleteFeedNeedsNoRepair(t *testing.T) {
	feed := feedLines(
		"BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//test//EN",
		"BEGIN:VEVENT", "UID:one", "DTSTAMP:20261105T000000Z", "DTSTART:20261110T070000", "SUMMARY:Papier", "END:VEVENT",
		"END:VCALENDAR",
	)
	if _, truncated := closeTruncated(feed); truncated {
		t.Fatal("a complete feed was treated as cut off")
	}
}

func zipOf(t *testing.T, files map[string][]byte) []byte {
	t.Helper()
	var buffer bytes.Buffer
	writer := zip.NewWriter(&buffer)
	for name, content := range files {
		entry, err := writer.Create(name)
		if err != nil {
			t.Fatal(err)
		}
		if _, err := entry.Write(content); err != nil {
			t.Fatal(err)
		}
	}
	if err := writer.Close(); err != nil {
		t.Fatal(err)
	}
	return buffer.Bytes()
}

func TestArchiveYieldsEachCalendarFile(t *testing.T) {
	one := feedLines("BEGIN:VCALENDAR", "VERSION:2.0", "BEGIN:VEVENT", "UID:a", "DTSTART:20261110T070000Z", "END:VEVENT", "END:VCALENDAR")
	two := feedLines("BEGIN:VCALENDAR", "VERSION:2.0", "BEGIN:VEVENT", "UID:b", "DTSTART:20261111T070000Z", "END:VEVENT", "END:VCALENDAR")
	archive := zipOf(t, map[string][]byte{
		"alice@example.com.ics":       one,
		"Work_abc@group.calendar.ics": two,
		"__MACOSX/._alice.ics":        []byte("junk"),
		"readme.txt":                  []byte("not a calendar"),
	})
	files, err := calendarFiles(archive)
	if err != nil {
		t.Fatal(err)
	}
	if len(files) != 2 {
		t.Fatalf("calendar files: %d", len(files))
	}
}

func TestArchiveWithoutCalendarsIsRejected(t *testing.T) {
	if _, err := calendarFiles(zipOf(t, map[string][]byte{"readme.txt": []byte("x")})); err == nil {
		t.Fatal("an archive without .ics files was accepted")
	}
}

func TestPlainFileIsItsOwnCalendar(t *testing.T) {
	plain := feedLines("BEGIN:VCALENDAR", "END:VCALENDAR")
	files, err := calendarFiles(plain)
	if err != nil || len(files) != 1 {
		t.Fatalf("files=%d err=%v", len(files), err)
	}
}
