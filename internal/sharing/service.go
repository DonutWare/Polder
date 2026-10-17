package sharing

import (
	"context"
	"database/sql"
	"strings"
	"time"
	"unicode/utf8"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
	"polder-server/internal/files"
	"polder-server/internal/groups"
	"polder-server/internal/users"
)

const maxNoteLength = 1000

type PasswordHasher interface {
	Hash(password string) (string, error)
	Verify(password, encodedHash string) bool
}

type Service struct {
	db     *sql.DB
	files  *files.Service
	users  *users.Store
	groups *groups.Service
	hasher PasswordHasher
	tokens linkTokens
}

func NewService(db *sql.DB, fileService *files.Service, userStore *users.Store, groupService *groups.Service, hasher PasswordHasher, linkKey []byte) *Service {
	return &Service{
		db: db, files: fileService, users: userStore, groups: groupService, hasher: hasher,
		tokens: linkTokens{key: linkKey, now: time.Now},
	}
}

func (s *Service) Share(ctx context.Context, owner users.User, request NewShare) (Share, error) {
	entry, err := s.files.EntryByID(ctx, owner.ID, request.FileID)
	if err != nil {
		return Share{}, err
	}
	if err := requireFuture(request.ExpiresAt); err != nil {
		return Share{}, err
	}
	note, err := cleanNote(request.Note)
	if err != nil {
		return Share{}, err
	}
	if err := s.validateRecipient(ctx, owner, request.Recipient); err != nil {
		return Share{}, err
	}
	row := shareRow{
		OwnerID: owner.ID, FileID: entry.ID, Permissions: request.Permissions.forEntry(entry.IsDir),
		ExpiresAt: request.ExpiresAt, Note: note,
	}
	if request.Recipient.Kind == RecipientGroup {
		row.RecipientGroupID = request.Recipient.ID
	} else {
		row.RecipientUserID = request.Recipient.ID
	}
	id, err := insertShare(ctx, s.db, row)
	if err != nil {
		return Share{}, err
	}
	return s.describedShare(ctx, owner, id)
}

func requireFuture(moment *time.Time) error {
	if moment != nil && !moment.After(time.Now()) {
		return apperr.Invalid("expiry must be in the future")
	}
	return nil
}

func cleanNote(raw string) (string, error) {
	note := strings.TrimSpace(raw)
	if utf8.RuneCountInString(note) > maxNoteLength {
		return "", apperr.Invalid("note is too long")
	}
	return note, nil
}

func (s *Service) validateRecipient(ctx context.Context, owner users.User, recipient RecipientRef) error {
	switch recipient.Kind {
	case RecipientUser:
		if recipient.ID == owner.ID {
			return apperr.Invalid("they already have this item")
		}
		user, err := s.users.ByID(ctx, recipient.ID)
		if err != nil || user.Disabled {
			return apperr.Invalid("no such user")
		}
	case RecipientGroup:
		role, member, err := s.groups.RoleOf(ctx, recipient.ID, owner.ID)
		if err != nil {
			return err
		}
		if !member || !role.CanShare() {
			return apperr.Forbidden("you cannot share with this group")
		}
	default:
		return apperr.Invalid("recipient kind must be %q or %q", RecipientUser, RecipientGroup)
	}
	return nil
}

func (s *Service) UpdateShare(ctx context.Context, owner users.User, id int64, changes ShareChanges) (Share, error) {
	row, err := shareByID(ctx, s.db, id)
	if err != nil {
		return Share{}, err
	}
	if owner.ID != row.OwnerID {
		return Share{}, notAvailable()
	}
	if changes.Permissions != nil {
		root, err := s.files.EntryByID(ctx, owner.ID, row.FileID)
		if err != nil {
			return Share{}, notAvailable()
		}
		row.Permissions = changes.Permissions.forEntry(root.IsDir)
	}
	switch {
	case changes.RemoveExpiry:
		row.ExpiresAt = nil
	case changes.ExpiresAt != nil:
		if err := requireFuture(changes.ExpiresAt); err != nil {
			return Share{}, err
		}
		row.ExpiresAt = changes.ExpiresAt
	}
	if changes.Note != nil {
		if row.Note, err = cleanNote(*changes.Note); err != nil {
			return Share{}, err
		}
	}
	if err := updateShare(ctx, s.db, row); err != nil {
		return Share{}, err
	}
	return s.describedShare(ctx, owner, id)
}

