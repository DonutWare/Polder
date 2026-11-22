package httpapi

import (
	"context"
	"strings"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/emails"
	"polder-server/internal/logging"
)

var emailLog = logging.For("emails")

type passwordResetRequest struct {
	Login string `json:"login" maxLength:"254" doc:"The username or email address of the account"`
}

type passwordResetInput struct {
	Body    passwordResetRequest
	address string
}

func (i *passwordResetInput) Resolve(ctx huma.Context) []error {
	i.address = clientAddress(ctx.RemoteAddr())
	return nil
}

type passwordResetCodeRequest struct {
	Login    string `json:"login" maxLength:"254" doc:"The username or email address the code was asked for"`
	Code     string `json:"code" maxLength:"32" doc:"The code from the reset email, with or without its dash"`
	Password string `json:"password" maxLength:"1024" doc:"The new password"`
}

type passwordResetCodeInput struct {
	Body    passwordResetCodeRequest
	address string
}

func (i *passwordResetCodeInput) Resolve(ctx huma.Context) []error {
	i.address = clientAddress(ctx.RemoteAddr())
	return nil
}

type testEmailRequest struct {
	To string `json:"to" required:"false" maxLength:"254" doc:"Where to send the test; empty sends it to your own email address"`
}

type emailPreferences struct {
	emails.Preferences
	HasEmail bool `json:"hasEmail" doc:"Whether the user has an email address to send to"`
	Enabled  bool `json:"enabled" doc:"Whether the server can send email at all"`
}

func (a *API) requestPasswordReset(_ context.Context, input *passwordResetInput) (*struct{}, error) {
	login := strings.TrimSpace(input.Body.Login)
	done, allowed := a.resetLimiter.attempt(input.address)
	done(true)
	if !allowed {
		authLog.Warn("password reset refused: too many attempts", "address", input.address)
		return nil, apperr.New(apperr.KindRateLimited, "too many attempts, try again in a minute")
	}
	authLog.Info("password reset asked", "login", login, "address", input.address)
	a.emails.PasswordResetRequested(login, a.auth.RequestPasswordReset)
	return nil, nil
}

func (a *API) resetPasswordWithCode(ctx context.Context, input *passwordResetCodeInput) (*struct{}, error) {
	login := strings.TrimSpace(input.Body.Login)
	done, allowed := a.resetLimiter.attempt(input.address)
	if !allowed {
		authLog.Warn("password reset code refused: too many attempts", "address", input.address)
		return nil, apperr.New(apperr.KindRateLimited, "too many attempts, try again in a minute")
	}
	user, err := a.auth.ResetPassword(ctx, login, input.Body.Code, input.Body.Password)
	done(err != nil)
	if err != nil {
		authLog.Info("password reset code failed", "login", login, "address", input.address, "error", err)
		return nil, err
	}
	authLog.Info("password reset with a code; logged out everywhere", "user", user.Username, "address", input.address)
	a.emails.PasswordChanged(user, emails.PasswordChange{Address: input.address})
	return nil, nil
}

func (a *API) sendTestEmail(ctx context.Context, input *jsonBody[testEmailRequest]) (*struct{}, error) {
	to := strings.TrimSpace(input.Body.To)
	if to == "" {
		to = currentUser(ctx).Profile.Email
	}
	if to == "" {
		return nil, apperr.Invalid("add an email address to your account, or say where to send the test")
	}
	if !a.emails.Configured(ctx) {
		return nil, apperr.Invalid("set a mail server and sender address first")
	}
	if err := a.emails.SendTest(ctx, to); err != nil {
		emailLog.Warn("test email failed", "to", to, "error", err)
		return nil, apperr.Invalid("the mail server refused the test: %v", err)
	}
	emailLog.Info("test email sent", "to", to, "by", currentUser(ctx).Username)
	return nil, nil
}

func (a *API) getEmailPreferences(ctx context.Context, _ *struct{}) (*jsonBody[emailPreferences], error) {
	return a.emailPreferences(ctx)
}

func (a *API) setEmailPreferences(ctx context.Context, input *jsonBody[emails.Preferences]) (*jsonBody[emailPreferences], error) {
	if err := a.emails.Store().SetPreferences(ctx, currentUser(ctx).ID, input.Body); err != nil {
		return nil, err
	}
	return a.emailPreferences(ctx)
}

func (a *API) emailPreferences(ctx context.Context) (*jsonBody[emailPreferences], error) {
	user := currentUser(ctx)
	preferences, err := a.emails.Store().Preferences(ctx, user.ID)
	if err != nil {
		return nil, err
	}
	return respond(emailPreferences{Preferences: preferences, HasEmail: user.Profile.Email != "", Enabled: a.emails.Configured(ctx)}), nil
}
