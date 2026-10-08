package files

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path"
	"path/filepath"
	"strings"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/logging"
	"polder-server/internal/storage"
	"polder-server/internal/users"

	"github.com/danielgtaylor/huma/v2"
)

var logger = logging.For("files")

const trashColumns = `id, original_path, name, is_dir, size, mime, hash, preview_state, storage_id, deleted_at`

type TrashItem struct {
	ID           int64        `json:"id"`
	Name         string       `json:"name"`
	OriginalPath string       `json:"originalPath" doc:"Where the item was when it was deleted, and where a restore puts it back"`
	IsDir        bool         `json:"isDir"`
	Size         int64        `json:"size" doc:"Bytes, including everything inside a directory"`
	Mime         string       `json:"mime"`
	Hash         string       `json:"hash"`
	PreviewState PreviewState `json:"previewState"`
	DeletedAt    time.Time    `json:"deletedAt"`
	ExpiresAt    *time.Time   `json:"expiresAt,omitempty" required:"false" doc:"When the item is deleted permanently; absent while the trash keeps items forever"`
	storageID    string
}

type RestoreMode string

const (
	RestoreFail      RestoreMode = "fail"
	RestoreOverwrite RestoreMode = "overwrite"
	RestoreKeepBoth  RestoreMode = "keepBoth"
)

func (RestoreMode) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(RestoreFail), string(RestoreOverwrite), string(RestoreKeepBoth)}
	return s
}

func scanTrashItem(row rowScanner) (TrashItem, error) {
	var item TrashItem
	var deletedAt int64
	err := row.Scan(&item.ID, &item.OriginalPath, &item.Name, &item.IsDir, &item.Size, &item.Mime, &item.Hash, &item.PreviewState,
		&item.storageID, &deletedAt)
	item.DeletedAt = time.Unix(deletedAt, 0).UTC()
	return item, err
}

