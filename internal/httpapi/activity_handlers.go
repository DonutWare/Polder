package httpapi

import (
	"context"
	"strconv"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

type activityInput struct {
	User   string `query:"user" default:"me" doc:"me, all, or a user id; anything but your own activity needs the administrator role"`
	Before int64  `query:"before" doc:"Cursor from the previous page; 0 starts at the newest"`
	Limit  int    `query:"limit" default:"50" doc:"Maximum number of entries to return; the server caps it"`
}

type liveTransfersInput struct {
	User string `query:"user" default:"me" doc:"me, all, or a user id; anything but your own transfers needs the administrator role"`
}

type liveTransfers struct {
	Transfers []activity.LiveTransfer `json:"transfers"`
}

func (a *API) listActivity(ctx context.Context, input *activityInput) (*jsonBody[activity.LogPage], error) {
	scope, err := a.resolveScope(ctx, currentUser(ctx), input.User)
	if err != nil {
		return nil, err
	}
	filter := activity.Filter{UserID: scope.Self, Before: input.Before, Limit: input.Limit}
	switch {
	case scope.All:
		filter.UserID = 0
	case scope.UserID != 0:
		filter.UserID = scope.UserID
	}
	page, err := a.activity.Store().List(ctx, filter)
	if err != nil {
		return nil, err
	}
	return respond(page), nil
}

func (a *API) listLiveTransfers(ctx context.Context, input *liveTransfersInput) (*jsonBody[liveTransfers], error) {
	scope, err := a.resolveScope(ctx, currentUser(ctx), input.User)
	if err != nil {
		return nil, err
	}
	if scope.UserID != 0 {
		scope = activity.Scope{Self: scope.UserID}
	}
	return respond(liveTransfers{Transfers: a.activity.Snapshot(scope)}), nil
}

// resolveScope turns me, all or a user id into whose activity the viewer gets to see.
func (a *API) resolveScope(ctx context.Context, viewer users.User, raw string) (activity.Scope, error) {
	scope := activity.Scope{Self: viewer.ID}
	if raw == "" || raw == "me" {
		return scope, nil
	}
	if !viewer.IsAdmin() {
		return activity.Scope{}, apperr.Forbidden("only administrators can see other users' activity")
	}
	if raw == "all" {
		scope.All = true
		return scope, nil
	}
	userID, err := strconv.ParseInt(raw, 10, 64)
	if err != nil {
		return activity.Scope{}, apperr.Invalid("user must be me, all or a user id")
	}
	if userID == viewer.ID {
		return scope, nil
	}
	if _, err := a.users.Store().ByID(ctx, userID); err != nil {
		return activity.Scope{}, err
	}
	scope.UserID = userID
	return scope, nil
}
