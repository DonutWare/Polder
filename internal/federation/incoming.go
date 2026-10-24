package federation

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"time"
	"unicode/utf8"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
	"polder-server/internal/sharing"
	"polder-server/internal/users"
)

const (
	maxPendingPerUser  = 200
	maxShareNameLength = 255
	maxSecretLength    = 256
)

var providerIDPattern = regexp.MustCompile(`^[A-Za-z0-9._-]{1,64}$`)

type IncomingFederatedShare struct {
	ID          int64                    `json:"id"`
	Name        string                   `json:"name"`
	Owner       string                   `json:"owner" doc:"The owner's federated cloud ID"`
	OwnerName   string                   `json:"ownerName"`
	SharedBy    string                   `json:"sharedBy" doc:"Cloud ID of whoever shared it; usually the owner"`
	Server      string                   `json:"server"`
	Provider    string                   `json:"provider" doc:"The software the remote server says it runs"`
	IsDir       bool                     `json:"isDir"`
	Permissions sharing.SharePermissions `json:"permissions" doc:"What the remote server allows, as last seen"`
	State       ShareState               `json:"state" doc:"Pending until accepted; pending shares cannot be opened"`
	CreatedAt   time.Time                `json:"createdAt"`
	MountPath   string                   `json:"mountPath" doc:"Where the item sits in the user's files once accepted; empty while pending"`
	Size        int64                    `json:"size" doc:"The shared item's size, as last seen"`
	Mtime       *time.Time               `json:"mtime,omitempty" required:"false" doc:"When the shared item last changed, as last seen"`
}

type incomingRow struct {
	id                int64
	userID            int64
	serverID          int64
	providerID        string
	ownerCloudID      string
	ownerName         string
	senderCloudID     string
	senderDisplayName string
	name              string
	isDir             bool
	webdavURI         string
	authScheme        string
	secretSealed      string
	secretHash        string
	permissions       int
	state             ShareState
	createdAt         time.Time
	remoteSize        int64
	remoteMtime       *time.Time
	server            Server
}

const incomingColumns = `i.id, i.user_id, i.server_id, i.provider_id, i.owner_cloud_id, i.owner_display_name, i.sender_cloud_id, i.sender_display_name,
	i.name, i.is_dir, i.webdav_uri, i.auth_scheme, i.secret_sealed, i.secret_hash, i.permissions, i.state, i.created_at,
	i.remote_size, i.remote_mtime, ` + serverColumnsPrefixed

const serverColumnsPrefixed = `s.id, s.remote, s.provider, s.ocm_endpoint, s.webdav_path, s.key_id, s.public_key_pem, s.api_version, s.resource_types,
	s.capabilities, s.allow_private_network, s.verify_sender_address, s.created_at, s.discovered_at`

const incomingFrom = ` FROM federated_shares_in i JOIN federation_servers s ON s.id = i.server_id`

type joinedScanner struct {
	row      database.RowScanner
	incoming *incomingRow
}

func (j joinedScanner) Scan(dest ...any) error {
	var createdAt int64
	var remoteMtime sql.NullInt64
	incomingDest := []any{&j.incoming.id, &j.incoming.userID, &j.incoming.serverID, &j.incoming.providerID, &j.incoming.ownerCloudID,
		&j.incoming.ownerName, &j.incoming.senderCloudID, &j.incoming.senderDisplayName, &j.incoming.name, &j.incoming.isDir,
		&j.incoming.webdavURI, &j.incoming.authScheme,
		&j.incoming.secretSealed, &j.incoming.secretHash, &j.incoming.permissions, &j.incoming.state, &createdAt,
		&j.incoming.remoteSize, &remoteMtime}
	if err := j.row.Scan(append(incomingDest, dest...)...); err != nil {
		return err
	}
	j.incoming.createdAt = time.Unix(createdAt, 0)
	if remoteMtime.Valid {
		mtime := time.Unix(remoteMtime.Int64, 0)
		j.incoming.remoteMtime = &mtime
	}
	return nil
}

