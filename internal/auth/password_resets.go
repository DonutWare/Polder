package auth

import (
	"context"
	"crypto/rand"
	"crypto/subtle"
	"database/sql"
	"errors"
	"strings"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

const (
	PasswordResetLifetime = time.Hour
	MaxResetCodeAttempts  = 5

	resetCodeAlphabet = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"
	resetCodeLength   = 8
)

type PasswordResets struct {
	db  *sql.DB
	now func() time.Time
}

func NewPasswordResets(db *sql.DB) *PasswordResets {
	return &PasswordResets{db: db, now: time.Now}
}

func (r *PasswordResets) Issue(ctx context.Context, userID int64) (string, error) {
	code := newResetCode()
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return "", err
	}
	defer func() { _ = tx.Rollback() }()
	if _, err := tx.ExecContext(ctx, `DELETE FROM password_resets WHERE user_id = $1 OR expires_at <= $2`, userID, r.now().Unix()); err != nil {
		return "", err
	}
	_, err = tx.ExecContext(ctx, `INSERT INTO password_resets (user_id, code_hash, expires_at) VALUES ($1, $2, $3)`,
		userID, hashToken(code), r.now().Add(PasswordResetLifetime).Unix())
	if err != nil {
		return "", err
	}
	return FormatResetCode(code), tx.Commit()
}

func (r *PasswordResets) ConsumeCode(ctx context.Context, userID int64, code string) error {
	var id int64
	var codeHash string
	err := r.db.QueryRowContext(ctx, `SELECT id, code_hash FROM password_resets WHERE user_id = $1 AND expires_at > $2`,
		userID, r.now().Unix()).Scan(&id, &codeHash)
	if errors.Is(err, sql.ErrNoRows) {
		return errInvalidResetCode
	}
	if err != nil {
		return err
	}
	if subtle.ConstantTimeCompare([]byte(hashToken(normalizeResetCode(code))), []byte(codeHash)) != 1 {
		return r.failCode(ctx, id)
	}
	return r.forget(ctx, userID)
}

func (r *PasswordResets) failCode(ctx context.Context, id int64) error {
	_, err := r.db.ExecContext(ctx, `UPDATE password_resets SET failed_attempts = failed_attempts + 1 WHERE id = $1`, id)
	if err != nil {
		return err
	}
	_, err = r.db.ExecContext(ctx, `DELETE FROM password_resets WHERE id = $1 AND failed_attempts >= $2`, id, MaxResetCodeAttempts)
	if err != nil {
		return err
	}
	return errInvalidResetCode
}

func (r *PasswordResets) forget(ctx context.Context, userID int64) error {
	_, err := r.db.ExecContext(ctx, `DELETE FROM password_resets WHERE user_id = $1`, userID)
	return err
}

var errInvalidResetCode = apperr.Invalid("this code is wrong or has expired")

func newResetCode() string {
	code := make([]byte, resetCodeLength)
	for i := range code {
		code[i] = resetCodeAlphabet[randomIndex(len(resetCodeAlphabet))]
	}
	return string(code)
}

func randomIndex(size int) int {
	limit := 256 - 256%size
	buffer := make([]byte, 1)
	for {
		_, _ = rand.Read(buffer)
		if int(buffer[0]) < limit {
			return int(buffer[0]) % size
		}
	}
}

func FormatResetCode(code string) string {
	half := len(code) / 2
	return code[:half] + "-" + code[half:]
}

func normalizeResetCode(code string) string {
	return strings.Map(func(r rune) rune {
		switch {
		case r == '-' || r == ' ':
			return -1
		case r >= 'a' && r <= 'z':
			return r - 'a' + 'A'
		}
		return r
	}, strings.TrimSpace(code))
}

func (s *Service) UsePasswordResets(resets *PasswordResets) {
	s.resets = resets
}

func (s *Service) RequestPasswordReset(ctx context.Context, login string) (users.User, string, error) {
	user, err := s.userKnownAs(ctx, strings.TrimSpace(login))
	if err != nil {
		return users.User{}, "", err
	}
	if user.Disabled || user.Profile.Email == "" {
		return users.User{}, "", apperr.NotFound("no account can be reset with %q", login)
	}
	code, err := s.resets.Issue(ctx, user.ID)
	return user, code, err
}

func (s *Service) userKnownAs(ctx context.Context, login string) (users.User, error) {
	if login == "" {
		return users.User{}, apperr.NotFound("user not found")
	}
	user, err := s.users.Store().ByUsername(ctx, login)
	if apperr.Is(err, apperr.KindNotFound) && strings.Contains(login, "@") {
		return s.users.Store().ByEmail(ctx, login)
	}
	return user, err
}

func (s *Service) ResetPassword(ctx context.Context, login, code, newPassword string) (users.User, error) {
	if err := users.ValidatePassword(newPassword); err != nil {
		return users.User{}, err
	}
	user, err := s.userKnownAs(ctx, strings.TrimSpace(login))
	if apperr.Is(err, apperr.KindNotFound) {
		return users.User{}, errInvalidResetCode
	}
	if err != nil {
		return users.User{}, err
	}
	if err := s.resets.ConsumeCode(ctx, user.ID, code); err != nil {
		return users.User{}, err
	}
	return s.setResetPassword(ctx, user.ID, newPassword)
}

func (s *Service) setResetPassword(ctx context.Context, userID int64, newPassword string) (users.User, error) {
	user, err := s.ActiveUser(ctx, userID)
	if err != nil {
		return users.User{}, err
	}
	if _, err := s.users.Update(ctx, user, user.ID, users.Changes{Password: &newPassword}); err != nil {
		return users.User{}, err
	}
	return user, s.LogOutEverywhere(ctx, user.ID)
}
