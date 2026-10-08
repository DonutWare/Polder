package files

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"

	"polder-server/internal/apperr"
	"polder-server/internal/chunkstore"
	"polder-server/internal/storage"
	"polder-server/internal/users"
)

type VersionState string

const (
	VersionPending VersionState = "pending"
	VersionReady   VersionState = "ready"
)

const versionColumns = `v.id, v.user_id, v.history_id, COALESCE(v.file_id, 0), COALESCE(v.trash_id, 0), COALESCE(v.trash_path, ''), v.size, v.hash, v.modified_ns, v.replaced_at, v.state`

type Version struct {
	ID         int64        `json:"id"`
	Size       int64        `json:"size" doc:"Bytes of the file as it was"`
	Hash       string       `json:"hash" doc:"SHA-256 of the content"`
	ModifiedAt time.Time    `json:"modifiedAt" doc:"When this content was saved"`
	ReplacedAt time.Time    `json:"replacedAt" doc:"When a newer save replaced it"`
	UserID     int64        `json:"-"`
	HistoryID  string       `json:"-"`
	FileID     int64        `json:"-"`
	TrashID    int64        `json:"-"`
	TrashPath  string       `json:"-"`
	State      VersionState `json:"-"`
}

type PendingVersion struct {
	Version
	Username string
}

type VersionChunk struct {
	Hash       string
	Size       int64
	StoredSize int64
	Compressed bool
}

type VersioningPolicy func(ctx context.Context, owner users.User) bool

func (s *Service) SetVersioningPolicy(enabled VersioningPolicy) {
	s.versioningEnabled = enabled
}

func (s *Service) OnVersionsChanged(callback func()) {
	s.versionsChanged = append(s.versionsChanged, callback)
}

func (s *Service) onVersionsChanged() {
	for _, callback := range s.versionsChanged {
		callback()
	}
}

func (s *Service) shouldCaptureVersion(ctx context.Context, owner users.User) bool {
	return s.versioningEnabled != nil && s.versioningEnabled(ctx, owner)
}

func scanVersion(row rowScanner, extra ...any) (Version, error) {
	var version Version
	var modifiedNanos, replacedAt int64
	destinations := append([]any{&version.ID, &version.UserID, &version.HistoryID, &version.FileID, &version.TrashID, &version.TrashPath,
		&version.Size, &version.Hash, &modifiedNanos, &replacedAt, &version.State}, extra...)
	err := row.Scan(destinations...)
	version.ModifiedAt = time.Unix(0, modifiedNanos).UTC()
	version.ReplacedAt = time.Unix(replacedAt, 0).UTC()
	return version, err
}

