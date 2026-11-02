package calendar

import (
	"context"
	"database/sql"
	"errors"
	"strconv"
	"strings"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
)

const (
	calendarColumns = `c.id, c.owner_id, c.uri, c.name, c.description, c.color, c.timezone, c.sort_order, c.kind, c.is_default,
	c.sync_revision, c.pruned_revision, c.source_url, c.refresh_seconds, c.fetched_at, c.fetch_etag, c.fetch_last_modified,
	c.fetch_error, c.created_at, c.updated_at`
	objectMetaColumns = `o.id, o.calendar_id, o.uri, o.uid, o.etag, o.schedule_tag, o.size, o.first_start, o.last_end, o.recurring,
	o.has_alarms, o.summary, o.created_at, o.updated_at`
	objectColumns = objectMetaColumns + `, o.data`
)

type Store struct {
	db *sql.DB
}

func NewStore(db *sql.DB) *Store {
	return &Store{db: db}
}

type Object struct {
	ID          int64
	CalendarID  int64
	URI         string
	UID         string
	ETag        string
	ScheduleTag string
	Data        []byte
	Size        int64
	FirstStart  time.Time
	LastEnd     *time.Time
	Recurring   bool
	HasAlarms   bool
	Summary     string
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

type Change struct {
	Revision int64
	URI      string
	Deleted  bool
}

func scanCalendar(row database.RowScanner) (Calendar, error) {
	var c Calendar
	var fetchedAt sql.NullInt64
	var createdAt, updatedAt int64
	err := row.Scan(&c.ID, &c.OwnerID, &c.URI, &c.Name, &c.Description, &c.Color, &c.Timezone, &c.Order, &c.Kind, &c.IsDefault,
		&c.SyncRevision, &c.PrunedRevision, &c.SourceURL, &c.RefreshSeconds, &fetchedAt, &c.FetchETag, &c.FetchLastModified,
		&c.FetchError, &createdAt, &updatedAt)
	c.CreatedAt, c.UpdatedAt = time.Unix(createdAt, 0).UTC(), time.Unix(updatedAt, 0).UTC()
	if fetchedAt.Valid {
		fetched := time.Unix(fetchedAt.Int64, 0).UTC()
		c.FetchedAt = &fetched
	}
	return c, err
}

func scanObjectMeta(row database.RowScanner) (Object, error) {
	var o Object
	var firstStart, createdAt, updatedAt int64
	var lastEnd sql.NullInt64
	err := row.Scan(&o.ID, &o.CalendarID, &o.URI, &o.UID, &o.ETag, &o.ScheduleTag, &o.Size, &firstStart, &lastEnd, &o.Recurring,
		&o.HasAlarms, &o.Summary, &createdAt, &updatedAt)
	o.FirstStart = time.Unix(firstStart, 0).UTC()
	o.CreatedAt, o.UpdatedAt = time.Unix(createdAt, 0).UTC(), time.Unix(updatedAt, 0).UTC()
	if lastEnd.Valid {
		end := time.Unix(lastEnd.Int64, 0).UTC()
		o.LastEnd = &end
	}
	return o, err
}

func scanObject(row database.RowScanner) (Object, error) {
	var o Object
	var firstStart, createdAt, updatedAt int64
	var lastEnd sql.NullInt64
	var data string
	err := row.Scan(&o.ID, &o.CalendarID, &o.URI, &o.UID, &o.ETag, &o.ScheduleTag, &o.Size, &firstStart, &lastEnd, &o.Recurring,
		&o.HasAlarms, &o.Summary, &createdAt, &updatedAt, &data)
	o.FirstStart = time.Unix(firstStart, 0).UTC()
	o.CreatedAt, o.UpdatedAt = time.Unix(createdAt, 0).UTC(), time.Unix(updatedAt, 0).UTC()
	o.Data = []byte(data)
	if lastEnd.Valid {
		end := time.Unix(lastEnd.Int64, 0).UTC()
		o.LastEnd = &end
	}
	return o, err
}

func (s *Store) InsertCalendar(ctx context.Context, c Calendar) (int64, error) {
	now := time.Now().Unix()
	var id int64
	err := s.db.QueryRowContext(ctx,
		`INSERT INTO calendars (owner_id, uri, name, description, color, timezone, sort_order, kind, is_default, source_url, refresh_seconds, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $12) RETURNING id`,
		c.OwnerID, c.URI, c.Name, c.Description, c.Color, c.Timezone, c.Order, c.Kind, c.IsDefault, c.SourceURL, c.RefreshSeconds, now).Scan(&id)
	if database.IsUniqueViolation(err) {
		return 0, apperr.AlreadyExists("a calendar at %s already exists", c.URI)
	}
	return id, err
}

func (s *Store) CalendarByID(ctx context.Context, id int64) (Calendar, error) {
	c, err := scanCalendar(s.db.QueryRowContext(ctx, `SELECT `+calendarColumns+` FROM calendars c WHERE c.id = $1`, id))
	if errors.Is(err, sql.ErrNoRows) {
		return Calendar{}, calendarNotFound()
	}
	return c, err
}

func (s *Store) CalendarByURI(ctx context.Context, ownerID int64, uri string) (Calendar, error) {
	c, err := scanCalendar(s.db.QueryRowContext(ctx, `SELECT `+calendarColumns+` FROM calendars c WHERE c.owner_id = $1 AND c.uri = $2`, ownerID, uri))
	if errors.Is(err, sql.ErrNoRows) {
		return Calendar{}, calendarNotFound()
	}
	return c, err
}

func (s *Store) OwnedCalendars(ctx context.Context, ownerID int64) ([]Calendar, error) {
	return database.QueryAll(ctx, s.db, scanCalendar,
		`SELECT `+calendarColumns+` FROM calendars c WHERE c.owner_id = $1 ORDER BY c.sort_order, c.id`, ownerID)
}

type shareReach struct {
	Calendar  Calendar
	Access    Access
	ViaGroup  bool
	GroupRole string
}

func (s *Store) ReachingShares(ctx context.Context, userID int64) ([]shareReach, error) {
	return database.QueryAll(ctx, s.db, func(row database.RowScanner) (shareReach, error) {
		var reach shareReach
		var groupID sql.NullInt64
		var role sql.NullString
		var c Calendar
		var fetchedAt sql.NullInt64
		var createdAt, updatedAt int64
		err := row.Scan(&c.ID, &c.OwnerID, &c.URI, &c.Name, &c.Description, &c.Color, &c.Timezone, &c.Order, &c.Kind, &c.IsDefault,
			&c.SyncRevision, &c.PrunedRevision, &c.SourceURL, &c.RefreshSeconds, &fetchedAt, &c.FetchETag, &c.FetchLastModified,
			&c.FetchError, &createdAt, &updatedAt, &reach.Access, &groupID, &role)
		c.CreatedAt, c.UpdatedAt = time.Unix(createdAt, 0).UTC(), time.Unix(updatedAt, 0).UTC()
		if fetchedAt.Valid {
			fetched := time.Unix(fetchedAt.Int64, 0).UTC()
			c.FetchedAt = &fetched
		}
		reach.Calendar, reach.ViaGroup, reach.GroupRole = c, groupID.Valid, role.String
		return reach, err
	}, `SELECT `+calendarColumns+`, s.access, s.recipient_group_id, gm.role FROM calendar_shares s
		JOIN calendars c ON c.id = s.calendar_id
		LEFT JOIN group_members gm ON gm.group_id = s.recipient_group_id AND gm.user_id = $1
		WHERE c.owner_id <> $1 AND (s.recipient_user_id = $1 OR gm.user_id IS NOT NULL)
		ORDER BY c.id`, userID)
}

func (s *Store) UpdateCalendar(ctx context.Context, c Calendar) error {
	return database.RequireAffected(calendarNotFound())(s.db.ExecContext(ctx,
		`UPDATE calendars SET name = $1, description = $2, color = $3, timezone = $4, sort_order = $5, source_url = $6,
		refresh_seconds = $7, sync_revision = sync_revision + 1, updated_at = $8 WHERE id = $9`,
		c.Name, c.Description, c.Color, c.Timezone, c.Order, c.SourceURL, c.RefreshSeconds, time.Now().Unix(), c.ID))
}

func (s *Store) DeleteCalendar(ctx context.Context, id int64) error {
	return database.RequireAffected(calendarNotFound())(s.db.ExecContext(ctx, `DELETE FROM calendars WHERE id = $1`, id))
}

func (s *Store) SetDefault(ctx context.Context, ownerID, id int64) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()
	if _, err := tx.ExecContext(ctx, `UPDATE calendars SET is_default = FALSE WHERE owner_id = $1`, ownerID); err != nil {
		return err
	}
	if err := database.RequireAffected(calendarNotFound())(tx.ExecContext(ctx,
		`UPDATE calendars SET is_default = TRUE WHERE owner_id = $1 AND id = $2 AND kind = $3`, ownerID, id, KindLocal)); err != nil {
		return err
	}
	return tx.Commit()
}

