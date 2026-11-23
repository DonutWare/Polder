package httpapi

import (
	"cmp"
	"context"
	"net/http"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/auth"
	"polder-server/internal/logging"
	"polder-server/internal/sso"
)

var ssoLog = logging.For("sso")

type redirectOutput struct {
	Status       int
	Location     string `header:"Location"`
	CacheControl string `header:"Cache-Control"`
}

func redirectTo(location string) *redirectOutput {
	return &redirectOutput{Status: http.StatusFound, Location: location, CacheControl: "no-store"}
}

func found(operation *huma.Operation) {
	operation.DefaultStatus = http.StatusFound
}

type ssoAuthorizeInput struct {
	ProviderID    string `path:"providerID"`
	RedirectURI   string `query:"redirect_uri" required:"true" doc:"Where the app waits for the result: polder://auth, a loopback address or the web app"`
	CodeChallenge string `query:"code_challenge" required:"true" doc:"PKCE S256 challenge of a verifier the app keeps"`
	DeviceName    string `query:"device_name" doc:"Name of the device the session is for"`
}

type ssoCallbackInput struct {
	ProviderID string `path:"providerID"`
	Code       string `query:"code"`
	State      string `query:"state"`
	Error      string `query:"error"`
}

type ssoTokenRequest struct {
	Code         string `json:"code" doc:"The code the app received on its redirect URI"`
	CodeVerifier string `json:"codeVerifier" doc:"The PKCE verifier the challenge was made from"`
	DeviceName   string `json:"deviceName,omitempty" required:"false" doc:"Name of the device the session is for"`
}

type ssoTokenInput struct {
	Body    ssoTokenRequest
	address string
}

func (i *ssoTokenInput) Resolve(ctx huma.Context) []error {
	i.address = clientAddress(ctx.RemoteAddr())
	return nil
}

type linkIdentityRequest struct {
	RedirectURI   string `json:"redirectUri" doc:"Where the app waits for the result; it gets code=<code> for POST /account/identities/confirm, or error=<reason>"`
	CodeChallenge string `json:"codeChallenge" doc:"PKCE S256 challenge of a verifier the app keeps"`
}

type confirmLinkRequest struct {
	Code         string `json:"code" doc:"The code the app received on its redirect URI"`
	CodeVerifier string `json:"codeVerifier" doc:"The PKCE verifier the challenge was made from"`
}

type linkedProvider struct {
	ProviderID string `json:"providerId"`
}

type linkIdentityInput struct {
	ProviderID string `path:"providerID"`
	Body       linkIdentityRequest
}

type linkIdentityStart struct {
	URL string `json:"url" doc:"Open this in a browser to sign in at the provider"`
}

type identityPath struct {
	IdentityID int64 `path:"identityID"`
}

type providerPath struct {
	ProviderID string `path:"providerID"`
}

type updateProviderInput struct {
	ProviderID string `path:"providerID"`
	Body       sso.AuthProviderChanges
}

type providerOrder struct {
	IDs []string `json:"ids" doc:"Every provider id, in the order the login screen shows them"`
}

type authProviderTest struct {
	OK      bool   `json:"ok"`
	Message string `json:"message,omitempty" required:"false"`
}

func (a *API) ssoAuthorize(ctx context.Context, input *ssoAuthorizeInput) (*redirectOutput, error) {
	target, err := a.sso.Authorize(ctx, input.ProviderID, sso.AuthorizeRequest{
		RedirectURI:   input.RedirectURI,
		CodeChallenge: input.CodeChallenge,
		DeviceName:    input.DeviceName,
	})
	if err != nil {
		return nil, err
	}
	return redirectTo(target), nil
}

func (a *API) ssoCallback(ctx context.Context, input *ssoCallbackInput) (*redirectOutput, error) {
	result, err := a.sso.Callback(ctx, input.ProviderID, input.Code, input.State, input.Error)
	if err != nil {
		return nil, err
	}
	if result.Failure != "" {
		ssoLog.Info("single sign-on ended without signing in", "provider", input.ProviderID, "reason", result.Failure)
	}
	return redirectTo(result.Redirect), nil
}

func (a *API) ssoToken(ctx context.Context, input *ssoTokenInput) (*jsonBody[auth.TokenPair], error) {
	done, allowed := a.limiter.attempt(input.address)
	if !allowed {
		return nil, errTooManyAttempts
	}
	tokens, err := a.sso.Exchange(ctx, input.Body.Code, input.Body.CodeVerifier, input.Body.DeviceName)
	done(apperr.Is(err, apperr.KindUnauthorized))
	if err != nil {
		return nil, err
	}
	device := cmp.Or(input.Body.DeviceName, auth.UnknownDevice)
	authLog.Info("logged in with single sign-on", "user", tokens.User.Username, "device", device, "address", input.address)
	a.emails.SignedIn(tokens.User, input.address, device)
	return respond(tokens), nil
}

