package calendar

import (
	"context"
	"database/sql"
	"time"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
	"polder-server/internal/users"
)

type RecipientKind string

const (
	RecipientUser  RecipientKind = "user"
	RecipientGroup RecipientKind = "group"
)

func (RecipientKind) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(RecipientUser), string(RecipientGroup)}
	return s
}

type GroupSummary struct {
	ID   int64  `json:"id"`
	Name string `json:"name"`
}

type CalendarShare struct {
	ID         int64              `json:"id"`
	CalendarID int64              `json:"calendarId"`
	User       *users.UserSummary `json:"user,omitempty" required:"false"`
	Group      *GroupSummary      `json:"group,omitempty" required:"false"`
	Access     Access             `json:"access"`
	CreatedAt  time.Time          `json:"createdAt"`
	userID     int64
	groupID    int64
}

type NewCalendarShare struct {
	RecipientKind RecipientKind `json:"recipientKind"`
	RecipientID   int64         `json:"recipientId"`
	Access        Access        `json:"access" doc:"freebusy shows only when the calendar is busy"`
}

func shareNotFound() error {
	return apperr.NotFound("share not found")
}

func (s *Service) ownedCalendar(ctx context.Context, viewer users.User, id int64) (Calendar, error) {
	c, err := s.Get(ctx, viewer, id)
	if err != nil {
		return Calendar{}, err
	}
	if !c.Access.IsOwner() {
		return Calendar{}, apperr.Forbidden("only the calendar's owner may do this")
	}
	return c, nil
}

func (s *Service) Shares(ctx context.Context, viewer users.User, calendarID int64) ([]CalendarShare, error) {
	if _, err := s.ownedCalendar(ctx, viewer, calendarID); err != nil {
		return nil, err
	}
	shares, err := s.store.Shares(ctx, calendarID)
	if err != nil {
		return nil, err
	}
	for i := range shares {
		if err := s.describeShare(ctx, &shares[i]); err != nil {
			return nil, err
		}
	}
	return shares, nil
}

func (s *Service) describeShare(ctx context.Context, share *CalendarShare) error {
	if share.userID != 0 {
		user, err := s.users.ByID(ctx, share.userID)
		if err != nil {
			return err
		}
		summary := user.Summary()
		share.User = &summary
		return nil
	}
	group, err := s.groups.ByID(ctx, share.groupID)
	if err != nil {
		return err
	}
	share.Group = &GroupSummary{ID: group.ID, Name: group.Name}
	return nil
}

func (s *Service) Share(ctx context.Context, viewer users.User, calendarID int64, request NewCalendarShare) (CalendarShare, error) {
	c, err := s.ownedCalendar(ctx, viewer, calendarID)
	if err != nil {
		return CalendarShare{}, err
	}
	if !validShareAccess(request.Access) {
		return CalendarShare{}, apperr.Invalid("access is readwrite, read or freebusy")
	}
	if c.Kind == KindSubscription && request.Access == AccessReadWrite {
		return CalendarShare{}, apperr.Invalid("a subscribed calendar can only be shared read-only")
	}
	share := CalendarShare{CalendarID: calendarID, Access: request.Access}
	switch request.RecipientKind {
	case RecipientUser:
		if err := s.validateUserRecipient(ctx, viewer, request.RecipientID); err != nil {
			return CalendarShare{}, err
		}
		share.userID = request.RecipientID
	case RecipientGroup:
		if err := s.validateGroupRecipient(ctx, viewer, request.RecipientID); err != nil {
			return CalendarShare{}, err
		}
		share.groupID = request.RecipientID
	default:
		return CalendarShare{}, apperr.Invalid("recipientKind is user or group")
	}
	id, err := s.store.InsertShare(ctx, share)
	if err != nil {
		return CalendarShare{}, err
	}
	s.publishCalendar(ctx, c)
	return s.oneShare(ctx, calendarID, id)
}

func (s *Service) validateUserRecipient(ctx context.Context, viewer users.User, userID int64) error {
	if userID == viewer.ID {
		return apperr.Invalid("you already own this calendar")
	}
	recipient, err := s.users.ByID(ctx, userID)
	if err != nil {
		return err
	}
	if recipient.Disabled {
		return apperr.Invalid("%s cannot log in", recipient.Username)
	}
	return nil
}

func (s *Service) validateGroupRecipient(ctx context.Context, viewer users.User, groupID int64) error {
	role, member, err := s.groups.RoleOf(ctx, groupID, viewer.ID)
	if err != nil {
		return err
	}
	if !member || !role.CanShare() {
		return apperr.Forbidden("you may only share with groups you are an admin or member of")
	}
	return nil
}

