package httpapi

import (
	"cmp"
	"context"
	"errors"
	"fmt"
	"io"
	"net/http"
	"path"
	"slices"
	"strings"
	"time"

	"github.com/danielgtaylor/huma/v2"
	"github.com/danielgtaylor/huma/v2/adapters/humachi"

	"polder-server/internal/apperr"
	"polder-server/internal/federation"
	"polder-server/internal/files"
	"polder-server/internal/sharing"
	"polder-server/internal/storage"
	"polder-server/internal/users"
)

type mountedPath struct {
	mount    files.Mount
	relative string
}

func (m mountedPath) federated() bool {
	return m.mount.Kind == files.MountFederated
}

func (m mountedPath) outer(relative string) string {
	if relative == storage.RootPath {
		return m.mount.Path
	}
	return m.mount.Path + relative
}

func (m mountedPath) entry(inner files.Entry) files.Entry {
	if inner.Path == storage.RootPath {
		inner.Name = path.Base(m.mount.Path)
	}
	inner.Path = m.outer(inner.Path)
	mount := m.mount
	inner.Mount = &mount
	return inner
}

func (m mountedPath) remoteEntry(remote federation.RemoteEntry) files.Entry {
	mime := remote.Mime
	if remote.IsDir {
		mime = files.DirectoryMime
	}
	return m.entry(files.Entry{
		Path: remote.Path, Name: remote.Name, IsDir: remote.IsDir, Size: remote.Size, Mtime: remote.Mtime, Rev: remote.Rev,
		Hash: remote.ETag, Mime: mime, Meta: map[string]any{}, PreviewState: files.PreviewNone,
	})
}

func (m mountedPath) remoteConflict(err error) error {
	var appErr *apperr.Error
	if !errors.As(err, &appErr) {
		return err
	}
	if current, ok := appErr.Current.(federation.RemoteEntry); ok {
		translated := *appErr
		translated.Current = m.remoteEntry(current)
		return &translated
	}
	return err
}

func (a *API) mounts(ctx context.Context, user users.User) ([]files.Mount, error) {
	placed, err := a.placeMounts(ctx, user)
	mounts := make([]files.Mount, 0, len(placed))
	for _, share := range placed {
		mounts = append(mounts, share.mount)
	}
	return mounts, err
}

func (a *API) visibleMounts(ctx context.Context, user users.User) ([]incomingMount, error) {
	hidden, err := a.users.Store().HidesSharesInFiles(ctx, user.ID)
	if err != nil || hidden {
		return nil, err
	}
	return a.placeMounts(ctx, user)
}

func (a *API) placeMounts(ctx context.Context, user users.User) ([]incomingMount, error) {
	candidates, err := a.incomingMounts(ctx, user)
	if err != nil || len(candidates) == 0 {
		return nil, err
	}
	_, own, err := a.files.List(ctx, user, storage.RootPath)
	if err != nil {
		return nil, err
	}
	taken := make(map[string]bool, len(own)+len(candidates))
	for _, entry := range own {
		taken[strings.ToLower(entry.Name)] = true
	}
	slices.SortStableFunc(candidates, func(x, y incomingMount) int {
		return cmp.Or(x.mount.SharedAt.Compare(y.mount.SharedAt), cmp.Compare(x.mount.Kind, y.mount.Kind), cmp.Compare(x.mount.ShareID, y.mount.ShareID))
	})
	for i := range candidates {
		name := uniqueMountName(candidates[i].name, candidates[i].mount.IsDir, taken)
		taken[strings.ToLower(name)] = true
		candidates[i].mount.Path = "/" + name
	}
	return candidates, nil
}

type incomingMount struct {
	mount files.Mount
	name  string
	size  int64
	mtime time.Time
}

func (a *API) incomingMounts(ctx context.Context, user users.User) ([]incomingMount, error) {
	incoming, err := a.sharing.Incoming(ctx, user)
	if err != nil {
		return nil, err
	}
	candidates := make([]incomingMount, 0, len(incoming))
	for _, share := range incoming {
		candidates = append(candidates, incomingMount{name: share.Entry.Name, mount: localMount(share)})
	}
	if a.federation == nil || !a.federation.Enabled(ctx) {
		return candidates, nil
	}
	federated, err := a.federation.Incoming(ctx, user)
	if err != nil {
		return nil, err
	}
	for _, share := range federated {
		if share.State == federation.StateAccepted {
			candidate := incomingMount{name: share.Name, mount: federatedMount(share), size: share.Size}
			if share.Mtime != nil {
				candidate.mtime = *share.Mtime
			}
			candidates = append(candidates, candidate)
		}
	}
	return candidates, nil
}

