package users

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"
	"time"

	"nomad-server/internal/apperr"
)

const selectUserColumns = `SELECT u.id, u.username, u.role, u.quota_bytes, u.disabled, u.created_at,
	u.trash_retention_days, u.trash_retention_override_days,
	COALESCE((SELECT SUM(f.size) FROM files f WHERE f.user_id = u.id), 0) FROM users u`

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
	var retention, retentionOverride sql.NullInt64
	err := row.Scan(&user.ID, &user.Username, &user.Role, &user.QuotaBytes, &user.Disabled, &createdAt,
		&retention, &retentionOverride, &user.UsedBytes)
	user.CreatedAt = time.Unix(createdAt, 0).UTC()
	user.TrashRetentionDays = optionalDays(retention)
	user.TrashRetentionOverrideDays = optionalDays(retentionOverride)
	return user, err
}

func optionalDays(value sql.NullInt64) *int {
	if !value.Valid {
		return nil
	}
	days := int(value.Int64)
	return &days
}

func nullableDays(days *int) any {
	if days == nil {
		return nil
	}
	return *days
}

func (s *Store) Count(ctx context.Context) (int, error) {
	var count int
	err := s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM users`).Scan(&count)
	return count, err
}

func (s *Store) Insert(ctx context.Context, newUser NewUser, passwordHash string) (User, error) {
	result, err := s.db.ExecContext(ctx,
		`INSERT INTO users (username, password_hash, role, quota_bytes, disabled, created_at) VALUES (?, ?, ?, ?, 0, ?)`,
		newUser.Username, passwordHash, newUser.Role, newUser.QuotaBytes, time.Now().Unix())
	if isUniqueViolation(err) {
		return User{}, apperr.AlreadyExists("user %q already exists", newUser.Username)
	}
	if err != nil {
		return User{}, fmt.Errorf("insert user: %w", err)
	}
	id, err := result.LastInsertId()
	if err != nil {
		return User{}, err
	}
	return s.ByID(ctx, id)
}

func (s *Store) ByID(ctx context.Context, id int64) (User, error) {
	user, err := scanUser(s.db.QueryRowContext(ctx, selectUserColumns+` WHERE u.id = ?`, id))
	if errors.Is(err, sql.ErrNoRows) {
		return User{}, apperr.NotFound("user not found")
	}
	return user, err
}

func (s *Store) CredentialsByUsername(ctx context.Context, username string) (User, string, error) {
	var passwordHash string
	err := s.db.QueryRowContext(ctx, `SELECT password_hash FROM users WHERE username = ?`, username).Scan(&passwordHash)
	if errors.Is(err, sql.ErrNoRows) {
		return User{}, "", apperr.NotFound("user not found")
	}
	if err != nil {
		return User{}, "", err
	}
	user, err := scanUser(s.db.QueryRowContext(ctx, selectUserColumns+` WHERE u.username = ?`, username))
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
	if changes.Password != nil {
		assignments, args = append(assignments, "password_hash = ?"), append(args, passwordHash)
	}
	if changes.Role != nil {
		assignments, args = append(assignments, "role = ?"), append(args, *changes.Role)
	}
	if changes.QuotaBytes != nil {
		assignments, args = append(assignments, "quota_bytes = ?"), append(args, *changes.QuotaBytes)
	}
	if changes.Disabled != nil {
		assignments, args = append(assignments, "disabled = ?"), append(args, *changes.Disabled)
	}
	if override := changes.TrashRetentionOverrideDays; override != nil {
		if *override == ClearRetentionOverride {
			override = nil
		}
		assignments, args = append(assignments, "trash_retention_override_days = ?"), append(args, nullableDays(override))
	}
	if len(assignments) == 0 {
		return nil
	}
	query := `UPDATE users SET ` + strings.Join(assignments, ", ") + ` WHERE id = ?`
	_, err := s.db.ExecContext(ctx, query, append(args, id)...)
	return err
}

func (s *Store) SetTrashRetention(ctx context.Context, id int64, days *int) error {
	_, err := s.db.ExecContext(ctx, `UPDATE users SET trash_retention_days = ? WHERE id = ?`, nullableDays(days), id)
	return err
}

func (s *Store) Delete(ctx context.Context, id int64) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM users WHERE id = ?`, id)
	return err
}

func isUniqueViolation(err error) bool {
	if err == nil {
		return false
	}
	message := strings.ToLower(err.Error())
	return strings.Contains(message, "unique") || strings.Contains(message, "duplicate")
}
