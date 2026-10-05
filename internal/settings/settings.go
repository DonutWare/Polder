package settings

import (
	"context"
	"database/sql"
	"strconv"

	"polder-server/internal/users"
)

const (
	trashRetentionDaysKey     = "trash_retention_days"
	trashRetentionEnforcedKey = "trash_retention_enforced"
)

type ServerSettings struct {
	TrashRetentionDays     int  `json:"trashRetentionDays" doc:"Days trashed items are kept before they're deleted permanently; 0 keeps them forever"`
	TrashRetentionEnforced bool `json:"trashRetentionEnforced" doc:"Apply trashRetentionDays to every user, ignoring their own setting"`
}

type ServerSettingsChanges struct {
	TrashRetentionDays     *int  `json:"trashRetentionDays" required:"false" doc:"Days trashed items are kept; 0 keeps them forever"`
	TrashRetentionEnforced *bool `json:"trashRetentionEnforced" required:"false" doc:"Apply trashRetentionDays to every user, ignoring their own setting"`
}

func (c ServerSettingsChanges) validate() error {
	if c.TrashRetentionDays != nil {
		return users.ValidateRetentionDays(*c.TrashRetentionDays)
	}
	return nil
}

type Store struct {
	db       *sql.DB
	defaults ServerSettings
}

func NewStore(db *sql.DB, defaults ServerSettings) *Store {
	return &Store{db: db, defaults: defaults}
}

func (s *Store) Get(ctx context.Context) (ServerSettings, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT name, value FROM server_settings`)
	if err != nil {
		return ServerSettings{}, err
	}
	defer rows.Close()

	current := s.defaults
	for rows.Next() {
		var name, value string
		if err := rows.Scan(&name, &value); err != nil {
			return ServerSettings{}, err
		}
		switch name {
		case trashRetentionDaysKey:
			if days, err := strconv.Atoi(value); err == nil {
				current.TrashRetentionDays = days
			}
		case trashRetentionEnforcedKey:
			if enforced, err := strconv.ParseBool(value); err == nil {
				current.TrashRetentionEnforced = enforced
			}
		}
	}
	return current, rows.Err()
}

func (s *Store) Update(ctx context.Context, changes ServerSettingsChanges) (ServerSettings, error) {
	if err := changes.validate(); err != nil {
		return ServerSettings{}, err
	}
	values := map[string]string{}
	if changes.TrashRetentionDays != nil {
		values[trashRetentionDaysKey] = strconv.Itoa(*changes.TrashRetentionDays)
	}
	if changes.TrashRetentionEnforced != nil {
		values[trashRetentionEnforcedKey] = strconv.FormatBool(*changes.TrashRetentionEnforced)
	}
	if err := s.save(ctx, values); err != nil {
		return ServerSettings{}, err
	}
	return s.Get(ctx)
}

// save replaces each row rather than upserting, which SQLite and MariaDB spell differently.
func (s *Store) save(ctx context.Context, values map[string]string) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()
	for name, value := range values {
		if _, err := tx.ExecContext(ctx, `DELETE FROM server_settings WHERE name = ?`, name); err != nil {
			return err
		}
		if _, err := tx.ExecContext(ctx, `INSERT INTO server_settings (name, value) VALUES (?, ?)`, name, value); err != nil {
			return err
		}
	}
	return tx.Commit()
}
