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
	"strconv"
	"strings"
	"time"
	"unicode/utf8"

	"polder-server/internal/database"
	"polder-server/internal/storage"
	"polder-server/internal/users"

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
	entryColumns = `f.id, f.user_id, f.path, f.name, f.is_dir, f.size, f.mtime_ns, f.hash, f.rev, f.mime, f.meta_json, f.preview_state, f.text_state`
)

type querier interface {
	ExecContext(ctx context.Context, query string, args ...any) (sql.Result, error)
	QueryContext(ctx context.Context, query string, args ...any) (*sql.Rows, error)
	QueryRowContext(ctx context.Context, query string, args ...any) *sql.Row
}

func pathKey(cleanPath string) string {
	sum := sha256.Sum256([]byte(cleanPath))
	return hex.EncodeToString(sum[:])
}

func scanEntry(row database.RowScanner) (Entry, error) {
	var entry Entry
	var mtimeNanos int64
	var metaJSON string
	err := row.Scan(&entry.ID, &entry.UserID, &entry.Path, &entry.Name, &entry.IsDir, &entry.Size, &mtimeNanos,
		&entry.Hash, &entry.Rev, &entry.Mime, &metaJSON, &entry.PreviewState, &entry.TextState)
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
	row := q.QueryRowContext(ctx, `SELECT `+entryColumns+` FROM files f WHERE f.user_id = $1 AND f.path_key = $2`,
		userID, pathKey(cleanPath))
	entry, err := scanEntry(row)
	if errors.Is(err, sql.ErrNoRows) {
		return Entry{}, false, nil
	}
	return entry, err == nil, err
}

func listChildren(ctx context.Context, q querier, userID int64, cleanPath string) ([]Entry, error) {
	rows, err := q.QueryContext(ctx, `SELECT `+entryColumns+` FROM files f WHERE f.user_id = $1 AND f.parent_key = $2`,
		userID, pathKey(cleanPath))
	if err != nil {
		return nil, err
	}
	entries, err := scanEntries(rows)
	if err != nil {
		return nil, err
	}
	if err := fillFolderSizes(ctx, q, userID, cleanPath, entries); err != nil {
		return nil, err
	}
	SortForListing(entries)
	return entries, nil
}

func descendantPrefix(cleanPath string) string {
	if cleanPath == storage.RootPath {
		return storage.RootPath
	}
	return cleanPath + "/"
}

func fillFolderSizes(ctx context.Context, q querier, userID int64, cleanPath string, entries []Entry) error {
	prefix := descendantPrefix(cleanPath)
	rows, err := q.QueryContext(ctx,
		`SELECT path, size FROM files WHERE user_id = $1 AND is_dir = FALSE AND SUBSTR(path, 1, $2) = $3`,
		userID, utf8.RuneCountInString(prefix), prefix)
	if err != nil {
		return err
	}
	defer rows.Close()
	sizes := map[string]int64{}
	for rows.Next() {
		var filePath string
		var size int64
		if err := rows.Scan(&filePath, &size); err != nil {
			return err
		}
		if child, _, nested := strings.Cut(strings.TrimPrefix(filePath, prefix), "/"); nested {
			sizes[child] += size
		}
	}
	if err := rows.Err(); err != nil {
		return err
	}
	for i := range entries {
		if entries[i].IsDir {
			entries[i].Size = sizes[entries[i].Name]
		}
	}
	return nil
}

func listAll(ctx context.Context, q querier, userID int64) ([]Entry, error) {
	rows, err := q.QueryContext(ctx, `SELECT `+entryColumns+` FROM files f WHERE f.user_id = $1`, userID)
	if err != nil {
		return nil, err
	}
	return scanEntries(rows)
}

func listTree(ctx context.Context, q querier, userID int64, cleanPath string) ([]Entry, error) {
	prefix := cleanPath + "/"
	rows, err := q.QueryContext(ctx,
		`SELECT `+entryColumns+` FROM files f WHERE f.user_id = $1 AND (f.path_key = $2 OR SUBSTR(f.path, 1, $3) = $4)`,
		userID, pathKey(cleanPath), utf8.RuneCountInString(prefix), prefix)
	if err != nil {
		return nil, err
	}
	entries, err := scanEntries(rows)
	sort.Slice(entries, func(i, j int) bool { return len(entries[i].Path) < len(entries[j].Path) })
	return entries, err
}

const entriesByIDBatch = 500