func localMount(share sharing.IncomingShare) files.Mount {
	groups := make([]string, 0, len(share.Groups))
	for _, group := range share.Groups {
		groups = append(groups, group.Name)
	}
	return files.Mount{
		Kind: files.MountShare, ShareID: share.ID, IsDir: share.Entry.IsDir, CanLeave: share.Direct, Owner: share.Owner.Username, OwnerName: share.Owner.DisplayName, Groups: groups,
		Permissions: mountPermissions(share.Permissions), Note: share.Note, ExpiresAt: share.ExpiresAt, SharedAt: share.CreatedAt,
	}
}

func federatedMount(share federation.IncomingFederatedShare) files.Mount {
	return files.Mount{
		Kind: files.MountFederated, ShareID: share.ID, IsDir: share.IsDir, CanLeave: true, Owner: share.Owner, OwnerName: share.OwnerName, Server: share.Server,
		Provider: share.Provider, Permissions: mountPermissions(share.Permissions), SharedAt: share.CreatedAt,
	}
}

func mountPermissions(permissions sharing.SharePermissions) files.MountPermissions {
	return files.MountPermissions{Create: permissions.Create, Edit: permissions.Edit, Delete: permissions.Delete}
}

func uniqueMountName(wanted string, isDir bool, taken map[string]bool) string {
	name := strings.TrimSpace(strings.ReplaceAll(wanted, "/", "-"))
	if name == "" || name == "." || name == ".." {
		name = "Shared"
	}
	extension := ""
	if !isDir {
		extension = path.Ext(name)
		if extension == name {
			extension = ""
		}
	}
	stem := strings.TrimSuffix(name, extension)
	candidate := name
	for attempt := 2; taken[strings.ToLower(candidate)]; attempt++ {
		candidate = fmt.Sprintf("%s (%d)%s", stem, attempt, extension)
	}
	return candidate
}

func (a *API) mountAt(ctx context.Context, user users.User, raw string) (*mountedPath, error) {
	clean, err := storage.CleanPath(raw)
	if err != nil || clean == storage.RootPath {
		return nil, nil
	}
	top, rest, _ := strings.Cut(strings.TrimPrefix(clean, "/"), "/")
	if _, err := a.files.Stat(ctx, user, "/"+top); err == nil {
		return nil, nil
	} else if !apperr.Is(err, apperr.KindNotFound) {
		return nil, err
	}
	mounts, err := a.mounts(ctx, user)
	if err != nil {
		return nil, err
	}
	for _, mount := range mounts {
		if mount.Path == "/"+top {
			return &mountedPath{mount: mount, relative: "/" + rest}, nil
		}
	}
	return nil, nil
}

func (a *API) transferMount(ctx context.Context, user users.User, from, to string) (*mountedPath, error) {
	source, err := a.mountAt(ctx, user, from)
	if err != nil {
		return nil, err
	}
	target, err := a.mountAt(ctx, user, to)
	if err != nil {
		return nil, err
	}
	switch {
	case source == nil && target == nil:
		return nil, nil
	case source != nil && target != nil && source.mount.Kind == target.mount.Kind && source.mount.ShareID == target.mount.ShareID:
		return source, nil
	}
	return nil, apperr.Invalid("moving or copying between your files and a share is not supported; download and upload instead")
}

func (a *API) listMounted(ctx context.Context, at mountedPath) (*jsonBody[listResponse], error) {
	if at.federated() {
		item, children, err := a.federation.RemoteList(ctx, currentUser(ctx), at.mount.ShareID, at.relative)
		if err != nil {
			return nil, err
		}
		entries := make([]files.Entry, 0, len(children))
		for _, child := range children {
			entries = append(entries, at.remoteEntry(child))
		}
		return respond(listResponse{Path: at.outer(item.Path), Entries: entries, Mount: &at.mount}), nil
	}
	ctx, access, err := a.recipientAccess(ctx, at.mount.ShareID)
	if err != nil {
		return nil, err
	}
	listed, err := a.spaceList(ctx, access, at.relative)
	if err != nil {
		return nil, err
	}
	for i, entry := range listed.Body.Entries {
		listed.Body.Entries[i] = at.entry(entry)
	}
	listed.Body.Path = at.outer(listed.Body.Path)
	listed.Body.Mount = &at.mount
	if err := a.attachTags(ctx, listed.Body.Entries); err != nil {
		return nil, err
	}
	return listed, nil
}

func (a *API) statMounted(ctx context.Context, at mountedPath) (files.Entry, error) {
	if at.federated() {
		entry, err := a.federation.RemoteStat(ctx, currentUser(ctx), at.mount.ShareID, at.relative)
		if err != nil {
			return files.Entry{}, err
		}
		return at.remoteEntry(entry), nil
	}
	ctx, access, err := a.recipientAccess(ctx, at.mount.ShareID)
	if err != nil {
		return files.Entry{}, err
	}
	entry, err := a.spaceStat(ctx, access, at.relative)
	if err != nil {
		return files.Entry{}, err
	}
	return at.entry(entry.Body), nil
}

