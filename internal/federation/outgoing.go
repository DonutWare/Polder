package federation

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"strconv"
	"time"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
	"polder-server/internal/files"
	"polder-server/internal/sharing"
	"polder-server/internal/users"
)

type ShareState string

const (
	StatePending  ShareState = "pending"
	StateAccepted ShareState = "accepted"

	ocmPermissionsPlaceholder = "{http://open-cloud-mesh.org/ns}share-permissions"
	maxRemoteDisplayName      = 255
)

func (ShareState) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(StatePending), string(StateAccepted)}
	return s
}

type OutgoingShare struct {
	ID            int64                    `json:"id"`
	File          sharing.FileSummary      `json:"file"`
	Recipient     string                   `json:"recipient" doc:"The recipient's federated cloud ID"`
	RecipientName string                   `json:"recipientName" doc:"The name the recipient's server reported; may be empty"`
	Permissions   sharing.SharePermissions `json:"permissions"`
	ExpiresAt     *time.Time               `json:"expiresAt,omitempty" required:"false"`
	State         ShareState               `json:"state" doc:"Pending until the recipient accepts"`
	Available     bool                     `json:"available" doc:"False while the shared item is in the trash"`
	CreatedAt     time.Time                `json:"createdAt"`
}

type NewOutgoingShare struct {
	FileID      int64                    `json:"fileId"`
	Recipient   string                   `json:"recipient" maxLength:"512" doc:"Federated cloud ID, such as alice@cloud.example.com"`
	Permissions sharing.SharePermissions `json:"permissions"`
	ExpiresAt   *time.Time               `json:"expiresAt,omitempty" required:"false"`
}

type OutgoingShareChanges struct {
	Permissions *sharing.SharePermissions `json:"permissions,omitempty" required:"false"`
	ExpiresAt   *time.Time                `json:"expiresAt,omitempty" required:"false"`
	NoExpiry    bool                      `json:"noExpiry,omitempty" required:"false" doc:"Remove the expiry date"`
}

type outgoingRow struct {
	id            int64
	ownerID       int64
	fileID        int64
	serverID      int64
	remoteUser    string
	remoteName    string
	secretSealed  string
	secretHash    string
	permissions   sharing.SharePermissions
	expiresAt     *time.Time
	state         ShareState
	createdAt     time.Time
	serverRemote  string
	privateTarget bool
}

const outgoingColumns = `o.id, o.owner_id, o.file_id, o.server_id, o.remote_user, o.remote_display_name, o.secret_sealed, o.secret_hash,
	o.can_create, o.can_update, o.can_delete, o.expires_at, o.state, o.created_at, s.remote, s.allow_private_network`

const outgoingFrom = ` FROM federated_shares_out o JOIN federation_servers s ON s.id = o.server_id`

func scanOutgoing(row database.RowScanner) (outgoingRow, error) {
	var r outgoingRow
	var expiresAt sql.NullInt64
	var createdAt int64
	err := row.Scan(&r.id, &r.ownerID, &r.fileID, &r.serverID, &r.remoteUser, &r.remoteName, &r.secretSealed, &r.secretHash,
		&r.permissions.Create, &r.permissions.Edit, &r.permissions.Delete, &expiresAt, &r.state, &createdAt, &r.serverRemote, &r.privateTarget)
	if err != nil {
		return outgoingRow{}, err
	}
	r.createdAt = time.Unix(createdAt, 0)
	if expiresAt.Valid {
		expires := time.Unix(expiresAt.Int64, 0)
		r.expiresAt = &expires
	}
	return r, nil
}

func (r outgoingRow) expired(now time.Time) bool {
	return r.expiresAt != nil && now.After(*r.expiresAt)
}

func (r outgoingRow) recipient() string {
	return r.remoteUser + "@" + r.serverRemote
}

func (r outgoingRow) sealContext() string {
	return "federated-share-out:" + r.secretHash
}

