package sharing

import (
	"errors"
	"strconv"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

const (
	linkTokenLifetime = 2 * time.Hour
	linkTokenIssuer   = "polder-share-link"
	LinkKeyPurpose    = "polder-share-link"
)

type linkGrant struct {
	LinkID     int64
	Code       string
	Generation int64
}

type linkClaims struct {
	jwt.RegisteredClaims
	Code       string `json:"code"`
	Generation int64  `json:"gen"`
}

type linkTokens struct {
	key []byte
	now func() time.Time
}

func (t linkTokens) issue(link linkRow) (string, time.Time, error) {
	now := t.now()
	expiresAt := now.Add(linkTokenLifetime)
	if link.ExpiresAt != nil && link.ExpiresAt.Before(expiresAt) {
		expiresAt = *link.ExpiresAt
	}
	claims := linkClaims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    linkTokenIssuer,
			Subject:   strconv.FormatInt(link.ID, 10),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(expiresAt),
		},
		Code:       link.Code,
		Generation: link.Generation,
	}
	signed, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(t.key)
	return signed, expiresAt, err
}

func (t linkTokens) parse(token string) (linkGrant, error) {
	if token == "" {
		return linkGrant{}, errors.New("missing share token")
	}
	claims := linkClaims{}
	_, err := jwt.ParseWithClaims(token, &claims, func(*jwt.Token) (any, error) { return t.key, nil },
		jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}), jwt.WithIssuer(linkTokenIssuer),
		jwt.WithExpirationRequired(), jwt.WithTimeFunc(t.now))
	if err != nil {
		return linkGrant{}, err
	}
	linkID, err := strconv.ParseInt(claims.Subject, 10, 64)
	if err != nil {
		return linkGrant{}, err
	}
	return linkGrant{LinkID: linkID, Code: claims.Code, Generation: claims.Generation}, nil
}
