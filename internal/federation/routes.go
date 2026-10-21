package federation

import (
	"context"
	"crypto/rsa"
	"crypto/subtle"
	"database/sql"
	"encoding/json"
	"errors"
	"io"
	"net"
	"net/http"
	"net/url"
	"slices"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/database"
	"polder-server/internal/sharing"
	"polder-server/internal/webdav"
)

const (
	maxOCMRequestBytes   = 64 << 10
	federationDevice     = "Federation"
	limiterKeyOCM        = "ocm:"
	limiterKeyShareToken = "share-token:"
)

type Guard interface {
	Blocked(keys ...string) bool
	Fail(keys ...string)
	Secure(r *http.Request) bool
}

func (s *Service) Routes(router chi.Router, guard Guard, dav *webdav.Handler) {
	discovery := s.enabledOnly(s.serveDiscovery)
	router.Get("/.well-known/ocm", discovery)
	router.Get("/ocm-provider", discovery)
	router.Get("/ocm-provider/", discovery)
	router.Post(ocmPath+"/shares", s.enabledOnly(func(w http.ResponseWriter, r *http.Request) { s.handleShare(w, r, guard) }))
	router.Post(ocmPath+notificationsPath, s.enabledOnly(func(w http.ResponseWriter, r *http.Request) { s.handleNotification(w, r, guard) }))
	router.Post(ocmPath+inviteAcceptedPath, s.enabledOnly(func(w http.ResponseWriter, r *http.Request) { s.handleInviteAccepted(w, r, guard) }))
	public := s.enabledOnly(func(w http.ResponseWriter, r *http.Request) { s.servePublicDAV(w, r, guard, dav) })
	router.Handle(publicWebDAVPath, public)
	router.Handle(publicWebDAVPath+"/*", public)
}

func (s *Service) enabledOnly(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if !s.Enabled(r.Context()) {
			http.NotFound(w, r)
			return
		}
		next(w, r)
	}
}

func clientAddress(r *http.Request) string {
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}

func writeOCMError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]any{"message": message, "validationErrors": []any{}})
}

func (s *Service) serveDiscovery(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Cache-Control", "public, max-age=3600")
	writeJSON(w, http.StatusOK, s.ownDiscovery())
}

func readOCMBody(w http.ResponseWriter, r *http.Request) ([]byte, bool) {
	body, err := io.ReadAll(io.LimitReader(r.Body, maxOCMRequestBytes+1))
	if err != nil || len(body) > maxOCMRequestBytes {
		writeOCMError(w, http.StatusBadRequest, "request body is too large")
		return nil, false
	}
	return body, true
}

func (s *Service) verify(r *http.Request, body []byte) (Server, error) {
	var signedBy Server
	_, err := verifyRequest(r, body, s.now(), func(keyID, origin string) (*rsa.PublicKey, error) {
		servers, err := s.servers.list(r.Context())
		if err != nil {
			return nil, err
		}
		for _, server := range servers {
			if sameHost(server.host(), origin) && server.keyID == keyID && server.publicKeyPEM != "" {
				signedBy = server
				return parsePublicKey(server.publicKeyPEM)
			}
		}
		return nil, errInvalidSignature
	})
	return signedBy, err
}

func (s *Service) handleShare(w http.ResponseWriter, r *http.Request, guard Guard) {
	address := clientAddress(r)
	if guard.Blocked(limiterKeyOCM + address) {
		writeOCMError(w, http.StatusTooManyRequests, "too many failed requests")
		return
	}
	body, ok := readOCMBody(w, r)
	if !ok {
		return
	}
	var payload incomingSharePayload
	if err := json.Unmarshal(body, &payload); err != nil {
		writeOCMError(w, http.StatusBadRequest, "Missing arguments")
		return
	}
	server, err := s.shareOrigin(r, body, payload)
	if err != nil {
		guard.Fail(limiterKeyOCM + address)
		logger.Warn("rejected a federated share", "address", address, "owner", truncate(payload.Owner, 120), "error", err)
		status := http.StatusBadRequest
		if errors.Is(err, errUntrustedServer) || errors.Is(err, errWrongAddress) {
			status = http.StatusForbidden
		} else if errors.Is(err, errMustSign) {
			status = http.StatusUnauthorized
		}
		writeOCMError(w, status, err.Error())
		return
	}
	received, err := s.receiveShare(r.Context(), server, payload)
	var failure *ocmError
	switch {
	case errors.As(err, &failure):
		writeOCMError(w, failure.status, failure.message)
		return
	case err != nil:
		logger.Error("store a federated share", "remote", server.Remote, "error", err)
		writeOCMError(w, http.StatusInternalServerError, "internal error")
		return
	}
	writeJSON(w, http.StatusCreated, map[string]string{"recipientDisplayName": received.recipient.ShownName()})
}