func (s *Service) UpdateShare(ctx context.Context, viewer users.User, calendarID, shareID int64, access Access) (CalendarShare, error) {
	c, err := s.ownedCalendar(ctx, viewer, calendarID)
	if err != nil {
		return CalendarShare{}, err
	}
	if !validShareAccess(access) || (c.Kind == KindSubscription && access == AccessReadWrite) {
		return CalendarShare{}, apperr.Invalid("access is readwrite, read or freebusy; subscriptions are never writable")
	}
	if err := s.store.UpdateShareAccess(ctx, calendarID, shareID, access); err != nil {
		return CalendarShare{}, err
	}
	s.publishCalendar(ctx, c)
	return s.oneShare(ctx, calendarID, shareID)
}

func (s *Service) RemoveShare(ctx context.Context, viewer users.User, calendarID, shareID int64) error {
	c, err := s.ownedCalendar(ctx, viewer, calendarID)
	if err != nil {
		return err
	}
	audience, err := s.audience(ctx, c)
	if err != nil {
		return err
	}
	if err := s.store.DeleteShare(ctx, calendarID, shareID); err != nil {
		return err
	}
	for _, userID := range audience {
		s.publishTo(userID, calendarID)
	}
	return nil
}

func (s *Service) oneShare(ctx context.Context, calendarID, shareID int64) (CalendarShare, error) {
	shares, err := s.store.Shares(ctx, calendarID)
	if err != nil {
		return CalendarShare{}, err
	}
	for _, share := range shares {
		if share.ID == shareID {
			return share, s.describeShare(ctx, &share)
		}
	}
	return CalendarShare{}, shareNotFound()
}

func scanShare(row database.RowScanner) (CalendarShare, error) {
	var share CalendarShare
	var userID, groupID sql.NullInt64
	var createdAt int64
	err := row.Scan(&share.ID, &share.CalendarID, &userID, &groupID, &share.Access, &createdAt)
	share.userID, share.groupID = userID.Int64, groupID.Int64
	share.CreatedAt = time.Unix(createdAt, 0).UTC()
	return share, err
}

func (s *Store) Shares(ctx context.Context, calendarID int64) ([]CalendarShare, error) {
	return database.QueryAll(ctx, s.db, scanShare,
		`SELECT id, calendar_id, recipient_user_id, recipient_group_id, access, created_at FROM calendar_shares WHERE calendar_id = $1 ORDER BY id`,
		calendarID)
}

func (s *Store) InsertShare(ctx context.Context, share CalendarShare) (int64, error) {
	var id int64
	err := s.db.QueryRowContext(ctx,
		`INSERT INTO calendar_shares (calendar_id, recipient_user_id, recipient_group_id, access, created_at) VALUES ($1, $2, $3, $4, $5) RETURNING id`,
		share.CalendarID, database.NullIfZero(share.userID), database.NullIfZero(share.groupID), share.Access, time.Now().Unix()).Scan(&id)
	if database.IsUniqueViolation(err) {
		return 0, apperr.AlreadyExists("the calendar is already shared with them")
	}
	return id, err
}

func (s *Store) UpdateShareAccess(ctx context.Context, calendarID, shareID int64, access Access) error {
	return database.RequireAffected(shareNotFound())(s.db.ExecContext(ctx,
		`UPDATE calendar_shares SET access = $1 WHERE calendar_id = $2 AND id = $3`, access, calendarID, shareID))
}

func (s *Store) DeleteShare(ctx context.Context, calendarID, shareID int64) error {
	return database.RequireAffected(shareNotFound())(s.db.ExecContext(ctx,
		`DELETE FROM calendar_shares WHERE calendar_id = $1 AND id = $2`, calendarID, shareID))
}

func (s *Store) RemoveUserShare(ctx context.Context, calendarID, userID int64) (bool, error) {
	result, err := s.db.ExecContext(ctx, `DELETE FROM calendar_shares WHERE calendar_id = $1 AND recipient_user_id = $2`, calendarID, userID)
	if err != nil {
		return false, err
	}
	affected, err := result.RowsAffected()
	return affected > 0, err
}

func (s *Store) ShareAudience(ctx context.Context, calendarID int64) ([]int64, error) {
	return database.QueryAll(ctx, s.db, database.ScanInt64,
		`SELECT recipient_user_id FROM calendar_shares WHERE calendar_id = $1 AND recipient_user_id IS NOT NULL
		UNION SELECT gm.user_id FROM calendar_shares s JOIN group_members gm ON gm.group_id = s.recipient_group_id WHERE s.calendar_id = $1`,
		calendarID)
}

func (s *Store) NotifyChoices(ctx context.Context, calendarID int64) (map[int64]bool, error) {
	rows, err := s.db.QueryContext(ctx,
		`SELECT user_id, notify FROM calendar_user_settings WHERE calendar_id = $1 AND notify IS NOT NULL`, calendarID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	choices := map[int64]bool{}
	for rows.Next() {
		var userID int64
		var notify bool
		if err := rows.Scan(&userID, &notify); err != nil {
			return nil, err
		}
		choices[userID] = notify
	}
	return choices, rows.Err()
}