func scanIncoming(row database.RowScanner) (incomingRow, error) {
	var incoming incomingRow
	server, err := scanServer(joinedScanner{row: row, incoming: &incoming})
	if err != nil {
		return incomingRow{}, err
	}
	incoming.server = server
	return incoming, nil
}

func (r incomingRow) sealContext() string {
	return "federated-share-in:" + r.secretHash
}

func (r incomingRow) describe() IncomingFederatedShare {
	return IncomingFederatedShare{
		ID: r.id, Name: r.name, Owner: r.ownerCloudID, OwnerName: r.ownerName, SharedBy: r.senderCloudID, Server: r.server.Remote,
		Provider: r.server.Provider, IsDir: r.isDir, Permissions: permissionsFromMask(r.permissions), State: r.state, CreatedAt: r.createdAt,
		Size: r.remoteSize, Mtime: r.remoteMtime,
	}
}

func permissionsFromMask(mask int) sharing.SharePermissions {
	return sharing.SharePermissions{Edit: mask&2 != 0, Create: mask&4 != 0, Delete: mask&8 != 0}
}

type ocmError struct {
	status  int
	message string
}

func (e *ocmError) Error() string { return e.message }

func ocmFailure(status int, message string) error {
	return &ocmError{status: status, message: message}
}

type incomingSharePayload struct {
	ShareWith         string          `json:"shareWith"`
	Name              string          `json:"name"`
	ProviderID        json.RawMessage `json:"providerId"`
	Owner             string          `json:"owner"`
	OwnerDisplayName  string          `json:"ownerDisplayName"`
	Sender            string          `json:"sender"`
	SenderDisplayName string          `json:"senderDisplayName"`
	ShareType         string          `json:"shareType"`
	ResourceType      string          `json:"resourceType"`
	Protocol          struct {
		Name    string `json:"name"`
		Options struct {
			SharedSecret string `json:"sharedSecret"`
		} `json:"options"`
		WebDAV struct {
			SharedSecret string `json:"sharedSecret"`
			URI          string `json:"uri"`
		} `json:"webdav"`
	} `json:"protocol"`
}

func (p incomingSharePayload) secret() string {
	return firstNonEmpty(p.Protocol.Options.SharedSecret, p.Protocol.WebDAV.SharedSecret)
}

func parseProviderID(raw json.RawMessage) (string, bool) {
	var text string
	if json.Unmarshal(raw, &text) != nil {
		var number json.Number
		if json.Unmarshal(raw, &number) != nil {
			return "", false
		}
		text = number.String()
	}
	return text, providerIDPattern.MatchString(text)
}

func validSecret(secret string) bool {
	if secret == "" || len(secret) > maxSecretLength {
		return false
	}
	for _, r := range secret {
		if r <= 0x20 || r >= 0x7f || r == ':' {
			return false
		}
	}
	return true
}

func cleanShareName(raw string) (string, bool) {
	name := strings.TrimSpace(raw)
	if name == "" || name == "." || name == ".." || utf8.RuneCountInString(name) > maxShareNameLength || strings.ContainsAny(name, "/\\\x00") {
		return "", false
	}
	return cleanProvider(name), true
}

type receivedShare struct {
	recipient users.User
}

