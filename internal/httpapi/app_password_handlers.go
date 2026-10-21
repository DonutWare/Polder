package httpapi

import (
	"context"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/auth"
)

type appPasswordRequest struct {
	Name            string `json:"name" maxLength:"100" doc:"What the password is for, such as the device or app using it"`
	ReadOnly        bool   `json:"readOnly,omitempty" required:"false" doc:"Only allow reading files"`
	CurrentPassword string `json:"currentPassword" doc:"The account password, to confirm it is really the user"`
}

type createAppPasswordInput struct {
	Body    appPasswordRequest
	address string
}

func (i *createAppPasswordInput) Resolve(ctx huma.Context) []error {
	i.address = clientAddress(ctx.RemoteAddr())
	return nil
}

type appPasswordPath struct {
	AppPasswordID int64 `path:"appPasswordID"`
}

func (a *API) listAppPasswords(ctx context.Context, _ *struct{}) (*jsonBody[[]auth.AppPassword], error) {
	list, err := a.auth.AppPasswords().List(ctx, currentUser(ctx).ID)
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) createAppPassword(ctx context.Context, input *createAppPasswordInput) (*jsonBody[auth.NewAppPassword], error) {
	user := currentUser(ctx)
	done, allowed := a.limiter.attempt(input.address, "user:"+user.Username)
	if !allowed {
		authLog.Warn("app password refused: too many failed attempts", "user", user.Username, "address", input.address)
		return nil, apperr.New(apperr.KindRateLimited, "too many failed attempts, try again in a minute")
	}
	created, err := a.auth.CreateAppPassword(ctx, user, input.Body.CurrentPassword, input.Body.Name, input.Body.ReadOnly)
	done(apperr.Is(err, apperr.KindForbidden))
	if err != nil {
		return nil, err
	}
	authLog.Info("app password created", "user", user.Username, "name", created.Name, "readOnly", created.ReadOnly, "address", input.address)
	return respond(created), nil
}

func (a *API) deleteAppPassword(ctx context.Context, input *appPasswordPath) (*struct{}, error) {
	user := currentUser(ctx)
	if err := a.auth.AppPasswords().Revoke(ctx, user.ID, input.AppPasswordID); err != nil {
		return nil, err
	}
	authLog.Info("app password revoked", "user", user.Username, "id", input.AppPasswordID)
	return nil, nil
}
