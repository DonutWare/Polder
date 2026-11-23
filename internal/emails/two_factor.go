package emails

import (
	"context"
	"time"

	"polder-server/internal/users"
)

func (s *Service) TwoFactorRequired(user users.User, deadline time.Time) {
	s.enqueue("two-factor required", user.ID, func(ctx context.Context) error {
		return s.deliver(ctx, user, user.Profile.Email, topicRequired, func(brand Brand) Content {
			return twoFactorRequiredContent(brand, user, deadline)
		})
	})
}

func (s *Service) TwoFactorReminder(user users.User, deadline time.Time, now time.Time) {
	s.enqueue("two-factor reminder", user.ID, func(ctx context.Context) error {
		return s.deliver(ctx, user, user.Profile.Email, topicRequired, func(brand Brand) Content {
			return twoFactorReminderContent(brand, user, deadline, now)
		})
	})
}

func (s *Service) TwoFactorEnabled(user users.User) {
	when := s.now()
	s.enqueue("two-factor enabled", user.ID, func(ctx context.Context) error {
		return s.deliver(ctx, user, user.Profile.Email, topicSecurity, func(brand Brand) Content {
			return twoFactorEnabledContent(brand, user, when)
		})
	})
}

func (s *Service) TwoFactorDisabled(user users.User, byAdministrator bool) {
	when := s.now()
	s.enqueue("two-factor disabled", user.ID, func(ctx context.Context) error {
		return s.deliver(ctx, user, user.Profile.Email, topicRequired, func(brand Brand) Content {
			return twoFactorDisabledContent(brand, user, byAdministrator, when)
		})
	})
}

func (s *Service) RecoveryCodeUsed(user users.User, remaining int, address, device string) {
	signIn := SignIn{Address: address, Device: device, At: s.now()}
	s.enqueue("recovery code used", user.ID, func(ctx context.Context) error {
		return s.deliver(ctx, user, user.Profile.Email, topicRequired, func(brand Brand) Content {
			return recoveryCodeUsedContent(brand, user, remaining, signIn)
		})
	})
}
