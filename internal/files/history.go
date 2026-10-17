package files

import (
	"bytes"
	"cmp"
	"context"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"errors"
	"io/fs"
	"maps"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"time"
	"unicode/utf8"

	"polder-server/internal/storage"
	"polder-server/internal/users"
)

const (
	locationFileName    = "location"
	manifestSuffix      = ".version"
	manifestStampLayout = "20060102T150405Z"
	storageIDLength     = 32
	contentHashLength   = 64
)

type historyLocation struct {
	Path  string `json:"path"`
	Trash string `json:"trash,omitempty"`
}

type versionManifest struct {
	Hash       string          `json:"hash"`
	Size       int64           `json:"size"`
	ModifiedNs int64           `json:"modifiedNs"`
	ReplacedAt int64           `json:"replacedAt"`
	Chunks     []manifestChunk `json:"chunks"`
}

type manifestChunk struct {
	Hash       string `json:"hash"`
	Size       int64  `json:"size"`
	Compressed bool   `json:"compressed"`
}

func manifestName(replacedAt time.Time, hash string) string {
	return replacedAt.UTC().Format(manifestStampLayout) + "." + hash + manifestSuffix
}

func newVersionManifest(version Version, chunks []VersionChunk) versionManifest {
	manifest := versionManifest{
		Hash:       version.Hash,
		Size:       version.Size,
		ModifiedNs: version.ModifiedAt.UnixNano(),
		ReplacedAt: version.ReplacedAt.Unix(),
		Chunks:     make([]manifestChunk, 0, len(chunks)),
	}
	for _, chunk := range chunks {
		manifest.Chunks = append(manifest.Chunks, manifestChunk{Hash: chunk.Hash, Size: chunk.Size, Compressed: chunk.Compressed})
	}
	return manifest
}

func isHex(value string, length int) bool {
	if len(value) != length {
		return false
	}
	_, err := hex.DecodeString(value)
	return err == nil
}

func (s *Service) writeHistoryFile(username, historyID, name string, value any) error {
	content, err := json.Marshal(value)
	if err != nil {
		return err
	}
	directory := s.disk.HistoryDir(username, historyID)
	if err := storage.MakeDirs(directory); err != nil {
		return err
	}
	target := filepath.Join(directory, name)
	if existing, err := os.ReadFile(target); err == nil && bytes.Equal(existing, content) {
		return nil
	}
	return storage.WriteFileAtomically(target, content)
}

func (s *Service) writeManifest(username string, version Version, chunks []VersionChunk) error {
	return s.writeHistoryFile(username, version.HistoryID, manifestName(version.ReplacedAt, version.Hash), newVersionManifest(version, chunks))
}

func (s *Service) readLocation(username, historyID string) (historyLocation, error) {
	var location historyLocation
	content, err := os.ReadFile(filepath.Join(s.disk.HistoryDir(username, historyID), locationFileName))
	if err != nil {
		return location, err
	}
	return location, json.Unmarshal(content, &location)
}

func (s *Service) readManifests(username, historyID string) (map[string]versionManifest, error) {
	directory := s.disk.HistoryDir(username, historyID)
	entries, err := os.ReadDir(directory)
	if errors.Is(err, fs.ErrNotExist) {
		return map[string]versionManifest{}, nil
	}
	if err != nil {
		return nil, err
	}
	manifests := map[string]versionManifest{}
	for _, entry := range entries {
		if entry.IsDir() || !strings.HasSuffix(entry.Name(), manifestSuffix) {
			continue
		}
		content, err := os.ReadFile(filepath.Join(directory, entry.Name()))
		if err != nil {
			return nil, err
		}
		var manifest versionManifest
		if err := json.Unmarshal(content, &manifest); err != nil || !validManifest(manifest) {
			logger.Warn("skip unreadable history version", "user", username, "history", historyID, "file", entry.Name())
			continue
		}
		manifests[entry.Name()] = manifest
	}
	return manifests, nil
}

