package users

import "strings"

type UserSummary struct {
	ID          int64   `json:"id"`
	Username    string  `json:"username"`
	DisplayName string  `json:"displayName" doc:"The name the apps show, falling back to the first name and then the username"`
	Avatar      *Avatar `json:"avatar,omitempty" required:"false"`
}

func (u User) Summary() UserSummary {
	return UserSummary{ID: u.ID, Username: u.Username, DisplayName: u.ShownName(), Avatar: u.Avatar}
}

func (u User) ShownName() string {
	for _, name := range []string{u.Profile.DisplayName, u.Profile.FirstName} {
		if trimmed := strings.TrimSpace(name); trimmed != "" {
			return trimmed
		}
	}
	return u.Username
}

func (u User) Matches(query string) bool {
	return MatchesAny(query, u.Username, u.Profile.DisplayName, u.Profile.FirstName, u.Profile.LastName)
}

func MatchesAny(query string, candidates ...string) bool {
	query = strings.ToLower(strings.TrimSpace(query))
	if query == "" {
		return true
	}
	for _, candidate := range candidates {
		if strings.Contains(strings.ToLower(candidate), query) {
			return true
		}
	}
	return false
}
