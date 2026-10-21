package federation

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
	"polder-server/internal/users"
)

const (
	inviteLifetime       = 7 * 24 * time.Hour
	maxActiveInvites     = 50
	maxInviteFieldLength = 255
	inviteAcceptedPath   = "/invite-accepted"
)

type Invite struct {
	ID        int64     `json:"id"`
	Token     string    `json:"token,omitempty" required:"false" doc:"The invite token; only returned when the invite is created"`
	Provider  string    `json:"provider" doc:"This server's address, which the other person enters together with the token"`
	ExpiresAt time.Time `json:"expiresAt"`
	CreatedAt time.Time `json:"createdAt"`
}

type Contact struct {
	ID        int64     `json:"id"`
	CloudID   string    `json:"cloudId" doc:"The contact's federated cloud ID, to share with"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	Server    string    `json:"server"`
	CreatedAt time.Time `json:"createdAt"`
}

type AcceptInviteRequest struct {
	Token    string `json:"token" maxLength:"255" doc:"The invite token the other person gave you"`
	Provider string `json:"provider" maxLength:"512" doc:"The address of the other person's server"`
}

func (s *Service) CreateInvite(ctx context.Context, user users.User) (Invite, error) {
	if err := s.requireEnabled(ctx); err != nil {
		return Invite{}, err
	}
	now := s.now()
	if _, err := s.db.ExecContext(ctx, `DELETE FROM federation_invites WHERE expires_at < $1`, now.Unix()); err != nil {
		return Invite{}, err
	}
	var active int
	if err := s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM federation_invites WHERE user_id = $1`, user.ID).Scan(&active); err != nil {
		return Invite{}, err
	}
	if active >= maxActiveInvites {
		return Invite{}, apperr.New(apperr.KindRateLimited, "you have too many open invites; revoke some first")
	}
	token := newShareSecret()
	invite := Invite{Token: token, Provider: s.publicHost, ExpiresAt: time.Unix(now.Add(inviteLifetime).Unix(), 0), CreatedAt: time.Unix(now.Unix(), 0)}
	err := s.db.QueryRowContext(ctx,
		`INSERT INTO federation_invites (user_id, token_hash, expires_at, created_at) VALUES ($1, $2, $3, $4) RETURNING id`,
		user.ID, hashSecret(token), invite.ExpiresAt.Unix(), invite.CreatedAt.Unix()).Scan(&invite.ID)
	return invite, err
}

func (s *Service) Invites(ctx context.Context, user users.User) ([]Invite, error) {
	return database.QueryAll(ctx, s.db, func(row database.RowScanner) (Invite, error) {
		var invite Invite
		var expiresAt, createdAt int64
		err := row.Scan(&invite.ID, &expiresAt, &createdAt)
		invite.Provider, invite.ExpiresAt, invite.CreatedAt = s.publicHost, time.Unix(expiresAt, 0), time.Unix(createdAt, 0)
		return invite, err
	}, `SELECT id, expires_at, created_at FROM federation_invites WHERE user_id = $1 AND expires_at >= $2 ORDER BY created_at DESC, id DESC`,
		user.ID, s.now().Unix())
}

func (s *Service) RevokeInvite(ctx context.Context, user users.User, id int64) error {
	return database.RequireAffected(apperr.NotFound("no such invite"))(
		s.db.ExecContext(ctx, `DELETE FROM federation_invites WHERE id = $1 AND user_id = $2`, id, user.ID))
}

type inviteAcceptedPayload struct {
	RecipientProvider string `json:"recipientProvider"`
	Token             string `json:"token"`
	UserID            string `json:"userID"`
	Email             string `json:"email"`
	Name              string `json:"name"`
}

type inviteAcceptedResponse struct {
	UserID string `json:"userID"`
	Email  string `json:"email"`
	Name   string `json:"name"`
}

func (s *Service) AcceptInvite(ctx context.Context, user users.User, request AcceptInviteRequest) (Contact, error) {
	if err := s.requireEnabled(ctx); err != nil {
		return Contact{}, err
	}
	remote, err := NormalizeRemote(request.Provider)
	if err != nil {
		return Contact{}, err
	}
	server, err := s.servers.byRemote(ctx, remote)
	if err != nil {
		return Contact{}, err
	}
	if !validSecret(request.Token) {
		return Contact{}, apperr.Invalid("the invite token is not valid")
	}
	response, err := s.postOCM(ctx, server, inviteAcceptedPath, inviteAcceptedPayload{
		RecipientProvider: s.publicHost, Token: request.Token, UserID: user.Username, Email: user.Profile.Email, Name: user.ShownName(),
	})
	if err != nil {
		return Contact{}, apperr.Unavailable("could not reach %s", server.Remote)
	}
	switch {
	case response.status == http.StatusConflict:
		return Contact{}, apperr.AlreadyExists("this invite was already accepted")
	case response.status == http.StatusNotFound || response.status == http.StatusBadRequest:
		return Contact{}, apperr.Invalid("%s does not know this invite token, or it expired", server.Remote)
	case response.status < 200 || response.status >= 300:
		return Contact{}, apperr.Unavailable("%s refused the invite: %s", server.Remote, firstNonEmpty(remoteMessage(response.body), http.StatusText(response.status)))
	}
	var accepted inviteAcceptedResponse
	if err := json.Unmarshal(response.body, &accepted); err != nil || !validRemoteUser(accepted.UserID) {
		return Contact{}, apperr.Unavailable("%s sent an unusable answer to the invite", server.Remote)
	}
	return s.saveContact(ctx, user.ID, server, accepted.UserID, accepted.Name, accepted.Email)
}

