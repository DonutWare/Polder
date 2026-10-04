package settings

import (
	"time"

	"nomad-server/internal/users"

	"github.com/danielgtaylor/huma/v2"
)

type RetentionSource string

const (
	RetentionDefault RetentionSource = "default"
	RetentionUser    RetentionSource = "user"
	RetentionServer  RetentionSource = "server"
	RetentionAdmin   RetentionSource = "admin"
)

func (RetentionSource) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(RetentionDefault), string(RetentionUser), string(RetentionServer), string(RetentionAdmin)}
	return s
}

type TrashRetention struct {
	Days        int             `json:"days" doc:"Days trashed items are kept before they're deleted permanently; 0 keeps them forever"`
	Source      RetentionSource `json:"source" doc:"Where days comes from; server and admin mean an administrator decides"`
	Locked      bool            `json:"locked" doc:"True when an administrator decides, so the user's own setting has no effect"`
	UserDays    *int            `json:"userDays,omitempty" required:"false" doc:"The user's own choice; absent when they follow the server default"`
	DefaultDays int             `json:"defaultDays" doc:"The server's default"`
}

func ResolveTrashRetention(server ServerSettings, user users.User) TrashRetention {
	retention := TrashRetention{
		Days:        server.TrashRetentionDays,
		Source:      RetentionDefault,
		UserDays:    user.TrashRetentionDays,
		DefaultDays: server.TrashRetentionDays,
	}
	switch {
	case user.TrashRetentionOverrideDays != nil:
		retention.Days, retention.Source = *user.TrashRetentionOverrideDays, RetentionAdmin
	case server.TrashRetentionEnforced:
		retention.Source = RetentionServer
	case user.TrashRetentionDays != nil:
		retention.Days, retention.Source = *user.TrashRetentionDays, RetentionUser
	}
	retention.Locked = retention.Source == RetentionAdmin || retention.Source == RetentionServer
	return retention
}

func (r TrashRetention) ExpiresAt(deletedAt time.Time) (time.Time, bool) {
	if r.Days <= 0 {
		return time.Time{}, false
	}
	return deletedAt.AddDate(0, 0, r.Days), true
}

func (r TrashRetention) Cutoff(now time.Time) (time.Time, bool) {
	if r.Days <= 0 {
		return time.Time{}, false
	}
	return now.AddDate(0, 0, -r.Days), true
}
