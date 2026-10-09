package users

import (
	"net/mail"
	"regexp"
	"strings"
	"unicode/utf8"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
)

const (
	maxNameLength    = 100
	maxEmailLength   = 254
	maxAddressLength = 500
	maxAge           = 150
)

var accentColorPattern = regexp.MustCompile(`^#[0-9A-Fa-f]{6}$`)

type Profile struct {
	FirstName   string `json:"firstName" doc:"Empty shows the username instead"`
	LastName    string `json:"lastName"`
	DisplayName string `json:"displayName" doc:"Empty shows the first name instead"`
	Email       string `json:"email"`
	Age         *int   `json:"age,omitempty" required:"false"`
	Address     string `json:"address"`
}

type Avatar struct {
	ID          string `json:"id"`
	ContentType string `json:"contentType" doc:"Such as image/png or image/svg+xml"`
}

type Theme string

const (
	ThemeSystem Theme = "system"
	ThemeLight  Theme = "light"
	ThemeDark   Theme = "dark"
)

func (Theme) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(ThemeSystem), string(ThemeLight), string(ThemeDark)}
	return s
}

type Appearance struct {
	Theme       *Theme  `json:"theme,omitempty" required:"false" doc:"Absent until the user picks one"`
	AccentColor *string `json:"accentColor,omitempty" required:"false" doc:"Accent color as #RRGGBB; absent follows the device"`
}

func (p *Profile) normalize() error {
	fields := []struct {
		value *string
		name  string
		limit int
	}{
		{&p.FirstName, "first name", maxNameLength},
		{&p.LastName, "last name", maxNameLength},
		{&p.DisplayName, "display name", maxNameLength},
		{&p.Email, "email", maxEmailLength},
		{&p.Address, "address", maxAddressLength},
	}
	for _, field := range fields {
		*field.value = strings.TrimSpace(*field.value)
		if utf8.RuneCountInString(*field.value) > field.limit {
			return apperr.Invalid("%s must be at most %d characters", field.name, field.limit)
		}
	}
	if p.Email != "" {
		parsed, err := mail.ParseAddress(p.Email)
		if err != nil || parsed.Address != p.Email {
			return apperr.Invalid("%q is not an email address", p.Email)
		}
	}
	if p.Age != nil && (*p.Age < 0 || *p.Age > maxAge) {
		return apperr.Invalid("age must be between 0 and %d", maxAge)
	}
	return nil
}

func (a *Appearance) normalize() error {
	if a.Theme != nil && *a.Theme != ThemeSystem && *a.Theme != ThemeLight && *a.Theme != ThemeDark {
		return apperr.Invalid("theme must be %q, %q or %q", ThemeSystem, ThemeLight, ThemeDark)
	}
	if a.AccentColor != nil {
		if !accentColorPattern.MatchString(*a.AccentColor) {
			return apperr.Invalid("%q is not a color as #RRGGBB", *a.AccentColor)
		}
		upper := strings.ToUpper(*a.AccentColor)
		a.AccentColor = &upper
	}
	return nil
}
