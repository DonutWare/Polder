package users

import (
	"regexp"
	"time"

	"github.com/danielgtaylor/huma/v2"

	"nomad-server/internal/apperr"
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
	minPasswordLength      = 8
	MaxRetentionDays       = 3650
	ClearRetentionOverride = -1
)

var usernamePattern = regexp.MustCompile(`^[a-z0-9][a-z0-9_.-]{1,31}$`)

type User struct {
	ID                         int64     `json:"id"`
	Username                   string    `json:"username"`
	Role                       Role      `json:"role"`
	QuotaBytes                 int64     `json:"quotaBytes" doc:"Storage limit in bytes; 0 is unlimited"`
	UsedBytes                  int64     `json:"usedBytes"`
	Disabled                   bool      `json:"disabled"`
	CreatedAt                  time.Time `json:"createdAt"`
	TrashRetentionDays         *int      `json:"trashRetentionDays,omitempty" required:"false" doc:"Days the user chose to keep trashed items; absent follows the server default"`
	TrashRetentionOverrideDays *int      `json:"trashRetentionOverrideDays,omitempty" required:"false" doc:"Days an administrator fixed for this user's trash; absent when not overridden"`
}

func (u User) IsAdmin() bool { return u.Role == RoleAdmin }

func (u User) HasUnlimitedQuota() bool { return u.QuotaBytes <= 0 }

type NewUser struct {
	Username   string `json:"username"`
	Password   string `json:"password"`
	Role       Role   `json:"role"`
	QuotaBytes int64  `json:"quotaBytes" required:"false" doc:"Storage limit in bytes; 0 or omitted is unlimited"`
}

type Changes struct {
	Password                   *string `json:"password" required:"false"`
	Role                       *Role   `json:"role" required:"false"`
	QuotaBytes                 *int64  `json:"quotaBytes" required:"false" doc:"Storage limit in bytes; 0 is unlimited"`
	Disabled                   *bool   `json:"disabled" required:"false"`
	TrashRetentionOverrideDays *int    `json:"trashRetentionOverrideDays" required:"false" doc:"Days to keep this user's trash regardless of their own setting (0 keeps it forever); -1 removes the override"`
}

func (n NewUser) validate() error {
	if !usernamePattern.MatchString(n.Username) {
		return apperr.Invalid("username must be 2-32 characters of a-z, 0-9, '.', '_' or '-'")
	}
	if err := validatePassword(n.Password); err != nil {
		return err
	}
	if err := validateRole(n.Role); err != nil {
		return err
	}
	return validateQuota(n.QuotaBytes)
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
	if c.TrashRetentionOverrideDays != nil && *c.TrashRetentionOverrideDays != ClearRetentionOverride {
		return ValidateRetentionDays(*c.TrashRetentionOverrideDays)
	}
	return nil
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
