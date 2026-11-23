package sso

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"database/sql"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"net"
	"net/url"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/auth"
	"polder-server/internal/users"
)

const (
	StateLifetime = 10 * time.Minute
	CodeLifetime  = time.Minute
	PruneInterval = time.Hour

	FailureSignupDisabled  = "signup_disabled"
	FailureAccountDisabled = "account_disabled"
	FailureAlreadyLinked   = "already_linked"
	FailureProvider        = "provider_error"
	FailureCancelled       = "cancelled"
	FailureLinkRequired    = "link_required"

	appCallbackHost = "auth"
	webCallbackPath = "/auth.html"
)

var appSchemes = map[string]bool{"polder": true, "polder-dev": true}

type AuthorizeRequest struct {
	RedirectURI   string
	CodeChallenge string
	DeviceName    string
	LinkUserID    int64
}

type CallbackResult struct {
	Redirect string
	Failure  string
}

func (s *Service) Authorize(ctx context.Context, providerID string, request AuthorizeRequest) (string, error) {
	provider, err := s.Provider(ctx, providerID)
	if err != nil {
		return "", err
	}
	if !provider.Enabled {
		return "", apperr.NotFound("sign-in provider %q is turned off", providerID)
	}
	if !s.allowedAppRedirect(request.RedirectURI) {
		return "", apperr.Invalid("%q is not a redirect URI the apps use", request.RedirectURI)
	}
	if !validChallenge(request.CodeChallenge) {
		return "", apperr.Invalid("code_challenge must be an S256 PKCE challenge")
	}
	connector, err := s.connectorFor(ctx, provider)
	if err != nil {
		return "", err
	}
	state, nonce, verifier := randomToken(), randomToken(), randomToken()
	var linkUser any
	if request.LinkUserID != 0 {
		linkUser = request.LinkUserID
	}
	_, err = s.db.ExecContext(ctx, `INSERT INTO sso_logins (state_hash, provider_id, nonce, idp_verifier, app_redirect, app_challenge,
		device_name, link_user_id, expires_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
		hashValue(state), provider.ID, nonce, verifier, request.RedirectURI, request.CodeChallenge, request.DeviceName, linkUser,
		s.now().Add(StateLifetime).Unix())
	if err != nil {
		return "", err
	}
	return connector.authCodeURL(state, nonce, verifier), nil
}

type pendingLogin struct {
	stateHash   string
	providerID  string
	nonce       string
	verifier    string
	appRedirect string
	linkUserID  sql.NullInt64
}

const invalidCodeMessage = "this sign-in code is wrong, expired or already used"

func (s *Service) Callback(ctx context.Context, providerID, code, state, providerError string) (CallbackResult, error) {
	pending, err := s.pending(ctx, providerID, state)
	if err != nil {
		return CallbackResult{}, err
	}
	if providerError != "" {
		failure := FailureProvider
		if providerError == "access_denied" {
			failure = FailureCancelled
		}
		return s.fail(ctx, pending, failure, errors.New(providerError))
	}
	provider, err := s.Provider(ctx, providerID)
	if err != nil {
		return CallbackResult{}, err
	}
	connector, err := s.connectorFor(ctx, provider)
	if err != nil {
		return s.fail(ctx, pending, FailureProvider, err)
	}
	identity, err := connector.exchange(ctx, code, pending.nonce, pending.verifier)
	if err != nil {
		return s.fail(ctx, pending, FailureProvider, err)
	}
	if pending.linkUserID.Valid {
		return s.offerLink(ctx, pending, provider, identity)
	}
	user, failure, err := s.resolveUser(ctx, provider, identity)
	if err != nil {
		return CallbackResult{}, err
	}
	if failure != "" {
		return s.fail(ctx, pending, failure, nil)
	}
	appCode := randomToken()
	_, err = s.db.ExecContext(ctx, `UPDATE sso_logins SET code_hash = $1, user_id = $2, expires_at = $3 WHERE state_hash = $4`,
		hashValue(appCode), user.ID, s.now().Add(CodeLifetime).Unix(), pending.stateHash)
	if err != nil {
		return CallbackResult{}, err
	}
	return CallbackResult{Redirect: withQuery(pending.appRedirect, "code", appCode)}, nil
}

func (s *Service) pending(ctx context.Context, providerID, state string) (pendingLogin, error) {
	pending := pendingLogin{stateHash: hashValue(state)}
	err := s.db.QueryRowContext(ctx, `SELECT provider_id, nonce, idp_verifier, app_redirect, link_user_id FROM sso_logins
		WHERE state_hash = $1 AND code_hash IS NULL AND expires_at > $2`, pending.stateHash, s.now().Unix()).
		Scan(&pending.providerID, &pending.nonce, &pending.verifier, &pending.appRedirect, &pending.linkUserID)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && pending.providerID != providerID) {
		return pendingLogin{}, apperr.Invalid("this sign-in has expired or was already used; start again in the app")
	}
	return pending, err
}

func (s *Service) fail(ctx context.Context, pending pendingLogin, failure string, cause error) (CallbackResult, error) {
	if cause != nil {
		logger.Warn("single sign-on failed", "provider", pending.providerID, "reason", failure, "error", cause)
	}
	if _, err := s.db.ExecContext(ctx, `DELETE FROM sso_logins WHERE state_hash = $1`, pending.stateHash); err != nil {
		return CallbackResult{}, err
	}
	return CallbackResult{Redirect: withQuery(pending.appRedirect, "error", failure), Failure: failure}, nil
}

func (s *Service) offerLink(ctx context.Context, pending pendingLogin, provider AuthProvider, identity Identity) (CallbackResult, error) {
	owner, err := s.identityOwner(ctx, provider.ID, identity.Subject)
	if err == nil && owner != pending.linkUserID.Int64 {
		return s.fail(ctx, pending, FailureAlreadyLinked, nil)
	}
	if err != nil && !errors.Is(err, sql.ErrNoRows) {
		return CallbackResult{}, err
	}
	appCode := randomToken()
	_, err = s.db.ExecContext(ctx, `UPDATE sso_logins SET code_hash = $1, link_subject = $2, link_email = $3, expires_at = $4 WHERE state_hash = $5`,
		hashValue(appCode), identity.Subject, identity.Email, s.now().Add(CodeLifetime).Unix(), pending.stateHash)
	if err != nil {
		return CallbackResult{}, err
	}
	return CallbackResult{Redirect: withQuery(pending.appRedirect, "code", appCode)}, nil
}

func (s *Service) ConfirmLink(ctx context.Context, userID int64, code, verifier string) (string, error) {
	invalid := apperr.Invalid(invalidCodeMessage)
	var providerID, challenge string
	var identity Identity
	err := s.db.QueryRowContext(ctx, `DELETE FROM sso_logins WHERE code_hash = $1 AND expires_at > $2 AND link_user_id = $3
		RETURNING provider_id, app_challenge, link_subject, link_email`, hashValue(code), s.now().Unix(), userID).
		Scan(&providerID, &challenge, &identity.Subject, &identity.Email)
	if errors.Is(err, sql.ErrNoRows) {
		return "", invalid
	}
	if err != nil {
		return "", err
	}
	if subtle.ConstantTimeCompare([]byte(pkceChallenge(verifier)), []byte(challenge)) != 1 {
		return "", invalid
	}
	owner, err := s.identityOwner(ctx, providerID, identity.Subject)
	switch {
	case err == nil && owner != userID:
		return "", apperr.AlreadyExists("this account at the provider is already linked to someone else")
	case err == nil:
		return providerID, nil
	case !errors.Is(err, sql.ErrNoRows):
		return "", err
	}
	if err := s.link(ctx, providerID, identity, userID); err != nil {
		return "", err
	}
	logger.Info("account linked", "provider", providerID, "user", userID)
	return providerID, nil
}

func (s *Service) resolveUser(ctx context.Context, provider AuthProvider, identity Identity) (users.User, string, error) {
	owner, err := s.identityOwner(ctx, provider.ID, identity.Subject)
	switch {
	case err == nil:
		return s.activeOrFailure(ctx, owner)
	case !errors.Is(err, sql.ErrNoRows):
		return users.User{}, "", err
	}
	if provider.LinkByEmail && identity.EmailVerified && identity.Email != "" {
		existing, matches, err := s.usersWithEmail(ctx, identity.Email)
		if err != nil {
			return users.User{}, "", err
		}
		if matches > 1 || (matches == 1 && !linkableByEmail(existing)) {
			logger.Info("single sign-on refused: the account must be linked from its settings", "provider", provider.ID, "email", identity.Email)
			return users.User{}, FailureLinkRequired, nil
		}
		if matches == 1 {
			if err := s.link(ctx, provider.ID, identity, existing.ID); err != nil && !apperr.Is(err, apperr.KindAlreadyExists) {
				return users.User{}, "", err
			}
			logger.Info("account linked by email address", "provider", provider.ID, "user", existing.Username)
			return s.activeOrFailure(ctx, existing.ID)
		}
	}
	if !provider.AllowSignup {
		logger.Info("single sign-on refused: no account and sign-up is off", "provider", provider.ID, "email", identity.Email)
		return users.User{}, FailureSignupDisabled, nil
	}
	created, err := s.signUp(ctx, provider, identity)
	return created, "", err
}

func (s *Service) usersWithEmail(ctx context.Context, email string) (users.User, int, error) {
	var matches int
	err := s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM users WHERE LOWER(email) = LOWER($1) AND email <> ''`, email).Scan(&matches)
	if err != nil || matches != 1 {
		return users.User{}, matches, err
	}
	user, err := s.users.Store().ByEmail(ctx, email)
	return user, matches, err
}