func validManifest(manifest versionManifest) bool {
	if !isHex(manifest.Hash, contentHashLength) {
		return false
	}
	for _, chunk := range manifest.Chunks {
		if !isHex(chunk.Hash, contentHashLength) {
			return false
		}
	}
	return true
}

func (s *Service) historiesOnDisk(username string) ([]string, error) {
	root := s.disk.HistoryRoot(username)
	groups, err := os.ReadDir(root)
	if errors.Is(err, fs.ErrNotExist) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	var historyIDs []string
	for _, group := range groups {
		if !group.IsDir() {
			continue
		}
		entries, err := os.ReadDir(filepath.Join(root, group.Name()))
		if err != nil {
			return nil, err
		}
		for _, entry := range entries {
			if entry.IsDir() && isHex(entry.Name(), storageIDLength) && strings.HasPrefix(entry.Name(), group.Name()) {
				historyIDs = append(historyIDs, entry.Name())
			}
		}
	}
	return historyIDs, nil
}

func (s *Service) historyOf(ctx context.Context, q querier, owner users.User, file Entry) (string, error) {
	var historyID string
	err := q.QueryRowContext(ctx, `SELECT history_id FROM file_versions WHERE user_id = $1 AND file_id = $2 LIMIT 1`, owner.ID, file.ID).Scan(&historyID)
	if err == nil {
		return historyID, nil
	}
	if !errors.Is(err, sql.ErrNoRows) {
		return "", err
	}
	historyID = storage.NewID()
	return historyID, s.writeHistoryFile(owner.Username, historyID, locationFileName, historyLocation{Path: file.Path})
}

func locationOf(ctx context.Context, q querier, userID int64, version Version) (historyLocation, bool, error) {
	if version.FileID != 0 {
		entries, err := entriesByID(ctx, q, userID, []int64{version.FileID})
		if err != nil {
			return historyLocation{}, false, err
		}
		entry, found := entries[version.FileID]
		return historyLocation{Path: entry.Path}, found, nil
	}
	item, err := scanTrashItem(q.QueryRowContext(ctx, `SELECT `+trashColumns+` FROM trash WHERE user_id = $1 AND id = $2`, userID, version.TrashID))
	if errors.Is(err, sql.ErrNoRows) {
		return historyLocation{}, false, nil
	}
	if err != nil {
		return historyLocation{}, false, err
	}
	return historyLocation{Path: item.OriginalPath + version.TrashPath, Trash: item.storageID}, true, nil
}

func (s *Service) writeLocations(ctx context.Context, q querier, owner users.User, historyIDs []string) error {
	for _, historyID := range historyIDs {
		versions, err := queryVersions(ctx, q, `WHERE v.user_id = $1 AND v.history_id = $2 LIMIT 1`, owner.ID, historyID)
		if err != nil {
			return err
		}
		if len(versions) == 0 {
			continue
		}
		location, found, err := locationOf(ctx, q, owner.ID, versions[0])
		if err != nil {
			return err
		}
		if !found {
			continue
		}
		if err := s.writeHistoryFile(owner.Username, historyID, locationFileName, location); err != nil {
			return err
		}
	}
	return nil
}

func (s *Service) relocateHistoriesOfTree(ctx context.Context, q querier, owner users.User, cleanPath string) error {
	prefix := cleanPath + "/"
	rows, err := q.QueryContext(ctx, `SELECT DISTINCT v.history_id FROM file_versions v JOIN files f ON f.id = v.file_id
		WHERE f.user_id = $1 AND (f.path_key = $2 OR SUBSTR(f.path, 1, $3) = $4)`,
		owner.ID, pathKey(cleanPath), utf8.RuneCountInString(prefix), prefix)
	if err != nil {
		return err
	}
	historyIDs, err := scanValues[string](rows)
	if err != nil {
		return err
	}
	return s.writeLocations(ctx, q, owner, historyIDs)
}

