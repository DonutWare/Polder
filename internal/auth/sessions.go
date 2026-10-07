package auth

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"database/sql"
	"encoding/base64"
	"encoding/hex"
	"errors"
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

type Session struct {
	ID         int64
	UserID     int64
	DeviceName string
}

func (s *Sessions) Create(ctx context.Context, userID int64, deviceName string) (Session, string, error) {
	token, tokenHash := newRefreshToken()
	now := time.Now()
	var id int64
	err := s.db.QueryRowContext(ctx,
		`INSERT INTO sessions (user_id, token_hash, device_name, created_at, last_used_at, expires_at) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`,
		userID, tokenHash, deviceName, now.Unix(), now.Unix(), now.Add(RefreshTokenLifetime).Unix()).Scan(&id)
	if err != nil {
		return Session{}, "", err
	}
	return Session{ID: id, UserID: userID, DeviceName: deviceName}, token, err
}

func (s *Sessions) Rotate(ctx context.Context, refreshToken, deviceName string) (Session, string, error) {
	session, expiresAt, err := s.find(ctx, refreshToken)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && time.Now().Unix() > expiresAt) {
		return Session{}, "", apperr.Unauthorized("refresh token is invalid or expired")
	}
	if err != nil {
		return Session{}, "", err
	}

	if deviceName != "" {
		session.DeviceName = deviceName
	}
	token, tokenHash := newRefreshToken()
	now := time.Now()
	_, err = s.db.ExecContext(ctx, `UPDATE sessions SET token_hash = $1, device_name = $2, last_used_at = $3, expires_at = $4 WHERE id = $5`,
		tokenHash, session.DeviceName, now.Unix(), now.Add(RefreshTokenLifetime).Unix(), session.ID)
	return session, token, err
}

func (s *Sessions) Revoke(ctx context.Context, refreshToken string) (Session, bool, error) {
	session, _, err := s.find(ctx, refreshToken)
	if errors.Is(err, sql.ErrNoRows) {
		return Session{}, false, nil
	}
	if err != nil {
		return Session{}, false, err
	}
	_, err = s.db.ExecContext(ctx, `DELETE FROM sessions WHERE id = $1`, session.ID)
	return session, err == nil, err
}

func (s *Sessions) find(ctx context.Context, refreshToken string) (Session, int64, error) {
	var session Session
	var expiresAt int64
	err := s.db.QueryRowContext(ctx, `SELECT id, user_id, device_name, expires_at FROM sessions WHERE token_hash = $1`, hashToken(refreshToken)).
		Scan(&session.ID, &session.UserID, &session.DeviceName, &expiresAt)
	return session, expiresAt, err
}

func (s *Sessions) RevokeAllForUser(ctx context.Context, userID int64) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM sessions WHERE user_id = $1`, userID)
	return err
}

func newRefreshToken() (token, tokenHash string) {
	buffer := make([]byte, 32)
	_, _ = rand.Read(buffer)
	token = base64.RawURLEncoding.EncodeToString(buffer)
	return token, hashToken(token)
}

func hashToken(token string) string {
	sum := sha256.Sum256([]byte(token))
	return hex.EncodeToString(sum[:])
}
