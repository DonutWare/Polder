package sso

import (
	"strings"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
)

type ProviderKind string

const (
	KindOIDC   ProviderKind = "oidc"
	KindGitHub ProviderKind = "github"
)

func (ProviderKind) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(KindOIDC), string(KindGitHub)}
	return s
}

type ProviderField string

const (
	FieldServerURL ProviderField = "serverUrl"
	FieldRealm     ProviderField = "realm"
	FieldSlug      ProviderField = "slug"
	FieldTenantID  ProviderField = "tenantId"
	FieldIssuer    ProviderField = "issuer"
)

func (ProviderField) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(FieldServerURL), string(FieldRealm), string(FieldSlug), string(FieldTenantID), string(FieldIssuer)}
	return s
}

type AuthProviderPreset struct {
	ID             string          `json:"id"`
	Kind           ProviderKind    `json:"kind"`
	Label          string          `json:"label" doc:"Name for the sign-in button"`
	IssuerTemplate string          `json:"issuerTemplate,omitempty" required:"false" doc:"How the issuer URL is built from the fields, such as {serverUrl}/realms/{realm}"`
	Fields         []ProviderField `json:"fields" doc:"What the administrator fills in besides the client ID and secret"`
	Scopes         string          `json:"scopes"`
	UsernameClaim  string          `json:"usernameClaim"`
	AllowSignup    bool            `json:"allowSignup" doc:"Whether new accounts are created by default"`
	LinkByEmail    bool            `json:"linkByEmail" doc:"Whether existing accounts are matched by verified email address by default"`
	Public         bool            `json:"public" doc:"Anyone can have an account at this provider, so new accounts are off by default"`
	SetupHint      string          `json:"setupHint" doc:"Where to register Polder at the provider"`
}

const (
	defaultOIDCScopes    = "openid profile email"
	defaultUsernameClaim = "preferred_username"
	PresetGeneric        = "oidc"
)

var presets = []AuthProviderPreset{
	{ID: "pocket-id", Kind: KindOIDC, Label: "Pocket ID", IssuerTemplate: "{serverUrl}", Fields: []ProviderField{FieldServerURL},
		Scopes: defaultOIDCScopes, UsernameClaim: defaultUsernameClaim, AllowSignup: true, LinkByEmail: true,
		SetupHint: "In Pocket ID, open OIDC Clients and add a client. Paste the callback URL under Callback URLs and leave Public Client off."},
	{ID: "authentik", Kind: KindOIDC, Label: "authentik", IssuerTemplate: "{serverUrl}/application/o/{slug}/", Fields: []ProviderField{FieldServerURL, FieldSlug},
		Scopes: defaultOIDCScopes, UsernameClaim: defaultUsernameClaim, AllowSignup: true, LinkByEmail: true,
		SetupHint: "In authentik, create an application with an OAuth2/OpenID Connect provider (confidential client) and add the callback URL as a strict redirect URI. authentik reports email addresses as unverified, so existing accounts are matched by connecting authentik in the account settings."},
	{ID: "authelia", Kind: KindOIDC, Label: "Authelia", IssuerTemplate: "{serverUrl}", Fields: []ProviderField{FieldServerURL},
		Scopes: defaultOIDCScopes, UsernameClaim: defaultUsernameClaim, AllowSignup: true, LinkByEmail: true,
		SetupHint: "Add a client under identity_providers.oidc.clients in Authelia's configuration, with the callback URL in redirect_uris and the openid, profile and email scopes."},
	{ID: "keycloak", Kind: KindOIDC, Label: "Keycloak", IssuerTemplate: "{serverUrl}/realms/{realm}", Fields: []ProviderField{FieldServerURL, FieldRealm},
		Scopes: defaultOIDCScopes, UsernameClaim: defaultUsernameClaim, AllowSignup: true, LinkByEmail: true,
		SetupHint: "In the realm, create an OpenID Connect client with Client authentication on and add the callback URL under Valid redirect URIs. The secret is on the Credentials tab."},
	{ID: "google", Kind: KindOIDC, Label: "Google", IssuerTemplate: "https://accounts.google.com", Fields: []ProviderField{},
		Scopes: defaultOIDCScopes, UsernameClaim: "email", Public: true,
		SetupHint: "In the Google Cloud console, create an OAuth client ID of type Web application and add the callback URL under Authorized redirect URIs."},
	{ID: "microsoft", Kind: KindOIDC, Label: "Microsoft", IssuerTemplate: "https://login.microsoftonline.com/{tenantId}/v2.0", Fields: []ProviderField{FieldTenantID},
		Scopes: defaultOIDCScopes, UsernameClaim: defaultUsernameClaim, Public: true,
		SetupHint: "In Microsoft Entra, register an application with the callback URL as a Web redirect URI and create a client secret; copy its Value, not its Secret ID. Use your directory (tenant) ID, or common, organizations or consumers to allow other directories. Entra only marks email addresses as verified when the xms_edov optional claim is added."},
	{ID: "github", Kind: KindGitHub, Label: "GitHub", Fields: []ProviderField{},
		Scopes: "read:user user:email", UsernameClaim: "login", Public: true,
		SetupHint: "In GitHub, go to Settings → Developer settings → OAuth Apps → New OAuth App and use the callback URL as the Authorization callback URL."},
	{ID: PresetGeneric, Kind: KindOIDC, Label: "OpenID Connect", IssuerTemplate: "{issuer}", Fields: []ProviderField{FieldIssuer},
		Scopes: defaultOIDCScopes, UsernameClaim: defaultUsernameClaim, LinkByEmail: true,
		SetupHint: "Register a confidential client at the provider with the callback URL as redirect URI."},
}

func Presets() []AuthProviderPreset {
	return presets
}

func PresetByID(id string) (AuthProviderPreset, bool) {
	for _, preset := range presets {
		if preset.ID == id {
			return preset, true
		}
	}
	return AuthProviderPreset{}, false
}

func (p AuthProviderPreset) Issuer(values map[ProviderField]string) (string, error) {
	if p.Kind != KindOIDC {
		return "", nil
	}
	issuer := p.IssuerTemplate
	for _, field := range p.Fields {
		value := strings.TrimSpace(values[field])
		if value == "" {
			return "", apperr.Invalid("%s needs %s", p.Label, field)
		}
		if field == FieldServerURL || field == FieldIssuer {
			value = strings.TrimSuffix(value, "/")
		}
		issuer = strings.ReplaceAll(issuer, "{"+string(field)+"}", value)
	}
	if err := validIssuer(issuer); err != nil {
		return "", err
	}
	return issuer, nil
}
