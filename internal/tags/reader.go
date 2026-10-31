package tags

import (
	"context"
	"time"

	"polder-server/internal/files"
	"polder-server/internal/logging"
	"polder-server/internal/users"
)

var logger = logging.For("tags")

const (
	queueCapacity   = 1024
	backlogInterval = time.Minute
	backlogBatch    = 20
)

type job struct {
	userID int64
	path   string
}

func (s *Service) Enqueue(userID int64, cleanPath string) {
	select {
	case s.queue <- job{userID: userID, path: cleanPath}:
	default:
	}
}

func (s *Service) Run(ctx context.Context) {
	sweep := time.NewTimer(0)
	defer sweep.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case next := <-s.queue:
			s.readPath(ctx, next.userID, next.path)
		case <-sweep.C:
			if s.sweep(ctx) {
				sweep.Reset(0)
			} else {
				sweep.Reset(backlogInterval)
			}
		}
	}
}

func (s *Service) sweep(ctx context.Context) (more bool) {
	stale, err := s.store.staleNotes(ctx, backlogBatch, files.MarkdownMime)
	if err != nil {
		logger.Warn("load notes whose tags are not read", "error", err)
		return false
	}
	for _, note := range stale {
		if ctx.Err() != nil {
			return false
		}
		s.readPath(ctx, note.userID, note.path)
	}
	return len(stale) == backlogBatch
}

func (s *Service) readPath(ctx context.Context, userID int64, cleanPath string) {
	owner, err := s.users.ByID(ctx, userID)
	if err != nil {
		return
	}
	entry, err := s.files.Stat(ctx, owner, cleanPath)
	if err != nil || entry.IsDir {
		return
	}
	if !isNote(entry) {
		if err := s.store.ForgetNote(ctx, entry.ID); err != nil {
			logger.Warn("forget tags", "path", entry.Path, "error", err)
		}
		return
	}
	source, err := s.content(ctx, owner, entry)
	if err == nil {
		err = s.readNote(ctx, owner, entry, source)
	}
	if err != nil {
		logger.Warn("read tags", "path", entry.Path, "error", err)
	}
}

func (s *Service) readNote(ctx context.Context, owner users.User, note files.Entry, source []byte) error {
	names := ReadTags(source)
	if err := s.store.ReplaceNoteTags(ctx, note.ID, note.Hash, names); err != nil {
		return err
	}
	return s.store.EnsureNames(ctx, owner.ID, names)
}
