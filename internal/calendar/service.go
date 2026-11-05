package calendar

import (
	"context"
	"database/sql"
	"net/http"
	"slices"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/groups"
	"polder-server/internal/mail"
	"polder-server/internal/users"
)

const (
	defaultCalendarName = "Personal"
	defaultCalendarURI  = "personal"
	changeRetention     = 90 * 24 * time.Hour
)

type Publisher interface {
	Publish(event activity.Event)
}

type Mailer interface {
	Configured() bool
	Send(ctx context.Context, message mail.Message) error
}

type Options struct {
	MaxResourceBytes          int
	MaxObjectsPerCalendar     int
	SubscriptionMinRefresh    time.Duration
	AllowPrivateSubscriptions bool
	PublicURL                 string
	RSVPKey                   []byte
	Mailer                    Mailer
}

type Service struct {
	store           *Store
	users           *users.Store
	groups          *groups.Service
	hub             Publisher
	options         Options
	fetcher         *http.Client
	now             func() time.Time
	refreshRequests chan struct{}
}

func NewService(db *sql.DB, userStore *users.Store, groupService *groups.Service, hub Publisher, options Options) *Service {
	if options.MaxResourceBytes <= 0 {
		options.MaxResourceBytes = DefaultMaxResourceBytes
	}
	if options.MaxObjectsPerCalendar <= 0 {
		options.MaxObjectsPerCalendar = 100000
	}
	if options.SubscriptionMinRefresh <= 0 {
		options.SubscriptionMinRefresh = 15 * time.Minute
	}
	return &Service{
		store:           NewStore(db),
		users:           userStore,
		groups:          groupService,
		hub:             hub,
		options:         options,
		fetcher:         newFeedClient(options.AllowPrivateSubscriptions),
		now:             time.Now,
		refreshRequests: make(chan struct{}, 1),
	}
}

func (s *Service) Store() *Store { return s.store }

func (s *Service) MaxResourceBytes() int { return s.options.MaxResourceBytes }

type NewCalendar struct {
	URI         string `json:"uri,omitempty" required:"false" doc:"Path segment under the CalDAV home; derived from the name when empty"`
	Name        string `json:"name" minLength:"1" maxLength:"128"`
	Description string `json:"description,omitempty" required:"false" maxLength:"4096"`
	Color       string `json:"color,omitempty" required:"false" doc:"Hex color such as #3e63dd; empty picks the next palette color"`
	Timezone    string `json:"timezone,omitempty" required:"false" doc:"IANA timezone such as Europe/Amsterdam"`
}

type CalendarChange struct {
	Name           *string `json:"name,omitempty" required:"false" maxLength:"128"`
	Description    *string `json:"description,omitempty" required:"false" maxLength:"4096"`
	Color          *string `json:"color,omitempty" required:"false"`
	Timezone       *string `json:"timezone,omitempty" required:"false"`
	Order          *int    `json:"order,omitempty" required:"false"`
	Hidden         *bool   `json:"hidden,omitempty" required:"false"`
	Notify         *bool   `json:"notify,omitempty" required:"false"`
	RefreshSeconds *int    `json:"refreshSeconds,omitempty" required:"false" doc:"How often a subscription is refreshed"`
}

func (s *Service) List(ctx context.Context, viewer users.User) ([]Calendar, error) {
	if _, err := s.DefaultCalendar(ctx, viewer); err != nil {
		return nil, err
	}
	owned, err := s.store.OwnedCalendars(ctx, viewer.ID)
	if err != nil {
		return nil, err
	}
	for i := range owned {
		owned[i].Access = AccessOwner
	}
	shared, err := s.sharedCalendars(ctx, viewer)
	if err != nil {
		return nil, err
	}
	return s.present(ctx, viewer, append(owned, shared...))
}

func (s *Service) sharedCalendars(ctx context.Context, viewer users.User) ([]Calendar, error) {
	reaches, err := s.store.ReachingShares(ctx, viewer.ID)
	if err != nil {
		return nil, err
	}
	byID := map[int64]int{}
	var calendars []Calendar
	for _, reach := range reaches {
		access := reachAccess(reach)
		index, seen := byID[reach.Calendar.ID]
		if !seen {
			byID[reach.Calendar.ID] = len(calendars)
			reach.Calendar.Access = access
			reach.Calendar.IsDefault = false
			calendars = append(calendars, reach.Calendar)
			continue
		}
		if access.rank() > calendars[index].Access.rank() {
			calendars[index].Access = access
		}
	}
	return calendars, nil
}

