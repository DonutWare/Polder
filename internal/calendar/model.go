package calendar

import (
	"regexp"
	"strings"
	"time"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/users"
)

type Kind string

const (
	KindLocal        Kind = "local"
	KindSubscription Kind = "subscription"
)

func (Kind) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(KindLocal), string(KindSubscription)}
	return s
}

type Access string

const (
	AccessOwner     Access = "owner"
	AccessReadWrite Access = "readwrite"
	AccessRead      Access = "read"
	AccessFreeBusy  Access = "freebusy"
	AccessNone      Access = ""
)

func (Access) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(AccessOwner), string(AccessReadWrite), string(AccessRead), string(AccessFreeBusy)}
	return s
}

func (a Access) rank() int {
	switch a {
	case AccessOwner:
		return 4
	case AccessReadWrite:
		return 3
	case AccessRead:
		return 2
	case AccessFreeBusy:
		return 1
	}
	return 0
}

func (a Access) CanSeeBusy() bool    { return a.rank() >= 1 }
func (a Access) CanReadEvents() bool { return a.rank() >= 2 }
func (a Access) CanEdit() bool       { return a.rank() >= 3 }
func (a Access) IsOwner() bool       { return a == AccessOwner }

func validShareAccess(a Access) bool {
	return a == AccessReadWrite || a == AccessRead || a == AccessFreeBusy
}

type Calendar struct {
	ID                int64              `json:"id"`
	OwnerID           int64              `json:"-"`
	Owner             *users.UserSummary `json:"owner,omitempty" required:"false"`
	URI               string             `json:"uri" doc:"The calendar's path segment under the CalDAV home"`
	Name              string             `json:"name"`
	Description       string             `json:"description"`
	Color             string             `json:"color" doc:"Hex color such as #3e63dd"`
	Timezone          string             `json:"timezone" doc:"IANA timezone for all-day and floating events; empty means UTC"`
	Order             int                `json:"order"`
	Kind              Kind               `json:"kind"`
	IsDefault         bool               `json:"isDefault" doc:"Invitations land in the default calendar"`
	Access            Access             `json:"access" doc:"What the logged-in user may do with the calendar"`
	Hidden            bool               `json:"hidden" doc:"Whether the logged-in user hid the calendar from their views"`
	Notify            bool               `json:"notify" doc:"Whether the logged-in user gets reminders for the calendar's events"`
	SourceURL         string             `json:"sourceUrl,omitempty" required:"false" doc:"The ICS feed a subscription follows"`
	RefreshSeconds    int                `json:"refreshSeconds,omitempty" required:"false"`
	FetchedAt         *time.Time         `json:"fetchedAt,omitempty" required:"false"`
	FetchError        string             `json:"fetchError,omitempty" required:"false" doc:"Why the last refresh of a subscription failed"`
	CreatedAt         time.Time          `json:"createdAt"`
	UpdatedAt         time.Time          `json:"updatedAt"`
	SyncRevision      int64              `json:"-"`
	PrunedRevision    int64              `json:"-"`
	FetchETag         string             `json:"-"`
	FetchLastModified string             `json:"-"`
}

func (c Calendar) ReadOnly() bool {
	return c.Kind == KindSubscription || !c.Access.CanEdit()
}

func (c Calendar) Location() *time.Location {
	return LocationOrUTC(c.Timezone)
}

var (
	colorPattern   = regexp.MustCompile(`^#[0-9a-f]{6}$`)
	uriPattern     = regexp.MustCompile(`^[A-Za-z0-9][A-Za-z0-9._~@+-]{0,127}$`)
	reservedURIs   = map[string]bool{"inbox": true, "outbox": true, "notifications": true}
	sharedPrefix   = "shared-"
	maxNameLength  = 128
	maxDescription = 4096
)

var palette = []string{
	"#3e63dd", "#e5484d", "#46a758", "#f76b15", "#8e4ec6",
	"#12a594", "#ffc53d", "#d6409f", "#0090ff", "#8d8d8d",
}

func normalizeColor(color string) string {
	color = strings.ToLower(strings.TrimSpace(color))
	if len(color) == 9 && strings.HasPrefix(color, "#") {
		color = color[:7]
	}
	return color
}

func validURI(uri string) bool {
	return uriPattern.MatchString(uri) && !reservedURIs[strings.ToLower(uri)] && !strings.HasPrefix(uri, sharedPrefix)
}

func slugFrom(name string) string {
	var b strings.Builder
	for _, r := range strings.ToLower(name) {
		switch {
		case r >= 'a' && r <= 'z', r >= '0' && r <= '9':
			b.WriteRune(r)
		case b.Len() > 0 && !strings.HasSuffix(b.String(), "-"):
			b.WriteByte('-')
		}
	}
	slug := strings.Trim(b.String(), "-")
	if len(slug) > 48 {
		slug = strings.Trim(slug[:48], "-")
	}
	if slug == "" || !validURI(slug) {
		return "calendar"
	}
	return slug
}
