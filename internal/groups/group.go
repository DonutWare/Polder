package groups

import (
	"strings"
	"time"
	"unicode/utf8"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

const maxNameLength = 64

type Role string

const (
	RoleAdmin  Role = "admin"
	RoleMember Role = "member"
	RoleViewer Role = "viewer"
)

func (Role) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(RoleAdmin), string(RoleMember), string(RoleViewer)}
	return s
}

func (r Role) validate() error {
	if r != RoleAdmin && r != RoleMember && r != RoleViewer {
		return apperr.Invalid("role must be %q, %q or %q", RoleAdmin, RoleMember, RoleViewer)
	}
	return nil
}

func (r Role) CanShare() bool { return r == RoleAdmin || r == RoleMember }

type Group struct {
	ID          int64              `json:"id"`
	Name        string             `json:"name"`
	MemberCount int                `json:"memberCount"`
	CreatedAt   time.Time          `json:"createdAt"`
	CreatedBy   *users.UserSummary `json:"createdBy,omitempty" required:"false"`
	MyRole      *Role              `json:"myRole,omitempty" required:"false" doc:"The logged-in user's role; absent when they are not a member"`
	createdByID int64
}

type Member struct {
	User users.UserSummary `json:"user"`
	Role Role              `json:"role"`
}

type GroupDetails struct {
	Group     Group    `json:"group"`
	Members   []Member `json:"members"`
	CanManage bool     `json:"canManage" doc:"Whether the logged-in user may rename the group, delete it and change its members"`
}

type GroupNameRequest struct {
	Name string `json:"name" minLength:"1" maxLength:"64"`
}

type NewMember struct {
	UserID int64 `json:"userId"`
	Role   Role  `json:"role" required:"false" default:"member"`
}

type RoleChange struct {
	Role Role `json:"role"`
}

type Scope string

const (
	ScopeMine Scope = "mine"
	ScopeAll  Scope = "all"
)

func (Scope) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(ScopeMine), string(ScopeAll)}
	return s
}

func normalizeName(raw string) (string, error) {
	name := strings.TrimSpace(raw)
	if name == "" || utf8.RuneCountInString(name) > maxNameLength {
		return "", apperr.Invalid("group name must be 1-%d characters", maxNameLength)
	}
	return name, nil
}
