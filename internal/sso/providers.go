package sso

import (
	"context"
	"database/sql"
	"errors"
	"net/url"
	"regexp"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
)

const (
	maxLabelLength = 64
	maxSlugLength  = 32
	ConfigID       = "config"
)

var (
	slugInvalid = regexp.MustCompile(`[^a-z0-9]+`)
	slugPattern = regexp.MustCompile(`^[a-z0-9][a-z0-9-]{0,31}$`)
)

type AuthProvider struct {
	ID              string       `json:"id" doc:"Used in the callback URL"`
	Kind            ProviderKind `json:"kind"`
	Preset          string       `json:"preset"`
	Label           string       `json:"label" doc:"Shown on the sign-in button"`
	Issuer          string       `json:"issuer" doc:"The OpenID Connect issuer URL; empty for GitHub"`
	ClientID        string       `json:"clientId"`
	ClientSecretSet bool         `json:"clientSecretSet" doc:"Whether a client secret is stored; the secret itself is never shown"`
	Scopes          string       `json:"scopes" doc:"Space-separated scopes asked for"`
	UsernameClaim   string       `json:"usernameClaim" doc:"Claim new accounts take their username from"`
	AllowSignup     bool         `json:"allowSignup" doc:"Create an account for people who sign in for the first time"`
	LinkByEmail     bool         `json:"linkByEmail" doc:"Sign people in to the existing account with the same verified email address"`
	Enabled         bool         `json:"enabled" doc:"Shown on the login screen"`
	Position        int          `json:"position"`
	ManagedByConfig bool         `json:"managedByConfig" doc:"Set in the server config, so it can't be changed here"`
	CallbackURL     string       `json:"callbackUrl" doc:"Register this at the provider as redirect URI"`
	LinkedUsers     int          `json:"linkedUsers" doc:"Accounts linked to this provider"`
	clientSecret    string
}

type NewAuthProvider struct {
	Preset        string `json:"preset" doc:"One of the presets"`
	Label         string `json:"label" required:"false" maxLength:"64" doc:"Shown on the sign-in button; the preset's name when empty"`
	ServerURL     string `json:"serverUrl,omitempty" required:"false" doc:"Where a self-hosted provider runs"`
	Realm         string `json:"realm,omitempty" required:"false" doc:"Keycloak realm"`
	Slug          string `json:"slug,omitempty" required:"false" doc:"Authentik application slug"`
	TenantID      string `json:"tenantId,omitempty" required:"false" doc:"Microsoft Entra tenant ID, or common or organizations"`
	Issuer        string `json:"issuer,omitempty" required:"false" doc:"Issuer URL for a generic OpenID Connect provider"`
	ClientID      string `json:"clientId"`
	ClientSecret  string `json:"clientSecret"`
	Scopes        string `json:"scopes,omitempty" required:"false" doc:"Space-separated scopes; the preset's when empty"`
	UsernameClaim string `json:"usernameClaim,omitempty" required:"false" doc:"The preset's when empty"`
	AllowSignup   *bool  `json:"allowSignup,omitempty" required:"false" doc:"The preset's default when absent"`
	LinkByEmail   *bool  `json:"linkByEmail,omitempty" required:"false" doc:"The preset's default when absent"`
}

type AuthProviderChanges struct {
	Label         *string `json:"label" required:"false" maxLength:"64"`
	Issuer        *string `json:"issuer" required:"false"`
	ClientID      *string `json:"clientId" required:"false"`
	ClientSecret  *string `json:"clientSecret" required:"false" doc:"A new client secret; absent keeps the stored one"`
	Scopes        *string `json:"scopes" required:"false"`
	UsernameClaim *string `json:"usernameClaim" required:"false"`
	AllowSignup   *bool   `json:"allowSignup" required:"false"`
	LinkByEmail   *bool   `json:"linkByEmail" required:"false"`
	Enabled       *bool   `json:"enabled" required:"false"`
}

