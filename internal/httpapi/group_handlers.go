package httpapi

import (
	"context"

	"polder-server/internal/groups"
	"polder-server/internal/sharing"
	"polder-server/internal/users"
)

const directoryLimit = 20

type groupsInput struct {
	Scope groups.Scope `query:"scope" default:"mine" doc:"mine: groups the logged-in user is in or created; all: every group, for administrators"`
}

type groupPath struct {
	GroupID int64 `path:"groupID"`
}

type renameGroupInput struct {
	GroupID int64 `path:"groupID"`
	Body    groups.GroupNameRequest
}

type addMemberInput struct {
	GroupID int64 `path:"groupID"`
	Body    groups.NewMember
}

type memberPath struct {
	GroupID int64 `path:"groupID"`
	UserID  int64 `path:"userID"`
}

type setRoleInput struct {
	GroupID int64 `path:"groupID"`
	UserID  int64 `path:"userID"`
	Body    groups.RoleChange
}

type directoryInput struct {
	Query string `query:"q" maxLength:"100" doc:"Part of a username, name or group name; empty lists the first matches"`
}

type directoryResponse struct {
	Users  []users.UserSummary `json:"users"`
	Groups []groups.Group      `json:"groups" doc:"Only groups the logged-in user may share with"`
}

func (a *API) listGroups(ctx context.Context, input *groupsInput) (*jsonBody[[]groups.Group], error) {
	list, err := a.groups.List(ctx, currentUser(ctx), input.Scope)
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) createGroup(ctx context.Context, input *jsonBody[groups.GroupNameRequest]) (*jsonBody[groups.Group], error) {
	group, err := a.groups.Create(ctx, currentUser(ctx), input.Body.Name)
	if err != nil {
		return nil, err
	}
	usersLog.Info("group created", "group", group.Name, "by", currentUser(ctx).Username)
	return respond(group), nil
}

func (a *API) getGroup(ctx context.Context, input *groupPath) (*jsonBody[groups.GroupDetails], error) {
	details, err := a.groups.Details(ctx, currentUser(ctx), input.GroupID)
	if err != nil {
		return nil, err
	}
	return respond(details), nil
}

func (a *API) renameGroup(ctx context.Context, input *renameGroupInput) (*jsonBody[groups.Group], error) {
	group, err := a.groups.Rename(ctx, currentUser(ctx), input.GroupID, input.Body.Name)
	if err != nil {
		return nil, err
	}
	return respond(group), nil
}

func (a *API) deleteGroup(ctx context.Context, input *groupPath) (*struct{}, error) {
	if err := a.groups.Delete(ctx, currentUser(ctx), input.GroupID); err != nil {
		return nil, err
	}
	usersLog.Info("group deleted", "group", input.GroupID, "by", currentUser(ctx).Username)
	return nil, nil
}

func (a *API) addGroupMember(ctx context.Context, input *addMemberInput) (*jsonBody[groups.GroupDetails], error) {
	details, err := a.groups.AddMember(ctx, currentUser(ctx), input.GroupID, input.Body)
	if err != nil {
		return nil, err
	}
	return respond(details), nil
}

func (a *API) setGroupMemberRole(ctx context.Context, input *setRoleInput) (*jsonBody[groups.GroupDetails], error) {
	details, err := a.groups.SetRole(ctx, currentUser(ctx), input.GroupID, input.UserID, input.Body.Role)
	if err != nil {
		return nil, err
	}
	return respond(details), nil
}

func (a *API) removeGroupMember(ctx context.Context, input *memberPath) (*struct{}, error) {
	return nil, a.groups.RemoveMember(ctx, currentUser(ctx), input.GroupID, input.UserID)
}

func (a *API) listGroupShares(ctx context.Context, input *groupPath) (*jsonBody[[]sharing.Share], error) {
	list, err := a.sharing.GroupShares(ctx, currentUser(ctx), input.GroupID)
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) searchDirectory(ctx context.Context, input *directoryInput) (*jsonBody[directoryResponse], error) {
	me := currentUser(ctx)
	allUsers, err := a.users.Store().List(ctx)
	if err != nil {
		return nil, err
	}
	shareable, err := a.groups.Shareable(ctx, me)
	if err != nil {
		return nil, err
	}
	found := directoryResponse{Users: []users.UserSummary{}, Groups: []groups.Group{}}
	for _, user := range allUsers {
		if user.ID != me.ID && !user.Disabled && user.Matches(input.Query) && len(found.Users) < directoryLimit {
			found.Users = append(found.Users, user.Summary())
		}
	}
	for _, group := range shareable {
		if users.MatchesAny(input.Query, group.Name) && len(found.Groups) < directoryLimit {
			found.Groups = append(found.Groups, group)
		}
	}
	return respond(found), nil
}
