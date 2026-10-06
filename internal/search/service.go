package search

import (
	"context"
	"errors"
	"log/slog"
	"sync"
	"time"

	"github.com/blevesearch/bleve/v2"
	"github.com/blevesearch/bleve/v2/search/query"

	"polder-server/internal/files"
	"polder-server/internal/users"
)

const (
	changePageSize = 1000
	batchSize      = 500
	pokeCapacity   = 256
	resyncInterval = 10 * time.Minute
)

// Service keeps a Bleve index of every user's files in step with the files table by following the
// per-user changes feed. The cursor into that feed is stored in the index itself, so an index that is
// deleted, stale or replaced simply catches up again from the database.
type Service struct {
	files *files.Service
	users *users.Store
	dir   string

	mu       sync.Mutex
	index    *index
	lastSync time.Time
	pokes    chan int64
}

func Open(dir string, fileService *files.Service, userStore *users.Store) (*Service, error) {
	opened, err := openIndex(dir)
	if err != nil {
		return nil, err
	}
	return &Service{files: fileService, users: userStore, dir: dir, index: opened, pokes: make(chan int64, pokeCapacity)}, nil
}

func (s *Service) Close() error {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.index.Close()
}

// FileMutation is a files.MutationFunc. It only schedules a sync, because the changes feed is the
// source of truth for what to index.
func (s *Service) FileMutation(_ context.Context, mutation files.Mutation) {
	select {
	case s.pokes <- mutation.Owner.ID:
	default:
	}
}

func (s *Service) Run(ctx context.Context) {
	s.syncAll(ctx)
	ticker := time.NewTicker(resyncInterval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case userID := <-s.pokes:
			if err := s.Sync(ctx, userID); err != nil && ctx.Err() == nil {
				slog.Warn("update search index", "user", userID, "error", err)
			}
		case <-ticker.C:
			s.syncAll(ctx)
		}
	}
}

func (s *Service) syncAll(ctx context.Context) {
	allUsers, err := s.users.List(ctx)
	if err != nil {
		slog.Warn("list users for search index", "error", err)
		return
	}
	known := make([]int64, len(allUsers))
	for i, user := range allUsers {
		known[i] = user.ID
		if err := s.Sync(ctx, user.ID); err != nil && ctx.Err() == nil {
			slog.Warn("update search index", "user", user.Username, "error", err)
		}
	}
	if err := s.removeOtherUsers(known); err != nil {
		slog.Warn("remove deleted users from search index", "error", err)
	}
}

func (s *Service) Sync(ctx context.Context, userID int64) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	cursor, indexed := s.index.cursor(userID)
	if !indexed {
		var err error
		if cursor, err = s.indexEverything(ctx, userID); err != nil {
			return err
		}
	}
	for {
		page, err := s.files.Changes(ctx, userID, cursor, changePageSize)
		if err != nil {
			return err
		}
		if err := s.apply(userID, page); err != nil {
			return err
		}
		cursor = page.Cursor
		if !page.HasMore {
			s.lastSync = time.Now()
			return nil
		}
	}
}

// indexEverything indexes a user from scratch. The feed position is read before the files, so a change
// that lands in between is applied again afterwards, which is harmless.
func (s *Service) indexEverything(ctx context.Context, userID int64) (int64, error) {
	cursor, err := s.files.LatestChangeSeq(ctx, userID)
	if err != nil {
		return 0, err
	}
	entries, err := s.files.AllEntries(ctx, userID)
	if err != nil {
		return 0, err
	}
	if err := s.deleteMatching(treeQuery(userID, "/")); err != nil {
		return 0, err
	}
	batch := s.index.NewBatch()
	for _, entry := range entries {
		if err := batch.Index(documentID(entry.ID), newDocument(entry)); err != nil {
			return 0, err
		}
		if batch.Size() >= batchSize {
			if err := s.index.Batch(batch); err != nil {
				return 0, err
			}
			batch.Reset()
		}
	}
	setCursor(batch, userID, cursor)
	return cursor, s.index.Batch(batch)
}

// apply replays one page of the changes feed in order. Upserts and moves that are still current carry
// the entry; deletes, and moves a later change superseded, only name a path, so whatever the index has
// under that path goes. A later upsert in the same page puts back anything that still exists.
func (s *Service) apply(userID int64, page files.ChangePage) error {
	batch := s.index.NewBatch()
	flush := func() error {
		if batch.Size() == 0 {
			return nil
		}
		err := s.index.Batch(batch)
		batch.Reset()
		return err
	}
	for _, change := range page.Changes {
		if change.Entry != nil {
			if err := batch.Index(documentID(change.Entry.ID), newDocument(*change.Entry)); err != nil {
				return err
			}
			continue
		}
		removed := change.Path
		if change.FromPath != "" {
			removed = change.FromPath
		}
		if err := flush(); err != nil {
			return err
		}
		if err := s.deleteMatching(treeQuery(userID, removed)); err != nil {
			return err
		}
	}
	setCursor(batch, userID, page.Cursor)
	return flush()
}

func (s *Service) deleteMatching(q query.Query) error {
	ids, err := s.index.matchingIDs(q)
	if err != nil || len(ids) == 0 {
		return err
	}
	batch := s.index.NewBatch()
	for _, id := range ids {
		batch.Delete(id)
	}
	return s.index.Batch(batch)
}

func (s *Service) removeOtherUsers(known []int64) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	others := bleve.NewBooleanQuery()
	others.AddMust(bleve.NewMatchAllQuery())
	for _, userID := range known {
		others.AddMustNot(termQuery(fieldUser, userTerm(userID)))
	}
	return s.deleteMatching(others)
}

type IndexStatus struct {
	Documents uint64     `json:"documents"`
	LastSync  *time.Time `json:"lastSync"`
}

func (s *Service) Status() (IndexStatus, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	count, err := s.index.DocCount()
	status := IndexStatus{Documents: count}
	if !s.lastSync.IsZero() {
		lastSync := s.lastSync
		status.LastSync = &lastSync
	}
	return status, err
}

func (s *Service) Rebuild(ctx context.Context) error {
	s.mu.Lock()
	closeErr := s.index.Close()
	rebuilt, err := createIndex(s.dir)
	if err != nil {
		if reopened, reopenErr := openIndex(s.dir); reopenErr == nil {
			s.index = reopened
		}
		s.mu.Unlock()
		return errors.Join(closeErr, err)
	}
	s.index = rebuilt
	s.mu.Unlock()
	s.syncAll(ctx)
	return nil
}