func entriesByID(ctx context.Context, q querier, userID int64, ids []int64) (map[int64]Entry, error) {
	found := make(map[int64]Entry, len(ids))
	for len(ids) > 0 {
		batch := ids[:min(len(ids), entriesByIDBatch)]
		ids = ids[len(batch):]
		args := make([]any, 0, len(batch)+1)
		args = append(args, userID)
		placeholders := make([]string, 0, len(batch))
		for _, id := range batch {
			args = append(args, id)
			placeholders = append(placeholders, "$"+strconv.Itoa(len(args)))
		}
		rows, err := q.QueryContext(ctx, `SELECT `+entryColumns+` FROM files f WHERE f.user_id = $1 AND f.id IN (`+strings.Join(placeholders, ",")+`)`, args...)
		if err != nil {
			return nil, err
		}
		entries, err := scanEntries(rows)
		if err != nil {
			return nil, err
		}
		for _, entry := range entries {
			found[entry.ID] = entry
		}
	}
	return found, nil
}

func SortForListing(entries []Entry) {
	sort.Slice(entries, func(i, j int) bool {
		if entries[i].IsDir != entries[j].IsDir {
			return entries[i].IsDir
		}
		return entries[i].Name < entries[j].Name
	})
}

func recordChange(ctx context.Context, q querier, userID int64, cleanPath string, changeType ChangeType) (int64, error) {
	return insertChange(ctx, q, userID, cleanPath, changeType, sql.NullString{}, sql.NullInt64{})
}

func insertChange(ctx context.Context, q querier, userID int64, cleanPath string, changeType ChangeType, fromPath sql.NullString, fileID sql.NullInt64) (int64, error) {
	var id int64
	err := q.QueryRowContext(ctx,
		`INSERT INTO changes (user_id, path, path_key, change_type, from_path, file_id, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`,
		userID, cleanPath, pathKey(cleanPath), changeType, fromPath, fileID, time.Now().Unix()).Scan(&id)
	return id, err
}

