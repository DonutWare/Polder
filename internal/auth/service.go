package auth

import (
	"context"
	"errors"
	"strings"
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
	Method    Method
	ExpiresAt time.Time
}

type SessionEvent string

const (
	SessionStarted SessionEvent = "started"
	SessionEnded   SessionEvent = "ended"
)

type SessionFunc func(ctx context.Context, user users.User, session Session, event SessionEvent)

type Service struct {
	users        *users.Service
	sessions     *Sessions
	appPasswords *AppPasswords
	tokens       *AccessTokens
	resets       *PasswordResets
	twoFactor    *TwoFactor
	challenges   *Challenges
	deviceLogins *DeviceLogins
	hasher       Argon2Hasher
	setupMu      sync.Mutex
	onSession    SessionFunc
}

func NewService(userService *users.Service, sessions *Sessions, appPasswords *AppPasswords, tokens *AccessTokens) *Service {
	return &Service{users: userService, sessions: sessions, appPasswords: appPasswords, tokens: tokens,
		onSession: func(context.Context, users.User, Session, SessionEvent) {}}
}

func (s *Service) AppPasswords() *AppPasswords {
	return s.appPasswords
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
	return s.startSession(ctx, admin, deviceName, MethodPassword, time.Now())
}

func (s *Service) Login(ctx context.Context, username, password, deviceName string) (TokenPair, error) {
	user, err := s.checkPassword(ctx, username, password)
	if err != nil {
		return TokenPair{}, err
	}
	if err := s.requireSecondFactor(ctx, user, deviceName); err != nil {
		return TokenPair{}, err
	}
	return s.startSession(ctx, user, deviceName, MethodPassword, time.Now())
}

func (s *Service) checkPassword(ctx context.Context, username, password string) (users.User, error) {
	user, passwordHash, err := s.users.Store().CredentialsByUsername(ctx, username)
	if apperr.Is(err, apperr.KindNotFound) {
		s.hasher.Verify(password, dummyHash)
		return users.User{}, apperr.Unauthorized("invalid username or password")
	}
	if err != nil {
		return users.User{}, err
	}
	if !s.hasher.Verify(password, passwordHash) {
		return users.User{}, apperr.Unauthorized("invalid username or password")
	}
	if user.Disabled {
		return users.User{}, apperr.Forbidden("this account is disabled")
	}
	return user, nil
}

func (s *Service) ChangePassword(ctx context.Context, user users.User, sessionID int64, currentPassword, newPassword string) error {
	if err := s.ConfirmPassword(ctx, user, sessionID, currentPassword); err != nil {
		return err
	}
	if _, err := s.users.Update(ctx, user, user.ID, users.Changes{Password: &newPassword}); err != nil {
		return err
	}
	if err := s.appPasswords.RevokeAllForUser(ctx, user.ID); err != nil {
		return err
	}
	return s.sessions.RevokeOthersForUser(ctx, user.ID, sessionID)
}

func (s *Service) ConfirmPassword(ctx context.Context, user users.User, sessionID int64, password string) error {
	passwordHash, err := s.users.Store().PasswordHash(ctx, user.ID)
	if err != nil {
		return err
	}
	if passwordHash == users.NoPasswordHash {
		return s.requireRecentSignIn(ctx, user.ID, sessionID)
	}
	if !s.hasher.Verify(password, passwordHash) {
		return apperr.Forbidden("current password is incorrect")
	}
	return nil
}

func (s *Service) requireRecentSignIn(ctx context.Context, userID, sessionID int64) error {
	authenticatedAt, err := s.sessions.AuthenticatedAt(ctx, userID, sessionID)
	if err != nil {
		return err
	}
	if time.Since(authenticatedAt) > RecentSignInWindow {
		return apperr.New(apperr.KindReauthenticationRequired, "sign in again to confirm it's you, then try once more")
	}
	return nil
}

func (s *Service) LogOutEverywhere(ctx context.Context, userID int64) error {
	return errors.Join(s.sessions.RevokeAllForUser(ctx, userID), s.appPasswords.RevokeAllForUser(ctx, userID))
}

func (s *Service) CreateAppPassword(ctx context.Context, user users.User, sessionID int64, accountPassword, name string, readOnly bool) (NewAppPassword, error) {
	if err := s.ConfirmPassword(ctx, user, sessionID, accountPassword); err != nil {
		return NewAppPassword{}, err
	}
	return s.appPasswords.Create(ctx, user.ID, name, readOnly)
}

func (s *Service) AuthenticateAppPassword(ctx context.Context, username, token, address string) (users.User, AppPassword, error) {
	invalid := apperr.Unauthorized("invalid username or password")
	identity, err := s.appPasswords.Verify(ctx, token, address)
	if err != nil {
		return users.User{}, AppPassword{}, err
	}
	user, err := s.ActiveUser(ctx, identity.UserID)
	if err != nil {
		return users.User{}, AppPassword{}, err
	}
	if !knownAs(user, username) {
		return users.User{}, AppPassword{}, invalid
	}
	if user.TwoFactor.SetupRequired {
		return users.User{}, AppPassword{}, apperr.Forbidden("set up two-factor authentication in the app before using app passwords again")
	}
	return user, identity.Password, nil
}

func knownAs(user users.User, login string) bool {
	email := user.Profile.Email
	return user.Username == login || (email != "" && strings.EqualFold(email, strings.TrimSpace(login)))
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

func (s *Service) StartSession(ctx context.Context, user users.User, deviceName string, method Method, authenticatedAt time.Time) (TokenPair, error) {
	return s.startSession(ctx, user, deviceName, method, authenticatedAt)
}

func (s *Service) StartSessionLike(ctx context.Context, identity Identity, deviceName string) (TokenPair, error) {
	authenticatedAt, err := s.sessions.AuthenticatedAt(ctx, identity.User.ID, identity.SessionID)
	if err != nil {
		return TokenPair{}, err
	}
	return s.startSession(ctx, identity.User, deviceName, identity.Method, authenticatedAt)
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
		device = UnknownDevice
	}
	return Identity{User: forSession(user, claims.Method), SessionID: claims.SessionID, Device: device, Method: claims.Method,
		ExpiresAt: claims.ExpiresAt}, nil
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

func forSession(user users.User, method Method) users.User {
	if method == MethodSSO {
		user.TwoFactor.SetupRequired = false
	}
	return user
}

func (s *Service) startSession(ctx context.Context, user users.User, deviceName string, method Method, authenticatedAt time.Time) (TokenPair, error) {
	if deviceName == "" {
		deviceName = UnknownDevice
	}
	session, refreshToken, err := s.sessions.Create(ctx, user.ID, deviceName, method, authenticatedAt)
	if err != nil {
		return TokenPair{}, err
	}
	pair, err := s.tokenPair(user, session, refreshToken)
	if err == nil {
		s.onSession(ctx, user, session, SessionStarted)
	}
	return pair, err
}

const (
	UnknownDevice      = "unknown device"
	RecentSignInWindow = 10 * time.Minute
)

func (s *Service) tokenPair(user users.User, session Session, refreshToken string) (TokenPair, error) {
	accessToken, err := s.tokens.Issue(user.ID, session.ID, session.DeviceName, session.Method)
	if err != nil {
		return TokenPair{}, err
	}
	return TokenPair{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    int(AccessTokenLifetime.Seconds()),
		User:         forSession(user, session.Method),
	}, nil
}
