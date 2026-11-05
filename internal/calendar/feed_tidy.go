package calendar

import (
	"net/url"
	"strings"

	"github.com/emersion/go-ical"
)

func isGooglePublicCalendar(source string) bool {
	parsed, err := url.Parse(source)
	if err != nil || !strings.EqualFold(parsed.Hostname(), "calendar.google.com") {
		return false
	}
	path, err := url.PathUnescape(parsed.EscapedPath())
	return err == nil && strings.Contains(path, "group.v.calendar.google.com")
}

func tidyFeed(source string, split splitCalendar) {
	if !isGooglePublicCalendar(source) {
		return
	}
	for _, components := range split.byUID {
		for _, component := range components {
			setText(component, ical.PropDescription, firstLine(propText(component, ical.PropDescription)))
		}
	}
}

func firstLine(text string) string {
	line, _, _ := strings.Cut(strings.TrimSpace(text), "\n")
	return strings.TrimSpace(line)
}