// relocateEntry moves an indexed entry to a new path in place, so it keeps its id and cached chunks.
func relocateEntry(ctx context.Context, q querier, entry Entry, newPath string) (Entry, error) {
	rev, err := insertChange(ctx, q, entry.UserID, newPath, changeMove, sql.NullString{String: entry.Path, Valid: true}, sql.NullInt64{})
	if err != nil {
		return Entry{}, err
	}
	_, err = q.ExecContext(ctx, `UPDATE files SET path = $1, path_key = $2, parent_key = $3, name = $4, rev = $5 WHERE id = $6`,
		newPath, pathKey(newPath), pathKey(storage.ParentPath(newPath)), path.Base(newPath), rev, entry.ID)
	if err != nil {
		return Entry{}, err
	}
	if _, err := q.ExecContext(ctx, `UPDATE file_chunks SET rev = $1 WHERE file_id = $2 AND rev = $3`, rev, entry.ID, entry.Rev); err != nil {
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

	err = q.QueryRowContext(ctx,
		`UPDATE files SET is_dir = $1, size = $2, mtime_ns = $3, hash = $4, rev = $5, mime = $6, meta_json = $7, preview_state = $8, text_state = $9
		 WHERE user_id = $10 AND path_key = $11 RETURNING id`,
		entry.IsDir, entry.Size, entry.Mtime.UnixNano(), entry.Hash, entry.Rev, entry.Mime, string(metaJSON), entry.PreviewState, entry.TextState,
		entry.UserID, pathKey(entry.Path)).Scan(&entry.ID)
	if err == nil {
		return entry, nil
	}
	if !errors.Is(err, sql.ErrNoRows) {
		return Entry{}, err
	}

	if entry.ID != 0 {
		var taken bool
		if err := q.QueryRowContext(ctx, `SELECT EXISTS (SELECT 1 FROM files WHERE id = $1)`, entry.ID).Scan(&taken); err != nil {
			return Entry{}, err
		}
		if !taken {
			_, err = q.ExecContext(ctx,
				`INSERT INTO files (id, user_id, path, path_key, parent_key, name, is_dir, size, mtime_ns, hash, rev, mime, meta_json, preview_state, text_state)
				 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)`,
				entry.ID, entry.UserID, entry.Path, pathKey(entry.Path), pathKey(storage.ParentPath(entry.Path)), entry.Name, entry.IsDir,
				entry.Size, entry.Mtime.UnixNano(), entry.Hash, entry.Rev, entry.Mime, string(metaJSON), entry.PreviewState, entry.TextState)
			return entry, err
		}
	}
	err = q.QueryRowContext(ctx,
		`INSERT INTO files (user_id, path, path_key, parent_key, name, is_dir, size, mtime_ns, hash, rev, mime, meta_json, preview_state, text_state)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) RETURNING id`,
		entry.UserID, entry.Path, pathKey(entry.Path), pathKey(storage.ParentPath(entry.Path)), entry.Name, entry.IsDir,
		entry.Size, entry.Mtime.UnixNano(), entry.Hash, entry.Rev, entry.Mime, string(metaJSON), entry.PreviewState, entry.TextState).Scan(&entry.ID)
	return entry, err
}

func (s *Service) removeTree(ctx context.Context, q querier, owner users.User, cleanPath string) error {
	var fileID sql.NullInt64
	err := q.QueryRowContext(ctx, `SELECT id FROM files WHERE user_id = $1 AND path_key = $2`, owner.ID, pathKey(cleanPath)).Scan(&fileID)
	if err != nil && !errors.Is(err, sql.ErrNoRows) {
		return err
	}
	if _, err := insertChange(ctx, q, owner.ID, cleanPath, changeDelete, sql.NullString{}, fileID); err != nil {
		return err
	}
	if err := s.removeVersionsOfTree(ctx, q, owner, cleanPath); err != nil {
		return err
	}
	prefix := cleanPath + "/"
	_, err = q.ExecContext(ctx, `DELETE FROM files WHERE user_id = $1 AND (path_key = $2 OR SUBSTR(path, 1, $3) = $4)`,
		owner.ID, pathKey(cleanPath), utf8.RuneCountInString(prefix), prefix)
	return err
}

func updateDerivedFields(ctx context.Context, q querier, userID int64, cleanPath, hash string, meta map[string]any, state PreviewState) error {
	metaJSON, _ := json.Marshal(meta)
	_, err := q.ExecContext(ctx, `UPDATE files SET meta_json = $1, preview_state = $2 WHERE user_id = $3 AND path_key = $4 AND hash = $5`,
		string(metaJSON), state, userID, pathKey(cleanPath), hash)
	return err
}

func entriesWithPreviewState(ctx context.Context, q querier, state PreviewState, limit int) ([]Entry, error) {
	rows, err := q.QueryContext(ctx, `SELECT `+entryColumns+` FROM files f WHERE f.preview_state = $1 LIMIT $2`, state, limit)
	if err != nil {
		return nil, err
	}
	return scanEntries(rows)
}

func mimesWithoutPreview(ctx context.Context, q querier) ([]string, error) {
	rows, err := q.QueryContext(ctx, `SELECT DISTINCT mime FROM files WHERE preview_state = $1 AND is_dir = FALSE`, PreviewNone)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var mimes []string
	for rows.Next() {
		var mimeType string
		if err := rows.Scan(&mimeType); err != nil {
			return nil, err
		}
		mimes = append(mimes, mimeType)
	}
	return mimes, rows.Err()
}

func requestPreviews(ctx context.Context, q querier, mimeType string) (int64, error) {
	result, err := q.ExecContext(ctx, `UPDATE files SET preview_state = $1 WHERE preview_state = $2 AND mime = $3 AND is_dir = FALSE`,
		PreviewPending, PreviewNone, mimeType)
	if err != nil {
		return 0, err
	}
	return result.RowsAffected()
}

func updateTextState(ctx context.Context, q querier, userID int64, cleanPath, hash string, state TextState) error {
	_, err := q.ExecContext(ctx, `UPDATE files SET text_state = $1 WHERE user_id = $2 AND path_key = $3 AND hash = $4`,
		state, userID, pathKey(cleanPath), hash)
	return err
}

func entriesWithTextState(ctx context.Context, q querier, state TextState, limit int, excludedMimePatterns []string) ([]Entry, error) {
	query := `SELECT ` + entryColumns + ` FROM files f WHERE f.text_state = $1`
	args := []any{state}
	for _, pattern := range excludedMimePatterns {
		args = append(args, pattern)
		query += ` AND f.mime NOT LIKE $` + strconv.Itoa(len(args))
	}
	args = append(args, limit)
	rows, err := q.QueryContext(ctx, query+` ORDER BY f.id LIMIT $`+strconv.Itoa(len(args)), args...)
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
