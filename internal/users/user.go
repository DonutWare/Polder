package users

import (
	"regexp"
	"time"

	"nomad-server/internal/apperr"
)

type Role string

const (
	RoleAdmin Role = "admin"
	RoleUser  Role = "user"
)

const minPasswordLength = 8

var usernamePattern = regexp.MustCompile(`^[a-z0-9][a-z0-9_.-]{1,31}$`)

type User struct {
	ID         int64     `json:"id"`
	Username   string    `json:"username"`
	Role       Role      `json:"role" enum:"admin,user"`
	QuotaBytes int64     `json:"quotaBytes" doc:"Storage limit in bytes; 0 is unlimited"`
	UsedBytes  int64     `json:"usedBytes"`
	Disabled   bool      `json:"disabled"`
	CreatedAt  time.Time `json:"createdAt"`
}

func (u User) IsAdmin() bool { return u.Role == RoleAdmin }

func (u User) HasUnlimitedQuota() bool { return u.QuotaBytes <= 0 }

type NewUser struct {
	Username   string `json:"username"`
	Password   string `json:"password"`
	Role       Role   `json:"role" enum:"admin,user"`
	QuotaBytes int64  `json:"quotaBytes" required:"false" doc:"Storage limit in bytes; 0 or omitted is unlimited"`
}

type Changes struct {
	Password   *string `json:"password" required:"false"`
	Role       *Role   `json:"role" required:"false" enum:"admin,user"`
	QuotaBytes *int64  `json:"quotaBytes" required:"false" doc:"Storage limit in bytes; 0 is unlimited"`
	Disabled   *bool   `json:"disabled" required:"false"`
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
		return validateQuota(*c.QuotaBytes)
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
