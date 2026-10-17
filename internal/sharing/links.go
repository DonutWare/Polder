package sharing

import (
	"context"
	"database/sql"
	"errors"
	"strconv"
	"strings"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
	"polder-server/internal/files"
	"polder-server/internal/logging"
	"polder-server/internal/storage"
	"polder-server/internal/users"
)

var logger = logging.For("sharing")

const (
	maxPasswordLength = 256
	codeAttempts      = 5
	linkColumns       = `SELECT id, code, owner_id, file_id, allow_view, allow_download, allow_upload, password_hash, expires_at, generation, created_at FROM share_links`
)

type LinkPermissions struct {
	View     bool `json:"view" doc:"Visitors can browse the folder and see previews"`
	Download bool `json:"download" doc:"Visitors can download files and folders; needs view"`
	Upload   bool `json:"upload" doc:"Visitors can add files to a folder; they never replace existing files"`
}

func (p LinkPermissions) validate(isDir bool) error {
	switch {
	case !p.View && !p.Upload:
		return apperr.Invalid("a link must let visitors view or upload")
	case p.Download && !p.View:
		return apperr.Invalid("downloading needs viewing")
	case p.Upload && !isDir:
		return apperr.Invalid("only links to folders can accept uploads")
	}
	return nil
}

type LinkPermissionChanges struct {
	View     *bool `json:"view,omitempty" required:"false"`
	Download *bool `json:"download,omitempty" required:"false"`
	Upload   *bool `json:"upload,omitempty" required:"false"`
}

func (c LinkPermissionChanges) applyTo(current LinkPermissions) LinkPermissions {
	for _, change := range []struct {
		value  *bool
		target *bool
	}{{c.View, &current.View}, {c.Download, &current.Download}, {c.Upload, &current.Upload}} {
		if change.value != nil {
			*change.target = *change.value
		}
	}
	return current
}

type ShareLink struct {
	ID          int64           `json:"id"`
	Code        string          `json:"code" doc:"Short code the link URL ends in, as in /share/<code>"`
	File        FileSummary     `json:"file"`
	Permissions LinkPermissions `json:"permissions"`
	HasPassword bool            `json:"hasPassword"`
	ExpiresAt   *time.Time      `json:"expiresAt,omitempty" required:"false" doc:"After this the link stops working; absent when it never expires"`
	Available   bool            `json:"available" doc:"False while the linked item is in the trash"`
	CreatedAt   time.Time       `json:"createdAt"`
}

type NewShareLink struct {
	FileID      int64            `json:"fileId"`
	Permissions *LinkPermissions `json:"permissions,omitempty" required:"false" doc:"What visitors may do; absent lets them view and download"`
	Password    *string          `json:"password,omitempty" required:"false" maxLength:"256" doc:"Visitors must enter it before they see anything; absent or empty for no password"`
	ExpiresAt   *time.Time       `json:"expiresAt,omitempty" required:"false" doc:"When the link stops working; absent for never"`
}

type LinkChanges struct {
	Permissions    *LinkPermissionChanges `json:"permissions,omitempty" required:"false"`
	Password       *string                `json:"password,omitempty" required:"false" maxLength:"256" doc:"A new password; visitors who unlocked the link must enter it again"`
	RemovePassword bool                   `json:"removePassword,omitempty" required:"false"`
	ExpiresAt      *time.Time             `json:"expiresAt,omitempty" required:"false"`
	RemoveExpiry   bool                   `json:"removeExpiry,omitempty" required:"false"`
}

type LinkInfo struct {
	NeedsPassword bool               `json:"needsPassword" doc:"The name, owner and contents stay hidden until the link is unlocked with its password"`
	Permissions   LinkPermissions    `json:"permissions"`
	ExpiresAt     *time.Time         `json:"expiresAt,omitempty" required:"false"`
	Name          string             `json:"name,omitempty" required:"false"`
	IsDir         bool               `json:"isDir,omitempty" required:"false"`
	Owner         *users.UserSummary `json:"owner,omitempty" required:"false"`
}

