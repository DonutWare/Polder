package auth

import (
	"context"
	"strconv"
	"time"

	"github.com/golang-jwt/jwt/v5"

	"polder-server/internal/apperr"
)

const (
	StreamTicketLifetime = 8 * time.Hour
	StreamTicketParam    = "ticket"
	streamTicketIssuer   = "polder-stream"
	streamKeyPurpose     = "polder-stream"
)

type streamClaims struct {
	jwt.RegisteredClaims
	SessionID int64  `json:"sid,omitempty"`
	Device    string `json:"dev,omitempty"`
}

func (s *Service) IssueStreamTicket(identity Identity, filePath string) (string, time.Time, error) {
	now := time.Now()
	expiresAt := now.Add(StreamTicketLifetime)
	claims := streamClaims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    streamTicketIssuer,
			Subject:   strconv.FormatInt(identity.User.ID, 10),
			Audience:  jwt.ClaimStrings{filePath},
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(expiresAt),
		},
		SessionID: identity.SessionID,
		Device:    identity.Device,
	}
	signed, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(s.tokens.DerivedKey(streamKeyPurpose))
	return signed, expiresAt, err
}

func (s *Service) AuthenticateStream(ctx context.Context, ticket, filePath string) (Identity, error) {
	claims := streamClaims{}
	_, err := jwt.ParseWithClaims(ticket, &claims,
		func(*jwt.Token) (any, error) { return s.tokens.DerivedKey(streamKeyPurpose), nil },
		jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}), jwt.WithIssuer(streamTicketIssuer),
		jwt.WithAudience(filePath), jwt.WithExpirationRequired())
	if err != nil {
		return Identity{}, apperr.Unauthorized("stream ticket is invalid, expired or for another file")
	}
	userID, err := strconv.ParseInt(claims.Subject, 10, 64)
	if err != nil {
		return Identity{}, apperr.Unauthorized("stream ticket is invalid")
	}
	user, err := s.ActiveUser(ctx, userID)
	if err != nil {
		return Identity{}, err
	}
	return Identity{User: user, SessionID: claims.SessionID, Device: claims.Device, ExpiresAt: claims.ExpiresAt.Time}, nil
}