func (s *Service) ShareOut(ctx context.Context, owner users.User, request NewOutgoingShare) (OutgoingShare, error) {
	if err := s.requireEnabled(ctx); err != nil {
		return OutgoingShare{}, err
	}
	recipient, err := ParseCloudID(request.Recipient)
	if err != nil {
		return OutgoingShare{}, err
	}
	server, err := s.servers.byRemote(ctx, recipient.Remote)
	if err != nil {
		return OutgoingShare{}, err
	}
	entry, err := s.files.EntryByID(ctx, owner.ID, request.FileID)
	if err != nil {
		return OutgoingShare{}, err
	}
	if request.ExpiresAt != nil && !request.ExpiresAt.After(s.now()) {
		return OutgoingShare{}, apperr.Invalid("the expiry date must be in the future")
	}
	permissions := request.Permissions
	if !entry.IsDir {
		permissions.Create, permissions.Delete = false, false
	}
	secret := newShareSecret()
	row := outgoingRow{ownerID: owner.ID, fileID: entry.ID, serverID: server.ID, remoteUser: recipient.User, secretHash: hashSecret(secret),
		permissions: permissions, expiresAt: request.ExpiresAt, state: StatePending, serverRemote: server.Remote}
	row.secretSealed = s.box.seal(secret, row.sealContext())
	if row.id, err = s.insertOutgoing(ctx, row); err != nil {
		return OutgoingShare{}, err
	}
	response, err := s.postOCM(ctx, server, "/shares", s.sharePayload(server, owner, entry, row, secret))
	if err == nil && (response.status < 200 || response.status >= 300) {
		err = apperr.Unavailable("%s refused the share: %s", server.Remote, firstNonEmpty(remoteMessage(response.body), strconv.Itoa(response.status)))
	}
	if err != nil {
		_, _ = s.db.ExecContext(ctx, `DELETE FROM federated_shares_out WHERE id = $1`, row.id)
		logger.Warn("federated share failed", "owner", owner.Username, "recipient", row.recipient(), "error", err)
		if _, isAppErr := apperr.KindOf(err); !isAppErr {
			err = apperr.Unavailable("could not reach %s", server.Remote)
		}
		return OutgoingShare{}, err
	}
	s.noteRecipientName(ctx, row.id, response.body)
	logger.Info("shared with a federated user", "owner", owner.Username, "path", entry.Path, "recipient", row.recipient())
	return s.describeOutgoing(ctx, owner, row.id)
}

func (s *Service) insertOutgoing(ctx context.Context, row outgoingRow) (int64, error) {
	now := s.now().Unix()
	var id int64
	err := s.db.QueryRowContext(ctx,
		`INSERT INTO federated_shares_out (owner_id, file_id, server_id, remote_user, secret_hash, secret_sealed, can_create, can_update, can_delete,
		 expires_at, state, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) RETURNING id`,
		row.ownerID, row.fileID, row.serverID, row.remoteUser, row.secretHash, row.secretSealed, row.permissions.Create, row.permissions.Edit,
		row.permissions.Delete, unixOrNil(row.expiresAt), row.state, now, now).Scan(&id)
	if database.IsUniqueViolation(err) {
		return 0, apperr.AlreadyExists("this item is already shared with %s", row.recipient())
	}
	return id, err
}

func (s *Service) sharePayload(server Server, owner users.User, entry files.Entry, row outgoingRow, secret string) map[string]any {
	ownerID := s.localCloudID(owner)
	resourceType := resourceFile
	if entry.IsDir && server.supports(resourceFolder) {
		resourceType = resourceFolder
	}
	webdav := map[string]any{"sharedSecret": secret, "permissions": ocmPermissionNames(row.permissions), "uri": s.publicURL + publicWebDAVPath + "/"}
	payload := map[string]any{
		"shareWith":         row.recipient(),
		"shareType":         "user",
		"name":              entry.Name,
		"resourceType":      resourceType,
		"description":       "",
		"providerId":        strconv.FormatInt(row.id, 10),
		"owner":             ownerID,
		"ownerDisplayName":  owner.ShownName(),
		"sender":            ownerID,
		"senderDisplayName": owner.ShownName(),
		"protocol":          map[string]any{"name": "multi", "webdav": webdav},
	}
	if server.legacyProtocol() {
		payload["protocol"] = map[string]any{
			"name":    "webdav",
			"options": map[string]any{"sharedSecret": secret, "permissions": ocmPermissionsPlaceholder},
			"webdav":  webdav,
		}
	}
	return payload
}

func ocmPermissionNames(permissions sharing.SharePermissions) []string {
	names := []string{"read"}
	if permissions.Create || permissions.Edit || permissions.Delete {
		names = append(names, "write")
	}
	return names
}

