package httpapi

import (
	"context"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/auth"
	"polder-server/internal/users"
)

type credentialsRequest struct {
	Username   string `json:"username"`
	Password   string `json:"password"`
	DeviceName string `json:"deviceName" required:"false" doc:"Name of the device the session is for"`
}

type refreshRequest struct {
	RefreshToken string `json:"refreshToken"`
}

type setupStatus struct {
	NeedsSetup bool `json:"needsSetup" doc:"True until the first administrator account exists"`
}

type loginInput struct {
	Body    credentialsRequest
	address string
}

func (i *loginInput) Resolve(ctx huma.Context) []error {
	i.address = clientAddress(ctx.RemoteAddr())
	return nil
}

func (a *API) setupStatus(ctx context.Context, _ *struct{}) (*jsonBody[setupStatus], error) {
	needsSetup, err := a.auth.NeedsSetup(ctx)
	if err != nil {
		return nil, err
	}
	return respond(setupStatus{NeedsSetup: needsSetup}), nil
}

func (a *API) setup(ctx context.Context, input *jsonBody[credentialsRequest]) (*jsonBody[auth.TokenPair], error) {
	tokens, err := a.auth.Setup(ctx, input.Body.Username, input.Body.Password, input.Body.DeviceName)
	if err != nil {
		return nil, err
	}
	return respond(tokens), nil
}

func (a *API) login(ctx context.Context, input *loginInput) (*jsonBody[auth.TokenPair], error) {
	if !a.limiter.allowed(input.address) {
		return nil, apperr.New(apperr.KindRateLimited, "too many failed attempts, try again in a minute")
	}
	tokens, err := a.auth.Login(ctx, input.Body.Username, input.Body.Password, input.Body.DeviceName)
	if apperr.Is(err, apperr.KindUnauthorized) {
		a.limiter.recordFailure(input.address)
	}
	if err != nil {
		return nil, err
	}
	return respond(tokens), nil
}

func (a *API) refresh(ctx context.Context, input *jsonBody[refreshRequest]) (*jsonBody[auth.TokenPair], error) {
	tokens, err := a.auth.Refresh(ctx, input.Body.RefreshToken)
	if err != nil {
		return nil, err
	}
	return respond(tokens), nil
}

func (a *API) logout(ctx context.Context, input *jsonBody[refreshRequest]) (*struct{}, error) {
	return nil, a.auth.Logout(ctx, input.Body.RefreshToken)
}

func (a *API) me(ctx context.Context, _ *struct{}) (*jsonBody[users.User], error) {
	return respond(currentUser(ctx)), nil
}