func linkableByEmail(user users.User) bool {
	return !user.IsAdmin() && !user.TwoFactor.Enabled
}

func (s *Service) activeOrFailure(ctx context.Context, userID int64) (users.User, string, error) {
	user, err := s.auth.ActiveUser(ctx, userID)
	if apperr.Is(err, apperr.KindForbidden) {
		return users.User{}, FailureAccountDisabled, nil
	}
	return user, "", err
}

func (s *Service) signUp(ctx context.Context, provider AuthProvider, identity Identity) (users.User, error) {
	username, err := s.freeUsername(ctx, identity)
	if err != nil {
		return users.User{}, err
	}
	email := ""
	if identity.EmailVerified {
		email = identity.Email
	}
	created, err := s.users.CreateWithoutPassword(ctx, users.NewUser{Username: username, Role: users.RoleUser, Email: email})
	if err != nil {
		return users.User{}, err
	}
	if identity.Name != "" {
		profile := created.Profile
		profile.DisplayName = identity.Name
		if updated, err := s.users.SetProfile(ctx, created.ID, profile); err == nil {
			created = updated
		}
	}
	if err := s.link(ctx, provider.ID, identity, created.ID); err != nil {
		return users.User{}, err
	}
	logger.Info("account created through single sign-on", "provider", provider.ID, "user", created.Username)
	return s.users.Store().ByID(ctx, created.ID)
}