func (s *Service) noteRecipientName(ctx context.Context, id int64, body []byte) {
	var parsed struct {
		RecipientDisplayName string `json:"recipientDisplayName"`
	}
	if json.Unmarshal(body, &parsed) != nil || parsed.RecipientDisplayName == "" {
		return
	}
	name := truncate(cleanProvider(parsed.RecipientDisplayName), maxRemoteDisplayName)
	_, _ = s.db.ExecContext(ctx, `UPDATE federated_shares_out SET remote_display_name = $1 WHERE id = $2`, name, id)
}

func (s *Service) Outgoing(ctx context.Context, owner users.User, fileID int64) ([]OutgoingShare, error) {
	query := `SELECT ` + outgoingColumns + outgoingFrom + ` WHERE o.owner_id = $1`
	args := []any{owner.ID}
	if fileID != 0 {
		query += ` AND o.file_id = $2`
		args = append(args, fileID)
	}
	rows, err := database.QueryAll(ctx, s.db, scanOutgoing, query+` ORDER BY o.created_at DESC, o.id DESC`, args...)
	if err != nil {
		return nil, err
	}
	ids := make([]int64, 0, len(rows))
	for _, row := range rows {
		ids = append(ids, row.fileID)
	}
	entries, err := s.files.EntriesByID(ctx, owner.ID, ids)
	if err != nil {
		return nil, err
	}
	shares := make([]OutgoingShare, 0, len(rows))
	for _, row := range rows {
		shares = append(shares, describeOutgoingRow(row, entries))
	}
	return shares, nil
}

func describeOutgoingRow(row outgoingRow, entries map[int64]files.Entry) OutgoingShare {
	entry, available := entries[row.fileID]
	summary := sharing.FileSummary{ID: row.fileID}
	if available {
		summary = sharing.FileSummary{ID: entry.ID, Path: entry.Path, Name: entry.Name, IsDir: entry.IsDir}
	}
	return OutgoingShare{
		ID: row.id, File: summary, Recipient: row.recipient(), RecipientName: row.remoteName, Permissions: row.permissions,
		ExpiresAt: row.expiresAt, State: row.state, Available: available, CreatedAt: row.createdAt,
	}
}

func (s *Service) ownOutgoing(ctx context.Context, owner users.User, id int64) (outgoingRow, error) {
	row, err := scanOutgoing(s.db.QueryRowContext(ctx, `SELECT `+outgoingColumns+outgoingFrom+` WHERE o.id = $1 AND o.owner_id = $2`, id, owner.ID))
	if errors.Is(err, sql.ErrNoRows) {
		return outgoingRow{}, apperr.NotFound("no such federated share")
	}
	return row, err
}

func (s *Service) describeOutgoing(ctx context.Context, owner users.User, id int64) (OutgoingShare, error) {
	row, err := s.ownOutgoing(ctx, owner, id)
	if err != nil {
		return OutgoingShare{}, err
	}
	entries, err := s.files.EntriesByID(ctx, owner.ID, []int64{row.fileID})
	if err != nil {
		return OutgoingShare{}, err
	}
	return describeOutgoingRow(row, entries), nil
}

func (s *Service) UpdateOutgoing(ctx context.Context, owner users.User, id int64, changes OutgoingShareChanges) (OutgoingShare, error) {
	row, err := s.ownOutgoing(ctx, owner, id)
	if err != nil {
		return OutgoingShare{}, err
	}
	if changes.Permissions != nil {
		row.permissions = *changes.Permissions
		if entry, err := s.files.EntryByID(ctx, owner.ID, row.fileID); err == nil && !entry.IsDir {
			row.permissions.Create, row.permissions.Delete = false, false
		}
	}
	switch {
	case changes.NoExpiry:
		row.expiresAt = nil
	case changes.ExpiresAt != nil:
		if !changes.ExpiresAt.After(s.now()) {
			return OutgoingShare{}, apperr.Invalid("the expiry date must be in the future")
		}
		row.expiresAt = changes.ExpiresAt
	}
	_, err = s.db.ExecContext(ctx,
		`UPDATE federated_shares_out SET can_create = $1, can_update = $2, can_delete = $3, expires_at = $4, updated_at = $5 WHERE id = $6`,
		row.permissions.Create, row.permissions.Edit, row.permissions.Delete, unixOrNil(row.expiresAt), s.now().Unix(), row.id)
	if err != nil {
		return OutgoingShare{}, err
	}
	if changes.Permissions != nil {
		s.announcePermissions(ctx, row)
	}
	return s.describeOutgoing(ctx, owner, id)
}

