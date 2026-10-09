package httpapi

import (
	"context"

	"polder-server/internal/apperr"
	"polder-server/internal/settings"
	"polder-server/internal/users"
)

const maxAvatarBytes = 2 << 20

type avatarPath struct {
	UserID  int64  `path:"userID"`
	ImageID string `path:"imageID"`
}

func (a *API) setProfile(ctx context.Context, input *jsonBody[users.Profile]) (*jsonBody[users.User], error) {
	updated, err := a.users.SetProfile(ctx, currentUser(ctx).ID, input.Body)
	if err != nil {
		return nil, err
	}
	return respond(updated), nil
}

func (a *API) setAppearance(ctx context.Context, input *jsonBody[users.Appearance]) (*jsonBody[users.User], error) {
	updated, err := a.users.SetAppearance(ctx, currentUser(ctx).ID, input.Body)
	if err != nil {
		return nil, err
	}
	return respond(updated), nil
}

func (a *API) setAvatar(ctx context.Context, input *imageUpload) (*jsonBody[users.User], error) {
	owner := currentUser(ctx)
	content, err := readImage(input.content, maxAvatarBytes)
	if err != nil {
		return nil, err
	}
	info, err := a.avatars.Save(owner.ID, content)
	if err != nil {
		return nil, err
	}
	if err := a.users.Store().SetAvatar(ctx, owner.ID, &users.Avatar{ID: info.ID, ContentType: info.ContentType}); err != nil {
		return nil, err
	}
	return a.freshUser(ctx, owner.ID)
}

func (a *API) removeAvatar(ctx context.Context, _ *struct{}) (*jsonBody[users.User], error) {
	owner := currentUser(ctx)
	if err := a.users.Store().SetAvatar(ctx, owner.ID, nil); err != nil {
		return nil, err
	}
	if err := a.avatars.Remove(owner.ID); err != nil {
		return nil, err
	}
	return a.freshUser(ctx, owner.ID)
}

func (a *API) freshUser(ctx context.Context, id int64) (*jsonBody[users.User], error) {
	updated, err := a.users.Store().ByID(ctx, id)
	if err != nil {
		return nil, err
	}
	return respond(updated), nil
}

func (a *API) userAvatar(ctx context.Context, input *avatarPath) (*imageOutput, error) {
	owner, err := a.users.Store().ByID(ctx, input.UserID)
	if err != nil {
		return nil, err
	}
	if owner.Avatar == nil || owner.Avatar.ID != input.ImageID {
		return nil, apperr.NotFound("no such icon")
	}
	return imageResponse(a.avatars.Read(owner.ID, settings.ImageInfo{ID: owner.Avatar.ID, ContentType: owner.Avatar.ContentType}))
}
