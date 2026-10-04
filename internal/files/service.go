package files

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path"
	"strings"
	"time"

	"nomad-server/internal/apperr"
	"nomad-server/internal/storage"
	"nomad-server/internal/users"
)

const (
	BaseRevMustNotExist int64 = 0
	BaseRevAny          int64 = -1
)

type ContentChangedFunc func(userID int64, cleanPath string)

type Service struct {
	db               *sql.DB
	disk             *storage.Disk
	locks            userLocks
	onContentChanged ContentChangedFunc
	onContentRemoved func()
}

func NewService(db *sql.DB, disk *storage.Disk) *Service {
	return &Service{db: db, disk: disk, onContentChanged: func(int64, string) {}, onContentRemoved: func() {}}
}

func (s *Service) OnContentChanged(callback ContentChangedFunc) {
	s.onContentChanged = callback
}

func (s *Service) OnContentRemoved(callback func()) {
	s.onContentRemoved = callback
}

func (s *Service) HashesInUse(ctx context.Context) (map[string]bool, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT hash FROM files WHERE hash <> '' UNION SELECT hash FROM trash WHERE hash <> ''`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	inUse := map[string]bool{}
	for rows.Next() {
		var hash string
		if err := rows.Scan(&hash); err != nil {
			return nil, err
		}
		inUse[hash] = true
	}
	return inUse, rows.Err()
}

func (s *Service) Disk() *storage.Disk { return s.disk }

func (s *Service) inTransaction(ctx context.Context, work func(tx *sql.Tx) error) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	if err := work(tx); err != nil {
		_ = tx.Rollback()
		return err
	}
	return tx.Commit()
}

func (s *Service) Stat(ctx context.Context, owner users.User, rawPath string) (Entry, error) {
	cleanPath, err := storage.CleanPath(rawPath)
	if err != nil {
		return Entry{}, err
	}
	if cleanPath == storage.RootPath {
		return newDirectoryEntry(owner.ID, storage.RootPath, time.Time{}), nil
	}
	return s.existingEntry(ctx, s.db, owner.ID, cleanPath)
}

func (s *Service) existingEntry(ctx context.Context, q querier, userID int64, cleanPath string) (Entry, error) {
	entry, found, err := findEntry(ctx, q, userID, cleanPath)
	if err != nil {
		return Entry{}, err
	}
	if !found {
		return Entry{}, apperr.NotFound("%s does not exist", cleanPath)
	}
	return entry, nil
}

func (s *Service) List(ctx context.Context, owner users.User, rawPath string) (string, []Entry, error) {
	directory, err := s.Stat(ctx, owner, rawPath)
	if err != nil {
		return "", nil, err
	}
	if !directory.IsDir {
		return "", nil, apperr.Invalid("%s is not a directory", directory.Path)
	}
	entries, err := listChildren(ctx, s.db, owner.ID, directory.Path)
	return directory.Path, entries, err
}

func (s *Service) Open(ctx context.Context, owner users.User, rawPath string) (*os.File, Entry, error) {
	entry, err := s.Stat(ctx, owner, rawPath)
	if err != nil {
		return nil, Entry{}, err
	}
	if entry.IsDir {
		return nil, Entry{}, apperr.Invalid("%s is a directory", entry.Path)
	}
	absolute, err := s.disk.Resolve(owner.Username, entry.Path)
	if err != nil {
		return nil, Entry{}, err
	}
	file, err := os.Open(absolute)
	if errors.Is(err, fs.ErrNotExist) {
		return nil, Entry{}, apperr.NotFound("%s does not exist", entry.Path)
	}
	return file, entry, err
}

func (s *Service) Mkdir(ctx context.Context, owner users.User, rawPath string) (Entry, error) {
	cleanPath, err := nonRootPath(rawPath)
	if err != nil {
		return Entry{}, err
	}
	unlock := s.locks.lock(owner.ID)
	defer unlock()

	var created Entry
	err = s.inTransaction(ctx, func(tx *sql.Tx) error {
		if err := s.requireAbsent(ctx, tx, owner.ID, cleanPath); err != nil {
			return err
		}
		if err := s.ensureParentDirectories(ctx, tx, owner, cleanPath); err != nil {
			return err
		}
		absolute, err := s.disk.Resolve(owner.Username, cleanPath)
		if err != nil {
			return err
		}
		if err := storage.MakeDirs(absolute); err != nil {
			return fmt.Errorf("create directory: %w", err)
		}
		created, err = saveEntry(ctx, tx, newDirectoryEntry(owner.ID, cleanPath, modificationTime(absolute)))
		return err
	})
	return created, err
}

func (s *Service) requireAbsent(ctx context.Context, q querier, userID int64, cleanPath string) error {
	existing, found, err := findEntry(ctx, q, userID, cleanPath)
	if err != nil {
		return err
	}
	if found {
		alreadyExists := apperr.AlreadyExists("%s already exists", cleanPath)
		alreadyExists.Current = existing
		return alreadyExists
	}
	return nil
}

func (s *Service) ensureParentDirectories(ctx context.Context, q querier, owner users.User, cleanPath string) error {
	for _, ancestor := range storage.Ancestors(cleanPath) {
		existing, found, err := findEntry(ctx, q, owner.ID, ancestor)
		if err != nil {
			return err
		}
		if found && !existing.IsDir {
			return apperr.Invalid("%s is a file, not a directory", ancestor)
		}
		if found {
			continue
		}
		absolute, err := s.disk.Resolve(owner.Username, ancestor)
		if err != nil {
			return err
		}
		if err := storage.MakeDirs(absolute); err != nil {
			return fmt.Errorf("create directory: %w", err)
		}
		if _, err := saveEntry(ctx, q, newDirectoryEntry(owner.ID, ancestor, modificationTime(absolute))); err != nil {
			return err
		}
	}
	return nil
}

func (s *Service) Delete(ctx context.Context, owner users.User, rawPath string, baseRev int64) error {
	cleanPath, err := nonRootPath(rawPath)
	if err != nil {
		return err
	}
	unlock := s.locks.lock(owner.ID)
	defer unlock()

	undo := func() {}
	err = s.inTransaction(ctx, func(tx *sql.Tx) error {
		current, err := s.existingEntry(ctx, tx, owner.ID, cleanPath)
		if err != nil {
			return err
		}
		if baseRev > 0 && current.Rev != baseRev {
			return apperr.Conflict(current, "%s changed since revision %d", cleanPath, baseRev)
		}
		undo, err = s.moveToTrash(ctx, tx, owner, current)
		return err
	})
	if err != nil {
		undo()
		return err
	}
	s.onContentRemoved()
	return nil
}

func (s *Service) Move(ctx context.Context, owner users.User, rawFrom, rawTo string, baseRev int64) (Entry, error) {
	from, err := nonRootPath(rawFrom)
	if err != nil {
		return Entry{}, err
	}
	to, err := nonRootPath(rawTo)
	if err != nil {
		return Entry{}, err
	}
	if storage.IsSameOrDescendant(to, from) {
		return Entry{}, apperr.Invalid("cannot move %s into itself", from)
	}
	unlock := s.locks.lock(owner.ID)
	defer unlock()

	var moved Entry
	err = s.inTransaction(ctx, func(tx *sql.Tx) error {
		source, err := s.existingEntry(ctx, tx, owner.ID, from)
		if err != nil {
			return err
		}
		if baseRev > 0 && source.Rev != baseRev {
			return apperr.Conflict(source, "%s changed since revision %d", from, baseRev)
		}
		if err := s.requireAbsent(ctx, tx, owner.ID, to); err != nil {
			return err
		}
		if err := s.ensureParentDirectories(ctx, tx, owner, to); err != nil {
			return err
		}
		if err := s.renameOnDisk(owner, from, to); err != nil {
			return err
		}
		moved, err = reindexMovedTree(ctx, tx, owner.ID, from, to)
		return err
	})
	if err == nil && !moved.IsDir {
		s.onContentChanged(owner.ID, moved.Path)
	}
	return moved, err
}

func (s *Service) renameOnDisk(owner users.User, from, to string) error {
	absoluteFrom, err := s.disk.Resolve(owner.Username, from)
	if err != nil {
		return err
	}
	absoluteTo, err := s.disk.Resolve(owner.Username, to)
	if err != nil {
		return err
	}
	if err := os.Rename(absoluteFrom, absoluteTo); err != nil {
		return fmt.Errorf("rename: %w", err)
	}
	return nil
}

func reindexMovedTree(ctx context.Context, q querier, userID int64, from, to string) (Entry, error) {
	tree, err := listTree(ctx, q, userID, from)
	if err != nil {
		return Entry{}, err
	}
	var movedRoot Entry
	for _, entry := range tree {
		saved, err := relocateEntry(ctx, q, entry, to+strings.TrimPrefix(entry.Path, from))
		if err != nil {
			return Entry{}, err
		}
		if saved.Path == to {
			movedRoot = saved
		}
	}
	return movedRoot, nil
}

func (s *Service) UpdateDerivedFields(ctx context.Context, userID int64, cleanPath, hash string, meta map[string]any, state PreviewState) error {
	return updateDerivedFields(ctx, s.db, userID, cleanPath, hash, meta, state)
}

func (s *Service) EntriesAwaitingPreview(ctx context.Context, limit int) ([]Entry, error) {
	return entriesWithPreviewState(ctx, s.db, PreviewPending, limit)
}

func (s *Service) UsedBytes(ctx context.Context, userID int64) (int64, error) {
	return usedBytes(ctx, s.db, userID)
}

func nonRootPath(rawPath string) (string, error) {
	cleanPath, err := storage.CleanPath(rawPath)
	if err != nil {
		return "", err
	}
	if cleanPath == storage.RootPath {
		return "", apperr.Invalid("this operation is not allowed on the root directory")
	}
	return cleanPath, nil
}

func modificationTime(absolutePath string) time.Time {
	info, err := os.Stat(absolutePath)
	if err != nil {
		return time.Now().UTC()
	}
	return info.ModTime().UTC()
}

func isInternalName(name string) bool {
	base := path.Base(name)
	return storage.IsReservedName(base) || storage.IsSystemFile(base)
}
