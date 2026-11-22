package emails

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"polder-server/internal/apperr"
)

type Preferences struct {
	Security bool `json:"security" doc:"New sign-ins and changes to the email address"`
	Quota    bool `json:"quota" doc:"Storage running out"`
	Shares   bool `json:"shares" doc:"Files and folders shared with the user"`
}

type Store struct {
	db *sql.DB
}

func NewStore(db *sql.DB) *Store {
	return &Store{db: db}
}

func (s *Store) Preferences(ctx context.Context, userID int64) (Preferences, error) {
	var preferences Preferences
	err := s.db.QueryRowContext(ctx, `SELECT email_security, email_quota, email_shares FROM users WHERE id = $1`, userID).
		Scan(&preferences.Security, &preferences.Quota, &preferences.Shares)
	if errors.Is(err, sql.ErrNoRows) {
		return Preferences{}, apperr.NotFound("user not found")
	}
	return preferences, err
}

func (s *Store) SetPreferences(ctx context.Context, userID int64, preferences Preferences) error {
	_, err := s.db.ExecContext(ctx, `UPDATE users SET email_security = $1, email_quota = $2, email_shares = $3 WHERE id = $4`,
		preferences.Security, preferences.Quota, preferences.Shares, userID)
	return err
}

func (s *Store) RememberSignIn(ctx context.Context, userID int64, address string, now time.Time) (unfamiliar bool, err error) {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return false, err
	}
	defer func() { _ = tx.Rollback() }()
	var known, seen int
	err = tx.QueryRowContext(ctx,
		`SELECT COUNT(*), COALESCE(SUM(CASE WHEN address = $2 THEN 1 ELSE 0 END), 0) FROM known_sign_ins WHERE user_id = $1`,
		userID, address).Scan(&known, &seen)
	if err != nil {
		return false, err
	}
	_, err = tx.ExecContext(ctx,
		`INSERT INTO known_sign_ins (user_id, address, last_seen) VALUES ($1, $2, $3)
		 ON CONFLICT (user_id, address) DO UPDATE SET last_seen = excluded.last_seen`,
		userID, address, now.Unix())
	if err != nil {
		return false, err
	}
	return known > 0 && seen == 0, tx.Commit()
}

func (s *Store) QuotaWarningLevel(ctx context.Context, userID int64) (int, error) {
	var level int
	err := s.db.QueryRowContext(ctx, `SELECT quota_warning_level FROM users WHERE id = $1`, userID).Scan(&level)
	if errors.Is(err, sql.ErrNoRows) {
		return 0, apperr.NotFound("user not found")
	}
	return level, err
}

func (s *Store) SetQuotaWarningLevel(ctx context.Context, userID int64, level int) error {
	_, err := s.db.ExecContext(ctx, `UPDATE users SET quota_warning_level = $1 WHERE id = $2`, level, userID)
	return err
}