func reachAccess(reach shareReach) Access {
	if reach.ViaGroup && groups.Role(reach.GroupRole) == groups.RoleViewer && reach.Access == AccessReadWrite {
		return AccessRead
	}
	return reach.Access
}

func (s *Service) present(ctx context.Context, viewer users.User, calendars []Calendar) ([]Calendar, error) {
	settings, err := s.store.UserSettings(ctx, viewer.ID)
	if err != nil {
		return nil, err
	}
	owners := map[int64]*users.UserSummary{}
	for i := range calendars {
		owner, err := s.ownerSummary(ctx, owners, calendars[i].OwnerID)
		if err != nil {
			return nil, err
		}
		calendars[i].Owner = owner
		applySettings(&calendars[i], settings[calendars[i].ID])
	}
	slices.SortStableFunc(calendars, func(a, b Calendar) int {
		if a.Access.IsOwner() != b.Access.IsOwner() {
			if a.Access.IsOwner() {
				return -1
			}
			return 1
		}
		return a.Order - b.Order
	})
	if calendars == nil {
		calendars = []Calendar{}
	}
	return calendars, nil
}

func (s *Service) ownerSummary(ctx context.Context, cache map[int64]*users.UserSummary, ownerID int64) (*users.UserSummary, error) {
	if summary, ok := cache[ownerID]; ok {
		return summary, nil
	}
	owner, err := s.users.ByID(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	summary := owner.Summary()
	cache[ownerID] = &summary
	return &summary, nil
}

func applySettings(c *Calendar, settings UserSettings) {
	if settings.DisplayName != "" && !c.Access.IsOwner() {
		c.Name = settings.DisplayName
	}
	if settings.Color != "" && !c.Access.IsOwner() {
		c.Color = settings.Color
	}
	if settings.Order != nil && !c.Access.IsOwner() {
		c.Order = *settings.Order
	}
	c.Hidden = settings.Hidden
	c.Notify = c.Access.IsOwner()
	if settings.Notify != nil {
		c.Notify = *settings.Notify
	}
	if !c.Access.CanReadEvents() {
		c.Notify = false
	}
}

func (s *Service) Get(ctx context.Context, viewer users.User, id int64) (Calendar, error) {
	c, err := s.store.CalendarByID(ctx, id)
	if err != nil {
		return Calendar{}, err
	}
	return s.withAccess(ctx, viewer, c)
}

func (s *Service) withAccess(ctx context.Context, viewer users.User, c Calendar) (Calendar, error) {
	access, err := s.accessFor(ctx, viewer.ID, c)
	if err != nil {
		return Calendar{}, err
	}
	if access == AccessNone {
		return Calendar{}, calendarNotFound()
	}
	c.Access = access
	if !access.IsOwner() {
		c.IsDefault = false
	}
	presented, err := s.present(ctx, viewer, []Calendar{c})
	if err != nil {
		return Calendar{}, err
	}
	return presented[0], nil
}

func (s *Service) accessFor(ctx context.Context, userID int64, c Calendar) (Access, error) {
	if c.OwnerID == userID {
		return AccessOwner, nil
	}
	reaches, err := s.store.ReachingShares(ctx, userID)
	if err != nil {
		return AccessNone, err
	}
	best := AccessNone
	for _, reach := range reaches {
		if reach.Calendar.ID != c.ID {
			continue
		}
		if access := reachAccess(reach); access.rank() > best.rank() {
			best = access
		}
	}
	return best, nil
}

func (s *Service) HomeCalendar(ctx context.Context, viewer users.User, segment string) (Calendar, error) {
	if rest, shared := strings.CutPrefix(segment, sharedPrefix); shared {
		id, err := strconv.ParseInt(rest, 10, 64)
		if err != nil {
			return Calendar{}, calendarNotFound()
		}
		c, err := s.Get(ctx, viewer, id)
		if err != nil || c.Access.IsOwner() {
			return Calendar{}, calendarNotFound()
		}
		return c, nil
	}
	c, err := s.store.CalendarByURI(ctx, viewer.ID, segment)
	if err != nil {
		return Calendar{}, err
	}
	return s.withAccess(ctx, viewer, c)
}

func HomeSegment(c Calendar) string {
	if c.Access.IsOwner() {
		return c.URI
	}
	return sharedPrefix + strconv.FormatInt(c.ID, 10)
}

func (s *Service) DefaultCalendar(ctx context.Context, owner users.User) (Calendar, error) {
	owned, err := s.store.OwnedCalendars(ctx, owner.ID)
	if err != nil {
		return Calendar{}, err
	}
	var firstLocal *Calendar
	for i := range owned {
		if owned[i].Kind != KindLocal {
			continue
		}
		if owned[i].IsDefault {
			owned[i].Access = AccessOwner
			return owned[i], nil
		}
		if firstLocal == nil {
			firstLocal = &owned[i]
		}
	}
	if firstLocal != nil {
		if err := s.store.SetDefault(ctx, owner.ID, firstLocal.ID); err != nil {
			return Calendar{}, err
		}
		firstLocal.IsDefault, firstLocal.Access = true, AccessOwner
		return *firstLocal, nil
	}
	id, err := s.store.InsertCalendar(ctx, Calendar{
		OwnerID: owner.ID, URI: defaultCalendarURI, Name: defaultCalendarName, Color: palette[0], Kind: KindLocal, IsDefault: true,
	})
	if apperr.Is(err, apperr.KindAlreadyExists) {
		return s.DefaultCalendar(ctx, owner)
	}
	if err != nil {
		return Calendar{}, err
	}
	created, err := s.store.CalendarByID(ctx, id)
	created.Access = AccessOwner
	return created, err
}

func (s *Service) Create(ctx context.Context, viewer users.User, request NewCalendar) (Calendar, error) {
	c := Calendar{OwnerID: viewer.ID, Kind: KindLocal, Name: strings.TrimSpace(request.Name), Description: request.Description,
		Color: normalizeColor(request.Color), Timezone: strings.TrimSpace(request.Timezone)}
	if err := validateDetails(c); err != nil {
		return Calendar{}, err
	}
	existing, err := s.store.OwnedCalendars(ctx, viewer.ID)
	if err != nil {
		return Calendar{}, err
	}
	if c.Color == "" {
		c.Color = palette[len(existing)%len(palette)]
	}
	c.Order = len(existing)
	c.IsDefault = !slices.ContainsFunc(existing, func(other Calendar) bool { return other.Kind == KindLocal })
	if c.URI, err = chooseURI(request.URI, c.Name, existing); err != nil {
		return Calendar{}, err
	}
	id, err := s.store.InsertCalendar(ctx, c)
	if err != nil {
		return Calendar{}, err
	}
	s.publishTo(viewer.ID, id)
	return s.Get(ctx, viewer, id)
}

func chooseURI(requested, name string, existing []Calendar) (string, error) {
	taken := map[string]bool{}
	for _, c := range existing {
		taken[c.URI] = true
	}
	if requested != "" {
		if !validURI(requested) {
			return "", apperr.Invalid("%q cannot be a calendar's path segment", requested)
		}
		if taken[requested] {
			return "", apperr.AlreadyExists("a calendar at %s already exists", requested)
		}
		return requested, nil
	}
	base := slugFrom(name)
	candidate := base
	for i := 2; taken[candidate]; i++ {
		candidate = base + "-" + strconv.Itoa(i)
	}
	return candidate, nil
}

func validateDetails(c Calendar) error {
	if c.Name == "" || utf8.RuneCountInString(c.Name) > maxNameLength {
		return apperr.Invalid("a calendar name has 1 to %d characters", maxNameLength)
	}
	if utf8.RuneCountInString(c.Description) > maxDescription {
		return apperr.Invalid("a calendar description has at most %d characters", maxDescription)
	}
	if c.Color != "" && !colorPattern.MatchString(c.Color) {
		return apperr.Invalid("%q is not a color such as #3e63dd", c.Color)
	}
	if !ValidTimezone(c.Timezone) {
		return violation(ConditionValidTimezone, apperr.KindInvalid, "%q is not a timezone such as Europe/Amsterdam", c.Timezone)
	}
	return nil
}

func (s *Service) Update(ctx context.Context, viewer users.User, id int64, change CalendarChange) (Calendar, error) {
	c, err := s.Get(ctx, viewer, id)
	if err != nil {
		return Calendar{}, err
	}
	if c.Access.IsOwner() {
		if err := s.updateOwned(ctx, c, change); err != nil {
			return Calendar{}, err
		}
	}
	if err := s.updateSettings(ctx, viewer, c, change); err != nil {
		return Calendar{}, err
	}
	s.publishCalendar(ctx, c)
	return s.Get(ctx, viewer, id)
}

func (s *Service) updateOwned(ctx context.Context, c Calendar, change CalendarChange) error {
	stored, err := s.store.CalendarByID(ctx, c.ID)
	if err != nil {
		return err
	}
	if change.Name != nil {
		stored.Name = strings.TrimSpace(*change.Name)
	}
	if change.Description != nil {
		stored.Description = *change.Description
	}
	if change.Color != nil {
		stored.Color = normalizeColor(*change.Color)
	}
	if change.Timezone != nil {
		stored.Timezone = strings.TrimSpace(*change.Timezone)
	}
	if change.Order != nil {
		stored.Order = *change.Order
	}
	if change.RefreshSeconds != nil && stored.Kind == KindSubscription {
		stored.RefreshSeconds = max(*change.RefreshSeconds, int(s.options.SubscriptionMinRefresh/time.Second))
	}
	if err := validateDetails(stored); err != nil {
		return err
	}
	return s.store.UpdateCalendar(ctx, stored)
}

func (s *Service) updateSettings(ctx context.Context, viewer users.User, c Calendar, change CalendarChange) error {
	all, err := s.store.UserSettings(ctx, viewer.ID)
	if err != nil {
		return err
	}
	settings := all[c.ID]
	touched := change.Hidden != nil || change.Notify != nil
	if change.Hidden != nil {
		settings.Hidden = *change.Hidden
	}
	if change.Notify != nil {
		settings.Notify = change.Notify
	}
	if !c.Access.IsOwner() {
		if change.Name != nil {
			settings.DisplayName, touched = strings.TrimSpace(*change.Name), true
		}
		if change.Color != nil {
			color := normalizeColor(*change.Color)
			if color != "" && !colorPattern.MatchString(color) {
				return apperr.Invalid("%q is not a color such as #3e63dd", color)
			}
			settings.Color, touched = color, true
		}
		if change.Order != nil {
			settings.Order, touched = change.Order, true
		}
	}
	if !touched {
		return nil
	}
	return s.store.SetUserSettings(ctx, viewer.ID, c.ID, settings)
}

func (s *Service) SetDefault(ctx context.Context, viewer users.User, id int64) (Calendar, error) {
	c, err := s.Get(ctx, viewer, id)
	if err != nil {
		return Calendar{}, err
	}
	if !c.Access.IsOwner() || c.Kind != KindLocal {
		return Calendar{}, apperr.Forbidden("only your own calendars can be the default")
	}
	if err := s.store.SetDefault(ctx, viewer.ID, id); err != nil {
		return Calendar{}, err
	}
	return s.Get(ctx, viewer, id)
}

func (s *Service) Delete(ctx context.Context, viewer users.User, id int64) error {
	c, err := s.Get(ctx, viewer, id)
	if err != nil {
		return err
	}
	if !c.Access.IsOwner() {
		return s.leaveShare(ctx, viewer, c)
	}
	recipients, err := s.audience(ctx, c)
	if err != nil {
		return err
	}
	if err := s.store.DeleteCalendar(ctx, id); err != nil {
		return err
	}
	for _, userID := range recipients {
		s.publishTo(userID, id)
	}
	return nil
}

func (s *Service) leaveShare(ctx context.Context, viewer users.User, c Calendar) error {
	removed, err := s.store.RemoveUserShare(ctx, c.ID, viewer.ID)
	if err != nil {
		return err
	}
	if !removed {
		return apperr.Forbidden("this calendar reaches you through a group; ask its owner to remove the group")
	}
	s.publishTo(viewer.ID, c.ID)
	return nil
}

func (s *Service) audience(ctx context.Context, c Calendar) ([]int64, error) {
	recipients, err := s.store.ShareAudience(ctx, c.ID)
	if err != nil {
		return nil, err
	}
	if !slices.Contains(recipients, c.OwnerID) {
		recipients = append(recipients, c.OwnerID)
	}
	return recipients, nil
}

func (s *Service) publishCalendar(ctx context.Context, c Calendar) {
	recipients, err := s.audience(ctx, c)
	if err != nil {
		logger.Warn("find who sees a calendar", "calendar", c.ID, "error", err)
		recipients = []int64{c.OwnerID}
	}
	for _, userID := range recipients {
		s.publishTo(userID, c.ID)
	}
}

func (s *Service) publishTo(userID, calendarID int64) {
	if s.hub == nil {
		return
	}
	s.hub.Publish(activity.Event{Type: activity.EventCalendarChanged, UserID: userID, Calendar: &activity.CalendarUpdate{CalendarID: calendarID}})
}

func (s *Service) PruneChanges(ctx context.Context) error {
	if err := s.store.PruneChanges(ctx, s.now().Add(-changeRetention)); err != nil {
		return err
	}
	if err := s.store.PruneAlarmLog(ctx, s.now().Add(-alarmLogRetention)); err != nil {
		return err
	}
	return s.store.PruneInbox(ctx, s.now().Add(-inboxRetention))
}
