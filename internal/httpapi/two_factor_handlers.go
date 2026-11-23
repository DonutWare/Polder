package httpapi

import (
	"cmp"
	"context"
	"strconv"
	"time"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/auth"
	"polder-server/internal/users"
)

type secondFactorRequest struct {
	Challenge    string `json:"challenge" doc:"The challenge from the two_factor_required answer to the login"`
	Code         string `json:"code,omitempty" required:"false" doc:"The six-digit code from the authenticator app"`
	RecoveryCode string `json:"recoveryCode,omitempty" required:"false" doc:"One of the recovery codes, instead of a code from the app"`
	DeviceName   string `json:"deviceName,omitempty" required:"false" doc:"Name of the device the session is for"`
}

type secondFactorInput struct {
	Body    secondFactorRequest
	address string
}

func (i *secondFactorInput) Resolve(ctx huma.Context) []error {
	i.address = clientAddress(ctx.RemoteAddr())
	return nil
}

type twoFactorPasswordRequest struct {
	Password string `json:"password" required:"false" doc:"The account password; accounts without one leave it out"`
}

type twoFactorCodeRequest struct {
	Code string `json:"code" doc:"The six-digit code from the authenticator app"`
}

type twoFactorSettings struct {
	auth.TwoFactorState
	Required bool       `json:"required" doc:"Whether the server requires two-factor authentication for this account"`
	Deadline *time.Time `json:"deadline,omitempty" required:"false" doc:"When it must be set up by"`
}

func (a *API) verifyTwoFactor(ctx context.Context, input *secondFactorInput) (*jsonBody[auth.TokenPair], error) {
	pending, err := a.auth.OpenChallenge(input.Body.Challenge)
	if err != nil {
		return nil, err
	}
	done, allowed := a.twoFactorLimiter.attempt(input.address, userLimitKey(pending.UserID))
	if !allowed {
		authLog.Warn("two-factor code refused: too many failed attempts", "user", pending.UserID, "address", input.address)
		return nil, errTooManyAttempts
	}
	factor := auth.SecondFactor{Code: input.Body.Code, RecoveryCode: input.Body.RecoveryCode}
	result, err := a.auth.CompleteSecondFactor(ctx, input.Body.Challenge, factor, input.Body.DeviceName)
	done(apperr.Is(err, apperr.KindUnauthorized))
	if err != nil {
		authLog.Warn("two-factor code refused", "user", pending.UserID, "address", input.address, "error", err)
		return nil, err
	}
	tokens := result.Tokens
	device := cmp.Or(input.Body.DeviceName, pending.Device, auth.UnknownDevice)
	authLog.Info("logged in with two-factor authentication", "user", tokens.User.Username, "device", device, "address", input.address,
		"recoveryCode", result.UsedRecoveryCode)
	a.emails.SignedIn(tokens.User, input.address, device)
	if result.UsedRecoveryCode {
		state, err := a.auth.TwoFactorState(ctx, tokens.User.ID)
		if err == nil {
			a.emails.RecoveryCodeUsed(tokens.User, state.RecoveryCodesRemaining, input.address, device)
		}
	}
	return respond(tokens), nil
}

func (a *API) getTwoFactor(ctx context.Context, _ *struct{}) (*jsonBody[twoFactorSettings], error) {
	user := currentUser(ctx)
	state, err := a.auth.TwoFactorState(ctx, user.ID)
	if err != nil {
		return nil, err
	}
	required, err := a.twoFactorPolicy.Applies(ctx, user)
	if err != nil {
		return nil, err
	}
	return respond(twoFactorSettings{TwoFactorState: state, Required: required, Deadline: user.TwoFactor.Deadline}), nil
}

func (a *API) beginTwoFactorSetup(ctx context.Context, input *jsonBody[twoFactorPasswordRequest]) (*jsonBody[auth.TwoFactorSetup], error) {
	user := currentUser(ctx)
	done, err := a.twoFactorAttempt(user)
	if err != nil {
		return nil, err
	}
	setup, err := a.auth.BeginTwoFactorSetup(ctx, user, currentIdentity(ctx).SessionID, input.Body.Password, a.brands.Current(ctx).Name)
	done(apperr.Is(err, apperr.KindForbidden))
	if err != nil {
		return nil, err
	}
	return respond(setup), nil
}