type AuthProviderOption struct {
	ID    string `json:"id"`
	Label string `json:"label"`
	Icon  string `json:"icon" doc:"The preset, for the apps to pick an icon"`
}

const selectProviderColumns = `SELECT p.id, p.kind, p.preset, p.label, p.issuer, p.client_id, p.client_secret_sealed, p.scopes, p.username_claim,
	p.allow_signup, p.link_by_email, p.enabled, p.position, p.managed_by_config,
	(SELECT COUNT(*) FROM user_identities i WHERE i.provider_id = p.id) FROM auth_providers p`

func (s *Service) scanProvider(row database.RowScanner) (AuthProvider, error) {
	var provider AuthProvider
	var sealed string
	err := row.Scan(&provider.ID, &provider.Kind, &provider.Preset, &provider.Label, &provider.Issuer, &provider.ClientID, &sealed,
		&provider.Scopes, &provider.UsernameClaim, &provider.AllowSignup, &provider.LinkByEmail, &provider.Enabled, &provider.Position,
		&provider.ManagedByConfig, &provider.LinkedUsers)
	if err != nil {
		return AuthProvider{}, err
	}
	provider.CallbackURL = s.callbackURL(provider.ID)
	if sealed != "" {
		secret, err := s.box.Open(sealed, secretContext(provider.ID))
		if err != nil {
			logger.Warn("stored client secret cannot be read; enter it again", "provider", provider.ID)
		}
		provider.clientSecret = secret
	}
	provider.ClientSecretSet = provider.clientSecret != ""
	return provider, nil
}

func secretContext(providerID string) string {
	return "sso-client:" + providerID
}

func (s *Service) callbackURL(providerID string) string {
	if s.publicURL == "" {
		return ""
	}
	return s.publicURL + "/api/v1/auth/sso/" + providerID + "/callback"
}

