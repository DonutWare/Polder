package users

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"time"

	"polder-server/internal/apperr"
)

const selectUserColumns = `SELECT u.id, u.username, u.role, u.quota_bytes, u.disabled, u.created_at,
	u.trash_retention_days, u.trash_retention_override_days,
	u.versions_enabled, u.versions_max_age_days, u.versions_max_per_file,
	COALESCE((SELECT SUM(f.size) FROM files f WHERE f.user_id = u.id), 0),
	COALESCE((SELECT SUM(k.stored_size) FROM version_chunks k WHERE k.user_id = u.id), 0)
	+ COALESCE((SELECT SUM(v.size) FROM file_versions v WHERE v.user_id = u.id AND v.state = 'pending'), 0) FROM users u`

type Store struct {
	db *sql.DB
}

func NewStore(db *sql.DB) *Store {
	return &Store{db: db}
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanUser(row rowScanner) (User, error) {
	var user User
	var createdAt int64
	var retention, retentionOverride, versionsMaxAge, versionsMaxPerFile sql.NullInt64
	var versionsEnabled sql.NullBool
	var fileBytes int64
	err := row.Scan(&user.ID, &user.Username, &user.Role, &user.QuotaBytes, &user.Disabled, &createdAt,
		&retention, &retentionOverride, &versionsEnabled, &versionsMaxAge, &versionsMaxPerFile, &fileBytes, &user.HistoryBytes)
	user.CreatedAt = time.Unix(createdAt, 0).UTC()
	user.TrashRetentionDays = optionalInt(retention)
	user.TrashRetentionOverrideDays = optionalInt(retentionOverride)
	user.Versions = VersionPreferences{
		Enabled:    optionalBool(versionsEnabled),
		MaxAgeDays: optionalInt(versionsMaxAge),
		MaxPerFile: optionalInt(versionsMaxPerFile),
	}
	user.UsedBytes = fileBytes + user.HistoryBytes
	return user, err
}

func optionalInt(value sql.NullInt64) *int {
	if !value.Valid {
		return nil
	}
	converted := int(value.Int64)
	return &converted
}

func optionalBool(value sql.NullBool) *bool {
	if !value.Valid {
		return nil
	}
	return &value.Bool
}

func nullableBool(value *bool) any {
	if value == nil {
		return nil
	}
	return *value
}

func nullableInt(value *int) any {
	if value == nil {
		return nil
	}
	return *value
}

func (s *Store) Count(ctx context.Context) (int, error) {
	var count int
	err := s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM users`).Scan(&count)
	return count, err
}

func (s *Store) Insert(ctx context.Context, newUser NewUser, passwordHash string) (User, error) {
	var id int64
	err := s.db.QueryRowContext(ctx,
		`INSERT INTO users (username, password_hash, role, quota_bytes, disabled, created_at) VALUES ($1, $2, $3, $4, FALSE, $5) RETURNING id`,
		newUser.Username, passwordHash, newUser.Role, newUser.QuotaBytes, time.Now().Unix()).Scan(&id)
	if isUniqueViolation(err) {
		return User{}, apperr.AlreadyExists("user %q already exists", newUser.Username)
	}
	if err != nil {
		return User{}, fmt.Errorf("insert user: %w", err)
	}
	return s.ByID(ctx, id)
}

func (s *Store) ByID(ctx context.Context, id int64) (User, error) {
	user, err := scanUser(s.db.QueryRowContext(ctx, selectUserColumns+` WHERE u.id = $1`, id))
	if errors.Is(err, sql.ErrNoRows) {
		return User{}, apperr.NotFound("user not found")
	}
	return user, err
}

func (s *Store) CredentialsByUsername(ctx context.Context, username string) (User, string, error) {
	var passwordHash string
	err := s.db.QueryRowContext(ctx, `SELECT password_hash FROM users WHERE username = $1`, username).Scan(&passwordHash)
	if errors.Is(err, sql.ErrNoRows) {
		return User{}, "", apperr.NotFound("user not found")
	}
	if err != nil {
		return User{}, "", err
	}
	user, err := scanUser(s.db.QueryRowContext(ctx, selectUserColumns+` WHERE u.username = $1`, username))
	return user, passwordHash, err
}

func (s *Store) List(ctx context.Context) ([]User, error) {
	rows, err := s.db.QueryContext(ctx, selectUserColumns+` ORDER BY u.username`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	list := []User{}
	for rows.Next() {
		user, err := scanUser(rows)
		if err != nil {
			return nil, err
		}
		list = append(list, user)
	}
	return list, rows.Err()
}

func (s *Store) Update(ctx context.Context, id int64, changes Changes, passwordHash string) error {
	var assignments []string
	var args []any
	set := func(column string, value any) {
		args = append(args, value)
		assignments = append(assignments, column+" = $"+strconv.Itoa(len(args)))
	}
	if changes.Password != nil {
		set("password_hash", passwordHash)
	}
	if changes.Role != nil {
		set("role", *changes.Role)
	}
	if changes.QuotaBytes != nil {
		set("quota_bytes", *changes.QuotaBytes)
	}
	if changes.Disabled != nil {
		set("disabled", *changes.Disabled)
	}
	if override := changes.TrashRetentionOverrideDays; override != nil {
		if *override == ClearRetentionOverride {
			override = nil
		}
		set("trash_retention_override_days", nullableInt(override))
	}
	if len(assignments) == 0 {
		return nil
	}
	args = append(args, id)
	query := `UPDATE users SET ` + strings.Join(assignments, ", ") + ` WHERE id = $` + strconv.Itoa(len(args))
	_, err := s.db.ExecContext(ctx, query, args...)
	return err
}

func (s *Store) SetTrashRetention(ctx context.Context, id int64, days *int) error {
	_, err := s.db.ExecContext(ctx, `UPDATE users SET trash_retention_days = $1 WHERE id = $2`, nullableInt(days), id)
	return err
}

func (s *Store) SetVersionPreferences(ctx context.Context, id int64, preferences VersionPreferences) error {
	_, err := s.db.ExecContext(ctx, `UPDATE users SET versions_enabled = $1, versions_max_age_days = $2, versions_max_per_file = $3 WHERE id = $4`,
		nullableBool(preferences.Enabled), nullableInt(preferences.MaxAgeDays), nullableInt(preferences.MaxPerFile), id)
	return err
}

func (s *Store) Delete(ctx context.Context, id int64) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM users WHERE id = $1`, id)
	return err
}

func isUniqueViolation(err error) bool {
	if err == nil {
		return false
	}
	message := strings.ToLower(err.Error())
	return strings.Contains(message, "unique") || strings.Contains(message, "duplicate")
}
