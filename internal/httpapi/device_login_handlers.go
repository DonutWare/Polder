package httpapi

import (
	"context"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/auth"
)

type deviceLoginRequest struct {
	Username   string `json:"username,omitempty" required:"false" doc:"Sign in without a password: a signed-in device of this account approves"`
	Challenge  string `json:"challenge,omitempty" required:"false" doc:"Instead of the authenticator code: the challenge from the two_factor_required answer"`
	DeviceName string `json:"deviceName,omitempty" required:"false" doc:"Name of the device the session is for; shown when approving"`
}

type deviceLoginInput struct {
	Body    deviceLoginRequest
	address string
}

func (i *deviceLoginInput) Resolve(ctx huma.Context) []error {
	i.address = clientAddress(ctx.RemoteAddr())
	return nil
}

type pollTokenBody struct {
	PollToken string `json:"pollToken"`
}

type deviceLoginStatusInput struct {
	RequestID string `path:"requestID"`
	Body      pollTokenBody
	address   string
}

func (i *deviceLoginStatusInput) Resolve(ctx huma.Context) []error {
	i.address = clientAddress(ctx.RemoteAddr())
	return nil
}

type loginRequestPath struct {
	RequestID string `path:"requestID"`
}

type approveLoginInput struct {
	RequestID string `path:"requestID"`
	Body      struct {
		Number int `json:"number" doc:"The number the new device shows"`
	}
}

func (a *API) startDeviceLogin(ctx context.Context, input *deviceLoginInput) (*jsonBody[auth.DeviceLoginStart], error) {
	keys := []string{input.address}
	if input.Body.Username != "" {
		keys = append(keys, "login:"+input.Body.Username)
	}
	if a.deviceLoginLimiter.blocked(keys...) {
		return nil, apperr.New(apperr.KindRateLimited, "too many sign-in requests, try again in a minute")
	}
	a.deviceLoginLimiter.fail(keys...)
	started, err := a.auth.StartDeviceLogin(ctx, auth.DeviceLoginRequest{
		Username:   input.Body.Username,
		Challenge:  input.Body.Challenge,
		DeviceName: input.Body.DeviceName,
		Address:    input.address,
	})
	if err != nil {
		return nil, err
	}
	authLog.Info("sign-in waiting for approval on another device", "login", input.Body.Username, "device", input.Body.DeviceName,
		"address", input.address, "secondFactor", input.Body.Challenge != "")
	return respond(started), nil
}

func (a *API) deviceLoginStatus(ctx context.Context, input *deviceLoginStatusInput) (*jsonBody[auth.DeviceLoginResult], error) {
	result, err := a.auth.DeviceLoginStatus(ctx, input.RequestID, input.Body.PollToken)
	if err != nil {
		return nil, err
	}
	if result.Tokens != nil {
		user := result.Tokens.User
		authLog.Info("logged in with approval from another device", "user", user.Username, "device", result.Device, "address", input.address)
		a.emails.SignedIn(user, input.address, result.Device)
	}
	return respond(result), nil
}

func (a *API) cancelDeviceLogin(_ context.Context, input *deviceLoginStatusInput) (*struct{}, error) {
	return nil, a.auth.CancelDeviceLogin(input.RequestID, input.Body.PollToken)
}

func (a *API) listLoginRequests(ctx context.Context, _ *struct{}) (*jsonBody[[]activity.LoginRequest], error) {
	return respond(a.auth.PendingLoginRequests(currentUser(ctx).ID)), nil
}

func (a *API) approveLoginRequest(ctx context.Context, input *approveLoginInput) (*struct{}, error) {
	user := currentUser(ctx)
	err := a.auth.ApproveLoginRequest(currentIdentity(ctx), input.RequestID, input.Body.Number)
	if apperr.Is(err, apperr.KindForbidden) {
		authLog.Warn("sign-in refused: the wrong number was typed", "user", user.Username, "device", currentIdentity(ctx).Device)
	}
	if err != nil {
		return nil, err
	}
	authLog.Info("sign-in approved", "user", user.Username, "by", currentIdentity(ctx).Device)
	return nil, nil
}

func (a *API) denyLoginRequest(ctx context.Context, input *loginRequestPath) (*struct{}, error) {
	user := currentUser(ctx)
	if err := a.auth.DenyLoginRequest(user, input.RequestID); err != nil {
		return nil, err
	}
	authLog.Info("sign-in denied", "user", user.Username, "by", currentIdentity(ctx).Device)
	return nil, nil
}
