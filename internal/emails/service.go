package emails

import (
	"context"
	"strings"
	"sync"
	"time"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/logging"
	"polder-server/internal/mail"
	"polder-server/internal/users"
)

const (
	queueSize   = 256
	sendTimeout = time.Minute
	fullLevel   = 100
)

var logger = logging.For("emails")

type topic int

const (
	topicRequired topic = iota
	topicSecurity
	topicQuota
	topicShares
)

func (p Preferences) allows(kind topic) bool {
	switch kind {
	case topicSecurity:
		return p.Security
	case topicQuota:
		return p.Quota
	case topicShares:
		return p.Shares
	}
	return true
}

type Mailer interface {
	Configured(ctx context.Context) bool
	Send(ctx context.Context, message mail.Message) error
}

type PasswordChange struct {
	Address         string
	ByAdministrator bool
}

type SignIn struct {
	Address string
	Device  string
	At      time.Time
}

type job struct {
	name   string
	userID int64
	run    func(ctx context.Context) error
}

type Service struct {
	store  *Store
	users  *users.Store
	mailer Mailer
	brands BrandSource
	jobs   chan job
	now    func() time.Time

	quotaMu      sync.Mutex
	quotaPending map[int64]struct{}
	quotaWake    chan struct{}
}

func NewService(store *Store, userStore *users.Store, mailer Mailer, brands BrandSource) *Service {
	return &Service{
		store:        store,
		users:        userStore,
		mailer:       mailer,
		brands:       brands,
		jobs:         make(chan job, queueSize),
		now:          time.Now,
		quotaPending: map[int64]struct{}{},
		quotaWake:    make(chan struct{}, 1),
	}
}

func (s *Service) Store() *Store { return s.store }

func (s *Service) Run(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			return
		case next := <-s.jobs:
			s.runJob(ctx, next)
		case <-s.quotaWake:
			s.checkPendingQuotas(ctx)
		}
	}
}

func (s *Service) runJob(ctx context.Context, next job) {
	jobCtx, cancel := context.WithTimeout(ctx, sendTimeout)
	defer cancel()
	if err := next.run(jobCtx); err != nil && ctx.Err() == nil {
		logger.Warn("send an email", "email", next.name, "user", next.userID, "error", err)
	}
}

func (s *Service) enqueue(name string, userID int64, run func(ctx context.Context) error) {
	select {
	case s.jobs <- job{name: name, userID: userID, run: run}:
	default:
		logger.Warn("email queue is full; dropped an email", "email", name, "user", userID)
	}
}

func (s *Service) Configured(ctx context.Context) bool {
	return s.mailer.Configured(ctx)
}

func (s *Service) PasswordResetAvailable(ctx context.Context) bool {
	return s.Configured(ctx)
}

func (s *Service) deliver(ctx context.Context, user users.User, address string, kind topic, build func(Brand) Content) error {
	if strings.TrimSpace(address) == "" || !s.mailer.Configured(ctx) {
		return nil
	}
	if kind != topicRequired {
		preferences, err := s.store.Preferences(ctx, user.ID)
		if err != nil {
			return err
		}
		if !preferences.allows(kind) {
			return nil
		}
	}
	brand := s.brands.Current(ctx)
	message, err := Compose(brand, address, build(brand))
	if err != nil {
		return err
	}
	return s.mailer.Send(ctx, message)
}

func (s *Service) SendTest(ctx context.Context, to string) error {
	brand := s.brands.Current(ctx)
	message, err := Compose(brand, to, testContent(brand))
	if err != nil {
		return err
	}
	return s.mailer.Send(ctx, message)
}

type ResetIssuer func(ctx context.Context, login string) (users.User, string, error)

func (s *Service) PasswordResetRequested(login string, issue ResetIssuer) {
	s.enqueue("password reset", 0, func(ctx context.Context) error {
		if !s.PasswordResetAvailable(ctx) {
			return nil
		}
		user, code, err := issue(ctx, login)
		if apperr.Is(err, apperr.KindNotFound) {
			logger.Info("password reset asked for an unknown account or one without an email address", "login", login)
			return nil
		}
		if err != nil {
			return err
		}
		return s.deliver(ctx, user, user.Profile.Email, topicRequired, func(brand Brand) Content {
			return passwordResetContent(brand, user, code)
		})
	})
}