type LinkUnlock struct {
	Token     string      `json:"token" doc:"Send as the X-Polder-Share-Token header, or as the token query parameter for downloads in a browser"`
	ExpiresAt time.Time   `json:"expiresAt" doc:"Unlock again after this"`
	Info      LinkInfo    `json:"info"`
	Root      files.Entry `json:"root" doc:"The linked item; its path is /"`
}

type LinkMatch struct {
	OwnPath *string `json:"ownPath,omitempty" required:"false" doc:"Set when the link is the user's own: where the item is in their storage"`
	ShareID *int64  `json:"shareId,omitempty" required:"false" doc:"Set when the item is in something shared with the user"`
	Path    *string `json:"path,omitempty" required:"false" doc:"With shareId: where the item is inside that share"`
}

type linkRow struct {
	ID           int64
	Code         string
	OwnerID      int64
	FileID       int64
	Permissions  LinkPermissions
	PasswordHash string
	ExpiresAt    *time.Time
	Generation   int64
	CreatedAt    time.Time
}

func scanLink(row database.RowScanner) (linkRow, error) {
	var link linkRow
	var passwordHash sql.NullString
	var expiresAt sql.NullInt64
	var createdAt int64
	err := row.Scan(&link.ID, &link.Code, &link.OwnerID, &link.FileID, &link.Permissions.View, &link.Permissions.Download, &link.Permissions.Upload, &passwordHash, &expiresAt, &link.Generation, &createdAt)
	link.PasswordHash = passwordHash.String
	link.ExpiresAt = optionalTime(expiresAt)
	link.CreatedAt = time.Unix(createdAt, 0).UTC()
	return link, err
}

func (s *Service) linkWhere(ctx context.Context, condition string, args ...any) (linkRow, error) {
	link, err := scanLink(s.db.QueryRowContext(ctx, linkColumns+` WHERE `+condition, args...))
	if errors.Is(err, sql.ErrNoRows) {
		return linkRow{}, linkNotFound()
	}
	return link, err
}

func (s *Service) linkByCode(ctx context.Context, code string) (linkRow, error) {
	if !validCode(code) {
		return linkRow{}, linkNotFound()
	}
	link, err := s.linkWhere(ctx, `code = $1`, code)
	if err != nil {
		return linkRow{}, err
	}
	if expired(link.ExpiresAt, time.Now()) {
		return linkRow{}, linkNotFound()
	}
	return link, nil
}

func linkNotFound() error {
	return apperr.NotFound("this link does not exist or has expired")
}

func (s *Service) Links(ctx context.Context, owner users.User, fileID int64) ([]ShareLink, error) {
	query, args := ownedQuery(owner.ID, fileID)
	links, err := database.QueryAll(ctx, s.db, scanLink, linkColumns+" "+query, args...)
	if err != nil {
		return nil, err
	}
	return s.describeLinks(ctx, owner, links)
}

func (s *Service) describeLinks(ctx context.Context, owner users.User, rows []linkRow) ([]ShareLink, error) {
	fileIDs := make([]int64, 0, len(rows))
	for _, row := range rows {
		fileIDs = append(fileIDs, row.FileID)
	}
	entries, err := s.files.EntriesByID(ctx, owner.ID, fileIDs)
	if err != nil {
		return nil, err
	}
	list := []ShareLink{}
	for _, row := range rows {
		entry, available := entries[row.FileID]
		file := FileSummary{ID: row.FileID}
		if available {
			file = summarize(entry)
		}
		list = append(list, ShareLink{
			ID: row.ID, Code: row.Code, File: file, Permissions: row.Permissions, HasPassword: row.PasswordHash != "",
			ExpiresAt: row.ExpiresAt, Available: available, CreatedAt: row.CreatedAt,
		})
	}
	return list, nil
}

func (s *Service) ownLink(ctx context.Context, owner users.User, id int64) (ShareLink, error) {
	row, err := s.linkWhere(ctx, `id = $1 AND owner_id = $2`, id, owner.ID)
	if err != nil {
		return ShareLink{}, err
	}
	described, err := s.describeLinks(ctx, owner, []linkRow{row})
	if err != nil {
		return ShareLink{}, err
	}
	return described[0], nil
}

