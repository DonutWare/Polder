package activity

import (
	"context"
	"database/sql"
	"strconv"
	"strings"
	"time"

	"polder-server/internal/database"
)

const (
	Retention        = 30 * 24 * time.Hour
	DefaultPageSize  = 50
	MaxPageSize      = 200
	selectEntryQuery = `SELECT a.id, a.user_id, u.username, a.device, a.via, a.kind, a.path, a.from_path, a.is_dir,
	a.size, a.bytes, a.duration_ms, a.item_count, a.status, a.detail, a.created_at
	FROM activity a JOIN users u ON u.id = a.user_id`
)

type LogEntry struct {
	ID         int64     `json:"id"`
	UserID     int64     `json:"userId"`
	Username   string    `json:"username"`
	Device     string    `json:"device" doc:"Device that did it, or server for the server's own work"`
	Via        string    `json:"via,omitempty" required:"false" doc:"Who acted through a share: another user's username, or link:<code> for a public link"`
	Kind       Kind      `json:"kind"`
	Path       string    `json:"path"`
	FromPath   string    `json:"fromPath,omitempty" required:"false" doc:"Where a moved or restored item came from"`
	IsDir      bool      `json:"isDir"`
	Size       *int64    `json:"size,omitempty" required:"false" doc:"Size of the file or items involved"`
	Bytes      *int64    `json:"bytes,omitempty" required:"false" doc:"Bytes sent over the network; less than size when delta sync reused chunks"`
	DurationMs *int64    `json:"durationMs,omitempty" required:"false"`
	Count      *int64    `json:"count,omitempty" required:"false" doc:"Number of items for trash operations and rescan summaries"`
	Status     Status    `json:"status"`
	Detail     string    `json:"detail" doc:"Error message, or for a rescan: added, changed, removed or summary"`
	CreatedAt  time.Time `json:"createdAt"`
	sessionID  int64
}

type LogPage struct {
	Entries    []LogEntry `json:"entries"`
	NextCursor int64      `json:"nextCursor" doc:"Pass as before for the next page; 0 when there are no more"`
}

type Filter struct {
	UserID int64
	Before int64
	Limit  int
}

type Store struct {
	db *sql.DB
}

func NewStore(db *sql.DB) *Store {
	return &Store{db: db}
}

func (s *Store) Insert(ctx context.Context, entry LogEntry) (LogEntry, error) {
	if entry.CreatedAt.IsZero() {
		entry.CreatedAt = time.Now().UTC().Truncate(time.Second)
	}
	err := s.db.QueryRowContext(ctx,
		`INSERT INTO activity (user_id, session_id, device, via, kind, path, from_path, is_dir, size, bytes, duration_ms, item_count, status, detail, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
		RETURNING id`,
		entry.UserID, database.NullIfZero(entry.sessionID), entry.Device, entry.Via, entry.Kind, entry.Path, entry.FromPath, entry.IsDir,
		database.NullIfNil(entry.Size), database.NullIfNil(entry.Bytes), database.NullIfNil(entry.DurationMs), database.NullIfNil(entry.Count),
		entry.Status, entry.Detail, entry.CreatedAt.Unix()).Scan(&entry.ID)
	if err != nil || entry.Username != "" {
		return entry, err
	}
	err = s.db.QueryRowContext(ctx, `SELECT username FROM users WHERE id = $1`, entry.UserID).Scan(&entry.Username)
	return entry, err
}

func (s *Store) List(ctx context.Context, filter Filter) (LogPage, error) {
	limit := filter.Limit
	if limit <= 0 {
		limit = DefaultPageSize
	}
	limit = min(limit, MaxPageSize)

	var conditions []string
	var args []any
	if filter.UserID != 0 {
		args = append(args, filter.UserID)
		conditions = append(conditions, "a.user_id = $"+strconv.Itoa(len(args)))
	}
	if filter.Before > 0 {
		args = append(args, filter.Before)
		conditions = append(conditions, "a.id < $"+strconv.Itoa(len(args)))
	}
	query := selectEntryQuery
	if len(conditions) > 0 {
		query += " WHERE " + strings.Join(conditions, " AND ")
	}
	args = append(args, limit+1)
	query += " ORDER BY a.id DESC LIMIT $" + strconv.Itoa(len(args))

	rows, err := s.db.QueryContext(ctx, query, args...)
	if err != nil {
		return LogPage{}, err
	}
	defer rows.Close()
	page := LogPage{Entries: []LogEntry{}}
	for rows.Next() {
		entry, err := scanEntry(rows)
		if err != nil {
			return LogPage{}, err
		}
		page.Entries = append(page.Entries, entry)
	}
	if err := rows.Err(); err != nil {
		return LogPage{}, err
	}
	if len(page.Entries) > limit {
		page.Entries = page.Entries[:limit]
		page.NextCursor = page.Entries[limit-1].ID
	}
	return page, nil
}

func (s *Store) PurgeOlderThan(ctx context.Context, cutoff time.Time) (int64, error) {
	result, err := s.db.ExecContext(ctx, `DELETE FROM activity WHERE created_at < $1`, cutoff.Unix())
	if err != nil {
		return 0, err
	}
	return result.RowsAffected()
}

func scanEntry(rows *sql.Rows) (LogEntry, error) {
	var entry LogEntry
	var size, bytes, duration, count sql.NullInt64
	var createdAt int64
	err := rows.Scan(&entry.ID, &entry.UserID, &entry.Username, &entry.Device, &entry.Via, &entry.Kind, &entry.Path, &entry.FromPath,
		&entry.IsDir, &size, &bytes, &duration, &count, &entry.Status, &entry.Detail, &createdAt)
	entry.Size = pointerOf(size)
	entry.Bytes = pointerOf(bytes)
	entry.DurationMs = pointerOf(duration)
	entry.Count = pointerOf(count)
	entry.CreatedAt = time.Unix(createdAt, 0).UTC()
	return entry, err
}

func pointerOf(value sql.NullInt64) *int64 {
	if !value.Valid {
		return nil
	}
	return &value.Int64
}

func ptr(value int64) *int64 {
	return &value
}
