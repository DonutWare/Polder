package calendar

import (
	"archive/zip"
	"bytes"
	"context"
	"crypto/sha1"
	"encoding/hex"
	"errors"
	"io"
	"path"
	"regexp"
	"strings"
	"time"

	"github.com/emersion/go-ical"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

const (
	maxImportErrors     = 20
	maxArchiveCalendars = 100
	maxArchiveBytes     = 50 << 20
)

var safeUIDPattern = regexp.MustCompile(`^[A-Za-z0-9][A-Za-z0-9._@-]{0,200}$`)

type ImportResult struct {
	Created int      `json:"created"`
	Updated int      `json:"updated"`
	Skipped int      `json:"skipped" doc:"Events identical to what the calendar already holds"`
	Errors  []string `json:"errors" doc:"Why some events could not be imported"`
}

func ObjectURIForUID(uid string) string {
	if safeUIDPattern.MatchString(uid) {
		return uid + ".ics"
	}
	sum := sha1.Sum([]byte(uid))
	return hex.EncodeToString(sum[:]) + ".ics"
}

type splitCalendar struct {
	timezones []*ical.Component
	byUID     map[string][]*ical.Component
	order     []string
	header    ical.Props
}

func closeTruncated(data []byte) ([]byte, bool) {
	depth, complete, offset := 0, 0, 0
	for offset < len(data) {
		end := bytes.IndexByte(data[offset:], '\n')
		if end < 0 {
			end = len(data)
		} else {
			end += offset + 1
		}
		line := strings.ToUpper(strings.TrimRight(string(data[offset:end]), "\r\n"))
		switch {
		case strings.HasPrefix(line, "BEGIN:"):
			depth++
		case strings.HasPrefix(line, "END:"):
			depth--
			if depth == 1 {
				complete = end
			}
		}
		offset = end
	}
	if depth <= 0 || complete == 0 {
		return nil, false
	}
	closed := append(bytes.Clone(data[:complete]), "END:VCALENDAR\r\n"...)
	return closed, true
}

func splitByUID(data []byte) (splitCalendar, error) {
	split := splitCalendar{byUID: map[string][]*ical.Component{}, header: ical.Props{}}
	seenZones := map[string]bool{}
	decoder := ical.NewDecoder(bytes.NewReader(data))
	for {
		cal, err := decoder.Decode()
		if errors.Is(err, io.EOF) {
			break
		}
		if err != nil {
			return splitCalendar{}, invalidData("the calendar file cannot be read: %v", err)
		}
		if len(split.header) == 0 {
			split.header = cal.Props
		}
		for _, child := range cal.Children {
			switch child.Name {
			case ical.CompTimezone:
				if id := propText(child, ical.PropTimezoneID); !seenZones[id] {
					seenZones[id] = true
					split.timezones = append(split.timezones, child)
				}
			case ical.CompEvent:
				uid := strings.TrimSpace(propText(child, ical.PropUID))
				if _, seen := split.byUID[uid]; !seen {
					split.order = append(split.order, uid)
				}
				split.byUID[uid] = append(split.byUID[uid], child)
			}
		}
	}
	return split, nil
}

func (split splitCalendar) resource(uid string, floating *time.Location) (*Resource, error) {
	cal := ical.NewCalendar()
	cal.Props.SetText(ical.PropVersion, "2.0")
	cal.Props.SetText(ical.PropProductID, ProductID)
	used := map[string]bool{}
	for _, event := range split.byUID[uid] {
		for _, props := range event.Props {
			for _, prop := range props {
				if tzid := prop.Params.Get(ical.ParamTimezoneID); tzid != "" {
					used[tzid] = true
				}
			}
		}
	}
	for _, zone := range split.timezones {
		if used[propText(zone, ical.PropTimezoneID)] {
			cal.Children = append(cal.Children, zone)
		}
	}
	cal.Children = append(cal.Children, split.byUID[uid]...)
	return FromCalendar(cal, floating)
}

func (s *Service) Import(ctx context.Context, viewer users.User, calendarID int64, data []byte) (ImportResult, error) {
	c, err := s.Get(ctx, viewer, calendarID)
	if err != nil {
		return ImportResult{}, err
	}
	if err := requireWritable(c); err != nil {
		return ImportResult{}, err
	}
	files, err := calendarFiles(data)
	if err != nil {
		return ImportResult{}, err
	}
	splits := make([]splitCalendar, 0, len(files))
	for _, file := range files {
		split, err := splitByUID(file)
		if err != nil {
			return ImportResult{}, err
		}
		splits = append(splits, split)
	}
	result := ImportResult{Errors: []string{}}
	for _, split := range splits {
		for _, uid := range split.order {
			outcome, err := s.importOne(ctx, c, split, uid)
			if err != nil {
				if len(result.Errors) < maxImportErrors {
					result.Errors = append(result.Errors, uid+": "+err.Error())
				}
				continue
			}
			result.add(outcome)
		}
	}
	return result, nil
}

func calendarFiles(data []byte) ([][]byte, error) {
	if !bytes.HasPrefix(data, []byte("PK\x03\x04")) {
		return [][]byte{data}, nil
	}
	archive, err := zip.NewReader(bytes.NewReader(data), int64(len(data)))
	if err != nil {
		return nil, invalidData("the archive cannot be read: %v", err)
	}
	var files [][]byte
	var total int64
	for _, entry := range archive.File {
		if !isCalendarEntry(entry) {
			continue
		}
		if len(files) == maxArchiveCalendars {
			return nil, invalidData("an archive holds at most %d calendar files", maxArchiveCalendars)
		}
		content, err := readArchiveEntry(entry, maxArchiveBytes-total)
		if err != nil {
			return nil, err
		}
		total += int64(len(content))
		files = append(files, content)
	}
	if len(files) == 0 {
		return nil, invalidData("the archive holds no .ics files")
	}
	return files, nil
}

func isCalendarEntry(entry *zip.File) bool {
	name := entry.Name
	return !entry.FileInfo().IsDir() &&
		!strings.HasPrefix(name, "__MACOSX/") &&
		!strings.HasPrefix(path.Base(name), ".") &&
		strings.EqualFold(path.Ext(name), ".ics")
}

func readArchiveEntry(entry *zip.File, budget int64) ([]byte, error) {
	reader, err := entry.Open()
	if err != nil {
		return nil, invalidData("%s cannot be read: %v", entry.Name, err)
	}
	defer reader.Close()
	content, err := io.ReadAll(io.LimitReader(reader, budget+1))
	if err != nil {
		return nil, invalidData("%s cannot be read: %v", entry.Name, err)
	}
	if int64(len(content)) > budget {
		return nil, invalidData("the calendars in the archive are larger than %d MiB", maxArchiveBytes>>20)
	}
	return content, nil
}

type importOutcome int

const (
	importCreated importOutcome = iota
	importUpdated
	importSkipped
)

func (r *ImportResult) add(outcome importOutcome) {
	switch outcome {
	case importCreated:
		r.Created++
	case importUpdated:
		r.Updated++
	default:
		r.Skipped++
	}
}

func (s *Service) importOne(ctx context.Context, c Calendar, split splitCalendar, uid string) (importOutcome, error) {
	if uid == "" {
		return 0, apperr.Invalid("an event without UID cannot be imported")
	}
	resource, err := split.resource(uid, c.Location())
	if err != nil {
		return 0, err
	}
	uri := ObjectURIForUID(uid)
	existing, err := s.store.ObjectByUID(ctx, c.ID, uid)
	exists := err == nil
	if err != nil && !apperr.Is(err, apperr.KindNotFound) {
		return 0, err
	}
	if exists {
		uri = existing.URI
		if data, err := resource.Bytes(); err == nil && etagOf(data) == existing.ETag {
			return importSkipped, nil
		}
	} else if err := s.checkUID(ctx, c, uri, uid, Object{}, false); err != nil {
		return 0, err
	}
	if _, err := s.save(ctx, c, uri, resource, existing.ScheduleTag); err != nil {
		return 0, err
	}
	if exists {
		return importUpdated, nil
	}
	return importCreated, nil
}

func (s *Service) Export(ctx context.Context, viewer users.User, calendarID int64) (Calendar, []byte, error) {
	c, err := s.Get(ctx, viewer, calendarID)
	if err != nil {
		return Calendar{}, nil, err
	}
	if err := requireReadable(c); err != nil {
		return Calendar{}, nil, err
	}
	data, err := s.render(ctx, c, false)
	return c, data, err
}

func (s *Service) render(ctx context.Context, c Calendar, busyOnly bool) ([]byte, error) {
	objects, err := s.store.Objects(ctx, c.ID)
	if err != nil {
		return nil, err
	}
	merged := ical.NewCalendar()
	merged.Props.SetText(ical.PropVersion, "2.0")
	merged.Props.SetText(ical.PropProductID, ProductID)
	merged.Props.SetText("X-WR-CALNAME", c.Name)
	if c.Timezone != "" {
		merged.Props.SetText("X-WR-TIMEZONE", c.Timezone)
	}
	refresh := rawProp(ical.PropRefreshInterval, "PT1H")
	refresh.SetValueType(ical.ValueDuration)
	merged.Props.Set(refresh)
	merged.Props.Set(rawProp("X-PUBLISHED-TTL", "PT1H"))
	zones := map[string]bool{}
	for _, object := range objects {
		resource, err := Parse(object.Data, c.Location())
		if err != nil {
			continue
		}
		appendResource(merged, resource, zones, busyOnly)
	}
	if len(merged.Children) == 0 {
		return emptyCalendar(merged), nil
	}
	return encodeCalendar(merged)
}

func emptyCalendar(cal *ical.Calendar) []byte {
	var b strings.Builder
	b.WriteString("BEGIN:VCALENDAR\r\n")
	for _, name := range []string{ical.PropVersion, ical.PropProductID, "X-WR-CALNAME", "X-WR-TIMEZONE"} {
		if prop := cal.Props.Get(name); prop != nil {
			b.WriteString(name + ":" + prop.Value + "\r\n")
		}
	}
	b.WriteString("END:VCALENDAR\r\n")
	return []byte(b.String())
}

func appendResource(merged *ical.Calendar, resource *Resource, zones map[string]bool, busyOnly bool) {
	for _, child := range resource.cal.Children {
		if child.Name == ical.CompTimezone {
			if id := propText(child, ical.PropTimezoneID); !zones[id] {
				zones[id] = true
				merged.Children = append(merged.Children, child)
			}
		}
	}
	for _, component := range resource.Components() {
		if !busyOnly {
			merged.Children = append(merged.Children, component)
			continue
		}
		if busy := busyComponent(component); busy != nil {
			merged.Children = append(merged.Children, busy)
		}
	}
}

var busyKeptProps = []string{
	ical.PropUID, ical.PropDateTimeStamp, ical.PropDateTimeStart, ical.PropDateTimeEnd, ical.PropDuration,
	ical.PropRecurrenceRule, ical.PropRecurrenceDates, ical.PropExceptionDates, ical.PropRecurrenceID, ical.PropStatus,
}

func busyComponent(component *ical.Component) *ical.Component {
	if !blocksTime(component) {
		return nil
	}
	busy := ical.NewComponent(ical.CompEvent)
	for _, name := range busyKeptProps {
		for _, prop := range component.Props.Values(name) {
			busy.Props.Add(cloneProp(&prop))
		}
	}
	busy.Props.SetText(ical.PropSummary, "Busy")
	busy.Props.SetText(ical.PropClass, "PRIVATE")
	return busy
}

func blocksTime(component *ical.Component) bool {
	return !strings.EqualFold(propText(component, ical.PropTransparency), "TRANSPARENT") &&
		!strings.EqualFold(propText(component, ical.PropStatus), statusCancelled)
}

func ExpandedData(resource *Resource, window TimeRange) ([]byte, error) {
	occurrences, err := resource.Occurrences(window.Start, window.End)
	if err != nil {
		return nil, err
	}
	expanded := ical.NewCalendar()
	for name, props := range resource.cal.Props {
		expanded.Props[name] = props
	}
	for _, occurrence := range occurrences {
		expanded.Children = append(expanded.Children, expandedComponent(occurrence))
	}
	if len(expanded.Children) == 0 {
		return emptyCalendar(expanded), nil
	}
	return encodeCalendar(expanded)
}

func expandedComponent(occurrence Occurrence) *ical.Component {
	component := cloneComponent(occurrence.Component)
	for _, name := range []string{ical.PropRecurrenceRule, ical.PropRecurrenceDates, ical.PropExceptionDates, ical.PropDuration, ical.PropDateTimeEnd} {
		component.Props.Del(name)
	}
	start := dateTime{Time: occurrence.Start, AllDay: occurrence.AllDay}
	end := dateTime{Time: occurrence.End, AllDay: occurrence.AllDay}
	setDateTimeProp(component.Props, ical.PropDateTimeStart, start, "")
	if occurrence.End.After(occurrence.Start) {
		setDateTimeProp(component.Props, ical.PropDateTimeEnd, end, "")
	}
	if occurrence.RecurrenceID != "" {
		recurrenceID := rawProp(ical.PropRecurrenceID, occurrence.RecurrenceID)
		if occurrence.AllDay {
			recurrenceID.SetValueType(ical.ValueDate)
		}
		component.Props.Set(recurrenceID)
	}
	return component
}
