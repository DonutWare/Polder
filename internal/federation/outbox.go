package federation

import (
	"context"
	"encoding/json"
	"strconv"
	"time"

	"polder-server/internal/database"
)

const (
	outboxInterval    = time.Minute
	outboxBatch       = 50
	maxOutboxAttempts = 12
	maxOutboxBackoff  = 6 * time.Hour
	outboxSealContext = "federation-outbox"
	notificationsPath = "/notifications"
)

func notificationPayload(kind, providerID, secret, message string) map[string]any {
	return map[string]any{
		"notificationType": kind,
		"resourceType":     "file",
		"providerId":       providerID,
		"notification":     map[string]any{"sharedSecret": secret, "message": message},
	}
}

func (s *Service) enqueueNotification(ctx context.Context, serverID int64, payload map[string]any) error {
	body, err := json.Marshal(payload)
	if err != nil {
		return err
	}
	now := s.now().Unix()
	_, err = s.db.ExecContext(ctx,
		`INSERT INTO federation_outbox (server_id, body_sealed, attempts, next_attempt_at, created_at) VALUES ($1, $2, 0, $3, $3)`,
		serverID, s.box.seal(string(body), outboxSealContext), now)
	if err != nil {
		return err
	}
	select {
	case s.outboxWake <- struct{}{}:
	default:
	}
	return nil
}

type outboxItem struct {
	id       int64
	serverID int64
	sealed   string
	attempts int
}

func scanOutboxItem(row database.RowScanner) (outboxItem, error) {
	var item outboxItem
	err := row.Scan(&item.id, &item.serverID, &item.sealed, &item.attempts)
	return item, err
}

func (s *Service) Run(ctx context.Context) {
	ticker := time.NewTicker(outboxInterval)
	defer ticker.Stop()
	for {
		if err := s.DeliverNotifications(ctx); err != nil && ctx.Err() == nil {
			logger.Warn("deliver federation notifications", "error", err)
		}
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
		case <-s.outboxWake:
		}
	}
}

func (s *Service) DeliverNotifications(ctx context.Context) error {
	if !s.Configured() {
		return nil
	}
	items, err := database.QueryAll(ctx, s.db, scanOutboxItem,
		`SELECT id, server_id, body_sealed, attempts FROM federation_outbox WHERE next_attempt_at <= $1 ORDER BY id LIMIT `+strconv.Itoa(outboxBatch),
		s.now().Unix())
	if err != nil {
		return err
	}
	for _, item := range items {
		s.deliver(ctx, item)
	}
	return nil
}

func (s *Service) deliver(ctx context.Context, item outboxItem) {
	body, err := s.box.open(item.sealed, outboxSealContext)
	if err != nil {
		s.dropOutboxItem(ctx, item.id)
		return
	}
	server, err := s.servers.byID(ctx, item.serverID)
	if err != nil {
		s.dropOutboxItem(ctx, item.id)
		return
	}
	response, err := s.postOCM(ctx, server, notificationsPath, json.RawMessage(body))
	if err == nil && response.status >= 200 && response.status < 300 {
		s.dropOutboxItem(ctx, item.id)
		return
	}
	if err == nil && response.status >= 400 && response.status < 500 && response.status != 429 {
		logger.Warn("remote server rejected a notification", "remote", server.Remote, "status", response.status, "message", remoteMessage(response.body))
		s.dropOutboxItem(ctx, item.id)
		return
	}
	attempts := item.attempts + 1
	if attempts >= maxOutboxAttempts {
		logger.Warn("giving up on a federation notification", "remote", server.Remote, "attempts", attempts)
		s.dropOutboxItem(ctx, item.id)
		return
	}
	backoff := min(time.Duration(1<<attempts)*time.Minute, maxOutboxBackoff)
	_, _ = s.db.ExecContext(ctx, `UPDATE federation_outbox SET attempts = $1, next_attempt_at = $2 WHERE id = $3`,
		attempts, s.now().Add(backoff).Unix(), item.id)
}

func (s *Service) dropOutboxItem(ctx context.Context, id int64) {
	if _, err := s.db.ExecContext(ctx, `DELETE FROM federation_outbox WHERE id = $1`, id); err != nil {
		logger.Warn("remove delivered notification", "error", err)
	}
}
