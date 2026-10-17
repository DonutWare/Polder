package sharing

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

const shareColumns = `SELECT id, owner_id, file_id, recipient_user_id, recipient_group_id,
	can_create, can_update, can_delete, expires_at, note, created_at FROM shares`

type shareRow struct {
	ID               int64
	OwnerID          int64
	FileID           int64
	RecipientUserID  int64
	RecipientGroupID int64
	Permissions      SharePermissions
	ExpiresAt        *time.Time
	Note             string
	CreatedAt        time.Time
}

func (r shareRow) recipient() RecipientRef {
	if r.RecipientGroupID != 0 {
		return RecipientRef{Kind: RecipientGroup, ID: r.RecipientGroupID}
	}
	return RecipientRef{Kind: RecipientUser, ID: r.RecipientUserID}
}

func expired(expiresAt *time.Time, now time.Time) bool {
	return expiresAt != nil && !now.Before(*expiresAt)
}

func scanShare(row database.RowScanner) (shareRow, error) {
	var share shareRow
	var userID, groupID, expiresAt sql.NullInt64
	var createdAt int64
	permissions := &share.Permissions
	err := row.Scan(&share.ID, &share.OwnerID, &share.FileID, &userID, &groupID,
		&permissions.Create, &permissions.Edit, &permissions.Delete, &expiresAt, &share.Note, &createdAt)
	share.RecipientUserID, share.RecipientGroupID = userID.Int64, groupID.Int64
	share.ExpiresAt = optionalTime(expiresAt)
	share.CreatedAt = time.Unix(createdAt, 0).UTC()
	return share, err
}

func optionalTime(value sql.NullInt64) *time.Time {
	if !value.Valid {
		return nil
	}
	moment := time.Unix(value.Int64, 0).UTC()
	return &moment
}

func unixOrNil(moment *time.Time) any {
	if moment == nil {
		return nil
	}
	return moment.Unix()
}

func queryShares(ctx context.Context, db *sql.DB, query string, args ...any) ([]shareRow, error) {
	return database.QueryAll(ctx, db, scanShare, shareColumns+" "+query, args...)
}

func ownedQuery(ownerID, fileID int64) (string, []any) {
	if fileID == 0 {
		return `WHERE owner_id = $1 ORDER BY created_at DESC, id DESC`, []any{ownerID}
	}
	return `WHERE owner_id = $1 AND file_id = $2 ORDER BY created_at DESC, id DESC`, []any{ownerID, fileID}
}

func shareByID(ctx context.Context, db *sql.DB, id int64) (shareRow, error) {
	share, err := scanShare(db.QueryRowContext(ctx, shareColumns+` WHERE id = $1`, id))
	if errors.Is(err, sql.ErrNoRows) {
		return shareRow{}, notAvailable()
	}
	return share, err
}

func insertShare(ctx context.Context, db *sql.DB, row shareRow) (int64, error) {
	now := time.Now().Unix()
	permissions := row.Permissions
	var id int64
	err := db.QueryRowContext(ctx,
		`INSERT INTO shares (owner_id, file_id, recipient_user_id, recipient_group_id,
			can_create, can_update, can_delete, expires_at, note, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $10) RETURNING id`,
		row.OwnerID, row.FileID, database.NullIfZero(row.RecipientUserID), database.NullIfZero(row.RecipientGroupID),
		permissions.Create, permissions.Edit, permissions.Delete, unixOrNil(row.ExpiresAt), row.Note, now).Scan(&id)
	if database.IsUniqueViolation(err) {
		return 0, apperr.AlreadyExists("this item is already shared with them")
	}
	return id, err
}

func updateShare(ctx context.Context, db *sql.DB, row shareRow) error {
	permissions := row.Permissions
	_, err := db.ExecContext(ctx,
		`UPDATE shares SET can_create = $1, can_update = $2, can_delete = $3, expires_at = $4, note = $5, updated_at = $6 WHERE id = $7`,
		permissions.Create, permissions.Edit, permissions.Delete, unixOrNil(row.ExpiresAt), row.Note, time.Now().Unix(), row.ID)
	return err
}

func deleteByFileIDs(ctx context.Context, db *sql.DB, table string, ownerID int64, fileIDs []int64) error {
	if len(fileIDs) == 0 {
		return nil
	}
	placeholders := make([]string, len(fileIDs))
	args := []any{ownerID}
	for i, id := range fileIDs {
		args = append(args, id)
		placeholders[i] = "$" + strconv.Itoa(i+2)
	}
	_, err := db.ExecContext(ctx, `DELETE FROM `+table+` WHERE owner_id = $1 AND file_id IN (`+strings.Join(placeholders, ", ")+`)`, args...)
	return err
}

func notAvailable() error {
	return apperr.NotFound("share not found")
}
