package calendar

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
	"polder-server/internal/users"
)

const inboxRetention = 30 * 24 * time.Hour

type InboxItem struct {
	ID        int64     `json:"id"`
	URI       string    `json:"uri"`
	Method    string    `json:"method" doc:"REQUEST, REPLY or CANCEL"`
	UID       string    `json:"uid"`
	Sender    string    `json:"sender"`
	Summary   string    `json:"summary"`
	CreatedAt time.Time `json:"createdAt"`
	ETag      string    `json:"-"`
	Data      []byte    `json:"-"`
}

func inboxItemNotFound() error {
	return apperr.NotFound("inbox item not found")
}

func scanInboxItem(row database.RowScanner) (InboxItem, error) {
	var item InboxItem
	var data string
	var createdAt int64
	err := row.Scan(&item.ID, &item.URI, &item.Method, &item.UID, &item.Sender, &item.Summary, &data, &item.ETag, &createdAt)
	item.Data = []byte(data)
	item.CreatedAt = time.Unix(createdAt, 0).UTC()
	return item, err
}

const inboxColumns = `id, uri, method, uid, sender, summary, data, etag, created_at`

func (s *Store) AddInbox(ctx context.Context, userID int64, message itipMessage, data []byte) error {
	_, err := s.db.ExecContext(ctx,
		`INSERT INTO calendar_inbox (user_id, uri, method, uid, sender, summary, data, etag, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
		userID, randomHex(16)+".ics", message.method, message.uid, message.sender, truncate(message.summary, maxSummaryLength),
		string(data), etagOf(data), time.Now().Unix())
	return err
}

func (s *Store) Inbox(ctx context.Context, userID int64) ([]InboxItem, error) {
	return database.QueryAll(ctx, s.db, scanInboxItem,
		`SELECT `+inboxColumns+` FROM calendar_inbox WHERE user_id = $1 ORDER BY created_at DESC, id DESC`, userID)
}

func (s *Store) InboxItem(ctx context.Context, userID int64, uri string) (InboxItem, error) {
	item, err := scanInboxItem(s.db.QueryRowContext(ctx,
		`SELECT `+inboxColumns+` FROM calendar_inbox WHERE user_id = $1 AND uri = $2`, userID, uri))
	if errors.Is(err, sql.ErrNoRows) {
		return InboxItem{}, inboxItemNotFound()
	}
	return item, err
}

func (s *Store) DeleteInboxItem(ctx context.Context, userID int64, uri string) error {
	return database.RequireAffected(inboxItemNotFound())(s.db.ExecContext(ctx,
		`DELETE FROM calendar_inbox WHERE user_id = $1 AND uri = $2`, userID, uri))
}

func (s *Store) PruneInbox(ctx context.Context, before time.Time) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM calendar_inbox WHERE created_at < $1`, before.Unix())
	return err
}

func (s *Service) Inbox(ctx context.Context, viewer users.User) ([]InboxItem, error) {
	return s.store.Inbox(ctx, viewer.ID)
}

func (s *Service) InboxItem(ctx context.Context, viewer users.User, uri string) (InboxItem, error) {
	return s.store.InboxItem(ctx, viewer.ID, uri)
}

func (s *Service) DeleteInboxItem(ctx context.Context, viewer users.User, uri string) error {
	return s.store.DeleteInboxItem(ctx, viewer.ID, uri)
}