func (s *Store) RecordFetch(ctx context.Context, id int64, etag, lastModified, fetchError string) error {
	_, err := s.db.ExecContext(ctx,
		`UPDATE calendars SET fetched_at = $1, fetch_etag = $2, fetch_last_modified = $3, fetch_error = $4 WHERE id = $5`,
		time.Now().Unix(), etag, lastModified, fetchError, id)
	return err
}

func (s *Store) DueSubscriptions(ctx context.Context, now time.Time) ([]Calendar, error) {
	return database.QueryAll(ctx, s.db, scanCalendar,
		`SELECT `+calendarColumns+` FROM calendars c WHERE c.kind = $1 AND (c.fetched_at IS NULL OR c.fetched_at + c.refresh_seconds <= $2)
		ORDER BY c.fetched_at`, KindSubscription, now.Unix())
}

type UserSettings struct {
	DisplayName string
	Color       string
	Hidden      bool
	Order       *int
	Notify      *bool
}

func (s *Store) UserSettings(ctx context.Context, userID int64) (map[int64]UserSettings, error) {
	rows, err := s.db.QueryContext(ctx,
		`SELECT calendar_id, display_name, color, hidden, sort_order, notify FROM calendar_user_settings WHERE user_id = $1`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	settings := map[int64]UserSettings{}
	for rows.Next() {
		var calendarID int64
		var entry UserSettings
		var order sql.NullInt64
		var notify sql.NullBool
		if err := rows.Scan(&calendarID, &entry.DisplayName, &entry.Color, &entry.Hidden, &order, &notify); err != nil {
			return nil, err
		}
		if order.Valid {
			value := int(order.Int64)
			entry.Order = &value
		}
		if notify.Valid {
			entry.Notify = &notify.Bool
		}
		settings[calendarID] = entry
	}
	return settings, rows.Err()
}

func (s *Store) SetUserSettings(ctx context.Context, userID, calendarID int64, settings UserSettings) error {
	_, err := s.db.ExecContext(ctx,
		`INSERT INTO calendar_user_settings (user_id, calendar_id, display_name, color, hidden, sort_order, notify)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		ON CONFLICT (user_id, calendar_id) DO UPDATE SET display_name = excluded.display_name, color = excluded.color,
		hidden = excluded.hidden, sort_order = excluded.sort_order, notify = excluded.notify`,
		userID, calendarID, settings.DisplayName, settings.Color, settings.Hidden, database.NullIfNil(settings.Order), database.NullIfNil(settings.Notify))
	return err
}

func (s *Store) Object(ctx context.Context, calendarID int64, uri string) (Object, error) {
	return s.oneObject(ctx, `o.calendar_id = $1 AND o.uri = $2`, calendarID, uri)
}

func (s *Store) ObjectByUID(ctx context.Context, calendarID int64, uid string) (Object, error) {
	return s.oneObject(ctx, `o.calendar_id = $1 AND o.uid = $2`, calendarID, uid)
}

func (s *Store) ObjectByID(ctx context.Context, id int64) (Object, error) {
	return s.oneObject(ctx, `o.id = $1`, id)
}

func (s *Store) oneObject(ctx context.Context, condition string, args ...any) (Object, error) {
	object, err := scanObject(s.db.QueryRowContext(ctx, `SELECT `+objectColumns+` FROM calendar_objects o WHERE `+condition, args...))
	if errors.Is(err, sql.ErrNoRows) {
		return Object{}, objectNotFound()
	}
	return object, err
}

func (s *Store) ObjectsByUIDForOwner(ctx context.Context, ownerID int64, uid string) ([]Object, error) {
	return database.QueryAll(ctx, s.db, scanObject,
		`SELECT `+objectColumns+` FROM calendar_objects o JOIN calendars c ON c.id = o.calendar_id
		WHERE c.owner_id = $1 AND c.kind = $2 AND o.uid = $3 ORDER BY c.is_default DESC, c.id`, ownerID, KindLocal, uid)
}

func (s *Store) ObjectMetas(ctx context.Context, calendarID int64) ([]Object, error) {
	return database.QueryAll(ctx, s.db, scanObjectMeta,
		`SELECT `+objectMetaColumns+` FROM calendar_objects o WHERE o.calendar_id = $1 ORDER BY o.uri`, calendarID)
}

func (s *Store) Objects(ctx context.Context, calendarID int64) ([]Object, error) {
	return database.QueryAll(ctx, s.db, scanObject,
		`SELECT `+objectColumns+` FROM calendar_objects o WHERE o.calendar_id = $1 ORDER BY o.uri`, calendarID)
}

func (s *Store) ObjectsByURIs(ctx context.Context, calendarID int64, uris []string) ([]Object, error) {
	if len(uris) == 0 {
		return []Object{}, nil
	}
	args := []any{calendarID}
	list := inList(&args, uris)
	return database.QueryAll(ctx, s.db, scanObject,
		`SELECT `+objectColumns+` FROM calendar_objects o WHERE o.calendar_id = $1 AND o.uri IN (`+list+`) ORDER BY o.uri`, args...)
}

func (s *Store) ObjectsInRange(ctx context.Context, calendarIDs []int64, window TimeRange) ([]Object, error) {
	if len(calendarIDs) == 0 {
		return []Object{}, nil
	}
	args := []any{}
	list := inList(&args, calendarIDs)
	query := `SELECT ` + objectColumns + ` FROM calendar_objects o WHERE o.calendar_id IN (` + list + `)`
	if !window.End.IsZero() {
		args = append(args, window.End.Unix())
		query += ` AND o.first_start < $` + strconv.Itoa(len(args))
	}
	if !window.Start.IsZero() {
		args = append(args, window.Start.Unix())
		query += ` AND (o.last_end IS NULL OR o.last_end >= $` + strconv.Itoa(len(args)) + `)`
	}
	return database.QueryAll(ctx, s.db, scanObject, query+` ORDER BY o.first_start, o.id`, args...)
}

func (s *Store) AlarmCandidates(ctx context.Context, from, to time.Time) ([]Object, error) {
	return database.QueryAll(ctx, s.db, scanObject,
		`SELECT `+objectColumns+` FROM calendar_objects o WHERE o.has_alarms = TRUE AND o.first_start < $1
		AND (o.last_end IS NULL OR o.last_end >= $2) ORDER BY o.id`, to.Unix(), from.Unix())
}

func (s *Store) CountObjects(ctx context.Context, calendarID int64) (int, error) {
	var count int
	err := s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM calendar_objects WHERE calendar_id = $1`, calendarID).Scan(&count)
	return count, err
}

func (s *Store) PutObject(ctx context.Context, object Object) (Object, error) {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return Object{}, err
	}
	defer func() { _ = tx.Rollback() }()
	now := time.Now().Unix()
	revision, err := bumpRevision(ctx, tx, object.CalendarID, now)
	if err != nil {
		return Object{}, err
	}
	var lastEnd any
	if object.LastEnd != nil {
		lastEnd = object.LastEnd.Unix()
	}
	err = tx.QueryRowContext(ctx,
		`INSERT INTO calendar_objects (calendar_id, uri, uid, etag, schedule_tag, component, data, size, first_start, last_end, recurring, has_alarms, summary, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $14)
		ON CONFLICT (calendar_id, uri) DO UPDATE SET uid = excluded.uid, etag = excluded.etag, schedule_tag = excluded.schedule_tag,
		data = excluded.data, size = excluded.size, first_start = excluded.first_start, last_end = excluded.last_end,
		recurring = excluded.recurring, has_alarms = excluded.has_alarms, summary = excluded.summary, updated_at = excluded.updated_at
		RETURNING id`,
		object.CalendarID, object.URI, object.UID, object.ETag, object.ScheduleTag, ComponentEvent, string(object.Data), len(object.Data),
		object.FirstStart.Unix(), lastEnd, object.Recurring, object.HasAlarms, object.Summary, now).Scan(&object.ID)
	if database.IsUniqueViolation(err) {
		return Object{}, violation(ConditionNoUIDConflict, apperr.KindAlreadyExists, "another event in this calendar has UID %s", object.UID)
	}
	if err != nil {
		return Object{}, err
	}
	if err := recordChange(ctx, tx, object.CalendarID, revision, object.URI, false, now); err != nil {
		return Object{}, err
	}
	if err := tx.Commit(); err != nil {
		return Object{}, err
	}
	return s.ObjectByID(ctx, object.ID)
}

func (s *Store) DeleteObject(ctx context.Context, calendarID int64, uri string) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()
	now := time.Now().Unix()
	revision, err := bumpRevision(ctx, tx, calendarID, now)
	if err != nil {
		return err
	}
	if err := database.RequireAffected(objectNotFound())(tx.ExecContext(ctx,
		`DELETE FROM calendar_objects WHERE calendar_id = $1 AND uri = $2`, calendarID, uri)); err != nil {
		return err
	}
	if err := recordChange(ctx, tx, calendarID, revision, uri, true, now); err != nil {
		return err
	}
	return tx.Commit()
}

func bumpRevision(ctx context.Context, tx *sql.Tx, calendarID, now int64) (int64, error) {
	var revision int64
	err := tx.QueryRowContext(ctx,
		`UPDATE calendars SET sync_revision = sync_revision + 1, updated_at = $1 WHERE id = $2 RETURNING sync_revision`,
		now, calendarID).Scan(&revision)
	if errors.Is(err, sql.ErrNoRows) {
		return 0, calendarNotFound()
	}
	return revision, err
}

func recordChange(ctx context.Context, tx *sql.Tx, calendarID, revision int64, uri string, deleted bool, now int64) error {
	_, err := tx.ExecContext(ctx,
		`INSERT INTO calendar_changes (calendar_id, revision, object_uri, deleted, created_at) VALUES ($1, $2, $3, $4, $5)`,
		calendarID, revision, uri, deleted, now)
	return err
}

func (s *Store) ChangesSince(ctx context.Context, calendarID, revision int64) ([]Change, error) {
	return database.QueryAll(ctx, s.db, func(row database.RowScanner) (Change, error) {
		var change Change
		err := row.Scan(&change.Revision, &change.URI, &change.Deleted)
		return change, err
	}, `SELECT c.revision, c.object_uri, c.deleted FROM calendar_changes c
		WHERE c.calendar_id = $1 AND c.revision > $2 AND c.revision = (
			SELECT MAX(latest.revision) FROM calendar_changes latest WHERE latest.calendar_id = c.calendar_id AND latest.object_uri = c.object_uri)
		ORDER BY c.revision`, calendarID, revision)
}

func (s *Store) PruneChanges(ctx context.Context, before time.Time) error {
	if _, err := s.db.ExecContext(ctx,
		`UPDATE calendars SET pruned_revision = (SELECT MAX(revision) FROM calendar_changes WHERE calendar_id = calendars.id AND created_at < $1)
		WHERE EXISTS (SELECT 1 FROM calendar_changes WHERE calendar_id = calendars.id AND created_at < $1)`, before.Unix()); err != nil {
		return err
	}
	_, err := s.db.ExecContext(ctx, `DELETE FROM calendar_changes WHERE created_at < $1`, before.Unix())
	return err
}

func (s *Store) NoteAlarm(ctx context.Context, objectID, userID int64, occurrenceStart time.Time, key string) (bool, error) {
	result, err := s.db.ExecContext(ctx,
		`INSERT INTO calendar_alarm_log (object_id, user_id, occurrence_start, alarm_key, fired_at) VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (object_id, user_id, occurrence_start, alarm_key) DO NOTHING`,
		objectID, userID, occurrenceStart.Unix(), key, time.Now().Unix())
	if err != nil {
		return false, err
	}
	affected, err := result.RowsAffected()
	return affected > 0, err
}

func (s *Store) PruneAlarmLog(ctx context.Context, before time.Time) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM calendar_alarm_log WHERE fired_at < $1`, before.Unix())
	return err
}

func inList[T any](args *[]any, values []T) string {
	placeholders := make([]string, 0, len(values))
	for _, value := range values {
		*args = append(*args, value)
		placeholders = append(placeholders, "$"+strconv.Itoa(len(*args)))
	}
	return strings.Join(placeholders, ",")
}
