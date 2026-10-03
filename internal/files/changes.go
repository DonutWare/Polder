package files

import (
	"context"
	"database/sql"
	"time"
)

const MaxChangePageSize = 5000

type Change struct {
	Seq      int64  `json:"seq"`
	Type     string `json:"type" enum:"upsert,delete,move"`
	Path     string `json:"path"`
	FromPath string `json:"fromPath,omitempty"`
	Entry    *Entry `json:"entry" required:"false" doc:"The entry after the change; null for a delete, or when a later change superseded it"`
}

type ChangePage struct {
	Changes []Change `json:"changes"`
	Cursor  int64    `json:"cursor"`
	HasMore bool     `json:"hasMore"`
}

// Upserts are only reported while they are the entry's latest revision. Deletes and moves are always
// reported, because a client needs them to know a path went away even when a later change superseded them.
const changeFeedQuery = `SELECT c.id, c.change_type, c.path, c.from_path, ` + entryColumns + `
	FROM changes c
	LEFT JOIN files f ON f.user_id = c.user_id AND f.path_key = c.path_key AND f.rev = c.id
	WHERE c.user_id = ? AND c.id > ?
	ORDER BY c.id
	LIMIT ?`

func (s *Service) Changes(ctx context.Context, userID, cursor int64, limit int) (ChangePage, error) {
	limit = min(max(limit, 1), MaxChangePageSize)
	rows, err := s.db.QueryContext(ctx, changeFeedQuery, userID, cursor, limit+1)
	if err != nil {
		return ChangePage{}, err
	}
	defer rows.Close()

	page := ChangePage{Changes: []Change{}, Cursor: cursor}
	scanned := 0
	for rows.Next() {
		scanned++
		if scanned > limit {
			page.HasMore = true
			break
		}
		change, current, err := scanChangeRow(rows)
		if err != nil {
			return ChangePage{}, err
		}
		page.Cursor = change.Seq
		if current {
			page.Changes = append(page.Changes, change)
		}
	}
	return page, rows.Err()
}

func scanChangeRow(rows *sql.Rows) (Change, bool, error) {
	var change Change
	var id, userID, size, mtimeNanos, rev sql.NullInt64
	var fromPath, filePath, name, hash, mime, metaJSON, previewState sql.NullString
	var isDir sql.NullBool
	err := rows.Scan(&change.Seq, &change.Type, &change.Path, &fromPath,
		&id, &userID, &filePath, &name, &isDir, &size, &mtimeNanos, &hash, &rev, &mime, &metaJSON, &previewState)
	if err != nil {
		return Change{}, false, err
	}
	change.FromPath = fromPath.String
	if change.Type == changeDelete {
		return change, true, nil
	}
	if !id.Valid {
		return change, change.Type == changeMove, nil
	}
	entry := Entry{
		ID: id.Int64, UserID: userID.Int64, Path: filePath.String, Name: name.String, IsDir: isDir.Bool,
		Size: size.Int64, Mtime: time.Unix(0, mtimeNanos.Int64).UTC(), Hash: hash.String, Rev: rev.Int64,
		Mime: mime.String, PreviewState: PreviewState(previewState.String), Meta: decodeMeta(metaJSON.String),
	}
	change.Entry = &entry
	return change, true, nil
}
