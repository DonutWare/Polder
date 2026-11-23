package sso

import (
	"context"
	"strings"
)

func (s *Service) UseConfiguredProvider(ctx context.Context, configured NewAuthProvider) error {
	if strings.TrimSpace(configured.Preset) == "" && strings.TrimSpace(configured.ClientID) == "" {
		_, err := s.db.ExecContext(ctx, `DELETE FROM auth_providers WHERE id = $1 AND managed_by_config`, ConfigID)
		s.forget(ConfigID)
		return err
	}
	configured.Preset = firstNonEmpty(configured.Preset, PresetGeneric)
	provider, err := providerFromPreset(configured)
	if err != nil {
		return err
	}
	provider.ID = ConfigID
	existing, err := s.Provider(ctx, ConfigID)
	if err != nil {
		return s.insert(ctx, provider, true)
	}
	provider.Enabled = existing.Enabled
	_, err = s.db.ExecContext(ctx, `UPDATE auth_providers SET kind = $1, preset = $2, label = $3, issuer = $4, client_id = $5,
		client_secret_sealed = $6, scopes = $7, username_claim = $8, allow_signup = $9, link_by_email = $10, managed_by_config = TRUE
		WHERE id = $11`, string(provider.Kind), provider.Preset, provider.Label, provider.Issuer, provider.ClientID,
		s.box.Seal(provider.clientSecret, secretContext(ConfigID)), provider.Scopes, provider.UsernameClaim, provider.AllowSignup,
		provider.LinkByEmail, ConfigID)
	s.forget(ConfigID)
	return err
}
