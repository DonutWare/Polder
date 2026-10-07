package auth

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
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
	tokenIssuer         = "polder"
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

// DerivedKey gives other token kinds their own signing key, so none of them can pass as an access token.
func (t *AccessTokens) DerivedKey(purpose string) []byte {
	mac := hmac.New(sha256.New, t.key)
	mac.Write([]byte(purpose))
	return mac.Sum(nil)
}

type Claims struct {
	UserID    int64
	SessionID int64
	Device    string
	ExpiresAt time.Time
}

type accessClaims struct {
	jwt.RegisteredClaims
	SessionID int64  `json:"sid,omitempty"`
	Device    string `json:"dev,omitempty"`
}

func (t *AccessTokens) Issue(userID, sessionID int64, device string) (string, error) {
	now := time.Now()
	claims := accessClaims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    tokenIssuer,
			Subject:   strconv.FormatInt(userID, 10),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(AccessTokenLifetime)),
		},
		SessionID: sessionID,
		Device:    device,
	}
	return jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(t.key)
}

func (t *AccessTokens) Parse(token string) (Claims, error) {
	claims := accessClaims{}
	_, err := jwt.ParseWithClaims(token, &claims, func(*jwt.Token) (any, error) { return t.key, nil },
		jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}), jwt.WithIssuer(tokenIssuer), jwt.WithExpirationRequired())
	if err != nil {
		return Claims{}, err
	}
	userID, err := strconv.ParseInt(claims.Subject, 10, 64)
	if err != nil {
		return Claims{}, err
	}
	return Claims{UserID: userID, SessionID: claims.SessionID, Device: claims.Device, ExpiresAt: claims.ExpiresAt.Time}, nil
}
