package settings

import (
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/users"

	"github.com/danielgtaylor/huma/v2"
)

type RetentionSource string

const (
	RetentionDefault RetentionSource = "default"
	RetentionUser    RetentionSource = "user"
)

func (RetentionSource) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(RetentionDefault), string(RetentionUser)}
	return s
}

type TrashRetention struct {
	Enabled       bool                   `json:"enabled" doc:"Whether deleted items go to the trash; off deletes them permanently"`
	Days          int                    `json:"days" doc:"Days trashed items are kept before they're deleted permanently; 0 keeps them forever"`
	Source        RetentionSource        `json:"source" doc:"Whether the values come from the user's own choices or the server"`
	ServerEnabled bool                   `json:"serverEnabled" doc:"Whether the server keeps a trash at all"`
	ServerDays    int                    `json:"serverDays" doc:"The server's limit, which the user can only lower; 0 for no limit"`
	User          users.TrashPreferences `json:"user" doc:"The user's own choices; absent fields follow the server"`
}

func ResolveTrashRetention(server ServerSettings, user users.User) TrashRetention {
	preferences := user.Trash
	retention := TrashRetention{
		Enabled:       server.TrashEnabled && (preferences.Enabled == nil || *preferences.Enabled),
		Days:          stricterLimit(preferences.Days, server.TrashRetentionDays),
		Source:        RetentionDefault,
		ServerEnabled: server.TrashEnabled,
		ServerDays:    server.TrashRetentionDays,
		User:          preferences,
	}
	if preferences.Enabled != nil || preferences.Days != nil {
		retention.Source = RetentionUser
	}
	return retention
}

func ValidateTrashPreferences(server ServerSettings, preferences users.TrashPreferences) error {
	if preferences.Days == nil {
		return nil
	}
	if err := users.ValidateRetentionDays(*preferences.Days); err != nil {
		return err
	}
	if exceedsLimit(*preferences.Days, server.TrashRetentionDays) {
		return apperr.Invalid("trash retention can be at most %d days", server.TrashRetentionDays)
	}
	return nil
}

func (r TrashRetention) ExpiresAt(deletedAt time.Time) (time.Time, bool) {
	if !r.Enabled {
		return deletedAt, true
	}
	if r.Days <= 0 {
		return time.Time{}, false
	}
	return deletedAt.AddDate(0, 0, r.Days), true
}

func (r TrashRetention) Cutoff(now time.Time) (time.Time, bool) {
	if !r.Enabled {
		return now, true
	}
	if r.Days <= 0 {
		return time.Time{}, false
	}
	return now.AddDate(0, 0, -r.Days), true
}
