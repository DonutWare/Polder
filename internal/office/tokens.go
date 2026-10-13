package office

import (
	"errors"
	"strconv"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

const (
	tokenLifetime = 10 * time.Hour
	tokenIssuer   = "polder-wopi"
)

type grant struct {
	UserID     int64
	FileID     int64
	VersionID  int64
	Generation int64
	SessionID  int64
	Device     string
	ReadOnly   bool
	// Origin is the page that embeds the editor, which the editor posts its messages to.
	Origin    string
	ExpiresAt time.Time
}

type grantClaims struct {
	jwt.RegisteredClaims
	FileID     int64  `json:"fid"`
	VersionID  int64  `json:"vid,omitempty"`
	Generation int64  `json:"gen,omitempty"`
	SessionID  int64  `json:"sid,omitempty"`
	Device     string `json:"dev,omitempty"`
	ReadOnly   bool   `json:"ro,omitempty"`
	Origin     string `json:"org,omitempty"`
}

type tokens struct {
	key []byte
	now func() time.Time
}

func (t *tokens) issue(g grant) (string, grant, error) {
	now := t.now()
	g.ExpiresAt = now.Add(tokenLifetime)
	claims := grantClaims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    tokenIssuer,
			Subject:   strconv.FormatInt(g.UserID, 10),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(g.ExpiresAt),
		},
		FileID:     g.FileID,
		VersionID:  g.VersionID,
		Generation: g.Generation,
		SessionID:  g.SessionID,
		Device:     g.Device,
		ReadOnly:   g.ReadOnly,
		Origin:     g.Origin,
	}
	signed, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(t.key)
	return signed, g, err
}

func (t *tokens) parse(token string) (grant, error) {
	if token == "" {
		return grant{}, errors.New("missing access token")
	}
	claims := grantClaims{}
	_, err := jwt.ParseWithClaims(token, &claims, func(*jwt.Token) (any, error) { return t.key, nil },
		jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}), jwt.WithIssuer(tokenIssuer),
		jwt.WithExpirationRequired(), jwt.WithTimeFunc(t.now))
	if err != nil {
		return grant{}, err
	}
	userID, err := strconv.ParseInt(claims.Subject, 10, 64)
	if err != nil {
		return grant{}, err
	}
	return grant{
		UserID:     userID,
		FileID:     claims.FileID,
		VersionID:  claims.VersionID,
		Generation: claims.Generation,
		SessionID:  claims.SessionID,
		Device:     claims.Device,
		ReadOnly:   claims.ReadOnly,
		Origin:     claims.Origin,
		ExpiresAt:  claims.ExpiresAt.Time,
	}, nil
}
