package sso

import (
	"context"
	"regexp"
	"strconv"
	"strings"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
	"polder-server/internal/users"
)

const (
	maxUsernameLength = 32
	fallbackUsername  = "user"
)

var usernameInvalid = regexp.MustCompile(`[^a-z0-9_.-]+`)

type LinkedIdentity struct {
	ID            int64     `json:"id"`
	ProviderID    string    `json:"providerId"`
	ProviderLabel string    `json:"providerLabel"`
	Preset        string    `json:"preset"`
	Email         string    `json:"email" doc:"The address the provider gave when the account was linked"`
	CreatedAt     time.Time `json:"createdAt"`
}

func (s *Service) identityOwner(ctx context.Context, providerID, subject string) (int64, error) {
	var userID int64
	err := s.db.QueryRowContext(ctx, `SELECT user_id FROM user_identities WHERE provider_id = $1 AND subject = $2`, providerID, subject).Scan(&userID)
	return userID, err
}

func (s *Service) link(ctx context.Context, providerID string, identity Identity, userID int64) error {
	_, err := s.db.ExecContext(ctx, `INSERT INTO user_identities (provider_id, subject, user_id, email, created_at) VALUES ($1, $2, $3, $4, $5)`,
		providerID, identity.Subject, userID, identity.Email, s.now().Unix())
	if database.IsUniqueViolation(err) {
		return apperr.AlreadyExists("this account is already linked to that provider")
	}
	return err
}

func (s *Service) Identities(ctx context.Context, userID int64) ([]LinkedIdentity, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT i.id, i.provider_id, p.label, p.preset, i.email, i.created_at
		FROM user_identities i JOIN auth_providers p ON p.id = i.provider_id WHERE i.user_id = $1 ORDER BY p.position`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	list := []LinkedIdentity{}
	for rows.Next() {
		var identity LinkedIdentity
		var createdAt int64
		if err := rows.Scan(&identity.ID, &identity.ProviderID, &identity.ProviderLabel, &identity.Preset, &identity.Email, &createdAt); err != nil {
			return nil, err
		}
		identity.CreatedAt = time.Unix(createdAt, 0).UTC()
		list = append(list, identity)
	}
	return list, rows.Err()
}

func (s *Service) Unlink(ctx context.Context, user users.User, identityID int64) error {
	identities, err := s.Identities(ctx, user.ID)
	if err != nil {
		return err
	}
	found := false
	for _, identity := range identities {
		found = found || identity.ID == identityID
	}
	if !found {
		return apperr.NotFound("linked account not found")
	}
	if !user.HasPassword && len(identities) == 1 {
		return apperr.Forbidden("this is the only way to sign in to your account; set a password first")
	}
	_, err = s.db.ExecContext(ctx, `DELETE FROM user_identities WHERE id = $1 AND user_id = $2`, identityID, user.ID)
	return err
}

func (s *Service) freeUsername(ctx context.Context, identity Identity) (string, error) {
	base := usernameFrom(identity)
	candidate := base
	for suffix := 2; ; suffix++ {
		_, err := s.users.Store().ByUsername(ctx, candidate)
		if apperr.Is(err, apperr.KindNotFound) {
			return candidate, nil
		}
		if err != nil {
			return "", err
		}
		ending := strconv.Itoa(suffix)
		trimmed := base
		if len(trimmed)+len(ending) > maxUsernameLength {
			trimmed = trimmed[:maxUsernameLength-len(ending)]
		}
		candidate = trimmed + ending
	}
}

func usernameFrom(identity Identity) string {
	for _, source := range []string{identity.PreferredUsername, identity.Email, identity.Name} {
		if local, _, found := strings.Cut(source, "@"); found {
			source = local
		}
		name := strings.Trim(usernameInvalid.ReplaceAllString(strings.ToLower(source), "-"), "-_.")
		if len(name) > maxUsernameLength-3 {
			name = strings.Trim(name[:maxUsernameLength-3], "-_.")
		}
		if users.ValidUsername(name) {
			return name
		}
	}
	return fallbackUsername
}