func (s *Service) CreateLink(ctx context.Context, owner users.User, request NewShareLink) (ShareLink, error) {
	permissions := LinkPermissions{View: true, Download: true}
	if request.Permissions != nil {
		permissions = *request.Permissions
	}
	entry, err := s.files.EntryByID(ctx, owner.ID, request.FileID)
	if err != nil {
		return ShareLink{}, err
	}
	if err := permissions.validate(entry.IsDir); err != nil {
		return ShareLink{}, err
	}
	passwordHash, err := s.hashPassword(request.Password)
	if err != nil {
		return ShareLink{}, err
	}
	if err := requireFuture(request.ExpiresAt); err != nil {
		return ShareLink{}, err
	}
	now := time.Now().Unix()
	for range codeAttempts {
		code, err := newCode()
		if err != nil {
			return ShareLink{}, err
		}
		var id int64
		err = s.db.QueryRowContext(ctx,
			`INSERT INTO share_links (code, owner_id, file_id, allow_view, allow_download, allow_upload, password_hash, expires_at, generation, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 1, $9, $9) RETURNING id`,
			code, owner.ID, entry.ID, permissions.View, permissions.Download, permissions.Upload, passwordHash, unixOrNil(request.ExpiresAt), now).Scan(&id)
		if database.IsUniqueViolation(err) {
			continue
		}
		if err != nil {
			return ShareLink{}, err
		}
		return s.ownLink(ctx, owner, id)
	}
	return ShareLink{}, errors.New("could not find a free link code")
}

func (s *Service) hashPassword(password *string) (any, error) {
	if password == nil || *password == "" {
		return nil, nil
	}
	if len(*password) > maxPasswordLength {
		return nil, apperr.Invalid("password is too long")
	}
	return s.hasher.Hash(*password)
}

func (s *Service) UpdateLink(ctx context.Context, owner users.User, id int64, changes LinkChanges) (ShareLink, error) {
	current, err := s.linkWhere(ctx, `id = $1 AND owner_id = $2`, id, owner.ID)
	if err != nil {
		return ShareLink{}, err
	}
	var assignments []string
	var args []any
	set := func(column string, value any) {
		args = append(args, value)
		assignments = append(assignments, column+" = $"+strconv.Itoa(len(args)))
	}
	revoke := false
	if changes.Permissions != nil {
		entry, err := s.files.EntryByID(ctx, owner.ID, current.FileID)
		if err != nil {
			return ShareLink{}, err
		}
		permissions := changes.Permissions.applyTo(current.Permissions)
		if err := permissions.validate(entry.IsDir); err != nil {
			return ShareLink{}, err
		}
		set("allow_view", permissions.View)
		set("allow_download", permissions.Download)
		set("allow_upload", permissions.Upload)
		revoke = revoke || permissions != current.Permissions
	}
	switch {
	case changes.RemovePassword:
		set("password_hash", nil)
	case changes.Password != nil:
		passwordHash, err := s.hashPassword(changes.Password)
		if err != nil {
			return ShareLink{}, err
		}
		set("password_hash", passwordHash)
		revoke = true
	}
	switch {
	case changes.RemoveExpiry:
		set("expires_at", nil)
	case changes.ExpiresAt != nil:
		if err := requireFuture(changes.ExpiresAt); err != nil {
			return ShareLink{}, err
		}
		set("expires_at", unixOrNil(changes.ExpiresAt))
	}
	if revoke {
		set("generation", current.Generation+1)
	}
	if len(assignments) > 0 {
		set("updated_at", time.Now().Unix())
		args = append(args, id)
		query := `UPDATE share_links SET ` + strings.Join(assignments, ", ") + ` WHERE id = $` + strconv.Itoa(len(args))
		if _, err := s.db.ExecContext(ctx, query, args...); err != nil {
			return ShareLink{}, err
		}
	}
	return s.ownLink(ctx, owner, id)
}

func (s *Service) RemoveLink(ctx context.Context, owner users.User, id int64) error {
	return database.RequireAffected(linkNotFound())(s.db.ExecContext(ctx, `DELETE FROM share_links WHERE id = $1 AND owner_id = $2`, id, owner.ID))
}