func (s *Service) relocateHistoriesOfTrashItem(ctx context.Context, q querier, owner users.User, trashID int64) error {
	rows, err := q.QueryContext(ctx, `SELECT DISTINCT history_id FROM file_versions WHERE user_id = $1 AND trash_id = $2`, owner.ID, trashID)
	if err != nil {
		return err
	}
	historyIDs, err := scanValues[string](rows)
	if err != nil {
		return err
	}
	return s.writeLocations(ctx, q, owner, historyIDs)
}

func (s *Service) ReconcileHistory(ctx context.Context, owner users.User) (map[string]bool, error) {
	unlock := s.locks.lock(owner.ID)
	defer unlock()
	referenced := map[string]bool{}
	err := s.inTransaction(ctx, func(tx *sql.Tx) error {
		clear(referenced)
		known, err := queryVersions(ctx, tx, `WHERE v.user_id = $1 ORDER BY v.id`, owner.ID)
		if err != nil {
			return err
		}
		histories := map[string][]Version{}
		for _, version := range known {
			histories[version.HistoryID] = append(histories[version.HistoryID], version)
		}
		onDisk, err := s.historiesOnDisk(owner.Username)
		if err != nil {
			return err
		}
		for _, historyID := range onDisk {
			if _, found := histories[historyID]; !found {
				histories[historyID] = nil
			}
		}
		for historyID, versions := range histories {
			if err := s.reconcileHistory(ctx, tx, owner, historyID, versions, referenced); err != nil {
				return err
			}
		}
		return nil
	})
	return referenced, err
}

func (s *Service) reconcileHistory(ctx context.Context, tx *sql.Tx, owner users.User, historyID string, versions []Version, referenced map[string]bool) error {
	manifests, err := s.readManifests(owner.Username, historyID)
	if err != nil {
		return err
	}
	for _, manifest := range manifests {
		for _, chunk := range manifest.Chunks {
			referenced[chunk.Hash] = true
		}
	}
	if len(versions) == 0 {
		return s.adoptHistory(ctx, tx, owner, historyID, manifests)
	}
	if err := s.writeLocations(ctx, tx, owner, []string{historyID}); err != nil {
		return err
	}
	known := map[string]bool{}
	for _, version := range versions {
		name := manifestName(version.ReplacedAt, version.Hash)
		known[name] = true
		if _, stored := manifests[name]; stored || version.State != VersionReady {
			continue
		}
		chunks, err := versionChunks(ctx, tx, version.ID)
		if err != nil {
			return err
		}
		if err := s.writeManifest(owner.Username, version, chunks); err != nil {
			return err
		}
		for _, chunk := range chunks {
			referenced[chunk.Hash] = true
		}
	}
	target := versionTarget{FileID: versions[0].FileID, TrashID: versions[0].TrashID, TrashPath: versions[0].TrashPath}
	for _, name := range oldestFirst(manifests) {
		if known[name] {
			continue
		}
		if err := s.importVersion(ctx, tx, owner, historyID, target, manifests[name]); err != nil {
			return err
		}
	}
	return nil
}

func oldestFirst(manifests map[string]versionManifest) []string {
	names := slices.Collect(maps.Keys(manifests))
	slices.SortFunc(names, func(a, b string) int {
		left, right := manifests[a], manifests[b]
		return cmp.Or(cmp.Compare(left.ReplacedAt, right.ReplacedAt), cmp.Compare(left.ModifiedNs, right.ModifiedNs), strings.Compare(a, b))
	})
	return names
}

type versionTarget struct {
	FileID    int64
	TrashID   int64
	TrashPath string
}

