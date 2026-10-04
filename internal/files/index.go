package files

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"errors"
	"path"
	"sort"
	"time"
	"unicode/utf8"

	"nomad-server/internal/storage"

	"github.com/danielgtaylor/huma/v2"
)

type ChangeType string

const (
	changeUpsert ChangeType = "upsert"
	changeDelete ChangeType = "delete"
	changeMove   ChangeType = "move"
)

func (ChangeType) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(changeUpsert), string(changeDelete), string(changeMove)}
	return s
}

const (
	entryColumns = `f.id, f.user_id, f.path, f.name, f.is_dir, f.size, f.mtime_ns, f.hash, f.rev, f.mime, f.meta_json, f.preview_state`
)

type querier interface {
	ExecContext(ctx context.Context, query string, args ...any) (sql.Result, error)
	QueryContext(ctx context.Context, query string, args ...any) (*sql.Rows, error)
	QueryRowContext(ctx context.Context, query string, args ...any) *sql.Row
}

type rowScanner interface {
	Scan(dest ...any) error
}

func pathKey(cleanPath string) string {
	sum := sha256.Sum256([]byte(cleanPath))
	return hex.EncodeToString(sum[:])
}

func scanEntry(row rowScanner) (Entry, error) {
	var entry Entry
	var mtimeNanos int64
	var metaJSON string
	err := row.Scan(&entry.ID, &entry.UserID, &entry.Path, &entry.Name, &entry.IsDir, &entry.Size, &mtimeNanos,
		&entry.Hash, &entry.Rev, &entry.Mime, &metaJSON, &entry.PreviewState)
	if err != nil {
		return Entry{}, err
	}
	entry.Mtime = time.Unix(0, mtimeNanos).UTC()
	entry.Meta = decodeMeta(metaJSON)
	return entry, nil
}

func scanEntries(rows *sql.Rows) ([]Entry, error) {
	defer rows.Close()
	entries := []Entry{}
	for rows.Next() {
		entry, err := scanEntry(rows)
		if err != nil {
			return nil, err
		}
		entries = append(entries, entry)
	}
	return entries, rows.Err()
}

func findEntry(ctx context.Context, q querier, userID int64, cleanPath string) (Entry, bool, error) {
	row := q.QueryRowContext(ctx, `SELECT `+entryColumns+` FROM files f WHERE f.user_id = ? AND f.path_key = ?`,
		userID, pathKey(cleanPath))
	entry, err := scanEntry(row)
	if errors.Is(err, sql.ErrNoRows) {
		return Entry{}, false, nil
	}
	return entry, err == nil, err
}

func listChildren(ctx context.Context, q querier, userID int64, cleanPath string) ([]Entry, error) {
	rows, err := q.QueryContext(ctx, `SELECT `+entryColumns+` FROM files f WHERE f.user_id = ? AND f.parent_key = ?`,
		userID, pathKey(cleanPath))
	if err != nil {
		return nil, err
	}
	entries, err := scanEntries(rows)
	sortForListing(entries)
	return entries, err
}

func listAll(ctx context.Context, q querier, userID int64) ([]Entry, error) {
	rows, err := q.QueryContext(ctx, `SELECT `+entryColumns+` FROM files f WHERE f.user_id = ?`, userID)
	if err != nil {
		return nil, err
	}
	return scanEntries(rows)
}

func listTree(ctx context.Context, q querier, userID int64, cleanPath string) ([]Entry, error) {
	prefix := cleanPath + "/"
	rows, err := q.QueryContext(ctx,
		`SELECT `+entryColumns+` FROM files f WHERE f.user_id = ? AND (f.path_key = ? OR SUBSTR(f.path, 1, ?) = ?)`,
		userID, pathKey(cleanPath), utf8.RuneCountInString(prefix), prefix)
	if err != nil {
		return nil, err
	}
	entries, err := scanEntries(rows)
	sort.Slice(entries, func(i, j int) bool { return len(entries[i].Path) < len(entries[j].Path) })
	return entries, err
}

func sortForListing(entries []Entry) {
	sort.Slice(entries, func(i, j int) bool {
		if entries[i].IsDir != entries[j].IsDir {
			return entries[i].IsDir
		}
		return entries[i].Name < entries[j].Name
	})
}

func recordChange(ctx context.Context, q querier, userID int64, cleanPath string, changeType ChangeType) (int64, error) {
	return insertChange(ctx, q, userID, cleanPath, changeType, sql.NullString{})
}