func (s *Service) RemoveShare(ctx context.Context, actor users.User, id int64) error {
	row, err := shareByID(ctx, s.db, id)
	if err != nil {
		return err
	}
	lookup := recipientNames{service: s, ctx: ctx}
	if !lookup.canRemove(actor, row) {
		if row.RecipientGroupID != 0 && s.isMember(ctx, row.RecipientGroupID, actor.ID) {
			return apperr.Forbidden("only the owner or the group's admins can remove this")
		}
		return notAvailable()
	}
	return database.RequireAffected(notAvailable())(s.db.ExecContext(ctx, `DELETE FROM shares WHERE id = $1`, id))
}

func (s *Service) isMember(ctx context.Context, groupID, userID int64) bool {
	_, member, err := s.groups.RoleOf(ctx, groupID, userID)
	return err == nil && member
}

func (s *Service) Outgoing(ctx context.Context, owner users.User, fileID int64) ([]Share, error) {
	query, args := ownedQuery(owner.ID, fileID)
	rows, err := queryShares(ctx, s.db, query, args...)
	if err != nil {
		return nil, err
	}
	return s.describe(ctx, owner, rows)
}

func (s *Service) GroupShares(ctx context.Context, actor users.User, groupID int64) ([]Share, error) {
	if _, err := s.groups.Details(ctx, actor, groupID); err != nil {
		return nil, err
	}
	rows, err := queryShares(ctx, s.db, `WHERE recipient_group_id = $1 ORDER BY created_at DESC, id DESC`, groupID)
	if err != nil {
		return nil, err
	}
	return s.describe(ctx, actor, rows)
}

func (s *Service) describedShare(ctx context.Context, actor users.User, id int64) (Share, error) {
	row, err := shareByID(ctx, s.db, id)
	if err != nil {
		return Share{}, err
	}
	described, err := s.describe(ctx, actor, []shareRow{row})
	if err != nil {
		return Share{}, err
	}
	if len(described) == 0 {
		return Share{}, notAvailable()
	}
	return described[0], nil
}

func (s *Service) describe(ctx context.Context, actor users.User, rows []shareRow) ([]Share, error) {
	byOwner := map[int64][]int64{}
	for _, row := range rows {
		byOwner[row.OwnerID] = append(byOwner[row.OwnerID], row.FileID)
	}
	entries := map[int64]map[int64]files.Entry{}
	for ownerID, ids := range byOwner {
		found, err := s.files.EntriesByID(ctx, ownerID, ids)
		if err != nil {
			return nil, err
		}
		entries[ownerID] = found
	}
	lookup := recipientNames{service: s, ctx: ctx}
	now := time.Now()
	list := []Share{}
	for _, row := range rows {
		recipient, ok := lookup.describe(row.recipient())
		owner := lookup.user(row.OwnerID)
		if !ok || owner == nil {
			continue
		}
		entry, available := entries[row.OwnerID][row.FileID]
		file := FileSummary{ID: row.FileID}
		if available {
			file = summarize(entry)
			if actor.ID != row.OwnerID {
				file.Path = ""
			}
		}
		list = append(list, Share{
			ID: row.ID, File: file, Owner: owner.Summary(), Recipient: recipient,
			Permissions: row.Permissions, ExpiresAt: row.ExpiresAt, Note: row.Note,
			Available: available && !expired(row.ExpiresAt, now),
			CanChange: actor.ID == row.OwnerID,
			CanRemove: lookup.canRemove(actor, row),
			CreatedAt: row.CreatedAt,
		})
	}
	return list, nil
}

func (s *Service) Incoming(ctx context.Context, user users.User) ([]IncomingShare, error) {
	rows, err := s.reachingShares(ctx, user, "")
	if err != nil {
		return nil, err
	}
	lookup := recipientNames{service: s, ctx: ctx}
	list := []IncomingShare{}
	for _, item := range s.reachedItems(ctx, user, rows) {
		access := item.access()
		_, direct := item.direct()
		list = append(list, IncomingShare{
			ID: item.primary().row.ID, Owner: access.Owner.Summary(), Direct: direct, Groups: item.groups(&lookup),
			Permissions: access.Permissions(), ExpiresAt: access.ExpiresAt, Note: item.note(),
			Entry: access.Relative(access.Root), CreatedAt: item.createdAt(),
		})
	}
	return list, nil
}

func (s *Service) reachingShares(ctx context.Context, user users.User, extra string, args ...any) ([]shareRow, error) {
	return queryShares(ctx, s.db, `WHERE owner_id <> $1 AND (recipient_user_id = $1
		OR recipient_group_id IN (SELECT group_id FROM group_members WHERE user_id = $1))`+extra+` ORDER BY created_at DESC, id DESC`,
		append([]any{user.ID}, args...)...)
}

