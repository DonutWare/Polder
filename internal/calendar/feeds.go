package calendar

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"database/sql"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"strconv"
	"strings"
	"time"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
	"polder-server/internal/users"
)

const (
	FeedPathPrefix = "/ical/"
	feedSuffix     = ".ics"
	feedTokenBytes = 32
	maxFeeds       = 20
)

type FeedMode string

const (
	FeedFull FeedMode = "full"
	FeedBusy FeedMode = "busy"
)

func (FeedMode) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(FeedFull), string(FeedBusy)}
	return s
}

type Feed struct {
	ID         int64      `json:"id"`
	CalendarID int64      `json:"calendarId"`
	Name       string     `json:"name"`
	Mode       FeedMode   `json:"mode" doc:"full shares every detail; busy only shows when the calendar is busy"`
	CreatedAt  time.Time  `json:"createdAt"`
	LastUsedAt *time.Time `json:"lastUsedAt,omitempty" required:"false"`
	URL        string     `json:"url,omitempty" required:"false" doc:"The secret address; only returned when the feed is created"`
	WebcalURL  string     `json:"webcalUrl,omitempty" required:"false" doc:"The same address for calendar apps that open webcal:// links"`
}

type NewFeed struct {
	Name string   `json:"name,omitempty" required:"false" maxLength:"128"`
	Mode FeedMode `json:"mode"`
}

type RenderedFeed struct {
	Data         []byte
	ETag         string
	LastModified time.Time
	Name         string
}

func feedNotFound() error {
	return apperr.NotFound("feed not found")
}

func hashFeedToken(token string) string {
	sum := sha256.Sum256([]byte(token))
	return hex.EncodeToString(sum[:])
}

func (s *Service) Feeds(ctx context.Context, viewer users.User, calendarID int64) ([]Feed, error) {
	if _, err := s.ownedCalendar(ctx, viewer, calendarID); err != nil {
		return nil, err
	}
	return s.store.Feeds(ctx, calendarID)
}

func (s *Service) CreateFeed(ctx context.Context, viewer users.User, calendarID int64, request NewFeed) (Feed, error) {
	if _, err := s.ownedCalendar(ctx, viewer, calendarID); err != nil {
		return Feed{}, err
	}
	if request.Mode != FeedFull && request.Mode != FeedBusy {
		return Feed{}, apperr.Invalid("mode is full or busy")
	}
	existing, err := s.store.Feeds(ctx, calendarID)
	if err != nil {
		return Feed{}, err
	}
	if len(existing) >= maxFeeds {
		return Feed{}, apperr.Invalid("a calendar has at most %d secret addresses", maxFeeds)
	}
	secret := make([]byte, feedTokenBytes)
	if _, err := rand.Read(secret); err != nil {
		return Feed{}, err
	}
	token := base64.RawURLEncoding.EncodeToString(secret)
	feed := Feed{CalendarID: calendarID, Name: strings.TrimSpace(request.Name), Mode: request.Mode}
	if feed.ID, err = s.store.InsertFeed(ctx, feed, hashFeedToken(token)); err != nil {
		return Feed{}, err
	}
	created, err := s.store.Feed(ctx, calendarID, feed.ID)
	if err != nil {
		return Feed{}, err
	}
	created.URL, created.WebcalURL = s.feedURLs(token)
	return created, nil
}

func (s *Service) feedURLs(token string) (string, string) {
	base := strings.TrimSuffix(s.options.PublicURL, "/")
	address := base + FeedPathPrefix + token + feedSuffix
	webcal := address
	for _, scheme := range []string{"https://", "http://"} {
		if rest, ok := strings.CutPrefix(address, scheme); ok {
			webcal = "webcal://" + rest
		}
	}
	return address, webcal
}

func (s *Service) DeleteFeed(ctx context.Context, viewer users.User, calendarID, feedID int64) error {
	if _, err := s.ownedCalendar(ctx, viewer, calendarID); err != nil {
		return err
	}
	return s.store.DeleteFeed(ctx, calendarID, feedID)
}

