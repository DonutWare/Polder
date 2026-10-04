package files

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"

	"nomad-server/internal/apperr"
	"nomad-server/internal/storage"
	"nomad-server/internal/users"
)

type WriteRequest struct {
	Path         string
	BaseRev      int64
	Mtime        time.Time
	ExpectedHash string
	Content      io.Reader
}

type stagedFile struct {
	tempPath string
	size     int64
	hash     string
}

func (f stagedFile) discard() {
	_ = os.Remove(f.tempPath)
}

func (s *Service) Write(ctx context.Context, owner users.User, request WriteRequest) (Entry, error) {
	cleanPath, err := nonRootPath(request.Path)
	if err != nil {
		return Entry{}, err
	}
	current, exists, err := findEntry(ctx, s.db, owner.ID, cleanPath)
	if err != nil {
		return Entry{}, err
	}
	if err := CheckWritePreconditions(current, exists, request.BaseRev); err != nil {
		return Entry{}, err
	}
	absolute, err := s.disk.Resolve(owner.Username, cleanPath)
	if err != nil {
		return Entry{}, err
	}
	budget, err := s.writeBudget(ctx, s.db, owner, current.Size)
	if err != nil {
		return Entry{}, err
	}

	staged, err := s.stage(filepath.Dir(absolute), request.Content, budget)
	if err != nil {
		return Entry{}, err
	}
	defer staged.discard()
	if request.ExpectedHash != "" && request.ExpectedHash != staged.hash {
		return Entry{}, apperr.Invalid("content hash mismatch: expected %s, got %s", request.ExpectedHash, staged.hash)
	}

	entry, err := s.commit(ctx, owner, cleanPath, absolute, staged, request)
	if err != nil {
		return Entry{}, err
	}
	s.onContentChanged(owner.ID, entry.Path)
	if exists && current.Hash != entry.Hash {
		s.onContentRemoved()
	}
	return entry, nil
}

func CheckWritePreconditions(current Entry, exists bool, baseRev int64) error {
	if exists && current.IsDir {
		return apperr.Invalid("%s is a directory", current.Path)
	}
	switch {
	case baseRev == BaseRevAny:
		return nil
	case baseRev == BaseRevMustNotExist && exists:
		return apperr.Conflict(current, "%s already exists", current.Path)
	case baseRev > 0 && !exists:
		return apperr.Conflict(nil, "file was deleted on the server")
	case baseRev > 0 && current.Rev != baseRev:
		return apperr.Conflict(current, "%s changed since revision %d", current.Path, baseRev)
	}
	return nil
}

const unlimitedBudget int64 = -1

func (s *Service) writeBudget(ctx context.Context, q querier, owner users.User, replacedSize int64) (int64, error) {
	if owner.HasUnlimitedQuota() {
		return unlimitedBudget, nil
	}
	used, err := usedBytes(ctx, q, owner.ID)
	if err != nil {
		return 0, err
	}
	return max(owner.QuotaBytes-used+replacedSize, 0), nil
}

func (s *Service) stage(directory string, content io.Reader, budget int64) (stagedFile, error) {
	if err := storage.MakeDirs(directory); err != nil {
		return stagedFile{}, apperr.Invalid("cannot create parent directory: %v", err)
	}
	temp, err := s.disk.CreateTempFile(directory)
	if err != nil {
		return stagedFile{}, fmt.Errorf("create temp file: %w", err)
	}
	staged := stagedFile{tempPath: temp.Name()}

	hasher := sha256.New()
	reader := content
	if budget != unlimitedBudget {
		reader = io.LimitReader(content, budget+1)
	}
	written, copyErr := io.Copy(io.MultiWriter(temp, hasher), reader)
	closeErr := temp.Close()
	if err := errors.Join(copyErr, closeErr); err != nil {
		staged.discard()
		return stagedFile{}, fmt.Errorf("store upload: %w", err)
	}
	if budget != unlimitedBudget && written > budget {
		staged.discard()
		return stagedFile{}, apperr.QuotaExceeded("this upload exceeds your storage quota")
	}
	staged.size = written
	staged.hash = hex.EncodeToString(hasher.Sum(nil))
	return staged, nil
}

func (s *Service) commit(ctx context.Context, owner users.User, cleanPath, absolute string, staged stagedFile, request WriteRequest) (Entry, error) {
	unlock := s.locks.lock(owner.ID)
	defer unlock()

	var saved Entry
	err := s.inTransaction(ctx, func(tx *sql.Tx) error {
		current, exists, err := findEntry(ctx, tx, owner.ID, cleanPath)
		if err != nil {
			return err
		}
		if err := CheckWritePreconditions(current, exists, request.BaseRev); err != nil {
			return err
		}
		budget, err := s.writeBudget(ctx, tx, owner, current.Size)
		if err != nil {
			return err
		}
		if budget != unlimitedBudget && staged.size > budget {
			return apperr.QuotaExceeded("this upload exceeds your storage quota")
		}
		if err := s.ensureParentDirectories(ctx, tx, owner, cleanPath); err != nil {
			return err
		}
		mtime, err := placeStagedFile(staged, absolute, request.Mtime)
		if err != nil {
			return err
		}
		saved, err = saveEntry(ctx, tx, newFileEntry(owner.ID, cleanPath, staged.size, mtime, staged.hash))
		return err
	})
	return saved, err
}

func placeStagedFile(staged stagedFile, absolute string, requestedMtime time.Time) (time.Time, error) {
	if !requestedMtime.IsZero() {
		if err := os.Chtimes(staged.tempPath, requestedMtime, requestedMtime); err != nil {
			return time.Time{}, err
		}
	}
	if err := os.Rename(staged.tempPath, absolute); err != nil {
		return time.Time{}, fmt.Errorf("place file: %w", err)
	}
	return modificationTime(absolute), nil
}
