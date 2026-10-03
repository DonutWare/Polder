package httpapi

import (
	"context"

	"nomad-server/internal/users"
)

type userPath struct {
	UserID int64 `path:"userID"`
}

type updateUserInput struct {
	UserID int64 `path:"userID"`
	Body   users.Changes
}

func (a *API) listUsers(ctx context.Context, _ *struct{}) (*jsonBody[[]users.User], error) {
	list, err := a.users.Store().List(ctx)
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) createUser(ctx context.Context, input *jsonBody[users.NewUser]) (*jsonBody[users.User], error) {
	created, err := a.users.Create(ctx, input.Body)
	if err != nil {
		return nil, err
	}
	return respond(created), nil
}

func (a *API) updateUser(ctx context.Context, input *updateUserInput) (*jsonBody[users.User], error) {
	changes := input.Body
	updated, err := a.users.Update(ctx, currentUser(ctx), input.UserID, changes)
	if err != nil {
		return nil, err
	}
	if changes.Password != nil || updated.Disabled {
		if err := a.sessions.RevokeAllForUser(ctx, input.UserID); err != nil {
			return nil, err
		}
	}
	return respond(updated), nil
}

func (a *API) deleteUser(ctx context.Context, input *userPath) (*struct{}, error) {
	return nil, a.users.Delete(ctx, currentUser(ctx), input.UserID)
}
