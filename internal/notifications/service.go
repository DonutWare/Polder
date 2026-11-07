package notifications

import (
	"context"
	"database/sql"
	"encoding/json"
	"time"

	"polder-server/internal/activity"
	"polder-server/internal/database"
	"polder-server/internal/logging"
)

const (
	MaxPageSize    = 200
	retention      = 30 * 24 * time.Hour
	PruneInterval  = 24 * time.Hour
	defaultPerPage = 100
)

var logger = logging.For("notifications")

type NotificationPage struct {
	Notifications []activity.Notification `json:"notifications"`
	Cursor        int64                   `json:"cursor" doc:"Pass as after to get what came next"`
	HasMore       bool                    `json:"hasMore"`
}

type payload struct {
	Share *activity.ShareNotice `json:"share,omitempty"`
}

type Publisher interface {
	Publish(event activity.Event)
}

type Service struct {
	db  *sql.DB
	hub Publisher
	now func() time.Time
}

func NewService(db *sql.DB, hub Publisher) *Service {
	return &Service{db: db, hub: hub, now: time.Now}
}

func (s *Service) ShareReceived(ctx context.Context, userIDs []int64, notice activity.ShareNotice) {
	s.notifyAll(ctx, userIDs, activity.NotificationShareReceived, payload{Share: &notice})
}

func (s *Service) FederatedShareReceived(ctx context.Context, userID int64, notice activity.ShareNotice) {
	s.notifyAll(ctx, []int64{userID}, activity.NotificationFederatedShareReceived, payload{Share: &notice})
}

func (s *Service) notifyAll(ctx context.Context, userIDs []int64, kind activity.NotificationKind, body payload) {
	for _, userID := range userIDs {
		if err := s.create(ctx, userID, kind, body); err != nil {
			logger.Warn("store a notification", "user", userID, "kind", kind, "error", err)
		}
	}
}

func (s *Service) create(ctx context.Context, userID int64, kind activity.NotificationKind, body payload) error {
	encoded, err := json.Marshal(body)
	if err != nil {
		return err
	}
	now := s.now().UTC().Truncate(time.Second)
	var id int64
	err = s.db.QueryRowContext(ctx,
		`INSERT INTO notifications (user_id, kind, payload, created_at) VALUES ($1, $2, $3, $4) RETURNING id`,
		userID, string(kind), string(encoded), now.Unix()).Scan(&id)
	if err != nil {
		return err
	}
	if s.hub != nil {
		notice := activity.Notification{ID: id, Kind: kind, CreatedAt: now, Share: body.Share}
		s.hub.Publish(activity.Event{Type: activity.EventNotification, UserID: userID, Notice: &notice})
	}
	return nil
}

func (s *Service) List(ctx context.Context, userID, after int64, limit int) (NotificationPage, error) {
	if after < 0 {
		var latest sql.NullInt64
		err := s.db.QueryRowContext(ctx, `SELECT MAX(id) FROM notifications WHERE user_id = $1`, userID).Scan(&latest)
		return NotificationPage{Notifications: []activity.Notification{}, Cursor: latest.Int64}, err
	}
	limit = pageSize(limit)
	list, err := database.QueryAll(ctx, s.db, scanNotification,
		`SELECT id, kind, payload, created_at, read_at FROM notifications WHERE user_id = $1 AND id > $2 ORDER BY id LIMIT $3`,
		userID, after, limit+1)
	if err != nil {
		return NotificationPage{}, err
	}
	page := NotificationPage{Notifications: list, Cursor: after}
	if len(list) > limit {
		page.Notifications, page.HasMore = list[:limit], true
	}
	if count := len(page.Notifications); count > 0 {
		page.Cursor = page.Notifications[count-1].ID
	}
	return page, nil
}

func pageSize(limit int) int {
	if limit <= 0 {
		return defaultPerPage
	}
	return min(limit, MaxPageSize)
}

func scanNotification(row database.RowScanner) (activity.Notification, error) {
	var notification activity.Notification
	var kind, encoded string
	var createdAt int64
	var readAt sql.NullInt64
	if err := row.Scan(&notification.ID, &kind, &encoded, &createdAt, &readAt); err != nil {
		return notification, err
	}
	var body payload
	if err := json.Unmarshal([]byte(encoded), &body); err != nil {
		return notification, err
	}
	notification.Kind = activity.NotificationKind(kind)
	notification.CreatedAt = time.Unix(createdAt, 0).UTC()
	notification.Read = readAt.Valid
	notification.Share = body.Share
	return notification, nil
}

func (s *Service) MarkRead(ctx context.Context, userID, upTo int64) error {
	_, err := s.db.ExecContext(ctx,
		`UPDATE notifications SET read_at = $1 WHERE user_id = $2 AND id <= $3 AND read_at IS NULL`,
		s.now().Unix(), userID, upTo)
	return err
}

func (s *Service) Prune(ctx context.Context) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM notifications WHERE created_at < $1`, s.now().Add(-retention).Unix())
	return err
}
