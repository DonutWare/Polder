package logging

import (
	"bytes"
	"encoding/json"
	"errors"
	"io/fs"
	"log/slog"
	"os"
	"slices"
	"strconv"
	"strings"
	"time"
)

const (
	DefaultPageSize = 100
	MaxPageSize     = 500
	readBlockSize   = 64 << 10
)

var ErrInvalidCursor = errors.New("invalid cursor")

type ServerLogEntry struct {
	ID        string            `json:"id" doc:"Pass as before to get the entries older than this one"`
	Time      *time.Time        `json:"time,omitempty" required:"false" doc:"Absent for lines the server could not parse"`
	Level     string            `json:"level" doc:"DEBUG, INFO, WARN or ERROR; empty for lines the server could not parse"`
	Component string            `json:"component" doc:"Part of the server that wrote it"`
	Message   string            `json:"message"`
	Attrs     map[string]string `json:"attrs"`
}

type ServerLogPage struct {
	Entries    []ServerLogEntry `json:"entries"`
	NextCursor string           `json:"nextCursor" doc:"Pass as before for the next page; empty when there are no more"`
}

type Query struct {
	MinLevel  slog.Level
	Component string
	Text      string
	Before    string
	Limit     int
}

type cursor struct {
	name   string
	offset int64
}

func parseCursor(raw string) (cursor, error) {
	name, offset, found := strings.Cut(raw, ":")
	if _, ok := dayOf(name); !ok || !found {
		return cursor{}, ErrInvalidCursor
	}
	position, err := strconv.ParseInt(offset, 10, 64)
	if err != nil || position < 0 {
		return cursor{}, ErrInvalidCursor
	}
	return cursor{name: name, offset: position}, nil
}

func (c cursor) String() string {
	return c.name + ":" + strconv.FormatInt(c.offset, 10)
}

// Read returns the entries matching query, newest first.
func (f *Files) Read(query Query) (ServerLogPage, error) {
	limit := query.Limit
	if limit <= 0 {
		limit = DefaultPageSize
	}
	limit = min(limit, MaxPageSize)
	start := cursor{offset: -1}
	if query.Before != "" {
		parsed, err := parseCursor(query.Before)
		if err != nil {
			return ServerLogPage{}, err
		}
		start = parsed
	}
	files, err := f.files()
	if err != nil {
		return ServerLogPage{}, err
	}
	text := strings.ToLower(query.Text)

	page := ServerLogPage{Entries: []ServerLogEntry{}}
	for _, file := range files {
		end := int64(-1)
		if start.name != "" {
			if file.Name > start.name {
				continue
			}
			if file.Name == start.name {
				end = start.offset
			}
		}
		full := false
		err := readBackward(file.path, end, func(offset int64, line []byte) bool {
			entry := parseEntry(line)
			entry.ID = cursor{name: file.Name, offset: offset}.String()
			if !entry.matches(query, text) {
				return true
			}
			if len(page.Entries) == limit {
				full = true
				return false
			}
			page.Entries = append(page.Entries, entry)
			return true
		})
		if err != nil && !errors.Is(err, fs.ErrNotExist) {
			return ServerLogPage{}, err
		}
		if full {
			page.NextCursor = page.Entries[limit-1].ID
			break
		}
	}
	return page, nil
}

func (e ServerLogEntry) matches(query Query, text string) bool {
	if e.Level != "" {
		var level slog.Level
		if err := level.UnmarshalText([]byte(e.Level)); err == nil && level < query.MinLevel {
			return false
		}
	}
	if query.Component != "" && e.Component != query.Component {
		return false
	}
	if text == "" {
		return true
	}
	if strings.Contains(strings.ToLower(e.Message), text) || strings.Contains(strings.ToLower(e.Component), text) {
		return true
	}
	for key, value := range e.Attrs {
		if strings.Contains(strings.ToLower(key), text) || strings.Contains(strings.ToLower(value), text) {
			return true
		}
	}
	return false
}

func parseEntry(line []byte) ServerLogEntry {
	var fields map[string]json.RawMessage
	if err := json.Unmarshal(line, &fields); err != nil {
		return ServerLogEntry{Message: string(line), Attrs: map[string]string{}}
	}
	entry := ServerLogEntry{Attrs: map[string]string{}}
	for key, raw := range fields {
		switch key {
		case slog.TimeKey:
			var moment time.Time
			if json.Unmarshal(raw, &moment) == nil {
				entry.Time = &moment
			}
		case slog.LevelKey:
			entry.Level = text(raw)
		case slog.MessageKey:
			entry.Message = text(raw)
		case componentKey:
			entry.Component = text(raw)
		default:
			entry.Attrs[key] = text(raw)
		}
	}
	return entry
}

// text gives a JSON string's value, and anything else as its JSON.
func text(raw json.RawMessage) string {
	var value string
	if json.Unmarshal(raw, &value) == nil {
		return value
	}
	return string(raw)
}

// readBackward calls visit for each line in the file before end, last line first, with the
// offset where the line starts. An end of -1 reads from the end of the file, leaving out a last
// line that is still being written.
func readBackward(path string, end int64, visit func(offset int64, line []byte) bool) error {
	file, err := os.Open(path)
	if err != nil {
		return err
	}
	defer file.Close()
	info, err := file.Stat()
	if err != nil {
		return err
	}
	dropPartial := end < 0
	if end < 0 || end > info.Size() {
		end = info.Size()
	}

	position := end
	var pending []byte
	for {
		if dropPartial {
			if i := bytes.LastIndexByte(pending, '\n'); i >= 0 {
				pending = pending[:i+1]
				dropPartial = false
			} else {
				pending = pending[:0]
			}
		}
		if !dropPartial {
			for len(pending) > 0 {
				body := bytes.TrimSuffix(pending, []byte("\n"))
				i := bytes.LastIndexByte(body, '\n')
				if i < 0 && position > 0 {
					break
				}
				lineStart := i + 1
				if line := body[lineStart:]; len(line) > 0 && !visit(position+int64(lineStart), line) {
					return nil
				}
				pending = pending[:lineStart]
			}
		}
		if position == 0 {
			return nil
		}
		size := min(readBlockSize, position)
		position -= size
		block := make([]byte, size, int(size)+len(pending))
		if _, err := file.ReadAt(block, position); err != nil {
			return err
		}
		pending = append(block, pending...)
	}
}

// Components lists the components that appear in the log files, sorted.
func (f *Files) Components() ([]string, error) {
	files, err := f.files()
	if err != nil {
		return nil, err
	}
	marker := []byte(`"` + componentKey + `":`)
	found := map[string]bool{}
	for _, file := range files {
		content, err := os.ReadFile(file.path)
		if err != nil {
			continue
		}
		for {
			i := bytes.Index(content, marker)
			if i < 0 {
				break
			}
			content = content[i+len(marker):]
			lineEnd := bytes.IndexByte(content, '\n')
			if lineEnd < 0 {
				lineEnd = len(content)
			}
			var name string
			if json.NewDecoder(bytes.NewReader(content[:lineEnd])).Decode(&name) == nil && name != "" {
				found[name] = true
			}
			content = content[lineEnd:]
		}
	}
	components := make([]string, 0, len(found))
	for name := range found {
		components = append(components, name)
	}
	slices.Sort(components)
	return components, nil
}