func (s *Service) Providers(ctx context.Context) ([]AuthProvider, error) {
	rows, err := s.db.QueryContext(ctx, selectProviderColumns+` ORDER BY p.position, p.created_at`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	list := []AuthProvider{}
	for rows.Next() {
		provider, err := s.scanProvider(rows)
		if err != nil {
			return nil, err
		}
		list = append(list, provider)
	}
	return list, rows.Err()
}

func (s *Service) Provider(ctx context.Context, id string) (AuthProvider, error) {
	provider, err := s.scanProvider(s.db.QueryRowContext(ctx, selectProviderColumns+` WHERE p.id = $1`, id))
	if errors.Is(err, sql.ErrNoRows) {
		return AuthProvider{}, apperr.NotFound("sign-in provider %q not found", id)
	}
	return provider, err
}

func (s *Service) LoginOptions(ctx context.Context) ([]AuthProviderOption, error) {
	if s.publicURL == "" {
		return []AuthProviderOption{}, nil
	}
	providers, err := s.Providers(ctx)
	if err != nil {
		return nil, err
	}
	options := []AuthProviderOption{}
	for _, provider := range providers {
		if provider.Enabled {
			options = append(options, AuthProviderOption{ID: provider.ID, Label: provider.Label, Icon: provider.Preset})
		}
	}
	return options, nil
}

func (s *Service) CreateProvider(ctx context.Context, input NewAuthProvider) (AuthProvider, error) {
	if s.publicURL == "" {
		return AuthProvider{}, apperr.Invalid("single sign-on needs publicUrl in the server config, for the callback URL")
	}
	provider, err := providerFromPreset(input)
	if err != nil {
		return AuthProvider{}, err
	}
	id, err := s.freeID(ctx, firstNonEmpty(slugify(provider.Label), provider.Preset))
	if err != nil {
		return AuthProvider{}, err
	}
	provider.ID = id
	if err := s.insert(ctx, provider, false); err != nil {
		return AuthProvider{}, err
	}
	return s.Provider(ctx, id)
}

func providerFromPreset(input NewAuthProvider) (AuthProvider, error) {
	preset, ok := PresetByID(input.Preset)
	if !ok {
		return AuthProvider{}, apperr.Invalid("%q is not a known provider preset", input.Preset)
	}
	issuer, err := preset.Issuer(map[ProviderField]string{
		FieldServerURL: input.ServerURL, FieldRealm: input.Realm, FieldSlug: input.Slug, FieldTenantID: input.TenantID, FieldIssuer: input.Issuer,
	})
	if err != nil {
		return AuthProvider{}, err
	}
	provider := AuthProvider{
		Kind:          preset.Kind,
		Preset:        preset.ID,
		Label:         firstNonEmpty(input.Label, preset.Label),
		Issuer:        issuer,
		ClientID:      strings.TrimSpace(input.ClientID),
		Scopes:        normalizeScopes(firstNonEmpty(input.Scopes, preset.Scopes)),
		UsernameClaim: firstNonEmpty(input.UsernameClaim, preset.UsernameClaim),
		AllowSignup:   valueOr(input.AllowSignup, preset.AllowSignup),
		LinkByEmail:   valueOr(input.LinkByEmail, preset.LinkByEmail),
		Enabled:       true,
		clientSecret:  input.ClientSecret,
	}
	return provider, provider.validate()
}

func (s *Service) insert(ctx context.Context, provider AuthProvider, managed bool) error {
	_, err := s.db.ExecContext(ctx, `INSERT INTO auth_providers (id, kind, preset, label, issuer, client_id, client_secret_sealed, scopes,
		username_claim, allow_signup, link_by_email, enabled, position, managed_by_config, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, (SELECT COALESCE(MAX(position), -1) + 1 FROM auth_providers), $13, $14)`,
		provider.ID, string(provider.Kind), provider.Preset, provider.Label, provider.Issuer, provider.ClientID,
		s.box.Seal(provider.clientSecret, secretContext(provider.ID)), provider.Scopes, provider.UsernameClaim,
		provider.AllowSignup, provider.LinkByEmail, provider.Enabled, managed, time.Now().Unix())
	if database.IsUniqueViolation(err) {
		return apperr.AlreadyExists("sign-in provider %q already exists", provider.ID)
	}
	return err
}

func (s *Service) UpdateProvider(ctx context.Context, id string, changes AuthProviderChanges) (AuthProvider, error) {
	provider, err := s.Provider(ctx, id)
	if err != nil {
		return AuthProvider{}, err
	}
	if provider.ManagedByConfig && changes.changesMoreThanEnabled() {
		return AuthProvider{}, apperr.Invalid("this provider is set in the server config, so it can only be turned on or off here")
	}
	applyText(&provider.Label, changes.Label)
	applyText(&provider.Issuer, changes.Issuer)
	applyText(&provider.ClientID, changes.ClientID)
	applyText(&provider.UsernameClaim, changes.UsernameClaim)
	if changes.Scopes != nil {
		provider.Scopes = normalizeScopes(*changes.Scopes)
	}
	if changes.ClientSecret != nil {
		provider.clientSecret = *changes.ClientSecret
	}
	provider.AllowSignup = valueOr(changes.AllowSignup, provider.AllowSignup)
	provider.LinkByEmail = valueOr(changes.LinkByEmail, provider.LinkByEmail)
	provider.Enabled = valueOr(changes.Enabled, provider.Enabled)
	if err := provider.validate(); err != nil {
		return AuthProvider{}, err
	}
	_, err = s.db.ExecContext(ctx, `UPDATE auth_providers SET label = $1, issuer = $2, client_id = $3, client_secret_sealed = $4, scopes = $5,
		username_claim = $6, allow_signup = $7, link_by_email = $8, enabled = $9 WHERE id = $10`,
		provider.Label, provider.Issuer, provider.ClientID, s.box.Seal(provider.clientSecret, secretContext(id)), provider.Scopes,
		provider.UsernameClaim, provider.AllowSignup, provider.LinkByEmail, provider.Enabled, id)
	if err != nil {
		return AuthProvider{}, err
	}
	s.forget(id)
	return s.Provider(ctx, id)
}

func (s *Service) DeleteProvider(ctx context.Context, id string) error {
	provider, err := s.Provider(ctx, id)
	if err != nil {
		return err
	}
	if provider.ManagedByConfig {
		return apperr.Invalid("this provider is set in the server config; remove it there")
	}
	if _, err := s.db.ExecContext(ctx, `DELETE FROM auth_providers WHERE id = $1`, id); err != nil {
		return err
	}
	s.forget(id)
	return nil
}

func (s *Service) ReorderProviders(ctx context.Context, ids []string) ([]AuthProvider, error) {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer func() { _ = tx.Rollback() }()
	for position, id := range ids {
		if _, err := tx.ExecContext(ctx, `UPDATE auth_providers SET position = $1 WHERE id = $2`, position, id); err != nil {
			return nil, err
		}
	}
	if err := tx.Commit(); err != nil {
		return nil, err
	}
	return s.Providers(ctx)
}

func (s *Service) freeID(ctx context.Context, base string) (string, error) {
	if len(base) > maxSlugLength-3 {
		base = strings.TrimRight(base[:maxSlugLength-3], "-")
	}
	candidate := base
	for suffix := 2; ; suffix++ {
		var taken bool
		if err := s.db.QueryRowContext(ctx, `SELECT EXISTS (SELECT 1 FROM auth_providers WHERE id = $1)`, candidate).Scan(&taken); err != nil {
			return "", err
		}
		if !taken && candidate != ConfigID {
			return candidate, nil
		}
		candidate = base + "-" + strconv.Itoa(suffix)
	}
}

func (p AuthProvider) validate() error {
	if p.Label == "" || utf8.RuneCountInString(p.Label) > maxLabelLength {
		return apperr.Invalid("the label must be 1 to %d characters", maxLabelLength)
	}
	if p.ClientID == "" {
		return apperr.Invalid("the client ID is missing")
	}
	if p.clientSecret == "" {
		return apperr.Invalid("the client secret is missing")
	}
	if p.Kind == KindOIDC {
		if err := validIssuer(p.Issuer); err != nil {
			return err
		}
		if !strings.Contains(" "+p.Scopes+" ", " openid ") {
			return apperr.Invalid("the scopes must include openid")
		}
	}
	if p.UsernameClaim == "" {
		return apperr.Invalid("the username claim is missing")
	}
	return nil
}

func (c AuthProviderChanges) changesMoreThanEnabled() bool {
	return c.Label != nil || c.Issuer != nil || c.ClientID != nil || c.ClientSecret != nil || c.Scopes != nil ||
		c.UsernameClaim != nil || c.AllowSignup != nil || c.LinkByEmail != nil
}

func validIssuer(issuer string) error {
	parsed, err := url.Parse(issuer)
	if err != nil || parsed.Host == "" || (parsed.Scheme != "https" && parsed.Scheme != "http") || parsed.RawQuery != "" || parsed.Fragment != "" {
		return apperr.Invalid("%q is not an issuer URL", issuer)
	}
	return nil
}

func slugify(label string) string {
	slug := strings.Trim(slugInvalid.ReplaceAllString(strings.ToLower(label), "-"), "-")
	if !slugPattern.MatchString(slug) {
		return ""
	}
	return slug
}

func normalizeScopes(scopes string) string {
	return strings.Join(strings.Fields(scopes), " ")
}

func firstNonEmpty(values ...string) string {
	for _, value := range values {
		if trimmed := strings.TrimSpace(value); trimmed != "" {
			return trimmed
		}
	}
	return ""
}

func valueOr(value *bool, fallback bool) bool {
	if value == nil {
		return fallback
	}
	return *value
}

func applyText(target *string, value *string) {
	if value != nil {
		*target = strings.TrimSpace(*value)
	}
}
