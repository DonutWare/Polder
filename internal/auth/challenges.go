package auth

import (
	"crypto/rand"
	"encoding/base64"
	"strconv"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"

	"polder-server/internal/apperr"
)

const (
	ChallengeKeyPurpose   = "two-factor-challenge"
	ChallengeLifetime     = 5 * time.Minute
	MaxChallengeAttempts  = 5
	challengeIssuer       = "polder-two-factor"
	challengeIDBytes      = 16
	challengeSweepEntries = 1024
)

var errInvalidChallenge = apperr.Unauthorized("the sign-in took too long or was already finished; sign in again")

type TwoFactorChallenge struct {
	Challenge      string `json:"challenge" doc:"Send this back with the code from the authenticator app"`
	ExpiresIn      int    `json:"expiresIn" doc:"Seconds until the challenge expires"`
	DeviceApproval bool   `json:"deviceApproval" doc:"Whether another signed-in device can approve this sign-in instead"`
}

type challengeClaims struct {
	jwt.RegisteredClaims
	Device string `json:"dev,omitempty"`
}

type PendingSignIn struct {
	UserID int64
	Device string
	ID     string
}

type Challenges struct {
	key      []byte
	mu       sync.Mutex
	attempts map[string]challengeUse
}

type challengeUse struct {
	failures int
	finished bool
	expires  time.Time
}

func NewChallenges(key []byte) *Challenges {
	return &Challenges{key: key, attempts: map[string]challengeUse{}}
}

func (c *Challenges) Issue(userID int64, device string) (string, error) {
	id := make([]byte, challengeIDBytes)
	_, _ = rand.Read(id)
	now := time.Now()
	claims := challengeClaims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    challengeIssuer,
			Subject:   strconv.FormatInt(userID, 10),
			ID:        base64.RawURLEncoding.EncodeToString(id),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(ChallengeLifetime)),
		},
		Device: device,
	}
	return jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(c.key)
}

func (c *Challenges) Open(token string) (PendingSignIn, error) {
	claims := challengeClaims{}
	_, err := jwt.ParseWithClaims(token, &claims, func(*jwt.Token) (any, error) { return c.key, nil },
		jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}), jwt.WithIssuer(challengeIssuer), jwt.WithExpirationRequired())
	if err != nil || claims.ID == "" {
		return PendingSignIn{}, errInvalidChallenge
	}
	userID, err := strconv.ParseInt(claims.Subject, 10, 64)
	if err != nil {
		return PendingSignIn{}, errInvalidChallenge
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	use := c.attempts[claims.ID]
	if use.finished || use.failures >= MaxChallengeAttempts {
		return PendingSignIn{}, errInvalidChallenge
	}
	return PendingSignIn{UserID: userID, Device: claims.Device, ID: claims.ID}, nil
}

func (c *Challenges) Failed(pending PendingSignIn) {
	c.record(pending.ID, func(use *challengeUse) { use.failures++ })
}

func (c *Challenges) Finish(pending PendingSignIn) bool {
	finished := false
	c.record(pending.ID, func(use *challengeUse) {
		if !use.finished && use.failures < MaxChallengeAttempts {
			use.finished = true
			finished = true
		}
	})
	return finished
}

func (c *Challenges) record(id string, change func(*challengeUse)) {
	c.mu.Lock()
	defer c.mu.Unlock()
	now := time.Now()
	if len(c.attempts) >= challengeSweepEntries {
		for key, use := range c.attempts {
			if now.After(use.expires) {
				delete(c.attempts, key)
			}
		}
	}
	use := c.attempts[id]
	use.expires = now.Add(ChallengeLifetime)
	change(&use)
	c.attempts[id] = use
}
