package logging

import (
	"bufio"
	"bytes"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"sync"
	"time"
)

const (
	currentName = "polder.log"
	filePrefix  = "polder-"
	fileSuffix  = ".log"
)

func fileName(day time.Time) string {
	return filePrefix + day.Format(time.DateOnly) + fileSuffix
}

func dayOf(name string) (time.Time, bool) {
	date, ok := strings.CutPrefix(name, filePrefix)
	if !ok {
		return time.Time{}, false
	}
	date, ok = strings.CutSuffix(date, fileSuffix)
	if !ok {
		return time.Time{}, false
	}
	day, err := time.Parse(time.DateOnly, date)
	return day, err == nil
}

// dailyFile always writes to polder.log, so tools such as fail2ban can follow one path. When the
// day changes it renames that file to polder-<day>.log and starts a new one.
type dailyFile struct {
	dir  string
	now  func() time.Time
	mu   sync.Mutex
	day  string
	file *os.File
}

func newDailyFile(dir string, now func() time.Time) (*dailyFile, error) {
	if err := os.MkdirAll(dir, 0o750); err != nil {
		return nil, fmt.Errorf("create log directory: %w", err)
	}
	d := &dailyFile{dir: dir, now: now}
	current := filepath.Join(dir, currentName)
	today := fileName(now())
	switch day, ok := currentDay(current); {
	case ok && day != today:
		if err := archive(current, filepath.Join(dir, day)); err != nil {
			return nil, err
		}
	case !ok:
		// Continue a log of today that was written before polder.log existed.
		if err := archive(filepath.Join(dir, today), current); err != nil && !errors.Is(err, fs.ErrNotExist) {
			return nil, err
		}
	}
	if err := d.open(today); err != nil {
		return nil, err
	}
	return d, nil
}

func (d *dailyFile) Write(p []byte) (int, error) {
	d.mu.Lock()
	defer d.mu.Unlock()
	if today := fileName(d.now()); today != d.day || d.file == nil {
		if err := d.rotate(today); err != nil {
			return 0, err
		}
	}
	return d.file.Write(p)
}

func (d *dailyFile) rotate(today string) error {
	if d.file != nil {
		_ = d.file.Close()
		d.file = nil
		if err := archive(filepath.Join(d.dir, currentName), filepath.Join(d.dir, d.day)); err != nil && !errors.Is(err, fs.ErrNotExist) {
			return err
		}
	}
	return d.open(today)
}

func (d *dailyFile) open(day string) error {
	file, err := os.OpenFile(filepath.Join(d.dir, currentName), os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o640)
	if err != nil {
		return fmt.Errorf("open log file: %w", err)
	}
	d.day, d.file = day, file
	return nil
}

func (d *dailyFile) Close() error {
	d.mu.Lock()
	defer d.mu.Unlock()
	if d.file == nil {
		return nil
	}
	err := d.file.Close()
	d.file = nil
	return err
}

// archive moves src to dst, appending to dst when it already exists.
func archive(src, dst string) error {
	if _, err := os.Stat(dst); errors.Is(err, fs.ErrNotExist) {
		return os.Rename(src, dst)
	}
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()
	out, err := os.OpenFile(dst, os.O_WRONLY|os.O_APPEND, 0o640)
	if err != nil {
		return err
	}
	if _, err := io.Copy(out, in); err != nil {
		out.Close()
		return err
	}
	if err := out.Close(); err != nil {
		return err
	}
	return os.Remove(src)
}

// currentDay names the day polder.log holds, by the time of its first entry, or its modification
// time when that cannot be read. It is false when there is no polder.log.
func currentDay(path string) (string, bool) {
	file, err := os.Open(path)
	if err != nil {
		return "", false
	}
	defer file.Close()
	line, _ := bufio.NewReader(file).ReadBytes('\n')
	if entry := parseEntry(bytes.TrimSpace(line)); entry.Time != nil {
		return fileName(entry.Time.Local()), true
	}
	info, err := file.Stat()
	if err != nil {
		return "", false
	}
	return fileName(info.ModTime()), true
}

// Files reads the log files Setup writes.
type Files struct {
	dir string
}

func NewFiles(dir string) *Files {
	return &Files{dir: dir}
}

type ServerLogFile struct {
	Name string `json:"name"`
	Day  string `json:"day" format:"date"`
	Size int64  `json:"size"`
}

type logFile struct {
	ServerLogFile
	path    string
	current bool
}

// List returns the log files, newest first. polder.log is listed under the name it will get at
// midnight, so names and cursors stay the same when it is renamed.
func (f *Files) List() ([]ServerLogFile, error) {
	files, err := f.files()
	list := make([]ServerLogFile, 0, len(files))
	for _, file := range files {
		list = append(list, file.ServerLogFile)
	}
	return list, err
}

func (f *Files) files() ([]logFile, error) {
	entries, err := os.ReadDir(f.dir)
	if errors.Is(err, fs.ErrNotExist) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	var list []logFile
	for _, entry := range entries {
		if !entry.Type().IsRegular() {
			continue
		}
		path := filepath.Join(f.dir, entry.Name())
		name, current := entry.Name(), entry.Name() == currentName
		if current {
			if name, current = currentDay(path); !current {
				continue
			}
		}
		day, ok := dayOf(name)
		if !ok {
			continue
		}
		info, err := entry.Info()
		if err != nil {
			continue
		}
		list = append(list, logFile{
			ServerLogFile: ServerLogFile{Name: name, Day: day.Format(time.DateOnly), Size: info.Size()},
			path:          path,
			current:       current,
		})
	}
	slices.SortFunc(list, func(a, b logFile) int {
		if order := strings.Compare(b.Name, a.Name); order != 0 {
			return order
		}
		return compareBool(a.current, b.current)
	})
	return list, nil
}

// compareBool puts true first, so polder.log reads before an archive of the same day.
func compareBool(a, b bool) int {
	switch {
	case a == b:
		return 0
	case a:
		return -1
	default:
		return 1
	}
}

// Open opens one log file by the name List gave; any other name is not found.
func (f *Files) Open(name string) (*os.File, error) {
	files, err := f.files()
	if err != nil {
		return nil, err
	}
	for _, file := range files {
		if file.Name == name {
			return os.Open(file.path)
		}
	}
	return nil, fs.ErrNotExist
}

// PurgeOlderThan deletes the files of days before cutoff's day; never polder.log.
func (f *Files) PurgeOlderThan(cutoff time.Time) (int, error) {
	files, err := f.files()
	if err != nil {
		return 0, err
	}
	keepFrom := fileName(cutoff)
	var removed int
	var failures []error
	for _, file := range files {
		if file.current || file.Name >= keepFrom {
			continue
		}
		if err := os.Remove(file.path); err != nil {
			failures = append(failures, err)
			continue
		}
		removed++
	}
	return removed, errors.Join(failures...)
}
