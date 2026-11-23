package users

import (
	"context"
	"time"
)

type TwoFactorReminder struct {
	User     User
	Deadline time.Time
	Level    int
}

const (
	ReminderRequired = 1
	ReminderFinal    = 2
)

const needsTwoFactor = `password_hash <> '` + NoPasswordHash + `' AND id NOT IN (SELECT user_id FROM user_totp WHERE confirmed_at IS NOT NULL)`

func (s *Store) AssignTwoFactorDeadlines(ctx context.Context, deadline time.Time) ([]int64, error) {
	rows, err := s.db.QueryContext(ctx, `UPDATE users SET two_factor_deadline = $1, two_factor_reminder_level = 0
		WHERE two_factor_deadline IS NULL AND `+needsTwoFactor+` RETURNING id`, deadline.Unix())
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var ids []int64
	for rows.Next() {
		var id int64
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, rows.Err()
}

func (s *Store) ClearTwoFactorDeadlines(ctx context.Context) error {
	_, err := s.db.ExecContext(ctx, `UPDATE users SET two_factor_deadline = NULL, two_factor_reminder_level = 0`)
	return err
}

func (s *Store) SetTwoFactorDeadline(ctx context.Context, id int64, deadline *time.Time) error {
	var value any
	if deadline != nil {
		value = deadline.Unix()
	}
	_, err := s.db.ExecContext(ctx, `UPDATE users SET two_factor_deadline = $1, two_factor_reminder_level = 0 WHERE id = $2`, value, id)
	return err
}

func (s *Store) AssignTwoFactorDeadline(ctx context.Context, id int64, deadline time.Time) (bool, error) {
	result, err := s.db.ExecContext(ctx, `UPDATE users SET two_factor_deadline = $1, two_factor_reminder_level = 0
		WHERE id = $2 AND `+needsTwoFactor, deadline.Unix(), id)
	if err != nil {
		return false, err
	}
	updated, err := result.RowsAffected()
	return updated > 0, err
}

func (s *Store) SetTwoFactorReminderLevel(ctx context.Context, id int64, level int) error {
	_, err := s.db.ExecContext(ctx, `UPDATE users SET two_factor_reminder_level = $1 WHERE id = $2`, level, id)
	return err
}

func (s *Store) PendingTwoFactorReminders(ctx context.Context, belowLevel int) ([]TwoFactorReminder, error) {
	levels, err := s.reminderLevels(ctx, belowLevel)
	if err != nil {
		return nil, err
	}
	reminders := make([]TwoFactorReminder, 0, len(levels))
	for _, pending := range levels {
		user, err := s.ByID(ctx, pending.id)
		if err != nil {
			return nil, err
		}
		if user.TwoFactor.Deadline != nil {
			reminders = append(reminders, TwoFactorReminder{User: user, Deadline: *user.TwoFactor.Deadline, Level: pending.level})
		}
	}
	return reminders, nil
}

type reminderLevel struct {
	id    int64
	level int
}

func (s *Store) reminderLevels(ctx context.Context, belowLevel int) ([]reminderLevel, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT id, two_factor_reminder_level FROM users WHERE two_factor_deadline IS NOT NULL
		AND two_factor_reminder_level < $1 AND id NOT IN (SELECT user_id FROM user_totp WHERE confirmed_at IS NOT NULL) ORDER BY id`, belowLevel)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var found []reminderLevel
	for rows.Next() {
		var next reminderLevel
		if err := rows.Scan(&next.id, &next.level); err != nil {
			return nil, err
		}
		found = append(found, next)
	}
	return found, rows.Err()
}