func (s *Service) ForRecipient(ctx context.Context, user users.User, shareID int64) (Access, error) {
	row, err := shareByID(ctx, s.db, shareID)
	if err != nil {
		return Access{}, err
	}
	rows, err := s.reachingShares(ctx, user, ` AND file_id = $2`, row.FileID)
	if err != nil {
		return Access{}, err
	}
	items := s.reachedItems(ctx, user, rows)
	if len(items) == 0 {
		return Access{}, notAvailable()
	}
	return items[0].access(), nil
}

func (s *Service) resolve(ctx context.Context, row shareRow, user users.User) (Access, error) {
	if expired(row.ExpiresAt, time.Now()) || (row.RecipientUserID != 0 && row.RecipientUserID != user.ID) {
		return Access{}, notAvailable()
	}
	owner, root, err := s.ownedEntry(ctx, row.OwnerID, row.FileID)
	if err != nil {
		return Access{}, err
	}
	permissions := row.Permissions.forEntry(root.IsDir)
	if row.RecipientGroupID != 0 {
		role, member, err := s.groups.RoleOf(ctx, row.RecipientGroupID, user.ID)
		if err != nil || !member {
			return Access{}, notAvailable()
		}
		if role == groups.RoleViewer {
			permissions = SharePermissions{}
		}
	}
	return Access{
		Owner: owner, Root: root, CanRead: true, CanDownload: true,
		CanCreate: permissions.Create, CanEdit: permissions.Edit, CanDelete: permissions.Delete,
		ExpiresAt: row.ExpiresAt, Via: user.Username,
	}, nil
}

func (s *Service) ownedEntry(ctx context.Context, ownerID, fileID int64) (users.User, files.Entry, error) {
	owner, err := s.users.ByID(ctx, ownerID)
	if err != nil || owner.Disabled {
		return users.User{}, files.Entry{}, notAvailable()
	}
	root, err := s.files.EntryByID(ctx, owner.ID, fileID)
	if err != nil {
		return users.User{}, files.Entry{}, notAvailable()
	}
	return owner, root, nil
}

func (s *Service) FileMutation(ctx context.Context, mutation files.Mutation) {
	if len(mutation.RemovedFileIDs) == 0 {
		return
	}
	for _, table := range []string{"shares", "share_links"} {
		if err := deleteByFileIDs(ctx, s.db, table, mutation.Owner.ID, mutation.RemovedFileIDs); err != nil {
			logger.Warn("remove shares of deleted files", "user", mutation.Owner.Username, "error", err)
		}
	}
}

type recipientNames struct {
	service *Service
	ctx     context.Context
	users   map[int64]*users.User
	groups  map[int64]*groups.Group
	manages map[int64]bool
}

func (n *recipientNames) canRemove(actor users.User, row shareRow) bool {
	if actor.ID == row.OwnerID || actor.ID == row.RecipientUserID {
		return true
	}
	if row.RecipientGroupID == 0 {
		return false
	}
	if n.manages == nil {
		n.manages = map[int64]bool{}
	}
	allowed, cached := n.manages[row.RecipientGroupID]
	if !cached {
		allowed = n.service.groups.CanManage(n.ctx, actor, row.RecipientGroupID)
		n.manages[row.RecipientGroupID] = allowed
	}
	return allowed
}

func (n *recipientNames) describe(ref RecipientRef) (Recipient, bool) {
	if ref.Kind == RecipientGroup {
		group := n.group(ref.ID)
		if group == nil {
			return Recipient{}, false
		}
		return Recipient{Kind: RecipientGroup, ID: group.ID, Name: group.Name}, true
	}
	user := n.user(ref.ID)
	if user == nil {
		return Recipient{}, false
	}
	return Recipient{Kind: RecipientUser, ID: user.ID, Name: user.ShownName(), Username: user.Username, Avatar: user.Avatar}, true
}

func (n *recipientNames) user(id int64) *users.User {
	if n.users == nil {
		n.users = map[int64]*users.User{}
	}
	if cached, ok := n.users[id]; ok {
		return cached
	}
	var found *users.User
	if user, err := n.service.users.ByID(n.ctx, id); err == nil {
		found = &user
	}
	n.users[id] = found
	return found
}

func (n *recipientNames) group(id int64) *groups.Group {
	if n.groups == nil {
		n.groups = map[int64]*groups.Group{}
	}
	if cached, ok := n.groups[id]; ok {
		return cached
	}
	var found *groups.Group
	if group, err := n.service.groups.ByID(n.ctx, id); err == nil {
		found = &group
	}
	n.groups[id] = found
	return found
}
