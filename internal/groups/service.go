package groups

import (
	"context"
	"sort"
	"strings"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

type Service struct {
	store *Store
	users *users.Store
}

func NewService(store *Store, userStore *users.Store) *Service {
	return &Service{store: store, users: userStore}
}

func (s *Service) ByID(ctx context.Context, id int64) (Group, error) {
	return s.store.ByID(ctx, id)
}

func (s *Service) List(ctx context.Context, actor users.User, scope Scope) ([]Group, error) {
	var list []Group
	var err error
	switch scope {
	case ScopeAll:
		if !actor.IsAdmin() {
			return nil, apperr.Forbidden("only administrators can see all groups")
		}
		list, err = s.store.List(ctx)
	default:
		list, err = s.store.Visible(ctx, actor.ID)
	}
	if err != nil {
		return nil, err
	}
	return s.describeAll(ctx, actor, list)
}

func (s *Service) Shareable(ctx context.Context, actor users.User) ([]Group, error) {
	list, err := s.store.ShareableFor(ctx, actor.ID)
	if err != nil {
		return nil, err
	}
	return s.describeAll(ctx, actor, list)
}

func (s *Service) describeAll(ctx context.Context, actor users.User, list []Group) ([]Group, error) {
	for i := range list {
		if err := s.describe(ctx, actor, &list[i]); err != nil {
			return nil, err
		}
	}
	return list, nil
}

func (s *Service) describe(ctx context.Context, actor users.User, group *Group) error {
	if group.createdByID != 0 {
		if creator, err := s.users.ByID(ctx, group.createdByID); err == nil {
			summary := creator.Summary()
			group.CreatedBy = &summary
		}
	}
	role, member, err := s.store.Role(ctx, group.ID, actor.ID)
	if err != nil {
		return err
	}
	if member {
		group.MyRole = &role
	}
	return nil
}

func (s *Service) Create(ctx context.Context, actor users.User, rawName string) (Group, error) {
	name, err := normalizeName(rawName)
	if err != nil {
		return Group{}, err
	}
	id, err := s.store.Insert(ctx, name, actor.ID)
	if err != nil {
		return Group{}, err
	}
	return s.visible(ctx, actor, id)
}

func (s *Service) visible(ctx context.Context, actor users.User, id int64) (Group, error) {
	group, err := s.store.ByID(ctx, id)
	if err != nil {
		return Group{}, err
	}
	if err := s.describe(ctx, actor, &group); err != nil {
		return Group{}, err
	}
	if group.MyRole == nil && !actor.IsAdmin() {
		return Group{}, notFound()
	}
	return group, nil
}

func (s *Service) managed(ctx context.Context, actor users.User, id int64) (Group, error) {
	group, err := s.visible(ctx, actor, id)
	if err != nil {
		return Group{}, err
	}
	if !canManage(actor, group) {
		return Group{}, apperr.Forbidden("only group admins can do this")
	}
	return group, nil
}

func canManage(actor users.User, group Group) bool {
	return actor.IsAdmin() || (group.MyRole != nil && *group.MyRole == RoleAdmin)
}

func (s *Service) Details(ctx context.Context, actor users.User, id int64) (GroupDetails, error) {
	group, err := s.visible(ctx, actor, id)
	if err != nil {
		return GroupDetails{}, err
	}
	roles, err := s.store.Members(ctx, id)
	if err != nil {
		return GroupDetails{}, err
	}
	members := []Member{}
	for userID, role := range roles {
		user, err := s.users.ByID(ctx, userID)
		if err != nil {
			continue
		}
		members = append(members, Member{User: user.Summary(), Role: role})
	}
	sort.Slice(members, func(i, j int) bool {
		if rank(members[i].Role) != rank(members[j].Role) {
			return rank(members[i].Role) < rank(members[j].Role)
		}
		return strings.ToLower(members[i].User.DisplayName) < strings.ToLower(members[j].User.DisplayName)
	})
	return GroupDetails{Group: group, Members: members, CanManage: canManage(actor, group)}, nil
}

func rank(role Role) int {
	switch role {
	case RoleAdmin:
		return 0
	case RoleMember:
		return 1
	}
	return 2
}

func (s *Service) Rename(ctx context.Context, actor users.User, id int64, rawName string) (Group, error) {
	if _, err := s.managed(ctx, actor, id); err != nil {
		return Group{}, err
	}
	name, err := normalizeName(rawName)
	if err != nil {
		return Group{}, err
	}
	if err := s.store.Rename(ctx, id, name); err != nil {
		return Group{}, err
	}
	return s.visible(ctx, actor, id)
}

func (s *Service) Delete(ctx context.Context, actor users.User, id int64) error {
	if _, err := s.managed(ctx, actor, id); err != nil {
		return err
	}
	return s.store.Delete(ctx, id)
}

func (s *Service) AddMember(ctx context.Context, actor users.User, id int64, member NewMember) (GroupDetails, error) {
	if member.Role == "" {
		member.Role = RoleMember
	}
	if err := member.Role.validate(); err != nil {
		return GroupDetails{}, err
	}
	if _, err := s.managed(ctx, actor, id); err != nil {
		return GroupDetails{}, err
	}
	user, err := s.users.ByID(ctx, member.UserID)
	if err != nil || user.Disabled {
		return GroupDetails{}, apperr.Invalid("no such user")
	}
	if err := s.store.AddMember(ctx, id, user.ID, member.Role); err != nil {
		return GroupDetails{}, err
	}
	return s.Details(ctx, actor, id)
}

func (s *Service) SetRole(ctx context.Context, actor users.User, id, userID int64, role Role) (GroupDetails, error) {
	if err := role.validate(); err != nil {
		return GroupDetails{}, err
	}
	if _, err := s.managed(ctx, actor, id); err != nil {
		return GroupDetails{}, err
	}
	if role != RoleAdmin {
		if err := s.keepAnAdmin(ctx, id, userID); err != nil {
			return GroupDetails{}, err
		}
	}
	if err := s.store.SetRole(ctx, id, userID, role); err != nil {
		return GroupDetails{}, err
	}
	return s.Details(ctx, actor, id)
}

func (s *Service) RemoveMember(ctx context.Context, actor users.User, id, userID int64) error {
	if userID == actor.ID {
		group, err := s.visible(ctx, actor, id)
		if err != nil {
			return err
		}
		if group.MyRole != nil && group.MemberCount == 1 {
			return s.store.Delete(ctx, id)
		}
	} else if _, err := s.managed(ctx, actor, id); err != nil {
		return err
	}
	if err := s.keepAnAdmin(ctx, id, userID); err != nil {
		return err
	}
	return s.store.RemoveMember(ctx, id, userID)
}

func (s *Service) keepAnAdmin(ctx context.Context, id, userID int64) error {
	role, member, err := s.store.Role(ctx, id, userID)
	if err != nil || !member || role != RoleAdmin {
		return err
	}
	admins, err := s.store.AdminCount(ctx, id)
	if err != nil {
		return err
	}
	if admins <= 1 {
		return apperr.Invalid("a group needs at least one admin; make someone else admin or delete the group")
	}
	return nil
}

func (s *Service) RoleOf(ctx context.Context, groupID, userID int64) (Role, bool, error) {
	return s.store.Role(ctx, groupID, userID)
}

func (s *Service) CanManage(ctx context.Context, actor users.User, groupID int64) bool {
	group, err := s.visible(ctx, actor, groupID)
	return err == nil && canManage(actor, group)
}
