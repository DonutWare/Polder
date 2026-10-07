package files

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"errors"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"polder-server/internal/storage"
	"polder-server/internal/users"
)

type diskItem struct {
	path  string
	isDir bool
	size  int64
	mtime time.Time
}

const (
	scanBatchSize     = 250
	scanBatchInterval = 2 * time.Second
	// scanChangeSample is how many changes a finished rescan reports by name; the rest are only counted.
	scanChangeSample = 100
)

// Rescan brings the index in line with the user's directory. It commits in batches, so a large
// directory fills in while it is still being read.
func (s *Service) Rescan(ctx context.Context, owner users.User) error {
	unlock := s.scanLocks.lock(owner.ID)
	defer unlock()
	if err := s.disk.EnsureUserRoot(owner.Username); err != nil {
		return err
	}
	indexedList, err := listAll(ctx, s.db, owner.ID)
	if err != nil {
		return err
	}
	indexed := make(map[string]Entry, len(indexedList))
	for _, entry := range indexedList {
		indexed[entry.Path] = entry
	}

	onDisk, err := s.walkUserRoot(owner.Username)
	if err != nil {
		return err
	}
	var pending []diskItem
	for _, item := range onDisk {
		if known, isKnown := indexed[item.path]; !isKnown || differs(known, item) {
			pending = append(pending, item)
		}
	}
	sort.Slice(pending, func(i, j int) bool { return len(pending[i].path) < len(pending[j].path) })
	if len(pending) > scanBatchSize {
		s.indexing.Store(owner.ID, true)
		defer s.indexing.Delete(owner.ID)
	}

	var summary scanSummary
	if removals := topmostMissingPaths(indexed, onDisk); len(removals) > 0 {
		changes, err := s.applyRemovals(ctx, owner, removals)
		if err != nil {
			return err
		}
		summary.add(changes)
	}

	var batch []Entry
	lastCommit := time.Now()
	commit := func() error {
		changes, err := s.applyUpserts(ctx, owner, batch)
		batch, lastCommit = batch[:0], time.Now()
		summary.add(changes)
		return err
	}
	for _, item := range pending {
		if err := ctx.Err(); err != nil {
			return err
		}
		if entry, err := s.entryFromDisk(owner, item, indexed[item.path]); err == nil {
			batch = append(batch, entry)
		}
		if len(batch) >= scanBatchSize || time.Since(lastCommit) >= scanBatchInterval {
			if err := commit(); err != nil {
				return err
			}
		}
	}
	if err := commit(); err != nil {
		return err
	}
	if summary.count > 0 {
		s.notify(ctx, Mutation{Owner: owner, Kind: MutationRescanFinished, Path: "/", IsDir: true, Count: summary.count, Changes: summary.sample})
	}
	return nil
}

type scanSummary struct {
	count  int
	sample []ScanChange
}

// IsIndexing reports whether a rescan with more than one batch of work is running for the user.
func (s *Service) IsIndexing(userID int64) bool {
	_, indexing := s.indexing.Load(userID)
	return indexing
}

func (s *scanSummary) add(changes []ScanChange) {
	s.count += len(changes)
	room := scanChangeSample - len(s.sample)
	s.sample = append(s.sample, changes[:min(room, len(changes))]...)
}

func differs(known Entry, item diskItem) bool {
	if known.IsDir != item.isDir {
		return true
	}
	return !item.isDir && (known.Size != item.size || !known.Mtime.Equal(item.mtime))
}

func (s *Service) walkUserRoot(username string) (map[string]diskItem, error) {
	root := s.disk.UserRoot(username)
	items := map[string]diskItem{}
	err := filepath.WalkDir(root, func(absolute string, dirEntry fs.DirEntry, err error) error {
		if err != nil || absolute == root {
			return err
		}
		if isInternalName(dirEntry.Name()) {
			return skipEntry(dirEntry)
		}
		if !dirEntry.IsDir() && !dirEntry.Type().IsRegular() {
			return nil
		}
		info, err := dirEntry.Info()
		if err != nil {
			return nil
		}
		relative, _ := filepath.Rel(root, absolute)
		cleanPath, err := storage.CleanPath("/" + filepath.ToSlash(relative))
		if err != nil {
			return skipEntry(dirEntry)
		}
		items[cleanPath] = diskItem{path: cleanPath, isDir: dirEntry.IsDir(), size: info.Size(), mtime: info.ModTime().UTC()}
		return nil
	})
	return items, err
}

func skipEntry(dirEntry fs.DirEntry) error {
	if dirEntry.IsDir() {
		return filepath.SkipDir
	}
	return nil
}

func (s *Service) entryFromDisk(owner users.User, item diskItem, known Entry) (Entry, error) {
	if item.isDir {
		return newDirectoryEntry(owner.ID, item.path, item.mtime), nil
	}
	absolute, err := s.disk.Resolve(owner.Username, item.path)
	if err != nil {
		return Entry{}, err
	}
	hash, err := hashFile(absolute)
	if err != nil {
		return Entry{}, err
	}
	entry := newFileEntry(owner.ID, item.path, item.size, item.mtime, hash)
	if !known.IsDir && known.Hash == hash {
		entry.Meta, entry.PreviewState, entry.TextState = known.Meta, known.PreviewState, known.TextState
	}
	return entry, nil
}