func validRemoteUser(user string) bool {
	return user != "" && len(user) <= maxUserLength && remoteUserPattern.MatchString(user)
}

func (s *Service) saveContact(ctx context.Context, userID int64, server Server, remoteUser, name, email string) (Contact, error) {
	contact := Contact{
		CloudID: remoteUser + "@" + server.Remote, Server: server.Remote, CreatedAt: time.Unix(s.now().Unix(), 0),
		Name:  truncate(cleanProvider(name), maxInviteFieldLength),
		Email: truncate(cleanProvider(email), maxInviteFieldLength),
	}
	err := s.db.QueryRowContext(ctx,
		`INSERT INTO federation_contacts (user_id, server_id, remote_user, name, email, created_at) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`,
		userID, server.ID, remoteUser, contact.Name, contact.Email, contact.CreatedAt.Unix()).Scan(&contact.ID)
	if database.IsUniqueViolation(err) {
		return Contact{}, apperr.AlreadyExists("%s is already a contact", contact.CloudID)
	}
	return contact, err
}

func (s *Service) Contacts(ctx context.Context, user users.User) ([]Contact, error) {
	return database.QueryAll(ctx, s.db, func(row database.RowScanner) (Contact, error) {
		var contact Contact
		var remoteUser string
		var createdAt int64
		err := row.Scan(&contact.ID, &remoteUser, &contact.Name, &contact.Email, &contact.Server, &createdAt)
		contact.CloudID, contact.CreatedAt = remoteUser+"@"+contact.Server, time.Unix(createdAt, 0)
		return contact, err
	}, `SELECT c.id, c.remote_user, c.name, c.email, s.remote, c.created_at FROM federation_contacts c
		JOIN federation_servers s ON s.id = c.server_id WHERE c.user_id = $1 ORDER BY c.name, c.remote_user`, user.ID)
}

func (s *Service) RemoveContact(ctx context.Context, user users.User, id int64) error {
	return database.RequireAffected(apperr.NotFound("no such contact"))(
		s.db.ExecContext(ctx, `DELETE FROM federation_contacts WHERE id = $1 AND user_id = $2`, id, user.ID))
}

func (s *Service) inviteAccepted(ctx context.Context, origin notificationOrigin, payload inviteAcceptedPayload) (inviteAcceptedResponse, error) {
	if !validSecret(payload.Token) || !validRemoteUser(payload.UserID) {
		return inviteAcceptedResponse{}, ocmFailure(http.StatusBadRequest, "the invite token or user is missing")
	}
	remote, err := NormalizeRemote(payload.RecipientProvider)
	if err != nil {
		return inviteAcceptedResponse{}, ocmFailure(http.StatusBadRequest, "recipientProvider is not a server address")
	}
	server, err := s.servers.byRemote(ctx, remote)
	if err != nil {
		if server, err = s.serverForHost(ctx, remote); err != nil {
			return inviteAcceptedResponse{}, ocmFailure(http.StatusForbidden, "this server does not trust "+truncate(remote, 80))
		}
	}
	if !origin.allows(server, false) {
		return inviteAcceptedResponse{}, ocmFailure(http.StatusForbidden, "the request does not come from "+server.Remote)
	}
	var inviteID, userID, expiresAt int64
	err = s.db.QueryRowContext(ctx, `SELECT id, user_id, expires_at FROM federation_invites WHERE token_hash = $1`, hashSecret(payload.Token)).
		Scan(&inviteID, &userID, &expiresAt)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && s.now().Unix() > expiresAt) {
		return inviteAcceptedResponse{}, ocmFailure(http.StatusBadRequest, "the invite token is unknown or expired")
	}
	if err != nil {
		return inviteAcceptedResponse{}, err
	}
	user, err := s.users.ByID(ctx, userID)
	if err != nil || user.Disabled {
		return inviteAcceptedResponse{}, ocmFailure(http.StatusBadRequest, "the invite token is unknown or expired")
	}
	if _, err := s.saveContact(ctx, user.ID, server, payload.UserID, payload.Name, payload.Email); err != nil {
		if apperr.Is(err, apperr.KindAlreadyExists) {
			return inviteAcceptedResponse{}, ocmFailure(http.StatusConflict, "the invite was already accepted")
		}
		return inviteAcceptedResponse{}, err
	}
	if _, err := s.db.ExecContext(ctx, `DELETE FROM federation_invites WHERE id = $1`, inviteID); err != nil {
		return inviteAcceptedResponse{}, err
	}
	logger.Info("federated invite accepted", "user", user.Username, "contact", payload.UserID+"@"+server.Remote)
	return inviteAcceptedResponse{UserID: user.Username, Email: user.Profile.Email, Name: user.ShownName()}, nil
}
