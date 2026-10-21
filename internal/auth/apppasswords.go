package auth

import (
	"context"
	"crypto/rand"
	"crypto/subtle"
	"database/sql"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"strings"
	"time"
	"unicode/utf8"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
)

const (
	appPasswordPrefix        = "polder_"
	appPasswordLookupBytes   = 6
	appPasswordSecretBytes   = 32
	maxAppPasswordNameLength = 100
	appPasswordUseInterval   = time.Minute
)

type AppPassword struct {
	ID              int64      `json:"id"`
	Name            string     `json:"name"`
	ReadOnly        bool       `json:"readOnly" doc:"Only allows reading files"`
	CreatedAt       time.Time  `json:"createdAt"`
	LastUsedAt      *time.Time `json:"lastUsedAt,omitempty" required:"false" doc:"Absent until the password is first used"`
	LastUsedAddress string     `json:"lastUsedAddress" doc:"Address the password was last used from"`
}

type NewAppPassword struct {
	AppPassword
	Token string `json:"token" doc:"The password itself; shown only this once"`
}

type AppPasswordIdentity struct {
	UserID   int64
	Password AppPassword
}

type AppPasswords struct {
	db *sql.DB
}

func NewAppPasswords(db *sql.DB) *AppPasswords {
	return &AppPasswords{db: db}
}

func (p *AppPasswords) Create(ctx context.Context, userID int64, name string, readOnly bool) (NewAppPassword, error) {
	name = strings.TrimSpace(name)
	if name == "" || utf8.RuneCountInString(name) > maxAppPasswordNameLength {
		return NewAppPassword{}, apperr.Invalid("an app password needs a name of at most %d characters", maxAppPasswordNameLength)
	}
	lookup, token := newAppPasswordToken()
	now := time.Now()
	created := NewAppPassword{
		AppPassword: AppPassword{Name: name, ReadOnly: readOnly, CreatedAt: time.Unix(now.Unix(), 0)},
		Token:       token,
	}
	err := p.db.QueryRowContext(ctx,
		`INSERT INTO app_passwords (user_id, name, lookup, token_hash, read_only, created_at) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`,
		userID, name, lookup, hashToken(token), readOnly, now.Unix()).Scan(&created.ID)
	return created, err
}

func (p *AppPasswords) List(ctx context.Context, userID int64) ([]AppPassword, error) {
	return database.QueryAll(ctx, p.db, scanAppPassword,
		`SELECT id, name, read_only, created_at, last_used_at, last_used_address FROM app_passwords WHERE user_id = $1 ORDER BY created_at DESC, id DESC`, userID)
}

func (p *AppPasswords) Revoke(ctx context.Context, userID, id int64) error {
	return database.RequireAffected(apperr.NotFound("no such app password"))(
		p.db.ExecContext(ctx, `DELETE FROM app_passwords WHERE id = $1 AND user_id = $2`, id, userID))
}

func (p *AppPasswords) RevokeAllForUser(ctx context.Context, userID int64) error {
	_, err := p.db.ExecContext(ctx, `DELETE FROM app_passwords WHERE user_id = $1`, userID)
	return err
}

func (p *AppPasswords) Verify(ctx context.Context, token, address string) (AppPasswordIdentity, error) {
	invalid := apperr.Unauthorized("invalid username or password")
	lookup, ok := appPasswordLookup(token)
	if !ok {
		return AppPasswordIdentity{}, invalid
	}
	var identity AppPasswordIdentity
	var tokenHash string
	var createdAt int64
	var lastUsedAt sql.NullInt64
	err := p.db.QueryRowContext(ctx,
		`SELECT id, user_id, name, read_only, created_at, last_used_at, last_used_address, token_hash FROM app_passwords WHERE lookup = $1`, lookup).
		Scan(&identity.Password.ID, &identity.UserID, &identity.Password.Name, &identity.Password.ReadOnly, &createdAt, &lastUsedAt,
			&identity.Password.LastUsedAddress, &tokenHash)
	if errors.Is(err, sql.ErrNoRows) {
		hashToken(token)
		return AppPasswordIdentity{}, invalid
	}
	if err != nil {
		return AppPasswordIdentity{}, err
	}
	if subtle.ConstantTimeCompare([]byte(hashToken(token)), []byte(tokenHash)) != 1 {
		return AppPasswordIdentity{}, invalid
	}
	identity.Password.CreatedAt = time.Unix(createdAt, 0)
	p.noteUse(ctx, &identity.Password, lastUsedAt, address)
	return identity, nil
}

func (p *AppPasswords) noteUse(ctx context.Context, password *AppPassword, lastUsedAt sql.NullInt64, address string) {
	now := time.Now()
	if lastUsedAt.Valid {
		previous := time.Unix(lastUsedAt.Int64, 0)
		password.LastUsedAt = &previous
		if now.Sub(previous) < appPasswordUseInterval && password.LastUsedAddress == address {
			return
		}
	}
	if _, err := p.db.ExecContext(ctx, `UPDATE app_passwords SET last_used_at = $1, last_used_address = $2 WHERE id = $3`,
		now.Unix(), address, password.ID); err != nil {
		return
	}
	used := time.Unix(now.Unix(), 0)
	password.LastUsedAt = &used
	password.LastUsedAddress = address
}

func scanAppPassword(row database.RowScanner) (AppPassword, error) {
	var password AppPassword
	var createdAt int64
	var lastUsedAt sql.NullInt64
	if err := row.Scan(&password.ID, &password.Name, &password.ReadOnly, &createdAt, &lastUsedAt, &password.LastUsedAddress); err != nil {
		return AppPassword{}, err
	}
	password.CreatedAt = time.Unix(createdAt, 0)
	if lastUsedAt.Valid {
		used := time.Unix(lastUsedAt.Int64, 0)
		password.LastUsedAt = &used
	}
	return password, nil
}

func newAppPasswordToken() (lookup, token string) {
	lookupBytes := make([]byte, appPasswordLookupBytes)
	secret := make([]byte, appPasswordSecretBytes)
	_, _ = rand.Read(lookupBytes)
	_, _ = rand.Read(secret)
	lookup = hex.EncodeToString(lookupBytes)
	return lookup, appPasswordPrefix + lookup + "_" + base64.RawURLEncoding.EncodeToString(secret)
}

func appPasswordLookup(token string) (string, bool) {
	rest, found := strings.CutPrefix(token, appPasswordPrefix)
	if !found {
		return "", false
	}
	lookup, secret, found := strings.Cut(rest, "_")
	if !found || len(lookup) != appPasswordLookupBytes*2 || len(secret) != base64.RawURLEncoding.EncodedLen(appPasswordSecretBytes) {
		return "", false
	}
	if _, err := hex.DecodeString(lookup); err != nil {
		return "", false
	}
	return lookup, true
}

func IsAppPasswordToken(token string) bool {
	_, ok := appPasswordLookup(token)
	return ok
}
