package auth

import (
	"crypto/rand"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

const (
	AccessTokenLifetime = 15 * time.Minute
	signingKeyLength    = 64
	tokenIssuer         = "nomad"
)

type AccessTokens struct {
	key []byte
}

func LoadOrCreateSigningKey(path string) (*AccessTokens, error) {
	key, err := os.ReadFile(path)
	if errors.Is(err, fs.ErrNotExist) {
		key, err = createSigningKey(path)
	}
	if err != nil {
		return nil, fmt.Errorf("signing key: %w", err)
	}
	return &AccessTokens{key: key}, nil
}

func createSigningKey(path string) ([]byte, error) {
	key := make([]byte, signingKeyLength)
	if _, err := rand.Read(key); err != nil {
		return nil, err
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o750); err != nil {
		return nil, err
	}
	return key, os.WriteFile(path, key, 0o600)
}

func (t *AccessTokens) Issue(userID int64) (string, error) {
	now := time.Now()
	claims := jwt.RegisteredClaims{
		Issuer:    tokenIssuer,
		Subject:   strconv.FormatInt(userID, 10),
		IssuedAt:  jwt.NewNumericDate(now),
		ExpiresAt: jwt.NewNumericDate(now.Add(AccessTokenLifetime)),
	}
	return jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(t.key)
}

func (t *AccessTokens) UserID(token string) (int64, error) {
	claims := jwt.RegisteredClaims{}
	_, err := jwt.ParseWithClaims(token, &claims, func(*jwt.Token) (any, error) { return t.key, nil },
		jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}), jwt.WithIssuer(tokenIssuer), jwt.WithExpirationRequired())
	if err != nil {
		return 0, err
	}
	return strconv.ParseInt(claims.Subject, 10, 64)
}