func (a *API) listIdentities(ctx context.Context, _ *struct{}) (*jsonBody[[]sso.LinkedIdentity], error) {
	identities, err := a.sso.Identities(ctx, currentUser(ctx).ID)
	if err != nil {
		return nil, err
	}
	return respond(identities), nil
}

func (a *API) linkIdentity(ctx context.Context, input *linkIdentityInput) (*jsonBody[linkIdentityStart], error) {
	target, err := a.sso.Authorize(ctx, input.ProviderID, sso.AuthorizeRequest{
		RedirectURI:   input.Body.RedirectURI,
		CodeChallenge: input.Body.CodeChallenge,
		LinkUserID:    currentUser(ctx).ID,
	})
	if err != nil {
		return nil, err
	}
	return respond(linkIdentityStart{URL: target}), nil
}

func (a *API) confirmLinkIdentity(ctx context.Context, input *jsonBody[confirmLinkRequest]) (*jsonBody[linkedProvider], error) {
	user := currentUser(ctx)
	providerID, err := a.sso.ConfirmLink(ctx, user.ID, input.Body.Code, input.Body.CodeVerifier)
	if err != nil {
		return nil, err
	}
	ssoLog.Info("account linked", "user", user.Username, "provider", providerID)
	return respond(linkedProvider{ProviderID: providerID}), nil
}

func (a *API) unlinkIdentity(ctx context.Context, input *identityPath) (*struct{}, error) {
	user := currentUser(ctx)
	if err := a.sso.Unlink(ctx, user, input.IdentityID); err != nil {
		return nil, err
	}
	ssoLog.Info("account unlinked", "user", user.Username, "identity", input.IdentityID)
	return nil, nil
}

func (a *API) listProviderPresets(context.Context, *struct{}) (*jsonBody[[]sso.AuthProviderPreset], error) {
	return respond(sso.Presets()), nil
}

func (a *API) listAuthProviders(ctx context.Context, _ *struct{}) (*jsonBody[[]sso.AuthProvider], error) {
	providers, err := a.sso.Providers(ctx)
	if err != nil {
		return nil, err
	}
	return respond(providers), nil
}

func (a *API) createAuthProvider(ctx context.Context, input *jsonBody[sso.NewAuthProvider]) (*jsonBody[sso.AuthProvider], error) {
	provider, err := a.sso.CreateProvider(ctx, input.Body)
	if err != nil {
		return nil, err
	}
	ssoLog.Info("sign-in provider added", "provider", provider.ID, "preset", provider.Preset, "by", currentUser(ctx).Username)
	return respond(provider), nil
}

func (a *API) updateAuthProvider(ctx context.Context, input *updateProviderInput) (*jsonBody[sso.AuthProvider], error) {
	provider, err := a.sso.UpdateProvider(ctx, input.ProviderID, input.Body)
	if err != nil {
		return nil, err
	}
	ssoLog.Info("sign-in provider changed", "provider", provider.ID, "fields", changedFields(input.Body), "by", currentUser(ctx).Username)
	return respond(provider), nil
}

func (a *API) deleteAuthProvider(ctx context.Context, input *providerPath) (*struct{}, error) {
	if err := a.sso.DeleteProvider(ctx, input.ProviderID); err != nil {
		return nil, err
	}
	ssoLog.Info("sign-in provider removed", "provider", input.ProviderID, "by", currentUser(ctx).Username)
	return nil, nil
}

func (a *API) reorderAuthProviders(ctx context.Context, input *jsonBody[providerOrder]) (*jsonBody[[]sso.AuthProvider], error) {
	providers, err := a.sso.ReorderProviders(ctx, input.Body.IDs)
	if err != nil {
		return nil, err
	}
	return respond(providers), nil
}

func (a *API) testAuthProvider(ctx context.Context, input *providerPath) (*jsonBody[authProviderTest], error) {
	err := a.sso.TestProvider(ctx, input.ProviderID)
	if apperr.Is(err, apperr.KindNotFound) {
		return nil, err
	}
	if err != nil {
		return respond(authProviderTest{Message: err.Error()}), nil
	}
	return respond(authProviderTest{OK: true}), nil
}