func (a *API) downloadMounted(ctx context.Context, at mountedPath, input *downloadInput) (_ *downloadOutput, err error) {
	if at.federated() {
		return a.downloadRemote(ctx, at, input)
	}
	ctx, access, err := a.recipientAccess(ctx, at.mount.ShareID)
	if err != nil {
		return nil, err
	}
	defer access.Scrub(&err)
	if err = access.RequireDownload(); err != nil {
		return nil, err
	}
	absolute, err := access.Path(at.relative)
	if err != nil {
		return nil, err
	}
	file, entry, err := a.files.Open(ctx, access.Owner, absolute)
	if err != nil {
		return nil, err
	}
	return &downloadOutput{
		CacheControl: "no-cache",
		ETag:         revisionETag(entry.Rev),
		Rev:          fmt.Sprint(entry.Rev),
		ContentType:  entry.Mime,
		Body:         a.serveFile(ctx, access.Owner, file, entry, input.Range != ""),
	}, nil
}

func (a *API) downloadRemote(ctx context.Context, at mountedPath, input *downloadInput) (*downloadOutput, error) {
	content, err := a.federation.RemoteOpen(ctx, currentUser(ctx), at.mount.ShareID, at.relative, input.Range, input.IfNoneMatch)
	if err != nil {
		return nil, err
	}
	return &downloadOutput{
		CacheControl: "no-cache",
		ETag:         content.ETag,
		ContentType:  content.Mime,
		Body: func(humaCtx huma.Context) {
			defer content.Body.Close()
			_, w := humachi.Unwrap(humaCtx)
			for name, value := range map[string]string{
				"Content-Length": content.ContentLength, "Content-Range": content.ContentRange, "Last-Modified": content.LastModified,
			} {
				if value != "" {
					w.Header().Set(name, value)
				}
			}
			w.Header().Set("X-Content-Type-Options", "nosniff")
			w.Header().Set("Content-Security-Policy", sandboxPolicy)
			w.WriteHeader(content.Status)
			if content.Status == http.StatusNotModified {
				return
			}
			if _, err := io.Copy(w, content.Body); err != nil {
				federationLog.Debug("stream a mounted federated file", "error", err)
			}
		},
	}, nil
}

func (a *API) uploadMounted(ctx context.Context, at mountedPath, input *uploadInput) (*jsonBody[files.Entry], error) {
	if at.federated() {
		if input.size == nil {
			return nil, apperr.Invalid("uploads into a share from another server need a Content-Length")
		}
		err := a.federation.RemoteWrite(ctx, currentUser(ctx), at.mount.ShareID, at.relative, input.content, *input.size, input.BaseRev)
		if err != nil {
			return nil, at.remoteConflict(err)
		}
		return a.respondMounted(ctx, at)
	}
	ctx, access, err := a.recipientAccess(ctx, at.mount.ShareID)
	if err != nil {
		return nil, err
	}
	written, err := a.spaceWrite(ctx, access, writeTarget{
		path: at.relative, baseRev: input.BaseRev, mtime: input.Mtime, content: input.content, size: input.size, client: input.TransferID,
	})
	if err != nil {
		return nil, err
	}
	return respond(at.entry(written.Body)), nil
}

func (a *API) mkdirMounted(ctx context.Context, at mountedPath) (*jsonBody[files.Entry], error) {
	if at.federated() {
		if err := a.federation.RemoteMkdir(ctx, currentUser(ctx), at.mount.ShareID, at.relative); err != nil {
			return nil, err
		}
		return a.respondMounted(ctx, at)
	}
	ctx, access, err := a.recipientAccess(ctx, at.mount.ShareID)
	if err != nil {
		return nil, err
	}
	made, err := a.spaceMkdir(ctx, access, at.relative)
	if err != nil {
		return nil, err
	}
	return respond(at.entry(made.Body)), nil
}

func (a *API) moveMounted(ctx context.Context, source mountedPath, to string, baseRev int64, copying bool) (*jsonBody[files.Entry], error) {
	clean, err := storage.CleanPath(to)
	if err != nil {
		return nil, err
	}
	target := mountedPath{mount: source.mount, relative: cmp.Or(strings.TrimPrefix(clean, source.mount.Path), storage.RootPath)}
	if source.federated() {
		if err := a.federation.RemoteMove(ctx, currentUser(ctx), source.mount.ShareID, source.relative, target.relative, copying); err != nil {
			return nil, err
		}
		return a.respondMounted(ctx, target)
	}
	ctx, access, err := a.recipientAccess(ctx, source.mount.ShareID)
	if err != nil {
		return nil, err
	}
	moved, err := a.spaceMove(ctx, access, moveRequest{From: source.relative, To: target.relative, BaseRev: baseRev}, copying)
	if err != nil {
		return nil, err
	}
	return respond(source.entry(moved.Body)), nil
}