func (s *Service) Exchange(ctx context.Context, code, verifier, deviceName string) (auth.TokenPair, error) {
	invalid := apperr.Unauthorized(invalidCodeMessage)
	var challenge, savedDevice string
	var userID int64
	err := s.db.QueryRowContext(ctx, `DELETE FROM sso_logins WHERE code_hash = $1 AND expires_at > $2 AND link_user_id IS NULL
		RETURNING app_challenge, device_name, user_id`, hashValue(code), s.now().Unix()).Scan(&challenge, &savedDevice, &userID)
	if errors.Is(err, sql.ErrNoRows) {
		return auth.TokenPair{}, invalid
	}
	if err != nil {
		return auth.TokenPair{}, err
	}
	if subtle.ConstantTimeCompare([]byte(pkceChallenge(verifier)), []byte(challenge)) != 1 {
		return auth.TokenPair{}, invalid
	}
	user, err := s.auth.ActiveUser(ctx, userID)
	if err != nil {
		return auth.TokenPair{}, err
	}
	if deviceName == "" {
		deviceName = savedDevice
	}
	return s.auth.StartSession(ctx, user, deviceName, auth.MethodSSO, s.now())
}

func (s *Service) TestProvider(ctx context.Context, providerID string) error {
	provider, err := s.Provider(ctx, providerID)
	if err != nil {
		return err
	}
	s.forget(providerID)
	_, err = s.connectorFor(ctx, provider)
	return err
}

func (s *Service) Prune(ctx context.Context) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM sso_logins WHERE expires_at <= $1`, s.now().Unix())
	return err
}

func (s *Service) allowedAppRedirect(raw string) bool {
	target, err := url.Parse(raw)
	if err != nil || target.Fragment != "" || target.User != nil {
		return false
	}
	if appSchemes[target.Scheme] {
		return target.Host == appCallbackHost
	}
	if target.Scheme == "http" && isLoopback(target.Hostname()) && target.Port() != "" {
		return true
	}
	public, err := url.Parse(s.publicURL)
	return err == nil && s.publicURL != "" && target.Scheme == public.Scheme && target.Host == public.Host &&
		target.Path == webCallbackPath
}

func isLoopback(host string) bool {
	if host == "localhost" {
		return true
	}
	ip := net.ParseIP(host)
	return ip != nil && ip.IsLoopback()
}

func validChallenge(challenge string) bool {
	decoded, err := base64.RawURLEncoding.DecodeString(challenge)
	return err == nil && len(decoded) == sha256.Size
}

func pkceChallenge(verifier string) string {
	sum := sha256.Sum256([]byte(verifier))
	return base64.RawURLEncoding.EncodeToString(sum[:])
}

func withQuery(raw, key, value string) string {
	target, err := url.Parse(raw)
	if err != nil {
		return raw
	}
	query := target.Query()
	query.Set(key, value)
	target.RawQuery = query.Encode()
	return target.String()
}

func randomToken() string {
	buffer := make([]byte, 32)
	_, _ = rand.Read(buffer)
	return base64.RawURLEncoding.EncodeToString(buffer)
}

func hashValue(value string) string {
	sum := sha256.Sum256([]byte(value))
	return hex.EncodeToString(sum[:])
}
