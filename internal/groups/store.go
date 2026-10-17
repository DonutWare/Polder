package groups

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
)

const selectGroupColumns = `SELECT g.id, g.name, g.created_at, COALESCE(g.created_by, 0),
	(SELECT COUNT(*) FROM group_members m WHERE m.group_id = g.id) FROM groups g`

type Store struct {
	db *sql.DB
}

func NewStore(db *sql.DB) *Store {
	return &Store{db: db}
}

func scanGroup(row database.RowScanner) (Group, error) {
	var group Group
	var createdAt int64
	err := row.Scan(&group.ID, &group.Name, &createdAt, &group.createdByID, &group.MemberCount)
	group.CreatedAt = time.Unix(createdAt, 0).UTC()
	return group, err
}

func (s *Store) queryGroups(ctx context.Context, query string, args ...any) ([]Group, error) {
	return database.QueryAll(ctx, s.db, scanGroup, selectGroupColumns+query, args...)
}

func (s *Store) List(ctx context.Context) ([]Group, error) {
	return s.queryGroups(ctx, ` ORDER BY LOWER(g.name), g.id`)
}

func (s *Store) Visible(ctx context.Context, userID int64) ([]Group, error) {
	return s.queryGroups(ctx, ` WHERE g.id IN (SELECT group_id FROM group_members WHERE user_id = $1) ORDER BY LOWER(g.name), g.id`, userID)
}

func (s *Store) ShareableFor(ctx context.Context, userID int64) ([]Group, error) {
	return s.queryGroups(ctx, ` WHERE g.id IN (SELECT group_id FROM group_members WHERE user_id = $1 AND role IN ('admin', 'member')) ORDER BY LOWER(g.name), g.id`, userID)
}

func (s *Store) ByID(ctx context.Context, id int64) (Group, error) {
	group, err := scanGroup(s.db.QueryRowContext(ctx, selectGroupColumns+` WHERE g.id = $1`, id))
	if errors.Is(err, sql.ErrNoRows) {
		return Group{}, notFound()
	}
	return group, err
}

func (s *Store) Insert(ctx context.Context, name string, createdBy int64) (int64, error) {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return 0, err
	}
	defer func() { _ = tx.Rollback() }()
	now := time.Now().Unix()
	var id int64
	err = tx.QueryRowContext(ctx, `INSERT INTO groups (name, created_by, created_at) VALUES ($1, $2, $3) RETURNING id`,
		name, createdBy, now).Scan(&id)
	if err != nil {
		return 0, err
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO group_members (group_id, user_id, role, added_at) VALUES ($1, $2, $3, $4)`,
		id, createdBy, RoleAdmin, now); err != nil {
		return 0, err
	}
	return id, tx.Commit()
}

func (s *Store) Rename(ctx context.Context, id int64, name string) error {
	return database.RequireAffected(notFound())(s.db.ExecContext(ctx, `UPDATE groups SET name = $1 WHERE id = $2`, name, id))
}

func (s *Store) Delete(ctx context.Context, id int64) error {
	return database.RequireAffected(notFound())(s.db.ExecContext(ctx, `DELETE FROM groups WHERE id = $1`, id))
}

func (s *Store) Members(ctx context.Context, groupID int64) (map[int64]Role, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT user_id, role FROM group_members WHERE group_id = $1`, groupID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	members := map[int64]Role{}
	for rows.Next() {
		var id int64
		var role Role
		if err := rows.Scan(&id, &role); err != nil {
			return nil, err
		}
		members[id] = role
	}
	return members, rows.Err()
}

func (s *Store) Role(ctx context.Context, groupID, userID int64) (Role, bool, error) {
	var role Role
	err := s.db.QueryRowContext(ctx, `SELECT role FROM group_members WHERE group_id = $1 AND user_id = $2`, groupID, userID).Scan(&role)
	if errors.Is(err, sql.ErrNoRows) {
		return "", false, nil
	}
	return role, err == nil, err
}

func (s *Store) AddMember(ctx context.Context, groupID, userID int64, role Role) error {
	_, err := s.db.ExecContext(ctx, `INSERT INTO group_members (group_id, user_id, role, added_at) VALUES ($1, $2, $3, $4)`,
		groupID, userID, role, time.Now().Unix())
	if database.IsUniqueViolation(err) {
		return apperr.AlreadyExists("already a member")
	}
	return err
}

func (s *Store) SetRole(ctx context.Context, groupID, userID int64, role Role) error {
	return database.RequireAffected(notFound())(s.db.ExecContext(ctx, `UPDATE group_members SET role = $1 WHERE group_id = $2 AND user_id = $3`, role, groupID, userID))
}

func (s *Store) RemoveMember(ctx context.Context, groupID, userID int64) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()
	if err := database.RequireAffected(notFound())(tx.ExecContext(ctx, `DELETE FROM group_members WHERE group_id = $1 AND user_id = $2`, groupID, userID)); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `DELETE FROM shares WHERE recipient_group_id = $1 AND owner_id = $2`, groupID, userID); err != nil {
		return err
	}
	return tx.Commit()
}

func (s *Store) AdminCount(ctx context.Context, groupID int64) (int, error) {
	var count int
	err := s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM group_members WHERE group_id = $1 AND role = $2`, groupID, RoleAdmin).Scan(&count)
	return count, err
}

func notFound() error {
	return apperr.NotFound("group not found")
}