func topmostMissingPaths(indexed map[string]Entry, onDisk map[string]diskItem) []string {
	var missing []string
	for indexedPath := range indexed {
		if _, present := onDisk[indexedPath]; !present {
			missing = append(missing, indexedPath)
		}
	}
	sort.Strings(missing)
	var topmost []string
	for _, candidate := range missing {
		if len(topmost) > 0 && storage.IsSameOrDescendant(candidate, topmost[len(topmost)-1]) {
			continue
		}
		topmost = append(topmost, candidate)
	}
	return topmost
}

func (s *Service) applyRemovals(ctx context.Context, owner users.User, removals []string) ([]ScanChange, error) {
	unlock := s.locks.lock(owner.ID)
	defer unlock()
	var changes []ScanChange
	err := s.inTransaction(ctx, func(tx *sql.Tx) error {
		changes = changes[:0]
		for _, removedPath := range removals {
			if !isInternalName(removedPath) && s.existsOnDisk(owner.Username, removedPath) {
				continue
			}
			removed, found, err := findEntry(ctx, tx, owner.ID, removedPath)
			if err != nil {
				return err
			}
			if err := removeTree(ctx, tx, owner.ID, removedPath); err != nil {
				return err
			}
			if found && !isInternalName(removedPath) {
				changes = append(changes, ScanChange{Path: removedPath, IsDir: removed.IsDir, Change: ScanRemoved})
			}
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	s.onContentRemoved()
	if len(changes) > 0 {
		s.notify(ctx, Mutation{Owner: owner, Kind: MutationRescan, Path: "/", IsDir: true, Changes: changes})
	}
	return changes, nil
}

func (s *Service) applyUpserts(ctx context.Context, owner users.User, upserts []Entry) ([]ScanChange, error) {
	if len(upserts) == 0 {
		return nil, nil
	}
	unlock := s.locks.lock(owner.ID)
	defer unlock()
	var changedFiles []string
	var changes []ScanChange
	err := s.inTransaction(ctx, func(tx *sql.Tx) error {
		changedFiles, changes = changedFiles[:0], changes[:0]
		for _, entry := range upserts {
			change, err := s.applyScannedEntry(ctx, tx, owner, entry)
			if err != nil {
				return err
			}
			if change != "" && !entry.IsDir {
				changedFiles = append(changedFiles, entry.Path)
			}
			if change == ScanAdded || (change == ScanChanged && !entry.IsDir) {
				changes = append(changes, ScanChange{Path: entry.Path, IsDir: entry.IsDir, Change: change})
			}
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	for _, changedPath := range changedFiles {
		s.onContentChanged(owner.ID, changedPath)
	}
	if len(changes) > 0 {
		s.notify(ctx, Mutation{Owner: owner, Kind: MutationRescan, Path: "/", IsDir: true, Changes: changes})
	}
	return changes, nil
}

func (s *Service) applyScannedEntry(ctx context.Context, tx *sql.Tx, owner users.User, entry Entry) (ScanChangeType, error) {
	if !s.stillMatchesDisk(owner.Username, entry) {
		return "", nil
	}
	known, found, err := findEntry(ctx, tx, owner.ID, entry.Path)
	if err != nil {
		return "", err
	}
	if found && known.IsDir != entry.IsDir {
		if err := removeTree(ctx, tx, owner.ID, entry.Path); err != nil {
			return "", err
		}
	}
	if _, err = saveEntry(ctx, tx, entry); err != nil {
		return "", err
	}
	if found {
		return ScanChanged, nil
	}
	return ScanAdded, nil
}

func (s *Service) existsOnDisk(username, cleanPath string) bool {
	absolute, err := s.disk.Resolve(username, cleanPath)
	if err != nil {
		return false
	}
	_, err = os.Lstat(absolute)
	return !errors.Is(err, fs.ErrNotExist)
}

func (s *Service) stillMatchesDisk(username string, entry Entry) bool {
	absolute, err := s.disk.Resolve(username, entry.Path)
	if err != nil {
		return false
	}
	info, err := os.Stat(absolute)
	if err != nil || info.IsDir() != entry.IsDir {
		return false
	}
	return entry.IsDir || (info.Size() == entry.Size && info.ModTime().UTC().Equal(entry.Mtime))
}

func hashFile(absolute string) (string, error) {
	file, err := os.Open(absolute)
	if err != nil {
		return "", err
	}
	defer file.Close()
	hasher := sha256.New()
	if _, err := io.Copy(hasher, file); err != nil {
		return "", err
	}
	return hex.EncodeToString(hasher.Sum(nil)), nil
}

func UsernameFromDiskPath(dataDir, absolute string) (string, bool) {
	relative, err := filepath.Rel(dataDir, absolute)
	if err != nil || relative == "." || strings.HasPrefix(relative, "..") {
		return "", false
	}
	username := strings.Split(filepath.ToSlash(relative), "/")[0]
	return username, !storage.IsReservedName(username)
}