func (s *Service) adoptHistory(ctx context.Context, tx *sql.Tx, owner users.User, historyID string, manifests map[string]versionManifest) error {
	if len(manifests) == 0 {
		return os.RemoveAll(s.disk.HistoryDir(owner.Username, historyID))
	}
	location, err := s.readLocation(owner.Username, historyID)
	if err != nil {
		logger.Warn("history has no readable location", "user", owner.Username, "history", historyID, "error", err)
		return nil
	}
	target, found, err := targetOf(ctx, tx, owner.ID, location)
	if err != nil || !found {
		return err
	}
	for _, name := range oldestFirst(manifests) {
		if err := s.importVersion(ctx, tx, owner, historyID, target, manifests[name]); err != nil {
			return err
		}
	}
	logger.Info("recovered file history", "user", owner.Username, "path", location.Path, "versions", len(manifests))
	return nil
}

func targetOf(ctx context.Context, q querier, userID int64, location historyLocation) (versionTarget, bool, error) {
	if location.Trash == "" {
		entry, found, err := findEntry(ctx, q, userID, location.Path)
		if err != nil || !found || entry.IsDir {
			return versionTarget{}, false, err
		}
		taken, err := hasVersions(ctx, q, `WHERE user_id = $1 AND file_id = $2`, userID, entry.ID)
		return versionTarget{FileID: entry.ID}, !taken, err
	}
	var trashID int64
	var originalPath string
	err := q.QueryRowContext(ctx, `SELECT id, original_path FROM trash WHERE user_id = $1 AND storage_id = $2`, userID, location.Trash).
		Scan(&trashID, &originalPath)
	if errors.Is(err, sql.ErrNoRows) {
		return versionTarget{}, false, nil
	}
	if err != nil {
		return versionTarget{}, false, err
	}
	trashPath := strings.TrimPrefix(location.Path, originalPath)
	if trashPath != "" && !strings.HasPrefix(trashPath, "/") {
		return versionTarget{}, false, nil
	}
	taken, err := hasVersions(ctx, q, `WHERE user_id = $1 AND trash_id = $2 AND trash_path = $3`, userID, trashID, trashPath)
	return versionTarget{TrashID: trashID, TrashPath: trashPath}, !taken, err
}

func hasVersions(ctx context.Context, q querier, condition string, args ...any) (bool, error) {
	var count int
	err := q.QueryRowContext(ctx, `SELECT COUNT(*) FROM file_versions `+condition, args...).Scan(&count)
	return count > 0, err
}

func (s *Service) importVersion(ctx context.Context, tx *sql.Tx, owner users.User, historyID string, target versionTarget, manifest versionManifest) error {
	chunks := make([]VersionChunk, 0, len(manifest.Chunks))
	for _, chunk := range manifest.Chunks {
		info, err := os.Stat(s.disk.VersionChunkPath(owner.Username, chunk.Hash))
		if err != nil {
			logger.Warn("history version is missing a chunk", "user", owner.Username, "history", historyID, "chunk", chunk.Hash)
			return nil
		}
		chunks = append(chunks, VersionChunk{Hash: chunk.Hash, Size: chunk.Size, StoredSize: info.Size(), Compressed: chunk.Compressed})
	}
	fileID := sql.NullInt64{Int64: target.FileID, Valid: target.FileID != 0}
	trashID := sql.NullInt64{Int64: target.TrashID, Valid: target.TrashID != 0}
	trashPath := sql.NullString{String: target.TrashPath, Valid: target.TrashID != 0}
	var versionID int64
	err := tx.QueryRowContext(ctx,
		`INSERT INTO file_versions (user_id, history_id, file_id, trash_id, trash_path, size, hash, modified_ns, replaced_at, state)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING id`,
		owner.ID, historyID, fileID, trashID, trashPath, manifest.Size, manifest.Hash, manifest.ModifiedNs, manifest.ReplacedAt, VersionReady).Scan(&versionID)
	if err != nil {
		return err
	}
	return insertVersionChunks(ctx, tx, owner.ID, versionID, chunks)
}
