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

	"nomad-server/internal/apperr"
)

const RefreshTokenLifetime = 30 * 24 * time.Hour

type Sessions struct {
	db *sql.DB
}

func NewSessions(db *sql.DB) *Sessions {
	return &Sessions{db: db}
}

func (s *Sessions) Create(ctx context.Context, userID int64, deviceName string) (string, error) {
	token, tokenHash := newRefreshToken()
	now := time.Now()
	_, err := s.db.ExecContext(ctx,
		`INSERT INTO sessions (user_id, token_hash, device_name, created_at, last_used_at, expires_at) VALUES (?, ?, ?, ?, ?, ?)`,
		userID, tokenHash, deviceName, now.Unix(), now.Unix(), now.Add(RefreshTokenLifetime).Unix())
	return token, err
}

func (s *Sessions) Rotate(ctx context.Context, refreshToken string) (int64, string, error) {
	var sessionID, userID, expiresAt int64
	err := s.db.QueryRowContext(ctx, `SELECT id, user_id, expires_at FROM sessions WHERE token_hash = ?`, hashToken(refreshToken)).
		Scan(&sessionID, &userID, &expiresAt)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && time.Now().Unix() > expiresAt) {
		return 0, "", apperr.Unauthorized("refresh token is invalid or expired")
	}
	if err != nil {
		return 0, "", err
	}

	token, tokenHash := newRefreshToken()
	now := time.Now()
	_, err = s.db.ExecContext(ctx, `UPDATE sessions SET token_hash = ?, last_used_at = ?, expires_at = ? WHERE id = ?`,
		tokenHash, now.Unix(), now.Add(RefreshTokenLifetime).Unix(), sessionID)
	return userID, token, err
}

func (s *Sessions) Revoke(ctx context.Context, refreshToken string) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM sessions WHERE token_hash = ?`, hashToken(refreshToken))
	return err
}

func (s *Sessions) RevokeAllForUser(ctx context.Context, userID int64) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM sessions WHERE user_id = ?`, userID)
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
