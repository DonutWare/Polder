package httpapi

import (
	"context"
	"reflect"
	"strings"

	"polder-server/internal/logging"
	"polder-server/internal/settings"
	"polder-server/internal/users"
)

var (
	usersLog    = logging.For("users")
	settingsLog = logging.For("settings")
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
	usersLog.Info("user created", "user", created.Username, "role", created.Role, "by", currentUser(ctx).Username)
	return respond(created), nil
}

func (a *API) updateUser(ctx context.Context, input *updateUserInput) (*jsonBody[users.User], error) {
	changes := input.Body
	updated, err := a.users.Update(ctx, currentUser(ctx), input.UserID, changes)
	if err != nil {
		return nil, err
	}
	usersLog.Info("user changed", "user", updated.Username, "fields", changedFields(changes), "by", currentUser(ctx).Username)
	if changes.Password != nil || updated.Disabled {
		if err := a.sessions.RevokeAllForUser(ctx, input.UserID); err != nil {
			return nil, err
		}
		usersLog.Info("user logged out everywhere", "user", updated.Username)
	}
	return respond(updated), nil
}

func (a *API) deleteUser(ctx context.Context, input *userPath) (*struct{}, error) {
	target, err := a.users.Store().ByID(ctx, input.UserID)
	if err != nil {
		return nil, err
	}
	if err := a.users.Delete(ctx, currentUser(ctx), input.UserID); err != nil {
		return nil, err
	}
	usersLog.Info("user deleted; files archived", "user", target.Username, "by", currentUser(ctx).Username)
	return nil, nil
}

func (a *API) getServerSettings(ctx context.Context, _ *struct{}) (*jsonBody[settings.ServerSettings], error) {
	current, err := a.settings.Get(ctx)
	if err != nil {
		return nil, err
	}
	return respond(current), nil
}

func (a *API) updateServerSettings(ctx context.Context, input *jsonBody[settings.ServerSettingsChanges]) (*jsonBody[settings.ServerSettings], error) {
	updated, err := a.settings.Update(ctx, input.Body)
	if err != nil {
		return nil, err
	}
	settingsLog.Info("server settings changed", "fields", changedFields(input.Body), "by", currentUser(ctx).Username)
	return respond(updated), nil
}

func changedFields(changes any) string {
	value := reflect.ValueOf(changes)
	var names []string
	for i := range value.NumField() {
		if field := value.Field(i); field.Kind() == reflect.Pointer && !field.IsNil() {
			name, _, _ := strings.Cut(value.Type().Field(i).Tag.Get("json"), ",")
			names = append(names, name)
		}
	}
	return strings.Join(names, ",")
}