func (a *API) confirmTwoFactorSetup(ctx context.Context, input *jsonBody[twoFactorCodeRequest]) (*jsonBody[auth.RecoveryCodes], error) {
	user := currentUser(ctx)
	done, err := a.twoFactorAttempt(user)
	if err != nil {
		return nil, err
	}
	codes, err := a.auth.ConfirmTwoFactorSetup(ctx, user, input.Body.Code)
	done(apperr.Is(err, apperr.KindInvalid))
	if err != nil {
		return nil, err
	}
	authLog.Info("two-factor authentication turned on", "user", user.Username)
	a.emails.TwoFactorEnabled(user)
	return respond(codes), nil
}

func (a *API) regenerateRecoveryCodes(ctx context.Context, input *jsonBody[twoFactorPasswordRequest]) (*jsonBody[auth.RecoveryCodes], error) {
	user := currentUser(ctx)
	done, err := a.twoFactorAttempt(user)
	if err != nil {
		return nil, err
	}
	codes, err := a.auth.RegenerateRecoveryCodes(ctx, user, currentIdentity(ctx).SessionID, input.Body.Password)
	done(apperr.Is(err, apperr.KindForbidden))
	if err != nil {
		return nil, err
	}
	authLog.Info("recovery codes replaced", "user", user.Username)
	return respond(codes), nil
}

func (a *API) disableTwoFactor(ctx context.Context, input *jsonBody[twoFactorPasswordRequest]) (*struct{}, error) {
	user := currentUser(ctx)
	required, err := a.twoFactorPolicy.Applies(ctx, user)
	if err != nil {
		return nil, err
	}
	if required {
		return nil, apperr.Forbidden("your administrator requires two-factor authentication, so it can't be turned off")
	}
	done, err := a.twoFactorAttempt(user)
	if err != nil {
		return nil, err
	}
	err = a.auth.DisableTwoFactor(ctx, user, currentIdentity(ctx).SessionID, input.Body.Password)
	done(apperr.Is(err, apperr.KindForbidden))
	if err != nil {
		return nil, err
	}
	authLog.Info("two-factor authentication turned off", "user", user.Username)
	a.emails.TwoFactorDisabled(user, false)
	return nil, nil
}

func (a *API) resetUserTwoFactor(ctx context.Context, input *userPath) (*jsonBody[users.User], error) {
	target, err := a.users.Store().ByID(ctx, input.UserID)
	if err != nil {
		return nil, err
	}
	if err := a.auth.ResetTwoFactor(ctx, target.ID); err != nil {
		return nil, err
	}
	if err := a.twoFactorPolicy.TwoFactorRemoved(ctx, target.ID, time.Now()); err != nil {
		return nil, err
	}
	usersLog.Info("two-factor authentication reset; user logged out everywhere", "user", target.Username, "by", currentUser(ctx).Username)
	a.emails.TwoFactorDisabled(target, true)
	updated, err := a.users.Store().ByID(ctx, target.ID)
	if err != nil {
		return nil, err
	}
	return respond(updated), nil
}

func (a *API) extendUserTwoFactorDeadline(ctx context.Context, input *userPath) (*jsonBody[users.User], error) {
	target, err := a.users.Store().ByID(ctx, input.UserID)
	if err != nil {
		return nil, err
	}
	extended, err := a.twoFactorPolicy.Extend(ctx, target.ID, time.Now())
	if err != nil {
		return nil, err
	}
	if !extended {
		return nil, apperr.Invalid("%s doesn't need to set up two-factor authentication", target.Username)
	}
	usersLog.Info("two-factor deadline extended", "user", target.Username, "by", currentUser(ctx).Username)
	updated, err := a.users.Store().ByID(ctx, target.ID)
	if err != nil {
		return nil, err
	}
	return respond(updated), nil
}

func userLimitKey(userID int64) string {
	return "user:" + strconv.FormatInt(userID, 10)
}

func (a *API) twoFactorAttempt(user users.User) (func(failed bool), error) {
	done, allowed := a.twoFactorLimiter.attempt(userLimitKey(user.ID))
	if !allowed {
		return nil, errTooManyAttempts
	}
	return done, nil
}
