package twofactor

import (
	"context"
	"errors"
	"time"

	"polder-server/internal/emails"
	"polder-server/internal/logging"
	"polder-server/internal/settings"
	"polder-server/internal/users"
)

const (
	ReminderWindow      = 3 * 24 * time.Hour
	ShortReminderWindow = 24 * time.Hour
	ReminderInterval    = time.Hour
)

var logger = logging.For("two-factor")

type Notifier interface {
	TwoFactorRequired(user users.User, deadline time.Time)
	TwoFactorReminder(user users.User, deadline time.Time, now time.Time)
}

type Policy struct {
	users    *users.Store
	settings *settings.Store
	notify   Notifier
}

func NewPolicy(userStore *users.Store, serverSettings *settings.Store, notify Notifier) *Policy {
	return &Policy{users: userStore, settings: serverSettings, notify: notify}
}

var _ Notifier = (*emails.Service)(nil)

func (p *Policy) Required(ctx context.Context) (bool, int, error) {
	current, err := p.settings.Get(ctx)
	return current.RequireTwoFactor, current.TwoFactorGraceDays, err
}

func (p *Policy) Applies(ctx context.Context, user users.User) (bool, error) {
	required, _, err := p.Required(ctx)
	return required && user.HasPassword, err
}

func (p *Policy) SettingsChanged(ctx context.Context, before, after settings.ServerSettings, now time.Time) error {
	switch {
	case after.RequireTwoFactor && !before.RequireTwoFactor:
		return p.requireFromEveryone(ctx, deadlineFrom(now, after.TwoFactorGraceDays))
	case !after.RequireTwoFactor && before.RequireTwoFactor:
		return p.users.ClearTwoFactorDeadlines(ctx)
	}
	return nil
}

func (p *Policy) requireFromEveryone(ctx context.Context, deadline time.Time) error {
	ids, err := p.users.AssignTwoFactorDeadlines(ctx, deadline)
	if err != nil {
		return err
	}
	logger.Info("two-factor authentication required", "users", len(ids), "deadline", deadline)
	var failures []error
	for _, id := range ids {
		failures = append(failures, p.announce(ctx, id, deadline))
	}
	return errors.Join(failures...)
}

func (p *Policy) UserCreated(ctx context.Context, user users.User, now time.Time) error {
	_, err := p.assign(ctx, user.ID, now)
	return err
}

func (p *Policy) TwoFactorRemoved(ctx context.Context, userID int64, now time.Time) error {
	_, err := p.assign(ctx, userID, now)
	return err
}

func (p *Policy) Extend(ctx context.Context, userID int64, now time.Time) (bool, error) {
	return p.assign(ctx, userID, now)
}

func (p *Policy) assign(ctx context.Context, userID int64, now time.Time) (bool, error) {
	required, graceDays, err := p.Required(ctx)
	if err != nil || !required {
		return false, err
	}
	deadline := deadlineFrom(now, graceDays)
	assigned, err := p.users.AssignTwoFactorDeadline(ctx, userID, deadline)
	if err != nil || !assigned {
		return false, err
	}
	return true, p.announce(ctx, userID, deadline)
}

func (p *Policy) announce(ctx context.Context, userID int64, deadline time.Time) error {
	user, err := p.users.ByID(ctx, userID)
	if err != nil {
		return err
	}
	if err := p.users.SetTwoFactorReminderLevel(ctx, userID, users.ReminderRequired); err != nil {
		return err
	}
	p.notify.TwoFactorRequired(user, deadline)
	return nil
}

func (p *Policy) SendReminders(ctx context.Context, now time.Time) error {
	required, graceDays, err := p.Required(ctx)
	if err != nil || !required {
		return err
	}
	pending, err := p.users.PendingTwoFactorReminders(ctx, users.ReminderFinal)
	if err != nil {
		return err
	}
	window := ReminderWindow
	if time.Duration(graceDays)*24*time.Hour <= ReminderWindow {
		window = ShortReminderWindow
	}
	var failures []error
	for _, reminder := range pending {
		failures = append(failures, p.remind(ctx, reminder, window, now))
	}
	return errors.Join(failures...)
}

func (p *Policy) remind(ctx context.Context, reminder users.TwoFactorReminder, window time.Duration, now time.Time) error {
	if reminder.Level < users.ReminderRequired {
		return p.announce(ctx, reminder.User.ID, reminder.Deadline)
	}
	left := reminder.Deadline.Sub(now)
	if left <= 0 || left > window {
		return nil
	}
	if err := p.users.SetTwoFactorReminderLevel(ctx, reminder.User.ID, users.ReminderFinal); err != nil {
		return err
	}
	p.notify.TwoFactorReminder(reminder.User, reminder.Deadline, now)
	return nil
}

func deadlineFrom(now time.Time, graceDays int) time.Time {
	return now.Add(time.Duration(graceDays) * 24 * time.Hour).Truncate(time.Second)
}
