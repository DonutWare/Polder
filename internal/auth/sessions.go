package auth

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"database/sql"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"math"
	"time"

	"polder-server/internal/apperr"
)

const RefreshTokenLifetime = 30 * 24 * time.Hour

type Sessions struct {
	db *sql.DB
}

func NewSessions(db *sql.DB) *Sessions {
	return &Sessions{db: db}
}

type Method string

const (
	MethodPassword Method = "password"
	MethodSSO      Method = "sso"
	MethodDevice   Method = "device"
)

func (m Method) orPassword() Method {
	if m == "" {
		return MethodPassword
	}
	return m
}

type Session struct {
	ID         int64
	UserID     int64
	DeviceName string
	Method     Method
}

func (s *Sessions) Create(ctx context.Context, userID int64, deviceName string, method Method, authenticatedAt time.Time) (Session, string, error) {
	token, tokenHash := newSecretToken()
	now := time.Now()
	method = method.orPassword()
	var id int64
	err := s.db.QueryRowContext(ctx,
		`INSERT INTO sessions (user_id, token_hash, device_name, created_at, last_used_at, expires_at, auth_method, authenticated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id`,
		userID, tokenHash, deviceName, now.Unix(), now.Unix(), now.Add(RefreshTokenLifetime).Unix(), string(method), authenticatedAt.Unix()).Scan(&id)
	if err != nil {
		return Session{}, "", err
	}
	return Session{ID: id, UserID: userID, DeviceName: deviceName, Method: method}, token, err
}

func (s *Sessions) AuthenticatedAt(ctx context.Context, userID, sessionID int64) (time.Time, error) {
	var authenticatedAt int64
	err := s.db.QueryRowContext(ctx, `SELECT authenticated_at FROM sessions WHERE id = $1 AND user_id = $2`, sessionID, userID).Scan(&authenticatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return time.Time{}, nil
	}
	return time.Unix(authenticatedAt, 0), err
}

func (s *Sessions) CountActiveForUser(ctx context.Context, userID int64) (int, error) {
	var count int
	err := s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM sessions WHERE user_id = $1 AND expires_at > $2`, userID, time.Now().Unix()).Scan(&count)
	return count, err
}

const (
	GraceTokensPerSession = 5
	rotateAttempts        = 3
)

var errRotationRaced = errors.New("session was rotated concurrently")

func (s *Sessions) Rotate(ctx context.Context, refreshToken, deviceName string) (Session, string, error) {
	for attempt := 1; ; attempt++ {
		session, token, err := s.rotateOnce(ctx, refreshToken, deviceName)
		if !errors.Is(err, errRotationRaced) {
			return session, token, err
		}
		if attempt == rotateAttempts {
			return Session{}, "", apperr.Unavailable("session is busy, try again")
		}
	}
}

func (s *Sessions) rotateOnce(ctx context.Context, refreshToken, deviceName string) (Session, string, error) {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return Session{}, "", err
	}
	defer func() { _ = tx.Rollback() }()

	match, err := find(ctx, tx, refreshToken)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && time.Now().Unix() > match.expiresAt) {
		return Session{}, "", apperr.Unauthorized("refresh token is invalid or expired")
	}
	if err != nil {
		return Session{}, "", err
	}

	session := match.session
	if deviceName != "" {
		session.DeviceName = deviceName
	}
	token, tokenHash := newSecretToken()
	now := time.Now()
	result, err := tx.ExecContext(ctx,
		`UPDATE sessions SET token_hash = $1, device_name = $2, last_used_at = $3, expires_at = $4 WHERE id = $5 AND token_hash = $6`,
		tokenHash, session.DeviceName, now.Unix(), now.Add(RefreshTokenLifetime).Unix(), session.ID, match.currentHash)
	if err != nil {
		return Session{}, "", err
	}
	if updated, err := result.RowsAffected(); err != nil || updated == 0 {
		return Session{}, "", errors.Join(errRotationRaced, err)
	}
	if err := keepGraceFrom(ctx, tx, match); err != nil {
		return Session{}, "", err
	}
	return session, token, tx.Commit()
}

func keepGraceFrom(ctx context.Context, tx *sql.Tx, match tokenMatch) error {
	id := match.session.ID
	steps := []struct {
		query string
		args  []any
	}{
		{`DELETE FROM session_grace_tokens WHERE session_id = $1 AND id < $2`, []any{id, match.supersededFrom()}},
		{`INSERT INTO session_grace_tokens (session_id, token_hash) VALUES ($1, $2)`, []any{id, match.currentHash}},
		{`DELETE FROM session_grace_tokens WHERE session_id = $1 AND id NOT IN (
			SELECT id FROM session_grace_tokens WHERE session_id = $1 ORDER BY id DESC LIMIT $2)`, []any{id, GraceTokensPerSession}},
	}
	for _, step := range steps {
		if _, err := tx.ExecContext(ctx, step.query, step.args...); err != nil {
			return err
		}
	}
	return nil
}

func (s *Sessions) Revoke(ctx context.Context, refreshToken string) (Session, bool, error) {
	match, err := find(ctx, s.db, refreshToken)
	if errors.Is(err, sql.ErrNoRows) {
		return Session{}, false, nil
	}
	if err != nil {
		return Session{}, false, err
	}
	_, err = s.db.ExecContext(ctx, `DELETE FROM sessions WHERE id = $1`, match.session.ID)
	return match.session, err == nil, err
}

type tokenMatch struct {
	session     Session
	expiresAt   int64
	currentHash string
	graceID     int64
}

func (m tokenMatch) supersededFrom() int64 {
	if m.graceID == 0 {
		return math.MaxInt64
	}
	return m.graceID
}

type queryer interface {
	QueryRowContext(ctx context.Context, query string, args ...any) *sql.Row
}

func find(ctx context.Context, db queryer, refreshToken string) (tokenMatch, error) {
	var match tokenMatch
	err := db.QueryRowContext(ctx, `
		SELECT id, user_id, device_name, auth_method, expires_at, token_hash, 0 FROM sessions WHERE token_hash = $1
		UNION ALL
		SELECT s.id, s.user_id, s.device_name, s.auth_method, s.expires_at, s.token_hash, g.id
		FROM session_grace_tokens g JOIN sessions s ON s.id = g.session_id WHERE g.token_hash = $1`,
		hashToken(refreshToken)).
		Scan(&match.session.ID, &match.session.UserID, &match.session.DeviceName, &match.session.Method, &match.expiresAt, &match.currentHash, &match.graceID)
	return match, err
}

func (s *Sessions) RevokeAllForUser(ctx context.Context, userID int64) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM sessions WHERE user_id = $1`, userID)
	return err
}

func (s *Sessions) RevokeOthersForUser(ctx context.Context, userID, keepID int64) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM sessions WHERE user_id = $1 AND id <> $2`, userID, keepID)
	return err
}

func newSecretToken() (token, tokenHash string) {
	buffer := make([]byte, 32)
	_, _ = rand.Read(buffer)
	token = base64.RawURLEncoding.EncodeToString(buffer)
	return token, hashToken(token)
}

func hashToken(token string) string {
	sum := sha256.Sum256([]byte(token))
	return hex.EncodeToString(sum[:])
}