func (s *Service) receiveShare(ctx context.Context, server Server, payload incomingSharePayload) (receivedShare, error) {
	if payload.ShareType != "user" {
		return receivedShare{}, ocmFailure(http.StatusNotImplemented, "only shares with users are supported")
	}
	if payload.ResourceType != resourceFile && payload.ResourceType != resourceFolder {
		return receivedShare{}, ocmFailure(http.StatusNotImplemented, "only file and folder shares are supported")
	}
	if payload.Protocol.Name != "webdav" && payload.Protocol.Name != "multi" {
		return receivedShare{}, ocmFailure(http.StatusNotImplemented, "only the webdav protocol is supported")
	}
	providerID, ok := parseProviderID(payload.ProviderID)
	secret := payload.secret()
	name, nameOK := cleanShareName(payload.Name)
	webdavURI, uriOK := cleanWebDAVURI(payload.Protocol.WebDAV.URI, server)
	if !ok || !validSecret(secret) || !nameOK || !uriOK {
		return receivedShare{}, ocmFailure(http.StatusBadRequest, "Missing arguments")
	}
	owner, err := ParseCloudID(payload.Owner)
	if err != nil || !sameHost(owner.Host(), server.host()) {
		return receivedShare{}, ocmFailure(http.StatusBadRequest, "share initiation from a different instance")
	}
	sender := owner
	if payload.Sender != "" {
		if sender, err = ParseCloudID(payload.Sender); err != nil || !sameHost(sender.Host(), server.host()) {
			return receivedShare{}, ocmFailure(http.StatusBadRequest, "share initiation from a different instance")
		}
	}
	recipient, err := s.localRecipient(ctx, payload.ShareWith)
	if err != nil {
		return receivedShare{}, err
	}
	if err := s.checkPendingLimit(ctx, recipient.ID); err != nil {
		return receivedShare{}, err
	}
	row := incomingRow{userID: recipient.ID, serverID: server.ID, providerID: providerID, ownerCloudID: owner.String(),
		ownerName:     truncate(cleanProvider(firstNonEmpty(payload.OwnerDisplayName, owner.User)), maxRemoteDisplayName),
		senderCloudID: sender.String(), senderDisplayName: truncate(cleanProvider(payload.SenderDisplayName), maxRemoteDisplayName),
		name: name, isDir: payload.ResourceType == resourceFolder, webdavURI: webdavURI, secretHash: hashSecret(secret)}
	row.secretSealed = s.box.seal(secret, row.sealContext())
	if err := s.insertIncoming(ctx, row); err != nil {
		return receivedShare{}, err
	}
	logger.Info("received a federated share", "user", recipient.Username, "owner", row.ownerCloudID, "name", name)
	return receivedShare{recipient: recipient}, nil
}

func cleanWebDAVURI(raw string, server Server) (string, bool) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return "", true
	}
	if len(raw) > 2048 {
		return "", false
	}
	parsed, err := url.Parse(raw)
	if err != nil || parsed.User != nil || parsed.RawQuery != "" || parsed.Fragment != "" || hasDotSegment(parsed.Path) {
		return "", false
	}
	if parsed.IsAbs() {
		endPoint, err := url.Parse(server.ocmEndpoint)
		if err != nil || parsed.Scheme != "https" || (!sameHost(parsed.Host, endPoint.Host) && !sameHost(parsed.Host, server.host())) {
			return "", false
		}
		return parsed.String(), true
	}
	if parsed.Host != "" {
		return "", false
	}
	return raw, true
}

func (s Server) host() string {
	host, _, _ := strings.Cut(s.Remote, "/")
	return host
}

func (s *Service) localRecipient(ctx context.Context, shareWith string) (users.User, error) {
	notFound := ocmFailure(http.StatusBadRequest, "User does not exist at "+s.publicHost)
	recipient, err := ParseCloudID(shareWith)
	if err != nil || !sameHost(recipient.Host(), s.publicHost) {
		return users.User{}, notFound
	}
	username := recipient.User
	for {
		trimmed, found := strings.CutSuffix(username, "@"+s.publicHost)
		if !found {
			break
		}
		username = trimmed
	}
	user, err := s.users.ByUsername(ctx, username)
	if apperr.Is(err, apperr.KindNotFound) || (err == nil && user.Disabled) {
		return users.User{}, notFound
	}
	return user, err
}

