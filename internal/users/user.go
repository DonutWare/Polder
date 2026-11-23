package users

import (
	"regexp"
	"time"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
)

type Role string

const (
	RoleAdmin Role = "admin"
	RoleUser  Role = "user"
)

func (Role) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(RoleAdmin), string(RoleUser)}
	return s
}

const (
	minPasswordLength = 8
	MaxRetentionDays  = 3650
)

var usernamePattern = regexp.MustCompile(`^[a-z0-9][a-z0-9_.-]{1,31}$`)

type User struct {
	ID           int64              `json:"id"`
	Username     string             `json:"username"`
	Role         Role               `json:"role"`
	QuotaBytes   int64              `json:"quotaBytes" doc:"Storage limit in bytes; 0 is unlimited"`
	UsedBytes    int64              `json:"usedBytes" doc:"Bytes counted against the quota, including file history"`
	HistoryBytes int64              `json:"historyBytes" doc:"Bytes used by earlier versions of files"`
	Disabled     bool               `json:"disabled"`
	CreatedAt    time.Time          `json:"createdAt"`
	Profile      Profile            `json:"profile"`
	Avatar       *Avatar            `json:"avatar,omitempty" required:"false" doc:"Absent when the user has no icon of their own"`
	Appearance   Appearance         `json:"appearance"`
	TwoFactor    TwoFactorStatus    `json:"twoFactor"`
	HasPassword  bool               `json:"hasPassword" doc:"False for accounts that only sign in through a single sign-on provider"`
	SSO          bool               `json:"sso" doc:"Whether the account is linked to a single sign-on provider"`
	Trash        TrashPreferences   `json:"-"`
	Versions     VersionPreferences `json:"-"`
}

type TwoFactorStatus struct {
	Enabled       bool       `json:"enabled" doc:"Whether sign-ins with a password also need a code from an authenticator app"`
	Deadline      *time.Time `json:"deadline,omitempty" required:"false" doc:"When two-factor authentication must be set up by; absent when it isn't required"`
	SetupRequired bool       `json:"setupRequired" doc:"The deadline has passed: until two-factor authentication is set up, this session can do nothing else"`
}

type TrashPreferences struct {
	Enabled *bool `json:"enabled,omitempty" required:"false" doc:"Whether deleted items go to the trash; absent follows the server"`
	Days    *int  `json:"days,omitempty" required:"false" doc:"Days to keep trashed items, 0 for forever; absent follows the server"`
}

type VersionPreferences struct {
	Enabled      *bool `json:"enabled,omitempty" required:"false" doc:"Whether to keep earlier versions of files; absent follows the server"`
	KeepAllHours *int  `json:"keepAllHours,omitempty" required:"false" doc:"Hours during which every saved version is kept; absent follows the server"`
	MaxAgeDays   *int  `json:"maxAgeDays,omitempty" required:"false" doc:"Days to keep earlier versions, 0 for no age limit; absent follows the server"`
	MaxPerFile   *int  `json:"maxPerFile,omitempty" required:"false" doc:"Most earlier versions kept per file, 0 for no count limit; absent follows the server"`
}

const NoPasswordHash = "!"

func (u User) IsAdmin() bool { return u.Role == RoleAdmin }

func (u User) HasUnlimitedQuota() bool { return u.QuotaBytes <= 0 }

type NewUser struct {
	Username   string `json:"username"`
	Password   string `json:"password"`
	Role       Role   `json:"role"`
	QuotaBytes int64  `json:"quotaBytes" required:"false" doc:"Storage limit in bytes; 0 or omitted is unlimited"`
	Email      string `json:"email" required:"false" doc:"Where the welcome email and later emails go; the user can change it"`
}

type Changes struct {
	Password   *string `json:"password" required:"false"`
	Role       *Role   `json:"role" required:"false"`
	QuotaBytes *int64  `json:"quotaBytes" required:"false" doc:"Storage limit in bytes; 0 is unlimited"`
	Disabled   *bool   `json:"disabled" required:"false"`
}

func (n NewUser) validate() error {
	if err := validatePassword(n.Password); err != nil {
		return err
	}
	return n.validateWithoutPassword()
}

func (n NewUser) validateWithoutPassword() error {
	if !ValidUsername(n.Username) {
		return apperr.Invalid("username must be 2-32 characters of a-z, 0-9, '.', '_' or '-'")
	}
	if err := validateRole(n.Role); err != nil {
		return err
	}
	if err := validateQuota(n.QuotaBytes); err != nil {
		return err
	}
	return (&Profile{Email: n.Email}).normalize()
}

func (c Changes) validate() error {
	if c.Password != nil {
		if err := validatePassword(*c.Password); err != nil {
			return err
		}
	}
	if c.Role != nil {
		if err := validateRole(*c.Role); err != nil {
			return err
		}
	}
	if c.QuotaBytes != nil {
		if err := validateQuota(*c.QuotaBytes); err != nil {
			return err
		}
	}
	return nil
}

func ValidUsername(username string) bool {
	return usernamePattern.MatchString(username)
}

func ValidatePassword(password string) error {
	return validatePassword(password)
}

func validatePassword(password string) error {
	if len(password) < minPasswordLength {
		return apperr.Invalid("password must be at least %d characters", minPasswordLength)
	}
	return nil
}

func validateRole(role Role) error {
	if role != RoleAdmin && role != RoleUser {
		return apperr.Invalid("role must be %q or %q", RoleAdmin, RoleUser)
	}
	return nil
}

func validateQuota(quotaBytes int64) error {
	if quotaBytes < 0 {
		return apperr.Invalid("quota cannot be negative")
	}
	return nil
}

func ValidateRetentionDays(days int) error {
	if days < 0 || days > MaxRetentionDays {
		return apperr.Invalid("trash retention must be between 0 and %d days", MaxRetentionDays)
	}
	return nil
}

func (s TwoFactorStatus) Due(now time.Time) bool {
	return !s.Enabled && s.Deadline != nil && !now.Before(*s.Deadline)
}