func (s *Service) shareOrigin(r *http.Request, body []byte, payload incomingSharePayload) (Server, error) {
	server, err := s.verify(r, body)
	if !errors.Is(err, errUnsigned) {
		return server, err
	}
	owner, err := ParseCloudID(payload.Owner)
	if err != nil {
		return Server{}, errUntrustedServer
	}
	server, err = s.serverForHost(r.Context(), owner.Host())
	if err != nil {
		return Server{}, err
	}
	return server, s.acceptUnsigned(r.Context(), server, r)
}

type notificationRequest struct {
	NotificationType string          `json:"notificationType"`
	ResourceType     string          `json:"resourceType"`
	ProviderID       json.RawMessage `json:"providerId"`
	Notification     struct {
		SharedSecret string `json:"sharedSecret"`
		Grantee      string `json:"grantee"`
		File         struct {
			ProviderID json.RawMessage `json:"providerId"`
		} `json:"file"`
		Protocol struct {
			WebDAV struct {
				Permissions []string `json:"permissions"`
			} `json:"webdav"`
		} `json:"protocol"`
	} `json:"notification"`
}

func (n notificationRequest) providerID() (string, bool) {
	if id, ok := parseProviderID(n.ProviderID); ok {
		return id, true
	}
	return parseProviderID(n.Notification.File.ProviderID)
}

func (s *Service) handleNotification(w http.ResponseWriter, r *http.Request, guard Guard) {
	address := clientAddress(r)
	if guard.Blocked(limiterKeyOCM + address) {
		writeOCMError(w, http.StatusTooManyRequests, "too many failed requests")
		return
	}
	body, ok := readOCMBody(w, r)
	if !ok {
		return
	}
	signedBy, err := s.verify(r, body)
	if err != nil && !errors.Is(err, errUnsigned) {
		guard.Fail(limiterKeyOCM + address)
		writeOCMError(w, http.StatusBadRequest, "Invalid signature")
		return
	}
	var request notificationRequest
	providerID, validID := "", false
	if json.Unmarshal(body, &request) == nil {
		providerID, validID = request.providerID()
	}
	secret := request.Notification.SharedSecret
	if !validID || (secret != "" && !validSecret(secret)) {
		writeOCMError(w, http.StatusBadRequest, "Missing arguments")
		return
	}
	origin := notificationOrigin{signed: err == nil, server: signedBy, request: r, service: s}
	switch request.NotificationType {
	case "SHARE_ACCEPTED", "SHARE_DECLINED":
		err = s.recipientResponded(r.Context(), origin, providerID, secret, request.NotificationType == "SHARE_ACCEPTED")
	case "SHARE_UNSHARED":
		err = s.ownerUnshared(r.Context(), origin, providerID, secret, request.Notification.Grantee)
	case "SHARE_CHANGE_PERMISSION":
		err = s.ownerChangedPermissions(r.Context(), origin, providerID, secret, request.Notification.Grantee, request.Notification.Protocol.WebDAV.Permissions)
	default:
		writeOCMError(w, http.StatusNotImplemented, "notification type is not supported")
		return
	}
	var failure *ocmError
	switch {
	case errors.As(err, &failure):
		guard.Fail(limiterKeyOCM + address)
		writeOCMError(w, failure.status, failure.message)
	case err != nil:
		logger.Error("handle a federation notification", "error", err)
		writeOCMError(w, http.StatusInternalServerError, "internal error")
	default:
		writeJSON(w, http.StatusCreated, []any{})
	}
}