func (a *API) deleteMounted(ctx context.Context, at mountedPath, baseRev int64) error {
	if clean, err := storage.CleanPath(at.relative); err == nil && clean == storage.RootPath {
		return apperr.Invalid("a share cannot be deleted from your files; leave the share instead")
	}
	if at.federated() {
		return a.federation.RemoteDelete(ctx, currentUser(ctx), at.mount.ShareID, at.relative)
	}
	ctx, access, err := a.recipientAccess(ctx, at.mount.ShareID)
	if err != nil {
		return err
	}
	return a.spaceDelete(ctx, access, at.relative, baseRev)
}

func (a *API) previewMounted(ctx context.Context, at mountedPath, size previewSize) (*previewOutput, error) {
	if at.federated() {
		return nil, apperr.NotFound("no preview available")
	}
	ctx, access, err := a.recipientAccess(ctx, at.mount.ShareID)
	if err != nil {
		return nil, err
	}
	return a.spacePreview(ctx, access, at.relative, size)
}

func (a *API) respondMounted(ctx context.Context, at mountedPath) (*jsonBody[files.Entry], error) {
	entry, err := a.statMounted(ctx, at)
	if err != nil {
		return nil, err
	}
	tagged := []files.Entry{entry}
	if err := a.attachTags(ctx, tagged); err != nil {
		return nil, err
	}
	return respond(tagged[0]), nil
}

func (a *API) mountRootEntries(ctx context.Context, mounts []incomingMount) []files.Entry {
	entries := make([]files.Entry, 0, len(mounts))
	for _, share := range mounts {
		at := mountedPath{mount: share.mount, relative: storage.RootPath}
		if share.mount.Kind == files.MountShare {
			if entry, err := a.statMounted(ctx, at); err == nil {
				entries = append(entries, entry)
				continue
			}
		}
		entries = append(entries, at.rootEntry(share.size, cmp.Or(share.mtime, share.mount.SharedAt)))
	}
	return entries
}

func (m mountedPath) rootEntry(size int64, mtime time.Time) files.Entry {
	mime := files.DirectoryMime
	if !m.mount.IsDir {
		mime = files.MimeFor(m.mount.Path)
	}
	return m.entry(files.Entry{
		Path: storage.RootPath, IsDir: m.mount.IsDir, Size: size, Mime: mime, Meta: map[string]any{}, PreviewState: files.PreviewNone, Mtime: mtime,
	})
}

func (a *API) mountPaths(ctx context.Context, user users.User, kind files.MountKind) (map[int64]string, error) {
	mounts, err := a.mounts(ctx, user)
	if err != nil {
		return nil, err
	}
	paths := make(map[int64]string, len(mounts))
	for _, mount := range mounts {
		if mount.Kind == kind {
			paths[mount.ShareID] = mount.Path
		}
	}
	return paths, nil
}

type shareDisplaySettings struct {
	ShowInFiles bool `json:"showInFiles" doc:"Whether shares appear at the root of the user's files; when off they open only from the shares list"`
}

func (a *API) getShareDisplaySettings(ctx context.Context, _ *struct{}) (*jsonBody[shareDisplaySettings], error) {
	hidden, err := a.users.Store().HidesSharesInFiles(ctx, currentUser(ctx).ID)
	if err != nil {
		return nil, err
	}
	return respond(shareDisplaySettings{ShowInFiles: !hidden}), nil
}

func (a *API) setShareDisplaySettings(ctx context.Context, input *jsonBody[shareDisplaySettings]) (*jsonBody[shareDisplaySettings], error) {
	if err := a.users.Store().SetHidesSharesInFiles(ctx, currentUser(ctx).ID, !input.Body.ShowInFiles); err != nil {
		return nil, err
	}
	return respond(input.Body), nil
}

func (a *API) markShared(ctx context.Context, owner users.User, entries []files.Entry) error {
	ids, err := a.sharing.SharedFileIDs(ctx, owner)
	if err != nil {
		return err
	}
	if a.federation != nil {
		federated, err := a.federation.SharedFileIDs(ctx, owner)
		if err != nil {
			return err
		}
		ids = append(ids, federated...)
	}
	shared := make(map[int64]bool, len(ids))
	for _, id := range ids {
		shared[id] = true
	}
	for i := range entries {
		entries[i].Shared = shared[entries[i].ID]
	}
	return nil
}