func (s *Service) announcePermissions(ctx context.Context, row outgoingRow) {
	secret, err := s.box.open(row.secretSealed, row.sealContext())
	if err != nil {
		return
	}
	payload := notificationPayload("SHARE_CHANGE_PERMISSION", strconv.FormatInt(row.id, 10), secret, "the owner changed the permissions")
	notification := payload["notification"].(map[string]any)
	notification["grantee"] = row.remoteUser
	notification["protocol"] = map[string]any{"name": "webdav", "webdav": map[string]any{"permissions": ocmPermissionNames(row.permissions)}}
	if err := s.enqueueNotification(ctx, row.serverID, payload); err != nil {
		logger.Warn("queue permission change notification", "recipient", row.recipient(), "error", err)
	}
}

func (s *Service) RemoveOutgoing(ctx context.Context, owner users.User, id int64) error {
	row, err := s.ownOutgoing(ctx, owner, id)
	if err != nil {
		return err
	}
	return s.unshare(ctx, row)
}

func (s *Service) unshare(ctx context.Context, row outgoingRow) error {
	if _, err := s.db.ExecContext(ctx, `DELETE FROM federated_shares_out WHERE id = $1`, row.id); err != nil {
		return err
	}
	secret, err := s.box.open(row.secretSealed, row.sealContext())
	if err != nil {
		logger.Warn("cannot tell the recipient a share ended", "recipient", row.recipient(), "error", err)
		return nil
	}
	payload := notificationPayload("SHARE_UNSHARED", strconv.FormatInt(row.id, 10), secret, "the owner stopped sharing")
	payload["notification"].(map[string]any)["grantee"] = row.remoteUser
	return s.enqueueNotification(ctx, row.serverID, payload)
}

func (s *Service) FileMutation(ctx context.Context, mutation files.Mutation) {
	if len(mutation.RemovedFileIDs) == 0 {
		return
	}
	for _, fileID := range mutation.RemovedFileIDs {
		rows, err := database.QueryAll(ctx, s.db, scanOutgoing,
			`SELECT `+outgoingColumns+outgoingFrom+` WHERE o.owner_id = $1 AND o.file_id = $2`, mutation.Owner.ID, fileID)
		if err != nil {
			logger.Warn("find federated shares of deleted files", "user", mutation.Owner.Username, "error", err)
			return
		}
		for _, row := range rows {
			if err := s.unshare(ctx, row); err != nil {
				logger.Warn("remove federated share of deleted file", "user", mutation.Owner.Username, "error", err)
			}
		}
	}
}

func (s *Service) ForSecret(ctx context.Context, secret string) (sharing.Access, error) {
	denied := apperr.Unauthorized("invalid share token")
	if !s.Enabled(ctx) || secret == "" || len(secret) > 256 {
		return sharing.Access{}, denied
	}
	row, err := scanOutgoing(s.db.QueryRowContext(ctx, `SELECT `+outgoingColumns+outgoingFrom+` WHERE o.secret_hash = $1`, hashSecret(secret)))
	if errors.Is(err, sql.ErrNoRows) {
		return sharing.Access{}, denied
	}
	if err != nil {
		return sharing.Access{}, err
	}
	if row.expired(s.now()) {
		return sharing.Access{}, denied
	}
	owner, err := s.users.ByID(ctx, row.ownerID)
	if err != nil {
		return sharing.Access{}, denied
	}
	if owner.Disabled {
		return sharing.Access{}, apperr.Forbidden("the owner's account is disabled")
	}
	root, err := s.files.EntryByID(ctx, owner.ID, row.fileID)
	if err != nil {
		return sharing.Access{}, apperr.NotFound("the shared item is not available")
	}
	return sharing.Access{
		Owner: owner, Root: root, CanRead: true, CanDownload: true,
		CanCreate: row.permissions.Create, CanEdit: row.permissions.Edit, CanDelete: row.permissions.Delete,
		ExpiresAt: row.expiresAt, Via: row.recipient(),
	}, nil
}

func unixOrNil(moment *time.Time) any {
	if moment == nil {
		return nil
	}
	return moment.Unix()
}

func firstNonEmpty(values ...string) string {
	for _, value := range values {
		if value != "" {
			return value
		}
	}
	return ""
}