type notificationOrigin struct {
	signed  bool
	server  Server
	request *http.Request
	service *Service
}

func (o notificationOrigin) allows(server Server, secretMatched bool) bool {
	if o.signed {
		return o.server.ID == server.ID
	}
	if server.SignsRequests {
		return false
	}
	return secretMatched || o.service.acceptUnsigned(o.request.Context(), server, o.request) == nil
}

func secretsMatch(storedHash, secret string) bool {
	return secret != "" && subtle.ConstantTimeCompare([]byte(storedHash), []byte(hashSecret(secret))) == 1
}

func (s *Service) recipientResponded(ctx context.Context, origin notificationOrigin, providerID, secret string, accepted bool) error {
	id, err := strconv.ParseInt(providerID, 10, 64)
	notFound := ocmFailure(http.StatusForbidden, "RESOURCE_NOT_FOUND")
	if err != nil || secret == "" {
		return notFound
	}
	row, err := scanOutgoing(s.db.QueryRowContext(ctx, `SELECT `+outgoingColumns+outgoingFrom+` WHERE o.id = $1`, id))
	if errors.Is(err, sql.ErrNoRows) {
		return notFound
	}
	if err != nil {
		return err
	}
	server, err := s.servers.byID(ctx, row.serverID)
	if err != nil {
		return err
	}
	if !secretsMatch(row.secretHash, secret) || !origin.allows(server, true) {
		return notFound
	}
	if accepted {
		_, err = s.db.ExecContext(ctx, `UPDATE federated_shares_out SET state = $1, updated_at = $2 WHERE id = $3`, StateAccepted, s.now().Unix(), row.id)
		return err
	}
	_, err = s.db.ExecContext(ctx, `DELETE FROM federated_shares_out WHERE id = $1`, row.id)
	if err == nil {
		logger.Info("federated recipient declined or removed a share", "recipient", row.recipient())
	}
	return err
}

func (s *Service) incomingFor(ctx context.Context, origin notificationOrigin, providerID, secret, grantee string) ([]incomingRow, error) {
	rows, err := database.QueryAll(ctx, s.db, scanIncoming, `SELECT `+incomingColumns+incomingFrom+` WHERE i.provider_id = $1`, providerID)
	if err != nil {
		return nil, err
	}
	matched := rows[:0]
	for _, row := range rows {
		secretMatched := secretsMatch(row.secretHash, secret)
		if secret != "" && !secretMatched {
			continue
		}
		if secret == "" && !s.granteeMatches(ctx, row.userID, grantee) {
			continue
		}
		if origin.allows(row.server, secretMatched) {
			matched = append(matched, row)
		}
	}
	return matched, nil
}

func (s *Service) granteeMatches(ctx context.Context, userID int64, grantee string) bool {
	user, err := s.users.ByID(ctx, userID)
	if err != nil {
		return false
	}
	if grantee == "" {
		return true
	}
	cloudID, err := ParseCloudID(grantee)
	name := grantee
	if err == nil {
		name = cloudID.User
	}
	name, _, _ = strings.Cut(name, "@")
	return name == user.Username
}

func (s *Service) ownerUnshared(ctx context.Context, origin notificationOrigin, providerID, secret, grantee string) error {
	rows, err := s.incomingFor(ctx, origin, providerID, secret, grantee)
	if err != nil {
		return err
	}
	for _, row := range rows {
		if _, err := s.db.ExecContext(ctx, `DELETE FROM federated_shares_in WHERE id = $1`, row.id); err != nil {
			return err
		}
		logger.Info("federated share ended by its owner", "owner", row.ownerCloudID)
	}
	return nil
}

func (s *Service) ownerChangedPermissions(ctx context.Context, origin notificationOrigin, providerID, secret, grantee string, names []string) error {
	rows, err := s.incomingFor(ctx, origin, providerID, secret, grantee)
	if err != nil {
		return err
	}
	write := slices.Contains(names, "write")
	mask := maskFromPermissions(sharing.SharePermissions{Edit: write, Create: write, Delete: write})
	for _, row := range rows {
		if _, err := s.db.ExecContext(ctx, `UPDATE federated_shares_in SET permissions = $1, updated_at = $2 WHERE id = $3`, mask, s.now().Unix(), row.id); err != nil {
			return err
		}
	}
	return nil
}