func queryTrashItems(ctx context.Context, q querier, query string, args ...any) ([]TrashItem, error) {
	rows, err := q.QueryContext(ctx, `SELECT `+trashColumns+` FROM trash `+query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	items := []TrashItem{}
	for rows.Next() {
		item, err := scanTrashItem(rows)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func findTrashItem(ctx context.Context, q querier, userID, id int64) (TrashItem, error) {
	item, err := scanTrashItem(q.QueryRowContext(ctx, `SELECT `+trashColumns+` FROM trash WHERE user_id = $1 AND id = $2`, userID, id))
	if errors.Is(err, sql.ErrNoRows) {
		return TrashItem{}, apperr.NotFound("no such item in the trash")
	}
	return item, err
}

func (s *Service) ListTrash(ctx context.Context, owner users.User) ([]TrashItem, error) {
	return queryTrashItems(ctx, s.db, `WHERE user_id = $1 ORDER BY deleted_at DESC, id DESC`, owner.ID)
}

func noUndo() {}

func (s *Service) moveToTrash(ctx context.Context, q querier, owner users.User, entry Entry) (func(), error) {
	absolute, err := s.disk.Resolve(owner.Username, entry.Path)
	if err != nil {
		return noUndo, err
	}
	size, err := treeSize(ctx, q, owner.ID, entry)
	if err != nil {
		return noUndo, err
	}
	storageID := storage.NewID()
	err = s.disk.MoveToTrash(owner.Username, absolute, storageID, entry.Name)
	if errors.Is(err, fs.ErrNotExist) {
		return noUndo, s.removeTree(ctx, q, owner, entry.Path)
	}
	if err != nil {
		return noUndo, fmt.Errorf("move to trash: %w", err)
	}
	undo := func() {
		_ = os.Rename(s.disk.TrashItemPath(owner.Username, storageID, entry.Name), absolute)
		_ = s.disk.RemoveTrashItem(owner.Username, storageID)
	}
	deletedAt := time.Now().UTC()
	trashID, err := insertTrashItem(ctx, q, owner.ID, entry, size, storageID, deletedAt)
	if err != nil {
		undo()
		return noUndo, err
	}
	if err := s.writeTrashSidecar(owner.Username, storageID, trashSidecar{OriginalPath: entry.Path, DeletedAt: deletedAt}); err != nil {
		undo()
		return noUndo, err
	}
	if err := attachVersionsToTrash(ctx, q, owner.ID, entry, trashID); err != nil {
		undo()
		return noUndo, err
	}
	if err := s.relocateHistoriesOfTrashItem(ctx, q, owner, trashID); err != nil {
		undo()
		return noUndo, err
	}
	if err := s.removeTree(ctx, q, owner, entry.Path); err != nil {
		undo()
		return noUndo, err
	}
	return undo, nil
}

func insertTrashItem(ctx context.Context, q querier, userID int64, entry Entry, size int64, storageID string, deletedAt time.Time) (int64, error) {
	var id int64
	err := q.QueryRowContext(ctx,
		`INSERT INTO trash (user_id, original_path, name, is_dir, size, mime, hash, preview_state, storage_id, deleted_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING id`,
		userID, entry.Path, entry.Name, entry.IsDir, size, entry.Mime, entry.Hash, entry.PreviewState, storageID, deletedAt.Unix()).Scan(&id)
	return id, err
}

func treeSize(ctx context.Context, q querier, userID int64, entry Entry) (int64, error) {
	if !entry.IsDir {
		return entry.Size, nil
	}
	tree, err := listTree(ctx, q, userID, entry.Path)
	var total int64
	for _, descendant := range tree {
		total += descendant.Size
	}
	return total, err
}

func (s *Service) RestoreFromTrash(ctx context.Context, owner users.User, id int64, mode RestoreMode) (Entry, error) {
	unlock := s.locks.lock(owner.ID)
	defer unlock()

	var item TrashItem
	var restored Entry
	var changedFiles []string
	var undo []func()
	err := s.inTransaction(ctx, func(tx *sql.Tx) error {
		var err error
		if item, err = findTrashItem(ctx, tx, owner.ID, id); err != nil {
			return err
		}
		target, undoOverwrite, err := s.restoreTarget(ctx, tx, owner, item, mode)
		if err != nil {
			return err
		}
		undo = append(undo, undoOverwrite)
		if err := s.ensureParentDirectories(ctx, tx, owner, target); err != nil {
			return err
		}
		absolute, err := s.disk.Resolve(owner.Username, target)
		if err != nil {
			return err
		}
		source := s.disk.TrashItemPath(owner.Username, item.storageID, item.Name)
		if err := os.Rename(source, absolute); err != nil {
			return fmt.Errorf("restore from trash: %w", err)
		}
		undo = append(undo, func() { _ = os.Rename(absolute, source) })
		if restored, changedFiles, err = s.indexRestoredTree(ctx, tx, owner, target, absolute); err != nil {
			return err
		}
		if err := s.relinkVersionsFromTrash(ctx, tx, owner, item.ID, target); err != nil {
			return err
		}
		_, err = tx.ExecContext(ctx, `DELETE FROM trash WHERE id = $1`, item.ID)
		return err
	})
	if err != nil {
		for i := len(undo) - 1; i >= 0; i-- {
			undo[i]()
		}
		return Entry{}, err
	}
	if err := s.disk.RemoveTrashItem(owner.Username, item.storageID); err != nil {
		logger.Warn("remove restored trash directory", "user", owner.Username, "error", err)
	}
	for _, changedPath := range changedFiles {
		s.onContentChanged(owner.ID, changedPath)
	}
	if mode == RestoreOverwrite {
		s.onContentRemoved()
	}
	s.notify(ctx, Mutation{Owner: owner, Kind: MutationRestore, Path: restored.Path, FromPath: item.OriginalPath, IsDir: restored.IsDir, Size: item.Size})
	return restored, nil
}

func (s *Service) restoreTarget(ctx context.Context, q querier, owner users.User, item TrashItem, mode RestoreMode) (string, func(), error) {
	existing, found, err := findEntry(ctx, q, owner.ID, item.OriginalPath)
	if err != nil || !found {
		return item.OriginalPath, noUndo, err
	}
	switch mode {
	case RestoreOverwrite:
		undo, err := s.moveToTrash(ctx, q, owner, existing)
		return item.OriginalPath, undo, err
	case RestoreKeepBoth:
		target, err := s.freeRestorePath(ctx, q, owner, item.OriginalPath)
		return target, noUndo, err
	default:
		alreadyExists := apperr.AlreadyExists("%s already exists", item.OriginalPath)
		alreadyExists.Current = existing
		return "", noUndo, alreadyExists
	}
}

func (s *Service) freeRestorePath(ctx context.Context, q querier, owner users.User, originalPath string) (string, error) {
	directory, name := storage.ParentPath(originalPath), path.Base(originalPath)
	extension := path.Ext(name)
	if extension == name {
		extension = ""
	}
	stem := strings.TrimSuffix(name, extension)
	for attempt := 1; attempt < 1000; attempt++ {
		suffix := " (restored)"
		if attempt > 1 {
			suffix = fmt.Sprintf(" (restored %d)", attempt)
		}
		candidate := path.Join(directory, stem+suffix+extension)
		_, found, err := findEntry(ctx, q, owner.ID, candidate)
		if err != nil {
			return "", err
		}
		if !found && !s.existsOnDisk(owner.Username, candidate) {
			return candidate, nil
		}
	}
	return "", apperr.AlreadyExists("no free name to restore %s under", originalPath)
}

func (s *Service) indexRestoredTree(ctx context.Context, q querier, owner users.User, target, absolute string) (Entry, []string, error) {
	var root Entry
	var changedFiles []string
	err := filepath.WalkDir(absolute, func(current string, dirEntry fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if current != absolute && isInternalName(dirEntry.Name()) {
			return skipEntry(dirEntry)
		}
		if !dirEntry.IsDir() && !dirEntry.Type().IsRegular() {
			return nil
		}
		info, err := dirEntry.Info()
		if err != nil {
			return err
		}
		relative, _ := filepath.Rel(absolute, current)
		cleanPath := target
		if relative != "." {
			cleanPath = path.Join(target, filepath.ToSlash(relative))
		}
		entry := newDirectoryEntry(owner.ID, cleanPath, info.ModTime().UTC())
		if !dirEntry.IsDir() {
			hash, err := hashFile(current)
			if err != nil {
				return err
			}
			entry = newFileEntry(owner.ID, cleanPath, info.Size(), info.ModTime().UTC(), hash)
			changedFiles = append(changedFiles, cleanPath)
		}
		saved, err := saveEntry(ctx, q, entry)
		if cleanPath == target {
			root = saved
		}
		return err
	})
	return root, changedFiles, err
}

func (s *Service) OpenTrashItem(ctx context.Context, owner users.User, id int64) (TrashItem, string, error) {
	item, err := findTrashItem(ctx, s.db, owner.ID, id)
	if err != nil {
		return TrashItem{}, "", err
	}
	absolute := s.disk.TrashItemPath(owner.Username, item.storageID, item.Name)
	info, err := os.Lstat(absolute)
	if errors.Is(err, fs.ErrNotExist) {
		return TrashItem{}, "", apperr.NotFound("%s is no longer in the trash", item.Name)
	}
	if err != nil {
		return TrashItem{}, "", err
	}
	if !info.IsDir() && !info.Mode().IsRegular() {
		return TrashItem{}, "", apperr.Forbidden("only files and directories can be downloaded")
	}
	return item, absolute, nil
}

func (s *Service) TrashItem(ctx context.Context, owner users.User, id int64) (TrashItem, error) {
	return findTrashItem(ctx, s.db, owner.ID, id)
}

func (s *Service) DeleteFromTrash(ctx context.Context, owner users.User, id int64) error {
	item, err := findTrashItem(ctx, s.db, owner.ID, id)
	if err != nil {
		return err
	}
	if err := s.purge(ctx, owner, []TrashItem{item}); err != nil {
		return err
	}
	s.notify(ctx, Mutation{Owner: owner, Kind: MutationTrashDelete, Path: item.OriginalPath, IsDir: item.IsDir, Size: item.Size, Count: 1})
	return nil
}

func (s *Service) EmptyTrash(ctx context.Context, owner users.User) error {
	items, err := s.ListTrash(ctx, owner)
	if err != nil {
		return err
	}
	if err := s.purge(ctx, owner, items); err != nil || len(items) == 0 {
		return err
	}
	s.notify(ctx, Mutation{Owner: owner, Kind: MutationTrashEmpty, Path: "/", IsDir: true, Size: totalSize(items), Count: len(items)})
	return nil
}

func (s *Service) PurgeTrash(ctx context.Context, owner users.User, deletedBefore time.Time) (int, error) {
	items, err := queryTrashItems(ctx, s.db, `WHERE user_id = $1 AND deleted_at < $2`, owner.ID, deletedBefore.Unix())
	if err != nil {
		return 0, err
	}
	if err := s.purge(ctx, owner, items); err != nil || len(items) == 0 {
		return len(items), err
	}
	s.notify(ctx, Mutation{Owner: owner, Kind: MutationTrashExpire, Path: "/", IsDir: true, Size: totalSize(items), Count: len(items)})
	return len(items), nil
}

func totalSize(items []TrashItem) int64 {
	var total int64
	for _, item := range items {
		total += item.Size
	}
	return total
}

func (s *Service) purge(ctx context.Context, owner users.User, items []TrashItem) error {
	if len(items) == 0 {
		return nil
	}
	defer s.onContentRemoved()
	var failures []error
	unlock := s.locks.lock(owner.ID)
	err := s.inTransaction(ctx, func(tx *sql.Tx) error {
		return s.removeVersionsOfTrashItems(ctx, tx, owner, items)
	})
	unlock()
	if err != nil {
		return err
	}
	defer s.onVersionsChanged()
	for _, item := range items {
		if _, err := s.db.ExecContext(ctx, `DELETE FROM trash WHERE id = $1`, item.ID); err != nil {
			return err
		}
		if err := s.disk.RemoveTrashItem(owner.Username, item.storageID); err != nil {
			failures = append(failures, fmt.Errorf("remove %s from trash: %w", item.Name, err))
		}
	}
	return errors.Join(failures...)
}

type trashSidecar struct {
	OriginalPath string    `json:"originalPath"`
	DeletedAt    time.Time `json:"deletedAt"`
}

func (s *Service) writeTrashSidecar(username, storageID string, sidecar trashSidecar) error {
	content, err := json.Marshal(sidecar)
	if err != nil {
		return err
	}
	return storage.WriteFileAtomically(s.disk.TrashSidecarPath(username, storageID), content)
}

func (s *Service) readTrashSidecar(username, storageID string) (trashSidecar, error) {
	var sidecar trashSidecar
	content, err := os.ReadFile(s.disk.TrashSidecarPath(username, storageID))
	if err != nil {
		return sidecar, err
	}
	if err := json.Unmarshal(content, &sidecar); err != nil {
		return sidecar, err
	}
	cleanPath, err := storage.CleanPath(sidecar.OriginalPath)
	if err != nil {
		return sidecar, err
	}
	sidecar.OriginalPath = cleanPath
	return sidecar, nil
}

func (s *Service) ReconcileTrash(ctx context.Context, owner users.User) (int, error) {
	unlock := s.locks.lock(owner.ID)
	defer unlock()
	root := s.disk.UserTrashRoot(owner.Username)
	entries, err := os.ReadDir(root)
	if errors.Is(err, fs.ErrNotExist) {
		return 0, nil
	}
	if err != nil {
		return 0, err
	}
	recovered := 0
	err = s.inTransaction(ctx, func(tx *sql.Tx) error {
		recovered = 0
		rows, err := tx.QueryContext(ctx, `SELECT storage_id FROM trash WHERE user_id = $1`, owner.ID)
		if err != nil {
			return err
		}
		storageIDs, err := scanValues[string](rows)
		if err != nil {
			return err
		}
		known := make(map[string]bool, len(storageIDs))
		for _, storageID := range storageIDs {
			known[storageID] = true
		}
		for _, entry := range entries {
			if !entry.IsDir() {
				storageID, isSidecar := strings.CutSuffix(entry.Name(), ".json")
				if _, err := os.Stat(filepath.Join(root, storageID)); isSidecar && errors.Is(err, fs.ErrNotExist) {
					if err := os.Remove(filepath.Join(root, entry.Name())); err != nil {
						return err
					}
				}
				continue
			}
			if known[entry.Name()] || !isHex(entry.Name(), storageIDLength) {
				continue
			}
			added, err := s.recoverTrashItem(ctx, tx, owner, entry.Name())
			if err != nil {
				return err
			}
			if added {
				recovered++
			}
		}
		return nil
	})
	return recovered, err
}

func (s *Service) recoverTrashItem(ctx context.Context, tx *sql.Tx, owner users.User, storageID string) (bool, error) {
	directory := filepath.Join(s.disk.UserTrashRoot(owner.Username), storageID)
	children, err := os.ReadDir(directory)
	if err != nil {
		return false, err
	}
	if len(children) != 1 {
		logger.Warn("skip trash folder that does not hold exactly one item", "user", owner.Username, "folder", storageID)
		return false, nil
	}
	name := children[0].Name()
	absolute := filepath.Join(directory, name)
	info, err := os.Lstat(absolute)
	if err != nil {
		return false, err
	}
	sidecar, err := s.readTrashSidecar(owner.Username, storageID)
	if err != nil || path.Base(sidecar.OriginalPath) != name {
		folder, statErr := os.Stat(directory)
		if statErr != nil {
			return false, statErr
		}
		sidecar = trashSidecar{OriginalPath: "/" + name, DeletedAt: folder.ModTime().UTC()}
	}
	var entry Entry
	var size int64
	switch {
	case info.IsDir():
		entry = newDirectoryEntry(owner.ID, sidecar.OriginalPath, info.ModTime().UTC())
		if size, err = treeSizeOnDisk(absolute); err != nil {
			return false, err
		}
	case info.Mode().IsRegular():
		hash, err := hashFile(absolute)
		if err != nil {
			return false, err
		}
		entry = newFileEntry(owner.ID, sidecar.OriginalPath, info.Size(), info.ModTime().UTC(), hash)
		entry.PreviewState = PreviewReady
		size = info.Size()
	default:
		return false, nil
	}
	if _, err := insertTrashItem(ctx, tx, owner.ID, entry, size, storageID, sidecar.DeletedAt); err != nil {
		return false, err
	}
	logger.Info("recovered trash item", "user", owner.Username, "path", sidecar.OriginalPath)
	return true, nil
}

func treeSizeOnDisk(root string) (int64, error) {
	var total int64
	err := filepath.WalkDir(root, func(_ string, entry fs.DirEntry, err error) error {
		if err != nil || !entry.Type().IsRegular() {
			return err
		}
		info, err := entry.Info()
		if err != nil {
			return err
		}
		total += info.Size()
		return nil
	})
	return total, err
}