func insertChange(ctx context.Context, q querier, userID int64, cleanPath string, changeType ChangeType, fromPath sql.NullString) (int64, error) {
	result, err := q.ExecContext(ctx,
		`INSERT INTO changes (user_id, path, path_key, change_type, from_path, created_at) VALUES (?, ?, ?, ?, ?, ?)`,
		userID, cleanPath, pathKey(cleanPath), changeType, fromPath, time.Now().Unix())
	if err != nil {
		return 0, err
	}
	return result.LastInsertId()
}

// relocateEntry moves an indexed entry to a new path in place, so it keeps its id and cached chunks.
func relocateEntry(ctx context.Context, q querier, entry Entry, newPath string) (Entry, error) {
	rev, err := insertChange(ctx, q, entry.UserID, newPath, changeMove, sql.NullString{String: entry.Path, Valid: true})
	if err != nil {
		return Entry{}, err
	}
	_, err = q.ExecContext(ctx, `UPDATE files SET path = ?, path_key = ?, parent_key = ?, name = ?, rev = ? WHERE id = ?`,
		newPath, pathKey(newPath), pathKey(storage.ParentPath(newPath)), path.Base(newPath), rev, entry.ID)
	if err != nil {
		return Entry{}, err
	}
	if _, err := q.ExecContext(ctx, `UPDATE file_chunks SET rev = ? WHERE file_id = ? AND rev = ?`, rev, entry.ID, entry.Rev); err != nil {
		return Entry{}, err
	}
	entry.Path, entry.Name, entry.Rev = newPath, path.Base(newPath), rev
	return entry, nil
}

func saveEntry(ctx context.Context, q querier, entry Entry) (Entry, error) {
	rev, err := recordChange(ctx, q, entry.UserID, entry.Path, changeUpsert)
	if err != nil {
		return Entry{}, err
	}
	entry.Rev = rev
	metaJSON, _ := json.Marshal(entry.Meta)

	result, err := q.ExecContext(ctx,
		`UPDATE files SET is_dir = ?, size = ?, mtime_ns = ?, hash = ?, rev = ?, mime = ?, meta_json = ?, preview_state = ?
		 WHERE user_id = ? AND path_key = ?`,
		entry.IsDir, entry.Size, entry.Mtime.UnixNano(), entry.Hash, entry.Rev, entry.Mime, string(metaJSON), entry.PreviewState,
		entry.UserID, pathKey(entry.Path))
	if err != nil {
		return Entry{}, err
	}
	if updated, _ := result.RowsAffected(); updated > 0 {
		return entry, nil
	}

	_, err = q.ExecContext(ctx,
		`INSERT INTO files (user_id, path, path_key, parent_key, name, is_dir, size, mtime_ns, hash, rev, mime, meta_json, preview_state)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		entry.UserID, entry.Path, pathKey(entry.Path), pathKey(storage.ParentPath(entry.Path)), entry.Name, entry.IsDir,
		entry.Size, entry.Mtime.UnixNano(), entry.Hash, entry.Rev, entry.Mime, string(metaJSON), entry.PreviewState)
	return entry, err
}

func removeTree(ctx context.Context, q querier, userID int64, cleanPath string) error {
	if _, err := recordChange(ctx, q, userID, cleanPath, changeDelete); err != nil {
		return err
	}
	prefix := cleanPath + "/"
	_, err := q.ExecContext(ctx, `DELETE FROM files WHERE user_id = ? AND (path_key = ? OR SUBSTR(path, 1, ?) = ?)`,
		userID, pathKey(cleanPath), utf8.RuneCountInString(prefix), prefix)
	return err
}

func usedBytes(ctx context.Context, q querier, userID int64) (int64, error) {
	var used int64
	err := q.QueryRowContext(ctx, `SELECT COALESCE(SUM(size), 0) FROM files WHERE user_id = ?`, userID).Scan(&used)
	return used, err
}

func updateDerivedFields(ctx context.Context, q querier, userID int64, cleanPath, hash string, meta map[string]any, state PreviewState) error {
	metaJSON, _ := json.Marshal(meta)
	_, err := q.ExecContext(ctx, `UPDATE files SET meta_json = ?, preview_state = ? WHERE user_id = ? AND path_key = ? AND hash = ?`,
		string(metaJSON), state, userID, pathKey(cleanPath), hash)
	return err
}

func entriesWithPreviewState(ctx context.Context, q querier, state PreviewState, limit int) ([]Entry, error) {
	rows, err := q.QueryContext(ctx, `SELECT `+entryColumns+` FROM files f WHERE f.preview_state = ? LIMIT ?`, state, limit)
	if err != nil {
		return nil, err
	}
	return scanEntries(rows)
}

func decodeMeta(metaJSON string) map[string]any {
	meta := map[string]any{}
	_ = json.Unmarshal([]byte(metaJSON), &meta)
	return meta
}