func (s *Service) handleInviteAccepted(w http.ResponseWriter, r *http.Request, guard Guard) {
	address := clientAddress(r)
	if guard.Blocked(limiterKeyOCM + address) {
		writeOCMError(w, http.StatusTooManyRequests, "too many failed requests")
		return
	}
	body, ok := readOCMBody(w, r)
	if !ok {
		return
	}
	signedBy, err := s.verify(r, body)
	if err != nil && !errors.Is(err, errUnsigned) {
		guard.Fail(limiterKeyOCM + address)
		writeOCMError(w, http.StatusBadRequest, "Invalid signature")
		return
	}
	payload, ok := parseInviteAccepted(r, body)
	if !ok {
		writeOCMError(w, http.StatusBadRequest, "the invite token or user is missing")
		return
	}
	origin := notificationOrigin{signed: err == nil, server: signedBy, request: r, service: s}
	accepted, err := s.inviteAccepted(r.Context(), origin, payload)
	var failure *ocmError
	switch {
	case errors.As(err, &failure):
		if failure.status != http.StatusConflict {
			guard.Fail(limiterKeyOCM + address)
		}
		writeOCMError(w, failure.status, failure.message)
	case err != nil:
		logger.Error("accept a federated invite", "error", err)
		writeOCMError(w, http.StatusInternalServerError, "internal error")
	default:
		writeJSON(w, http.StatusOK, accepted)
	}
}

func parseInviteAccepted(r *http.Request, body []byte) (inviteAcceptedPayload, bool) {
	var payload inviteAcceptedPayload
	if strings.HasPrefix(r.Header.Get("Content-Type"), "application/x-www-form-urlencoded") {
		values, err := url.ParseQuery(string(body))
		if err != nil {
			return payload, false
		}
		payload = inviteAcceptedPayload{
			RecipientProvider: values.Get("recipientProvider"), Token: values.Get("token"), UserID: values.Get("userID"),
			Email: values.Get("email"), Name: values.Get("name"),
		}
		return payload, true
	}
	return payload, json.Unmarshal(body, &payload) == nil
}

func shareSecretFrom(r *http.Request) (string, bool) {
	if token, found := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer "); found {
		token = strings.TrimSpace(token)
		return token, token != ""
	}
	if token, found := strings.CutPrefix(r.Header.Get("Authorization"), "bearer "); found {
		token = strings.TrimSpace(token)
		return token, token != ""
	}
	secret, _, ok := r.BasicAuth()
	return secret, ok && secret != ""
}

func (s *Service) servePublicDAV(w http.ResponseWriter, r *http.Request, guard Guard, dav *webdav.Handler) {
	if !guard.Secure(r) {
		webdav.WriteError(w, r, apperr.Forbidden("WebDAV needs HTTPS"))
		return
	}
	address := clientAddress(r)
	key := limiterKeyShareToken + address
	if guard.Blocked(key) {
		webdav.WriteError(w, r, apperr.New(apperr.KindRateLimited, "too many failed attempts, try again in a minute"))
		return
	}
	secret, ok := shareSecretFrom(r)
	if !ok {
		webdav.WriteError(w, r, apperr.Unauthorized("authenticate with the share token"))
		return
	}
	access, err := s.ForSecret(r.Context(), secret)
	if err != nil {
		if apperr.Is(err, apperr.KindUnauthorized) {
			guard.Fail(key)
		}
		webdav.WriteError(w, r, err)
		return
	}
	space := webdav.Space{Access: access, Root: publicWebDAVPath, Principal: "federated:" + hashSecret(secret)[:24]}
	ctx := activity.WithActor(r.Context(), activity.Actor{Device: federationDevice, Via: access.Via})
	dav.Serve(w, r.WithContext(ctx), space)
}