func (s *Service) RenderFeed(ctx context.Context, token string) (RenderedFeed, error) {
	token = strings.TrimSuffix(token, feedSuffix)
	if token == "" || len(token) > 128 {
		return RenderedFeed{}, feedNotFound()
	}
	feed, calendarID, err := s.store.FeedByHash(ctx, hashFeedToken(token))
	if err != nil {
		return RenderedFeed{}, err
	}
	c, err := s.store.CalendarByID(ctx, calendarID)
	if err != nil {
		return RenderedFeed{}, err
	}
	s.store.NoteFeedUse(ctx, feed.ID)
	rendered := RenderedFeed{
		ETag:         `"` + strconv.FormatInt(c.ID, 10) + "-" + strconv.FormatInt(c.SyncRevision, 10) + "-" + string(feed.Mode) + `"`,
		LastModified: c.UpdatedAt,
		Name:         c.Name,
	}
	rendered.Data, err = s.render(ctx, c, feed.Mode == FeedBusy)
	return rendered, err
}

func scanFeed(row database.RowScanner) (Feed, error) {
	var feed Feed
	var createdAt int64
	var lastUsed sql.NullInt64
	err := row.Scan(&feed.ID, &feed.CalendarID, &feed.Name, &feed.Mode, &createdAt, &lastUsed)
	feed.CreatedAt = time.Unix(createdAt, 0).UTC()
	if lastUsed.Valid {
		used := time.Unix(lastUsed.Int64, 0).UTC()
		feed.LastUsedAt = &used
	}
	return feed, err
}

const feedColumns = `id, calendar_id, name, mode, created_at, last_used_at`

func (s *Store) Feeds(ctx context.Context, calendarID int64) ([]Feed, error) {
	return database.QueryAll(ctx, s.db, scanFeed, `SELECT `+feedColumns+` FROM calendar_feeds WHERE calendar_id = $1 ORDER BY id`, calendarID)
}

func (s *Store) Feed(ctx context.Context, calendarID, feedID int64) (Feed, error) {
	feed, err := scanFeed(s.db.QueryRowContext(ctx, `SELECT `+feedColumns+` FROM calendar_feeds WHERE calendar_id = $1 AND id = $2`, calendarID, feedID))
	if errors.Is(err, sql.ErrNoRows) {
		return Feed{}, feedNotFound()
	}
	return feed, err
}

func (s *Store) FeedByHash(ctx context.Context, hash string) (Feed, int64, error) {
	feed, err := scanFeed(s.db.QueryRowContext(ctx, `SELECT `+feedColumns+` FROM calendar_feeds WHERE secret_hash = $1`, hash))
	if errors.Is(err, sql.ErrNoRows) {
		return Feed{}, 0, feedNotFound()
	}
	return feed, feed.CalendarID, err
}

func (s *Store) InsertFeed(ctx context.Context, feed Feed, hash string) (int64, error) {
	var id int64
	err := s.db.QueryRowContext(ctx,
		`INSERT INTO calendar_feeds (calendar_id, secret_hash, mode, name, created_at) VALUES ($1, $2, $3, $4, $5) RETURNING id`,
		feed.CalendarID, hash, feed.Mode, feed.Name, time.Now().Unix()).Scan(&id)
	return id, err
}

func (s *Store) DeleteFeed(ctx context.Context, calendarID, feedID int64) error {
	return database.RequireAffected(feedNotFound())(s.db.ExecContext(ctx,
		`DELETE FROM calendar_feeds WHERE calendar_id = $1 AND id = $2`, calendarID, feedID))
}

func (s *Store) NoteFeedUse(ctx context.Context, feedID int64) {
	if _, err := s.db.ExecContext(ctx, `UPDATE calendar_feeds SET last_used_at = $1 WHERE id = $2`, time.Now().Unix(), feedID); err != nil {
		logger.Warn("note that a calendar feed was read", "feed", feedID, "error", err)
	}
}
