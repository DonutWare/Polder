package scanner

import (
	"context"
	"io/fs"
	"log/slog"
	"os"
	"path/filepath"
	"sync"
	"time"

	"github.com/fsnotify/fsnotify"

	"polder-server/internal/files"
	"polder-server/internal/storage"
	"polder-server/internal/users"
)

const watchDebounce = 2 * time.Second

type Scanner struct {
	files    *files.Service
	users    *users.Store
	interval time.Duration
	watch    bool

	pendingMu sync.Mutex
	pending   map[string]*time.Timer

	requestedMu sync.Mutex
	requested   map[string]struct{}
	wake        chan struct{}
}

func New(fileService *files.Service, userStore *users.Store, interval time.Duration, watch bool) *Scanner {
	return &Scanner{files: fileService, users: userStore, interval: interval, watch: watch, pending: map[string]*time.Timer{},
		requested: map[string]struct{}{}, wake: make(chan struct{}, 1)}
}

func (s *Scanner) Request(username string) {
	s.requestedMu.Lock()
	s.requested[username] = struct{}{}
	s.requestedMu.Unlock()
	select {
	case s.wake <- struct{}{}:
	default:
	}
}

func (s *Scanner) rescanRequested(ctx context.Context) {
	s.requestedMu.Lock()
	requested := s.requested
	s.requested = map[string]struct{}{}
	s.requestedMu.Unlock()
	for username := range requested {
		s.rescanByUsername(ctx, username)
	}
}

func (s *Scanner) Run(ctx context.Context) {
	s.RescanAll(ctx)
	if s.watch {
		go s.watchDataDir(ctx)
	}
	var tick <-chan time.Time
	if s.interval > 0 {
		ticker := time.NewTicker(s.interval)
		defer ticker.Stop()
		tick = ticker.C
	}
	for {
		select {
		case <-ctx.Done():
			return
		case <-tick:
			s.RescanAll(ctx)
		case <-s.wake:
			s.rescanRequested(ctx)
		}
	}
}

func (s *Scanner) RescanAll(ctx context.Context) {
	allUsers, err := s.users.List(ctx)
	if err != nil {
		slog.Error("list users for rescan", "error", err)
		return
	}
	for _, user := range allUsers {
		s.rescanUser(ctx, user)
	}
}

func (s *Scanner) rescanUser(ctx context.Context, user users.User) {
	started := time.Now()
	if err := s.files.Rescan(ctx, user); err != nil {
		slog.Error("rescan", "user", user.Username, "error", err)
		return
	}
	slog.Debug("rescan finished", "user", user.Username, "duration", time.Since(started))
}

func (s *Scanner) watchDataDir(ctx context.Context) {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		slog.Warn("file watching unavailable, relying on periodic rescans", "error", err)
		return
	}
	defer watcher.Close()

	dataDir := s.files.Disk().DataDir()
	addDirectoryTree(watcher, dataDir)
	for {
		select {
		case <-ctx.Done():
			return
		case event, ok := <-watcher.Events:
			if !ok {
				return
			}
			s.handleEvent(ctx, watcher, dataDir, event)
		case err, ok := <-watcher.Errors:
			if !ok {
				return
			}
			slog.Warn("file watcher", "error", err)
		}
	}
}

func (s *Scanner) handleEvent(ctx context.Context, watcher *fsnotify.Watcher, dataDir string, event fsnotify.Event) {
	if name := filepath.Base(event.Name); storage.IsReservedName(name) || storage.IsSystemFile(name) {
		return
	}
	if event.Has(fsnotify.Create) {
		if info, err := os.Stat(event.Name); err == nil && info.IsDir() {
			addDirectoryTree(watcher, event.Name)
		}
	}
	username, ok := files.UsernameFromDiskPath(dataDir, event.Name)
	if ok {
		s.scheduleRescan(ctx, username)
	}
}

func (s *Scanner) scheduleRescan(ctx context.Context, username string) {
	s.pendingMu.Lock()
	defer s.pendingMu.Unlock()
	if timer, exists := s.pending[username]; exists {
		timer.Reset(watchDebounce)
		return
	}
	s.pending[username] = time.AfterFunc(watchDebounce, func() {
		s.pendingMu.Lock()
		delete(s.pending, username)
		s.pendingMu.Unlock()
		s.rescanByUsername(ctx, username)
	})
}

func (s *Scanner) rescanByUsername(ctx context.Context, username string) {
	allUsers, err := s.users.List(ctx)
	if err != nil {
		return
	}
	for _, user := range allUsers {
		if user.Username == username {
			s.rescanUser(ctx, user)
		}
	}
}

func addDirectoryTree(watcher *fsnotify.Watcher, root string) {
	_ = filepath.WalkDir(root, func(path string, entry fs.DirEntry, err error) error {
		if err != nil || !entry.IsDir() {
			return nil
		}
		if path != root && storage.IsReservedName(entry.Name()) {
			return filepath.SkipDir
		}
		if err := watcher.Add(path); err != nil {
			slog.Debug("watch directory", "path", path, "error", err)
		}
		return nil
	})
}