func (s *Service) checkPendingLimit(ctx context.Context, userID int64) error {
	var pending int
	err := s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM federated_shares_in WHERE user_id = $1 AND state = $2`, userID, StatePending).Scan(&pending)
	if err != nil {
		return err
	}
	if pending >= maxPendingPerUser {
		return ocmFailure(http.StatusTooManyRequests, "the recipient has too many pending shares")
	}
	return nil
}

func (s *Service) insertIncoming(ctx context.Context, row incomingRow) error {
	now := s.now().Unix()
	_, err := s.db.ExecContext(ctx,
		`INSERT INTO federated_shares_in (user_id, server_id, provider_id, owner_cloud_id, owner_display_name, sender_cloud_id, sender_display_name,
		 name, is_dir, webdav_uri, secret_sealed, secret_hash, permissions, state, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, 1, $13, $14, $14)`,
		row.userID, row.serverID, row.providerID, row.ownerCloudID, row.ownerName, row.senderCloudID, row.senderDisplayName,
		row.name, row.isDir, row.webdavURI, row.secretSealed, row.secretHash, StatePending, now)
	if database.IsUniqueViolation(err) {
		return ocmFailure(http.StatusBadRequest, "this share already exists")
	}
	return err
}

func (s *Service) Incoming(ctx context.Context, user users.User) ([]IncomingFederatedShare, error) {
	rows, err := database.QueryAll(ctx, s.db, scanIncoming,
		`SELECT `+incomingColumns+incomingFrom+` WHERE i.user_id = $1 ORDER BY i.created_at DESC, i.id DESC`, user.ID)
	if err != nil {
		return nil, err
	}
	shares := make([]IncomingFederatedShare, 0, len(rows))
	for _, row := range rows {
		shares = append(shares, row.describe())
	}
	return shares, nil
}

func (s *Service) ownIncoming(ctx context.Context, user users.User, id int64) (incomingRow, error) {
	row, err := scanIncoming(s.db.QueryRowContext(ctx, `SELECT `+incomingColumns+incomingFrom+` WHERE i.id = $1 AND i.user_id = $2`, id, user.ID))
	if errors.Is(err, sql.ErrNoRows) {
		return incomingRow{}, apperr.NotFound("no such federated share")
	}
	return row, err
}

func (s *Service) AcceptIncoming(ctx context.Context, user users.User, id int64) (IncomingFederatedShare, error) {
	if err := s.requireEnabled(ctx); err != nil {
		return IncomingFederatedShare{}, err
	}
	row, err := s.ownIncoming(ctx, user, id)
	if err != nil {
		return IncomingFederatedShare{}, err
	}
	if row.state == StateAccepted {
		return row.describe(), nil
	}
	if _, err := s.db.ExecContext(ctx, `UPDATE federated_shares_in SET state = $1, updated_at = $2 WHERE id = $3`, StateAccepted, s.now().Unix(), id); err != nil {
		return IncomingFederatedShare{}, err
	}
	row.state = StateAccepted
	s.notifyOwner(ctx, row, "SHARE_ACCEPTED", "the recipient accepted the share")
	if remote, err := s.remote(row); err == nil && remote.negotiate(ctx) == nil {
		s.refreshIncomingRoot(ctx, &row, remote)
	}
	return row.describe(), nil
}

func (s *Service) RemoveIncoming(ctx context.Context, user users.User, id int64) error {
	row, err := s.ownIncoming(ctx, user, id)
	if err != nil {
		return err
	}
	if _, err := s.db.ExecContext(ctx, `DELETE FROM federated_shares_in WHERE id = $1`, id); err != nil {
		return err
	}
	s.notifyOwner(ctx, row, "SHARE_DECLINED", "the recipient declined the share")
	return nil
}

func (s *Service) notifyOwner(ctx context.Context, row incomingRow, kind, message string) {
	secret, err := s.box.open(row.secretSealed, row.sealContext())
	if err != nil {
		logger.Warn("cannot notify the owner of a federated share", "owner", row.ownerCloudID, "error", err)
		return
	}
	if err := s.enqueueNotification(ctx, row.serverID, notificationPayload(kind, row.providerID, secret, message)); err != nil {
		logger.Warn("queue federation notification", "owner", row.ownerCloudID, "error", err)
	}
}

func (s *Service) refreshIncomingRoot(ctx context.Context, row *incomingRow, remote *remoteShare) {
	root, err := remote.stat(ctx, "/")
	if err != nil {
		return
	}
	s.rememberRoot(ctx, row, root)
}

func maskFromPermissions(permissions sharing.SharePermissions) int {
	mask := 1
	if permissions.Edit {
		mask |= 2
	}
	if permissions.Create {
		mask |= 4
	}
	if permissions.Delete {
		mask |= 8
	}
	return mask
}
