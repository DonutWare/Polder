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
	Enabled            bool                     `json:"enabled" doc:"Whether earlier versions of this user's files are kept"`
	KeepAllHours       int                      `json:"keepAllHours" doc:"Hours during which every saved version is kept; older versions thin out gradually"`
	MaxAgeDays         int                      `json:"maxAgeDays" doc:"Days earlier versions are kept; 0 for no age limit"`
	MaxPerFile         int                      `json:"maxPerFile" doc:"Most earlier versions kept per file; 0 for no count limit"`
	Source             RetentionSource          `json:"source" doc:"Whether the values come from the user's own choices or the server"`
	ServerEnabled      bool                     `json:"serverEnabled" doc:"Whether the server keeps history at all"`
	ServerKeepAllHours int                      `json:"serverKeepAllHours" doc:"The server's limit, which the user can only lower"`
	ServerMaxAgeDays   int                      `json:"serverMaxAgeDays" doc:"The server's limit, which the user can only lower; 0 for no age limit"`
	ServerMaxPerFile   int                      `json:"serverMaxPerFile" doc:"The server's limit, which the user can only lower; 0 for no count limit"`
	User               users.VersionPreferences `json:"user" doc:"The user's own choices; absent fields follow the server"`
}

func ResolveVersionRetention(server ServerSettings, user users.User) VersionRetention {
	preferences := user.Versions
	retention := VersionRetention{
		Enabled:            server.VersionsEnabled && (preferences.Enabled == nil || *preferences.Enabled),
		KeepAllHours:       atMost(preferences.KeepAllHours, server.VersionsKeepAllHours),
		MaxAgeDays:         stricterLimit(preferences.MaxAgeDays, server.VersionsMaxAgeDays),
		MaxPerFile:         stricterLimit(preferences.MaxPerFile, server.VersionsMaxPerFile),
		Source:             RetentionDefault,
		ServerEnabled:      server.VersionsEnabled,
		ServerKeepAllHours: server.VersionsKeepAllHours,
		ServerMaxAgeDays:   server.VersionsMaxAgeDays,
		ServerMaxPerFile:   server.VersionsMaxPerFile,
		User:               preferences,
	}
	if preferences.Enabled != nil || preferences.KeepAllHours != nil || preferences.MaxAgeDays != nil || preferences.MaxPerFile != nil {
		retention.Source = RetentionUser
	}
	return retention
}

func (r VersionRetention) KeepAll() time.Duration {
	return time.Duration(r.KeepAllHours) * time.Hour
}

func (r VersionRetention) MaxAge() time.Duration {
	return time.Duration(r.MaxAgeDays) * 24 * time.Hour
}

func ValidateVersionPreferences(server ServerSettings, preferences users.VersionPreferences) error {
	if err := ValidateVersionLimits(preferences.KeepAllHours, preferences.MaxAgeDays, preferences.MaxPerFile); err != nil {
		return err
	}
	if hours := preferences.KeepAllHours; hours != nil && *hours > server.VersionsKeepAllHours {
		return apperr.Invalid("every version can be kept for at most %d hours", server.VersionsKeepAllHours)
	}
	if days := preferences.MaxAgeDays; days != nil && exceedsLimit(*days, server.VersionsMaxAgeDays) {
		return apperr.Invalid("versions can be kept for at most %d days", server.VersionsMaxAgeDays)
	}
	if count := preferences.MaxPerFile; count != nil && exceedsLimit(*count, server.VersionsMaxPerFile) {
		return apperr.Invalid("at most %d versions can be kept per file", server.VersionsMaxPerFile)
	}
	return nil
}

func ValidateVersionLimits(keepAllHours, maxAgeDays, maxPerFile *int) error {
	if keepAllHours != nil && (*keepAllHours < 0 || *keepAllHours > MaxVersionKeepAllHours) {
		return apperr.Invalid("hours to keep every version must be between 0 and %d", MaxVersionKeepAllHours)
	}
	if maxAgeDays != nil && (*maxAgeDays < 0 || *maxAgeDays > MaxVersionAgeDays) {
		return apperr.Invalid("days to keep versions must be between 0 and %d", MaxVersionAgeDays)
	}
	if maxPerFile != nil && (*maxPerFile < 0 || *maxPerFile > MaxVersionsPerFile) {
		return apperr.Invalid("versions per file must be between 0 and %d", MaxVersionsPerFile)
	}
	return nil
}