func queryVersions(ctx context.Context, q querier, query string, args ...any) ([]Version, error) {
	rows, err := q.QueryContext(ctx, `SELECT `+versionColumns+` FROM file_versions v `+query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	versions := []Version{}
	for rows.Next() {
		version, err := scanVersion(rows)
		if err != nil {
			return nil, err
		}
		versions = append(versions, version)
	}
	return versions, rows.Err()
}

func fileBytes(ctx context.Context, q querier, userID int64) (int64, error) {
	var used int64
	err := q.QueryRowContext(ctx, `SELECT COALESCE(SUM(size), 0) FROM files WHERE user_id = $1`, userID).Scan(&used)
	return used, err
}

func historyBytes(ctx context.Context, q querier, userID int64) (int64, error) {
	var stored, pending int64
	err := q.QueryRowContext(ctx, `SELECT
		COALESCE((SELECT SUM(stored_size) FROM version_chunks WHERE user_id = $1), 0),
		COALESCE((SELECT SUM(size) FROM file_versions WHERE user_id = $1 AND state = $2), 0)`,
		userID, VersionPending).Scan(&stored, &pending)
	return stored + pending, err
}

func (s *Service) FileBytes(ctx context.Context, userID int64) (int64, error) {
	return fileBytes(ctx, s.db, userID)
}

func (s *Service) captureVersion(ctx context.Context, q querier, owner users.User, current Entry, absolute string) (bool, error) {
	historyID, err := s.historyOf(ctx, q, owner, current)
	if err != nil {
		return false, err
	}
	replacedAt := time.Now().Unix()
	var duplicates int
	err = q.QueryRowContext(ctx, `SELECT COUNT(*) FROM file_versions WHERE user_id = $1 AND history_id = $2 AND hash = $3 AND replaced_at = $4`,
		owner.ID, historyID, current.Hash, replacedAt).Scan(&duplicates)
	if err != nil || duplicates > 0 {
		return false, err
	}
	var versionID int64
	err = q.QueryRowContext(ctx,
		`INSERT INTO file_versions (user_id, history_id, file_id, size, hash, modified_ns, replaced_at, state) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id`,
		owner.ID, historyID, current.ID, current.Size, current.Hash, current.Mtime.UnixNano(), replacedAt, VersionPending).Scan(&versionID)
	if err != nil {
		return false, err
	}
	pendingPath := s.disk.PendingVersionPath(owner.Username, versionID)
	if err := storage.MakeDirs(s.disk.PendingVersionsDir(owner.Username)); err != nil {
		return false, err
	}
	if err := os.Link(absolute, pendingPath); err == nil {
		return true, nil
	}
	return true, copyFile(absolute, pendingPath)
}

func copyFile(source, target string) error {
	input, err := os.Open(source)
	if err != nil {
		return fmt.Errorf("keep previous version: %w", err)
	}
	defer input.Close()
	output, err := os.OpenFile(target, os.O_CREATE|os.O_EXCL|os.O_WRONLY, 0o640)
	if err != nil {
		return fmt.Errorf("keep previous version: %w", err)
	}
	_, copyErr := io.Copy(output, input)
	closeErr := output.Close()
	if err := errors.Join(copyErr, closeErr); err != nil {
		_ = os.Remove(target)
		return fmt.Errorf("keep previous version: %w", err)
	}
	return nil
}

func (s *Service) makeRoomForHistory(ctx context.Context, q querier, owner users.User, filesAfterWrite, incoming int64) (fits, evicted bool, err error) {
	if owner.HasUnlimitedQuota() {
		return true, false, nil
	}
	for {
		history, err := historyBytes(ctx, q, owner.ID)
		if err != nil {
			return false, evicted, err
		}
		if filesAfterWrite+history+incoming <= owner.QuotaBytes {
			return true, evicted, nil
		}
		oldest, err := queryVersions(ctx, q, `WHERE v.user_id = $1 ORDER BY v.replaced_at, v.id LIMIT 1`, owner.ID)
		if err != nil {
			return false, evicted, err
		}
		if len(oldest) == 0 {
			return filesAfterWrite+history+incoming <= owner.QuotaBytes, evicted, nil
		}
		if err := s.deleteVersions(ctx, q, owner.ID, owner.Username, []int64{oldest[0].ID}); err != nil {
			return false, evicted, err
		}
		evicted = true
	}
}

func (s *Service) deleteVersions(ctx context.Context, q querier, userID int64, username string, ids []int64) error {
	touched := map[string]bool{}
	for len(ids) > 0 {
		batch := ids[:min(len(ids), entriesByIDBatch)]
		ids = ids[len(batch):]
		placeholders, args := idPlaceholders(userID, batch)
		doomed, err := queryVersions(ctx, q, `WHERE v.user_id = $1 AND v.id IN (`+placeholders+`)`, args...)
		if err != nil {
			return err
		}
		if _, err := q.ExecContext(ctx, `DELETE FROM file_version_chunks WHERE user_id = $1 AND version_id IN (`+placeholders+`)`, args...); err != nil {
			return err
		}
		if _, err := q.ExecContext(ctx, `DELETE FROM file_versions WHERE user_id = $1 AND id IN (`+placeholders+`)`, args...); err != nil {
			return err
		}
		for _, version := range doomed {
			touched[version.HistoryID] = true
			manifest := filepath.Join(s.disk.HistoryDir(username, version.HistoryID), manifestName(version.ReplacedAt, version.Hash))
			if err := os.Remove(manifest); err != nil && !errors.Is(err, fs.ErrNotExist) {
				return err
			}
		}
	}
	for historyID := range touched {
		var remaining int
		err := q.QueryRowContext(ctx, `SELECT COUNT(*) FROM file_versions WHERE user_id = $1 AND history_id = $2`, userID, historyID).Scan(&remaining)
		if err != nil {
			return err
		}
		if remaining == 0 {
			if err := os.RemoveAll(s.disk.HistoryDir(username, historyID)); err != nil {
				return err
			}
		}
	}
	return removeUnreferencedChunks(ctx, q, userID)
}

func idPlaceholders(userID int64, ids []int64) (string, []any) {
	args := make([]any, 0, len(ids)+1)
	args = append(args, userID)
	placeholders := make([]string, 0, len(ids))
	for _, id := range ids {
		args = append(args, id)
		placeholders = append(placeholders, "$"+strconv.Itoa(len(args)))
	}
	return strings.Join(placeholders, ","), args
}

func removeUnreferencedChunks(ctx context.Context, q querier, userID int64) error {
	_, err := q.ExecContext(ctx, `DELETE FROM version_chunks WHERE user_id = $1 AND NOT EXISTS
		(SELECT 1 FROM file_version_chunks c WHERE c.user_id = $1 AND c.chunk_hash = version_chunks.hash)`, userID)
	return err
}

func (s *Service) removeVersionsOfTree(ctx context.Context, q querier, owner users.User, cleanPath string) error {
	prefix := cleanPath + "/"
	rows, err := q.QueryContext(ctx, `SELECT v.id FROM file_versions v JOIN files f ON f.id = v.file_id
		WHERE f.user_id = $1 AND (f.path_key = $2 OR SUBSTR(f.path, 1, $3) = $4)`,
		owner.ID, pathKey(cleanPath), utf8.RuneCountInString(prefix), prefix)
	if err != nil {
		return err
	}
	ids, err := scanValues[int64](rows)
	if err != nil || len(ids) == 0 {
		return err
	}
	return s.deleteVersions(ctx, q, owner.ID, owner.Username, ids)
}

func scanValues[T any](rows *sql.Rows) ([]T, error) {
	defer rows.Close()
	var values []T
	for rows.Next() {
		var value T
		if err := rows.Scan(&value); err != nil {
			return nil, err
		}
		values = append(values, value)
	}
	return values, rows.Err()
}

func attachVersionsToTrash(ctx context.Context, q querier, userID int64, entry Entry, trashID int64) error {
	tree := []Entry{entry}
	if entry.IsDir {
		var err error
		if tree, err = listTree(ctx, q, userID, entry.Path); err != nil {
			return err
		}
	}
	for _, item := range tree {
		if item.IsDir {
			continue
		}
		relative := strings.TrimPrefix(item.Path, entry.Path)
		_, err := q.ExecContext(ctx, `UPDATE file_versions SET file_id = NULL, trash_id = $1, trash_path = $2 WHERE user_id = $3 AND file_id = $4`,
			trashID, relative, userID, item.ID)
		if err != nil {
			return err
		}
	}
	return nil
}

func (s *Service) relinkVersionsFromTrash(ctx context.Context, q querier, owner users.User, trashID int64, target string) error {
	versions, err := queryVersions(ctx, q, `WHERE v.user_id = $1 AND v.trash_id = $2`, owner.ID, trashID)
	if err != nil {
		return err
	}
	var orphaned []int64
	for _, version := range versions {
		entry, found, err := findEntry(ctx, q, owner.ID, target+version.TrashPath)
		if err != nil {
			return err
		}
		if !found || entry.IsDir {
			orphaned = append(orphaned, version.ID)
			continue
		}
		_, err = q.ExecContext(ctx, `UPDATE file_versions SET file_id = $1, trash_id = NULL, trash_path = NULL WHERE id = $2`, entry.ID, version.ID)
		if err != nil {
			return err
		}
	}
	if len(orphaned) > 0 {
		if err := s.deleteVersions(ctx, q, owner.ID, owner.Username, orphaned); err != nil {
			return err
		}
	}
	return s.relocateHistoriesOfTree(ctx, q, owner, target)
}

func (s *Service) removeVersionsOfTrashItems(ctx context.Context, q querier, owner users.User, items []TrashItem) error {
	var ids []int64
	for _, item := range items {
		rows, err := q.QueryContext(ctx, `SELECT id FROM file_versions WHERE user_id = $1 AND trash_id = $2`, owner.ID, item.ID)
		if err != nil {
			return err
		}
		found, err := scanValues[int64](rows)
		if err != nil {
			return err
		}
		ids = append(ids, found...)
	}
	if len(ids) == 0 {
		return nil
	}
	return s.deleteVersions(ctx, q, owner.ID, owner.Username, ids)
}

func (s *Service) ListVersions(ctx context.Context, owner users.User, rawPath string) (Entry, []Version, error) {
	entry, err := s.Stat(ctx, owner, rawPath)
	if err != nil {
		return Entry{}, nil, err
	}
	if entry.IsDir {
		return Entry{}, nil, apperr.Invalid("%s is a directory", entry.Path)
	}
	versions, err := queryVersions(ctx, s.db, `WHERE v.user_id = $1 AND v.file_id = $2 ORDER BY v.replaced_at DESC, v.id DESC`, owner.ID, entry.ID)
	return entry, versions, err
}

func (s *Service) FindVersion(ctx context.Context, owner users.User, versionID int64) (Version, Entry, error) {
	versions, err := queryVersions(ctx, s.db, `WHERE v.user_id = $1 AND v.id = $2 AND v.file_id IS NOT NULL`, owner.ID, versionID)
	if err != nil {
		return Version{}, Entry{}, err
	}
	if len(versions) == 0 {
		return Version{}, Entry{}, apperr.NotFound("no such version")
	}
	entries, err := entriesByID(ctx, s.db, owner.ID, []int64{versions[0].FileID})
	if err != nil {
		return Version{}, Entry{}, err
	}
	entry, found := entries[versions[0].FileID]
	if !found {
		return Version{}, Entry{}, apperr.NotFound("no such version")
	}
	return versions[0], entry, nil
}

func (s *Service) OpenVersion(ctx context.Context, owner users.User, versionID int64) (io.ReadCloser, Version, Entry, error) {
	version, entry, err := s.FindVersion(ctx, owner, versionID)
	if err != nil {
		return nil, Version{}, Entry{}, err
	}
	if version.State == VersionPending {
		file, err := os.Open(s.disk.PendingVersionPath(owner.Username, version.ID))
		if err == nil {
			return file, version, entry, nil
		}
		version, entry, err = s.FindVersion(ctx, owner, versionID)
		if err != nil {
			return nil, Version{}, Entry{}, err
		}
		if version.State == VersionPending {
			return nil, Version{}, Entry{}, apperr.NotFound("this version is no longer available")
		}
	}
	chunks, err := versionChunks(ctx, s.db, version.ID)
	if err != nil {
		return nil, Version{}, Entry{}, err
	}
	parts := make([]chunkstore.Part, 0, len(chunks))
	for _, chunk := range chunks {
		parts = append(parts, chunkstore.Part{Path: s.disk.VersionChunkPath(owner.Username, chunk.Hash), Compressed: chunk.Compressed})
	}
	return chunkstore.NewSequenceReader(parts), version, entry, nil
}

func versionChunks(ctx context.Context, q querier, versionID int64) ([]VersionChunk, error) {
	rows, err := q.QueryContext(ctx, `SELECT c.chunk_hash, c.size, k.stored_size, k.compressed FROM file_version_chunks c
		JOIN version_chunks k ON k.user_id = c.user_id AND k.hash = c.chunk_hash
		WHERE c.version_id = $1 ORDER BY c.idx`, versionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var chunks []VersionChunk
	for rows.Next() {
		var chunk VersionChunk
		if err := rows.Scan(&chunk.Hash, &chunk.Size, &chunk.StoredSize, &chunk.Compressed); err != nil {
			return nil, err
		}
		chunks = append(chunks, chunk)
	}
	return chunks, rows.Err()
}

func (s *Service) RestoreVersion(ctx context.Context, owner users.User, versionID, baseRev int64) (Entry, error) {
	content, version, entry, err := s.OpenVersion(ctx, owner, versionID)
	if err != nil {
		return Entry{}, err
	}
	defer content.Close()
	if baseRev == 0 {
		baseRev = entry.Rev
	}
	restored, err := s.Write(ctx, owner, WriteRequest{Path: entry.Path, BaseRev: baseRev, ExpectedHash: version.Hash, Content: content})
	if err != nil {
		return Entry{}, err
	}
	_, err = s.db.ExecContext(ctx, `INSERT INTO file_restores (file_id, restore_count) VALUES ($1, 1)
		ON CONFLICT (file_id) DO UPDATE SET restore_count = file_restores.restore_count + 1`, entry.ID)
	return restored, err
}

func (s *Service) RestoreCount(ctx context.Context, fileID int64) (int64, error) {
	var count int64
	err := s.db.QueryRowContext(ctx, `SELECT restore_count FROM file_restores WHERE file_id = $1`, fileID).Scan(&count)
	if errors.Is(err, sql.ErrNoRows) {
		return 0, nil
	}
	return count, err
}

func (s *Service) DeleteVersion(ctx context.Context, owner users.User, versionID int64) error {
	if _, _, err := s.FindVersion(ctx, owner, versionID); err != nil {
		return err
	}
	return s.DeleteVersions(ctx, owner, []int64{versionID})
}

func (s *Service) DeleteVersions(ctx context.Context, owner users.User, versionIDs []int64) error {
	if len(versionIDs) == 0 {
		return nil
	}
	unlock := s.locks.lock(owner.ID)
	err := s.inTransaction(ctx, func(tx *sql.Tx) error {
		return s.deleteVersions(ctx, tx, owner.ID, owner.Username, versionIDs)
	})
	unlock()
	if err == nil {
		s.onVersionsChanged()
		s.onContentRemoved()
	}
	return err
}

func (s *Service) AllVersions(ctx context.Context, userID int64) ([]Version, error) {
	return queryVersions(ctx, s.db, `WHERE v.user_id = $1`, userID)
}

func (s *Service) PendingVersions(ctx context.Context, limit int) ([]PendingVersion, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT `+versionColumns+`, u.username FROM file_versions v JOIN users u ON u.id = v.user_id
		WHERE v.state = $1 ORDER BY v.id LIMIT $2`, VersionPending, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var pending []PendingVersion
	for rows.Next() {
		var item PendingVersion
		if item.Version, err = scanVersion(rows, &item.Username); err != nil {
			return nil, err
		}
		pending = append(pending, item)
	}
	return pending, rows.Err()
}

func (s *Service) StoredChunk(ctx context.Context, userID int64, chunkHash string) (VersionChunk, bool, error) {
	chunk := VersionChunk{Hash: chunkHash}
	err := s.db.QueryRowContext(ctx, `SELECT stored_size, compressed FROM version_chunks WHERE user_id = $1 AND hash = $2`,
		userID, chunkHash).Scan(&chunk.StoredSize, &chunk.Compressed)
	if errors.Is(err, sql.ErrNoRows) {
		return VersionChunk{}, false, nil
	}
	return chunk, err == nil, err
}

func (s *Service) CompleteVersion(ctx context.Context, version PendingVersion, chunks []VersionChunk) error {
	unlock := s.locks.lock(version.UserID)
	defer unlock()
	return s.inTransaction(ctx, func(tx *sql.Tx) error {
		var state VersionState
		err := tx.QueryRowContext(ctx, `SELECT state FROM file_versions WHERE id = $1`, version.ID).Scan(&state)
		if errors.Is(err, sql.ErrNoRows) || (err == nil && state != VersionPending) {
			return nil
		}
		if err != nil {
			return err
		}
		if err := s.writeManifest(version.Username, version.Version, chunks); err != nil {
			return err
		}
		if err := insertVersionChunks(ctx, tx, version.UserID, version.ID, chunks); err != nil {
			return err
		}
		_, err = tx.ExecContext(ctx, `UPDATE file_versions SET state = $1 WHERE id = $2`, VersionReady, version.ID)
		return err
	})
}

func insertVersionChunks(ctx context.Context, q querier, userID, versionID int64, chunks []VersionChunk) error {
	for index, chunk := range chunks {
		_, err := q.ExecContext(ctx, `INSERT INTO version_chunks (user_id, hash, stored_size, compressed) VALUES ($1, $2, $3, $4)
			ON CONFLICT (user_id, hash) DO NOTHING`, userID, chunk.Hash, chunk.StoredSize, chunk.Compressed)
		if err != nil {
			return err
		}
		_, err = q.ExecContext(ctx, `INSERT INTO file_version_chunks (version_id, idx, user_id, chunk_hash, size) VALUES ($1, $2, $3, $4, $5)`,
			versionID, index, userID, chunk.Hash, chunk.Size)
		if err != nil {
			return err
		}
	}
	return nil
}

func (s *Service) DropVersion(ctx context.Context, version PendingVersion) error {
	unlock := s.locks.lock(version.UserID)
	defer unlock()
	return s.inTransaction(ctx, func(tx *sql.Tx) error {
		return s.deleteVersions(ctx, tx, version.UserID, version.Username, []int64{version.ID})
	})
}

func (s *Service) StoredChunkHashes(ctx context.Context, userID int64) (map[string]bool, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT hash FROM version_chunks WHERE user_id = $1`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	hashes := map[string]bool{}
	for rows.Next() {
		var chunkHash string
		if err := rows.Scan(&chunkHash); err != nil {
			return nil, err
		}
		hashes[chunkHash] = true
	}
	return hashes, rows.Err()
}

func (s *Service) PendingVersionIDs(ctx context.Context, userID int64) (map[int64]bool, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT id FROM file_versions WHERE user_id = $1 AND state = $2`, userID, VersionPending)
	if err != nil {
		return nil, err
	}
	ids, err := scanValues[int64](rows)
	if err != nil {
		return nil, err
	}
	pending := make(map[int64]bool, len(ids))
	for _, id := range ids {
		pending[id] = true
	}
	return pending, nil
}

func (s *Service) RemoveOrphanedPendingVersions(ctx context.Context, owner users.User) error {
	unlock := s.locks.lock(owner.ID)
	defer unlock()
	pending, err := s.PendingVersionIDs(ctx, owner.ID)
	if err != nil {
		return err
	}
	directory := s.disk.PendingVersionsDir(owner.Username)
	entries, err := os.ReadDir(directory)
	if errors.Is(err, fs.ErrNotExist) {
		return nil
	}
	if err != nil {
		return err
	}
	var failures []error
	for _, entry := range entries {
		id, err := strconv.ParseInt(entry.Name(), 10, 64)
		if err == nil && pending[id] {
			continue
		}
		if err := os.Remove(filepath.Join(directory, entry.Name())); err != nil {
			failures = append(failures, err)
		}
	}
	return errors.Join(failures...)
}
