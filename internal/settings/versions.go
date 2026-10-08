package settings

import (
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

const (
	DefaultVersionKeepAllHours = 6
	DefaultVersionMaxAgeDays   = 90
	DefaultVersionMaxPerFile   = 100

	MaxVersionKeepAllHours = 720
	MaxVersionAgeDays      = 3650
	MaxVersionsPerFile     = 10000
)

type VersionRetention struct {
	Enabled          bool                     `json:"enabled" doc:"Whether earlier versions of this user's files are kept"`
	KeepAllHours     int                      `json:"keepAllHours" doc:"Hours during which every saved version is kept; older versions thin out gradually"`
	MaxAgeDays       int                      `json:"maxAgeDays" doc:"Days earlier versions are kept; 0 for no age limit"`
	MaxPerFile       int                      `json:"maxPerFile" doc:"Most earlier versions kept per file; 0 for no count limit"`
	Source           RetentionSource          `json:"source" doc:"Where the values come from; server means an administrator decides"`
	Locked           bool                     `json:"locked" doc:"True when an administrator decides, so the user's own settings have no effect"`
	ServerEnabled    bool                     `json:"serverEnabled" doc:"Whether the server keeps history at all"`
	ServerMaxAgeDays int                      `json:"serverMaxAgeDays" doc:"The server's limit, which the user can only lower; 0 for no age limit"`
	ServerMaxPerFile int                      `json:"serverMaxPerFile" doc:"The server's limit, which the user can only lower; 0 for no count limit"`
	User             users.VersionPreferences `json:"user" doc:"The user's own choices; absent fields follow the server"`
}

func ResolveVersionRetention(server ServerSettings, user users.User) VersionRetention {
	retention := VersionRetention{
		Enabled:          server.VersionsEnabled,
		KeepAllHours:     server.VersionsKeepAllHours,
		MaxAgeDays:       server.VersionsMaxAgeDays,
		MaxPerFile:       server.VersionsMaxPerFile,
		Source:           RetentionDefault,
		ServerEnabled:    server.VersionsEnabled,
		ServerMaxAgeDays: server.VersionsMaxAgeDays,
		ServerMaxPerFile: server.VersionsMaxPerFile,
		User:             user.Versions,
	}
	if !server.VersionsEnabled || server.VersionsEnforced {
		retention.Source, retention.Locked = RetentionServer, true
		return retention
	}
	preferences := user.Versions
	if preferences.Enabled != nil || preferences.MaxAgeDays != nil || preferences.MaxPerFile != nil {
		retention.Source = RetentionUser
	}
	if preferences.Enabled != nil {
		retention.Enabled = *preferences.Enabled
	}
	retention.MaxAgeDays = stricterLimit(preferences.MaxAgeDays, server.VersionsMaxAgeDays)
	retention.MaxPerFile = stricterLimit(preferences.MaxPerFile, server.VersionsMaxPerFile)
	return retention
}

func stricterLimit(chosen *int, serverLimit int) int {
	if chosen == nil {
		return serverLimit
	}
	if serverLimit == 0 {
		return *chosen
	}
	if *chosen == 0 || *chosen > serverLimit {
		return serverLimit
	}
	return *chosen
}

func (r VersionRetention) KeepAll() time.Duration {
	return time.Duration(r.KeepAllHours) * time.Hour
}

func (r VersionRetention) MaxAge() time.Duration {
	return time.Duration(r.MaxAgeDays) * 24 * time.Hour
}

func ValidateVersionLimits(maxAgeDays, maxPerFile *int) error {
	if maxAgeDays != nil && (*maxAgeDays < 0 || *maxAgeDays > MaxVersionAgeDays) {
		return apperr.Invalid("days to keep versions must be between 0 and %d", MaxVersionAgeDays)
	}
	if maxPerFile != nil && (*maxPerFile < 0 || *maxPerFile > MaxVersionsPerFile) {
		return apperr.Invalid("versions per file must be between 0 and %d", MaxVersionsPerFile)
	}
	return nil
}