func (s *Service) PasswordChanged(user users.User, change PasswordChange) {
	when := s.now()
	s.enqueue("password changed", user.ID, func(ctx context.Context) error {
		return s.deliver(ctx, user, user.Profile.Email, topicRequired, func(brand Brand) Content {
			return passwordChangedContent(brand, user, change, when)
		})
	})
}

func (s *Service) EmailChanged(before users.User, newAddress string) {
	oldAddress := before.Profile.Email
	if oldAddress == "" || strings.EqualFold(oldAddress, newAddress) {
		return
	}
	s.enqueue("email changed", before.ID, func(ctx context.Context) error {
		return s.deliver(ctx, before, oldAddress, topicSecurity, func(brand Brand) Content {
			return emailChangedContent(brand, before, newAddress)
		})
	})
}

func (s *Service) SignedIn(user users.User, address, device string) {
	if address == "" {
		return
	}
	signIn := SignIn{Address: address, Device: device, At: s.now()}
	s.enqueue("new sign-in", user.ID, func(ctx context.Context) error {
		unfamiliar, err := s.store.RememberSignIn(ctx, user.ID, address, signIn.At)
		if err != nil || !unfamiliar {
			return err
		}
		return s.deliver(ctx, user, user.Profile.Email, topicSecurity, func(brand Brand) Content {
			return newSignInContent(brand, user, signIn)
		})
	})
}

func (s *Service) AccountCreated(user users.User) {
	if user.Profile.Email == "" {
		return
	}
	s.enqueue("account created", user.ID, func(ctx context.Context) error {
		resetAvailable := s.PasswordResetAvailable(ctx)
		return s.deliver(ctx, user, user.Profile.Email, topicRequired, func(brand Brand) Content {
			return accountCreatedContent(brand, user, resetAvailable)
		})
	})
}

func (s *Service) ShareReceived(userIDs []int64, notice activity.ShareNotice) {
	for _, userID := range userIDs {
		s.enqueue("share received", userID, func(ctx context.Context) error {
			user, err := s.users.ByID(ctx, userID)
			if err != nil {
				return err
			}
			return s.deliver(ctx, user, user.Profile.Email, topicShares, func(brand Brand) Content {
				return shareContent(brand, user, notice)
			})
		})
	}
}

func (s *Service) FileMutation(_ context.Context, mutation files.Mutation) {
	if mutation.Owner.ID == 0 || mutation.Owner.HasUnlimitedQuota() {
		return
	}
	s.QuotaChanged(mutation.Owner.ID)
}

func (s *Service) QuotaChanged(userID int64) {
	s.quotaMu.Lock()
	s.quotaPending[userID] = struct{}{}
	s.quotaMu.Unlock()
	select {
	case s.quotaWake <- struct{}{}:
	default:
	}
}

func (s *Service) checkPendingQuotas(ctx context.Context) {
	s.quotaMu.Lock()
	pending := s.quotaPending
	s.quotaPending = map[int64]struct{}{}
	s.quotaMu.Unlock()
	for userID := range pending {
		jobCtx, cancel := context.WithTimeout(ctx, sendTimeout)
		if err := s.checkQuota(jobCtx, userID); err != nil && ctx.Err() == nil {
			logger.Warn("check storage use", "user", userID, "error", err)
		}
		cancel()
	}
}

func (s *Service) checkQuota(ctx context.Context, userID int64) error {
	user, err := s.users.ByID(ctx, userID)
	if err != nil {
		return err
	}
	level := QuotaLevel(user)
	stored, err := s.store.QuotaWarningLevel(ctx, userID)
	if err != nil || level == stored {
		return err
	}
	if err := s.store.SetQuotaWarningLevel(ctx, userID, level); err != nil {
		return err
	}
	if level < stored {
		return nil
	}
	return s.deliver(ctx, user, user.Profile.Email, topicQuota, func(brand Brand) Content {
		return quotaContent(brand, user, level)
	})
}

func QuotaLevel(user users.User) int {
	if user.HasUnlimitedQuota() {
		return 0
	}
	percentage := float64(user.UsedBytes) * 100 / float64(user.QuotaBytes)
	switch {
	case percentage >= 99:
		return fullLevel
	case percentage >= 95:
		return 95
	case percentage >= 80:
		return 80
	}
	return 0
}