func (s *Service) linkTarget(ctx context.Context, link linkRow) (users.User, files.Entry, error) {
	owner, root, err := s.ownedEntry(ctx, link.OwnerID, link.FileID)
	if err != nil {
		return users.User{}, files.Entry{}, linkNotFound()
	}
	return owner, root, nil
}

func (s *Service) PublicInfo(ctx context.Context, code string) (LinkInfo, error) {
	link, err := s.linkByCode(ctx, code)
	if err != nil {
		return LinkInfo{}, err
	}
	owner, root, err := s.linkTarget(ctx, link)
	if err != nil {
		return LinkInfo{}, err
	}
	return linkInfo(link, owner, root, link.PasswordHash == ""), nil
}

func linkInfo(link linkRow, owner users.User, root files.Entry, reveal bool) LinkInfo {
	info := LinkInfo{NeedsPassword: link.PasswordHash != "", Permissions: link.Permissions, ExpiresAt: link.ExpiresAt}
	if reveal {
		summary := owner.Summary()
		info.Name, info.IsDir, info.Owner = root.Name, root.IsDir, &summary
	}
	return info
}

func (s *Service) Unlock(ctx context.Context, code, password string) (LinkUnlock, error) {
	link, err := s.linkByCode(ctx, code)
	if err != nil {
		return LinkUnlock{}, err
	}
	owner, root, err := s.linkTarget(ctx, link)
	if err != nil {
		return LinkUnlock{}, err
	}
	if link.PasswordHash != "" && !s.hasher.Verify(password, link.PasswordHash) {
		return LinkUnlock{}, apperr.Unauthorized("wrong password")
	}
	token, expiresAt, err := s.tokens.issue(link)
	if err != nil {
		return LinkUnlock{}, err
	}
	access := linkAccess(link, owner, root)
	return LinkUnlock{Token: token, ExpiresAt: expiresAt, Info: linkInfo(link, owner, root, true), Root: access.Relative(root)}, nil
}

func (s *Service) ForLink(ctx context.Context, code, token string) (Access, error) {
	link, err := s.linkByCode(ctx, code)
	if err != nil {
		return Access{}, err
	}
	grant, err := s.tokens.parse(token)
	if err != nil || grant.LinkID != link.ID || grant.Code != link.Code || grant.Generation != link.Generation {
		return Access{}, apperr.Unauthorized("unlock the link first")
	}
	owner, root, err := s.linkTarget(ctx, link)
	if err != nil {
		return Access{}, err
	}
	return linkAccess(link, owner, root), nil
}

func linkAccess(link linkRow, owner users.User, root files.Entry) Access {
	return Access{
		Owner: owner, Root: root,
		CanRead:     link.Permissions.View,
		CanDownload: link.Permissions.Download,
		CanDrop:     link.Permissions.Upload,
		Via:         "link:" + link.Code,
	}
}

func (s *Service) MatchLink(ctx context.Context, user users.User, code string) (LinkMatch, error) {
	link, err := s.linkByCode(ctx, code)
	if err != nil {
		return LinkMatch{}, err
	}
	_, target, err := s.linkTarget(ctx, link)
	if err != nil {
		return LinkMatch{}, err
	}
	if link.OwnerID == user.ID {
		return LinkMatch{OwnPath: &target.Path}, nil
	}
	rows, err := s.reachingShares(ctx, user, ` AND owner_id = $2`, link.OwnerID)
	if err != nil {
		return LinkMatch{}, err
	}
	var best *Access
	var bestID int64
	for _, item := range s.reachedItems(ctx, user, rows) {
		access := item.access()
		if !storage.IsSameOrDescendant(target.Path, access.Root.Path) {
			continue
		}
		if best == nil || len(access.Root.Path) > len(best.Root.Path) {
			best, bestID = &access, item.primary().row.ID
		}
	}
	if best == nil {
		return LinkMatch{}, linkNotFound()
	}
	relative := best.RelativePath(target.Path)
	return LinkMatch{ShareID: &bestID, Path: &relative}, nil
}
