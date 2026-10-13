package auth

import (
	"context"
	"sync"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

type TokenPair struct {
	AccessToken  string     `json:"accessToken"`
	RefreshToken string     `json:"refreshToken"`
	ExpiresIn    int        `json:"expiresIn"`
	User         users.User `json:"user"`
}

type Identity struct {
	User      users.User
	SessionID int64
	Device    string
	ExpiresAt time.Time
}

type SessionEvent string

const (
	SessionStarted SessionEvent = "started"
	SessionEnded   SessionEvent = "ended"
)

type SessionFunc func(ctx context.Context, user users.User, session Session, event SessionEvent)

type Service struct {
	users     *users.Service
	sessions  *Sessions
	tokens    *AccessTokens
	hasher    Argon2Hasher
	setupMu   sync.Mutex
	onSession SessionFunc
}

func NewService(userService *users.Service, sessions *Sessions, tokens *AccessTokens) *Service {
	return &Service{users: userService, sessions: sessions, tokens: tokens, onSession: func(context.Context, users.User, Session, SessionEvent) {}}
}

func (s *Service) OnSession(callback SessionFunc) {
	s.onSession = callback
}

func (s *Service) NeedsSetup(ctx context.Context) (bool, error) {
	count, err := s.users.Store().Count(ctx)
	return count == 0, err
}

func (s *Service) Setup(ctx context.Context, username, password, deviceName string) (TokenPair, error) {
	s.setupMu.Lock()
	defer s.setupMu.Unlock()

	needsSetup, err := s.NeedsSetup(ctx)
	if err != nil {
		return TokenPair{}, err
	}
	if !needsSetup {
		return TokenPair{}, apperr.Forbidden("setup has already been completed")
	}
	admin, err := s.users.Create(ctx, users.NewUser{Username: username, Password: password, Role: users.RoleAdmin})
	if err != nil {
		return TokenPair{}, err
	}
	return s.startSession(ctx, admin, deviceName)
}

func (s *Service) Login(ctx context.Context, username, password, deviceName string) (TokenPair, error) {
	user, passwordHash, err := s.users.Store().CredentialsByUsername(ctx, username)
	if apperr.Is(err, apperr.KindNotFound) {
		s.hasher.Verify(password, dummyHash)
		return TokenPair{}, apperr.Unauthorized("invalid username or password")
	}
	if err != nil {
		return TokenPair{}, err
	}
	if !s.hasher.Verify(password, passwordHash) {
		return TokenPair{}, apperr.Unauthorized("invalid username or password")
	}
	if user.Disabled {
		return TokenPair{}, apperr.Forbidden("this account is disabled")
	}
	return s.startSession(ctx, user, deviceName)
}

func (s *Service) ChangePassword(ctx context.Context, user users.User, sessionID int64, currentPassword, newPassword string) error {
	passwordHash, err := s.users.Store().PasswordHash(ctx, user.ID)
	if err != nil {
		return err
	}
	if !s.hasher.Verify(currentPassword, passwordHash) {
		return apperr.Forbidden("current password is incorrect")
	}
	if _, err := s.users.Update(ctx, user, user.ID, users.Changes{Password: &newPassword}); err != nil {
		return err
	}
	return s.sessions.RevokeOthersForUser(ctx, user.ID, sessionID)
}

var dummyHash, _ = Argon2Hasher{}.Hash("timing-equalizer")

func (s *Service) Refresh(ctx context.Context, refreshToken, deviceName string) (TokenPair, error) {
	session, rotatedToken, err := s.sessions.Rotate(ctx, refreshToken, deviceName)
	if err != nil {
		return TokenPair{}, err
	}
	user, err := s.ActiveUser(ctx, session.UserID)
	if err != nil {
		return TokenPair{}, err
	}
	return s.tokenPair(user, session, rotatedToken)
}

func (s *Service) Logout(ctx context.Context, refreshToken string) error {
	session, revoked, err := s.sessions.Revoke(ctx, refreshToken)
	if err != nil || !revoked {
		return err
	}
	if user, err := s.users.Store().ByID(ctx, session.UserID); err == nil {
		s.onSession(ctx, user, session, SessionEnded)
	}
	return nil
}

func (s *Service) Authenticate(ctx context.Context, accessToken string) (Identity, error) {
	claims, err := s.tokens.Parse(accessToken)
	if err != nil {
		return Identity{}, apperr.Unauthorized("access token is invalid or expired")
	}
	user, err := s.ActiveUser(ctx, claims.UserID)
	if err != nil {
		return Identity{}, err
	}
	device := claims.Device
	if device == "" {
		device = unknownDevice
	}
	return Identity{User: user, SessionID: claims.SessionID, Device: device, ExpiresAt: claims.ExpiresAt}, nil
}

func (s *Service) ActiveUser(ctx context.Context, userID int64) (users.User, error) {
	user, err := s.users.Store().ByID(ctx, userID)
	if apperr.Is(err, apperr.KindNotFound) {
		return users.User{}, apperr.Unauthorized("account no longer exists")
	}
	if err != nil {
		return users.User{}, err
	}
	if user.Disabled {
		return users.User{}, apperr.Forbidden("this account is disabled")
	}
	return user, nil
}

func (s *Service) startSession(ctx context.Context, user users.User, deviceName string) (TokenPair, error) {
	if deviceName == "" {
		deviceName = unknownDevice
	}
	session, refreshToken, err := s.sessions.Create(ctx, user.ID, deviceName)
	if err != nil {
		return TokenPair{}, err
	}
	pair, err := s.tokenPair(user, session, refreshToken)
	if err == nil {
		s.onSession(ctx, user, session, SessionStarted)
	}
	return pair, err
}

const unknownDevice = "unknown device"

func (s *Service) tokenPair(user users.User, session Session, refreshToken string) (TokenPair, error) {
	accessToken, err := s.tokens.Issue(user.ID, session.ID, session.DeviceName)
	if err != nil {
		return TokenPair{}, err
	}
	return TokenPair{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    int(AccessTokenLifetime.Seconds()),
		User:         user,
	}, nil
}
