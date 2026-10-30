package httpapi

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/danielgtaylor/huma/v2"
	"github.com/danielgtaylor/huma/v2/adapters/humachi"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/links"
	"polder-server/internal/preview"
	"polder-server/internal/storage"
	"polder-server/internal/users"
)

type listResponse struct {
	Path     string        `json:"path"`
	Entries  []files.Entry `json:"entries"`
	Indexing bool          `json:"indexing" doc:"Files found on disk are still being added, so the listing may be incomplete"`
	Mount    *files.Mount  `json:"mount,omitempty" required:"false" doc:"The share the listed folder is in, when it is inside one"`
}

type pathRequest struct {
	Path string `json:"path"`
}

type moveRequest struct {
	From    string `json:"from"`
	To      string `json:"to"`
	BaseRev int64  `json:"baseRev" required:"false" doc:"Revision the client last saw of the source; 0 or -1 skips the check"`
}

type copyRequest struct {
	From string `json:"from"`
	To   string `json:"to" doc:"Where the copy goes; nothing may exist there yet"`
}

type pathQuery struct {
	Path string `query:"path" doc:"Path inside the user's storage, such as /Photos/cat.jpg; empty means the root"`
}

type downloadInput struct {
	Path        string `query:"path" doc:"Path inside the user's storage, such as /Photos/cat.jpg"`
	Range       string `header:"Range" doc:"Byte range to send, such as bytes=0-1023"`
	IfMatch     string `header:"If-Match" doc:"Fail with 412 unless the file still has this ETag"`
	IfNoneMatch string `header:"If-None-Match" doc:"Answer 304 if the file still has this ETag"`
}

type uploadInput struct {
	Path string `query:"path" doc:"Where to store the file, such as /Photos/cat.jpg"`
	UploadContent
}

type UploadContent struct {
	BaseRev    int64  `query:"baseRev" default:"0" doc:"Revision this content replaces: 0 when the file must not exist yet, -1 to overwrite whatever is there"`
	Mtime      string `query:"mtime" format:"date-time" doc:"Modification time to record, as RFC 3339; defaults to now"`
	TransferID string `header:"X-Polder-Transfer-Id" doc:"Any ID the client picks; live transfer events echo it back as clientId"`
	content    io.Reader
	size       *int64
}

func (i *UploadContent) Resolve(ctx huma.Context) []error {
	i.content, i.size = ctx.BodyReader(), contentLength(ctx)
	return nil
}

func contentLength(ctx huma.Context) *int64 {
	length, err := strconv.ParseInt(ctx.Header("Content-Length"), 10, 64)
	if err != nil || length < 0 {
		return nil
	}
	return &length
}

type DeleteInput struct {
	Path    string `query:"path"`
	BaseRev int64  `query:"baseRev" default:"-1" doc:"Revision the client last saw; -1 deletes whatever is there"`
}

type PreviewInput struct {
	Path string      `query:"path"`
	Size previewSize `query:"size" default:"256" doc:"Thumbnail width and height in pixels"`
}

// previewSize documents the thumbnail sizes the preview worker renders, so the spec follows preview.Sizes.
type previewSize int

func (previewSize) Schema(huma.Registry) *huma.Schema {
	sizes := make([]any, len(preview.Sizes))
	for i, size := range preview.Sizes {
		sizes[i] = size
	}
	return &huma.Schema{Type: huma.TypeInteger, Enum: sizes}
}

// downloadOutput and previewOutput write their body straight to the connection.
type downloadOutput struct {
	ETag        string `header:"ETag" doc:"The file's revision, quoted; send it in If-Match or If-None-Match"`
	Rev         string `header:"X-Polder-Rev" doc:"The file's revision"`
	ContentType string `header:"Content-Type"`
	Body        func(huma.Context)
}

type previewOutput struct {
	ETag         string `header:"ETag"`
	CacheControl string `header:"Cache-Control"`
	ContentType  string `header:"Content-Type"`
	Body         func(huma.Context)
}

func (a *API) listFiles(ctx context.Context, input *pathQuery) (*jsonBody[listResponse], error) {
	owner := currentUser(ctx)
	at, err := a.mountAt(ctx, owner, input.Path)
	if err != nil {
		return nil, err
	}
	if at != nil {
		return a.listMounted(ctx, *at)
	}
	listedPath, entries, err := a.files.List(ctx, owner, input.Path)
	if err != nil {
		return nil, err
	}
	if err := a.markShared(ctx, owner, entries); err != nil {
		return nil, err
	}
	if listedPath == storage.RootPath {
		mounts, err := a.visibleMounts(ctx, owner)
		if err != nil {
			return nil, err
		}
		entries = append(entries, a.mountRootEntries(ctx, mounts)...)
		files.SortForListing(entries)
	}
	return respond(listResponse{Path: listedPath, Entries: entries, Indexing: a.files.IsIndexing(owner.ID)}), nil
}

func (a *API) statFile(ctx context.Context, input *pathQuery) (*jsonBody[files.Entry], error) {
	at, err := a.mountAt(ctx, currentUser(ctx), input.Path)
	if err != nil {
		return nil, err
	}
	if at != nil {
		return a.respondMounted(ctx, *at)
	}
	entry, err := a.files.Stat(ctx, currentUser(ctx), input.Path)
	if err != nil {
		return nil, err
	}
	marked := []files.Entry{entry}
	if err := a.markShared(ctx, currentUser(ctx), marked); err != nil {
		return nil, err
	}
	return respond(marked[0]), nil
}

func (a *API) downloadFile(ctx context.Context, input *downloadInput) (*downloadOutput, error) {
	owner := currentUser(ctx)
	at, err := a.mountAt(ctx, owner, input.Path)
	if err != nil {
		return nil, err
	}
	if at != nil {
		return a.downloadMounted(ctx, *at, input)
	}
	file, entry, err := a.files.Open(ctx, owner, input.Path)
	if err != nil {
		return nil, err
	}
	return &downloadOutput{
		ETag:        revisionETag(entry.Rev),
		Rev:         fmt.Sprint(entry.Rev),
		ContentType: entry.Mime,
		Body:        a.serveFile(ctx, owner, file, entry, input.Range != ""),
	}, nil
}

func (a *API) serveFile(ctx context.Context, owner users.User, file *os.File, entry files.Entry, ranged bool) func(huma.Context) {
	return func(humaCtx huma.Context) {
		defer file.Close()
		r, w := humachi.Unwrap(humaCtx)
		release := func() {}
		metered := &meteredResponse{ResponseWriter: w, start: func() *activity.Transfer {
			transfer := a.startDownload(ctx, owner, entry, ranged)
			if !ranged {
				release = transfer.Hold()
			}
			return transfer
		}}
		http.ServeContent(metered, r, entry.Name, entry.Mtime, file)
		release()
		if metered.transfer == nil || ranged {
			return
		}
		var incomplete error
		if metered.written < entry.Size {
			incomplete = io.ErrUnexpectedEOF
		}
		a.activity.Finish(ctx, metered.transfer, incomplete)
	}
}

// startDownload tracks a whole-file download on its own, and gathers the range reads one session
// makes of one revision, as sync clients do, into a single transfer.
func (a *API) startDownload(ctx context.Context, owner users.User, entry files.Entry, ranged bool) *activity.Transfer {
	spec := activity.TransferSpec{Owner: owner, Direction: activity.DirectionDownload, Path: entry.Path}
	if !ranged {
		spec.Total = &entry.Size
		return a.activity.Start(ctx, spec)
	}
	key := fmt.Sprintf("%d:%d:%s:%d", owner.ID, activity.ActorFrom(ctx).SessionID, entry.Path, entry.Rev)
	return a.activity.Aggregate(ctx, key, spec)
}

// meteredResponse counts the body bytes of a successful response, starting the transfer on the
// first one so that 304 and 412 answers are never tracked.
type meteredResponse struct {
	http.ResponseWriter
	status   int
	written  int64
	start    func() *activity.Transfer
	transfer *activity.Transfer
}

func (m *meteredResponse) WriteHeader(status int) {
	if m.status == 0 {
		m.status = status
	}
	m.ResponseWriter.WriteHeader(status)
}

func (m *meteredResponse) Write(p []byte) (int, error) {
	if m.status == 0 {
		m.status = http.StatusOK
	}
	if m.transfer == nil && (m.status == http.StatusOK || m.status == http.StatusPartialContent) {
		m.transfer = m.start()
	}
	n, err := m.ResponseWriter.Write(p)
	m.written += int64(n)
	if m.transfer != nil {
		m.transfer.Add(int64(n))
	}
	return n, err
}

func (a *API) uploadFile(ctx context.Context, input *uploadInput) (*jsonBody[files.Entry], error) {
	mtime, err := optionalTime(input.Mtime)
	if err != nil {
		return nil, err
	}
	cleanPath, err := storage.CleanPath(input.Path)
	if err != nil {
		return nil, err
	}
	at, err := a.mountAt(ctx, currentUser(ctx), cleanPath)
	if err != nil {
		return nil, err
	}
	if at != nil {
		return a.uploadMounted(ctx, *at, input)
	}
	entry, err := a.trackedWrite(ctx, currentUser(ctx), files.WriteRequest{
		Path:    cleanPath,
		BaseRev: input.BaseRev,
		Mtime:   mtime,
		Content: input.content,
	}, input.size, input.TransferID)
	if err != nil {
		return nil, err
	}
	return respond(entry), nil
}

func (a *API) trackedWrite(ctx context.Context, owner users.User, request files.WriteRequest, size *int64, clientID string) (files.Entry, error) {
	transfer := a.activity.Start(ctx, activity.TransferSpec{
		Owner: owner, Direction: activity.DirectionUpload, Path: request.Path, Total: size, ClientID: clientID,
	})
	defer transfer.Hold()()
	request.Content = transfer.Reader(request.Content)
	entry, err := a.files.Write(activity.WithTransfer(ctx, transfer), owner, request)
	a.activity.Finish(ctx, transfer, err)
	return entry, err
}

func (a *API) makeDirectory(ctx context.Context, input *jsonBody[pathRequest]) (*jsonBody[files.Entry], error) {
	at, err := a.mountAt(ctx, currentUser(ctx), input.Body.Path)
	if err != nil {
		return nil, err
	}
	if at != nil {
		return a.mkdirMounted(ctx, *at)
	}
	entry, err := a.files.Mkdir(ctx, currentUser(ctx), input.Body.Path)
	if err != nil {
		return nil, err
	}
	return respond(entry), nil
}

func (a *API) moveFile(ctx context.Context, input *jsonBody[moveRequest]) (*jsonBody[files.Entry], error) {
	source, err := a.transferMount(ctx, currentUser(ctx), input.Body.From, input.Body.To)
	if err != nil {
		return nil, err
	}
	if source != nil {
		return a.moveMounted(ctx, *source, input.Body.To, input.Body.BaseRev, false)
	}
	entry, err := a.files.Move(ctx, currentUser(ctx), input.Body.From, input.Body.To, input.Body.BaseRev)
	if err != nil {
		return nil, err
	}
	return respond(entry), nil
}

func (a *API) copyFile(ctx context.Context, input *jsonBody[copyRequest]) (*jsonBody[files.Entry], error) {
	source, err := a.transferMount(ctx, currentUser(ctx), input.Body.From, input.Body.To)
	if err != nil {
		return nil, err
	}
	if source != nil {
		return a.moveMounted(ctx, *source, input.Body.To, 0, true)
	}
	entry, err := a.files.Copy(ctx, currentUser(ctx), input.Body.From, input.Body.To)
	if err != nil {
		return nil, err
	}
	return respond(entry), nil
}

func (a *API) deleteFile(ctx context.Context, input *DeleteInput) (*struct{}, error) {
	at, err := a.mountAt(ctx, currentUser(ctx), input.Path)
	if err != nil {
		return nil, err
	}
	if at != nil {
		return nil, a.deleteMounted(ctx, *at, input.BaseRev)
	}
	return nil, a.files.Delete(ctx, currentUser(ctx), input.Path, input.BaseRev)
}

func (a *API) previewFile(ctx context.Context, input *PreviewInput) (*previewOutput, error) {
	at, err := a.mountAt(ctx, currentUser(ctx), input.Path)
	if err != nil {
		return nil, err
	}
	if at != nil {
		return a.previewMounted(ctx, *at, input.Size)
	}
	entry, err := a.files.Stat(ctx, currentUser(ctx), input.Path)
	if err != nil {
		return nil, err
	}
	return a.thumbnail(entry.Hash, entry.PreviewState, int(input.Size))
}

func (a *API) thumbnail(contentHash string, state files.PreviewState, size int) (*previewOutput, error) {
	if state != files.PreviewReady || !a.previews.HasThumbnail(contentHash, size) {
		return nil, apperr.NotFound("no preview available")
	}
	path := a.previews.ThumbnailPath(contentHash, size)
	return &previewOutput{
		ETag:         fmt.Sprintf(`"%s-%d%s"`, contentHash, size, filepath.Ext(path)),
		CacheControl: "private, max-age=86400",
		ContentType:  preview.ThumbnailContentType(path),
		Body: func(ctx huma.Context) {
			r, w := humachi.Unwrap(ctx)
			http.ServeFile(w, r, path)
		},
	}, nil
}

func revisionETag(rev int64) string {
	return fmt.Sprintf(`"%d"`, rev)
}

func optionalTime(raw string) (time.Time, error) {
	if raw == "" {
		return time.Time{}, nil
	}
	parsed, err := time.Parse(time.RFC3339Nano, raw)
	if err != nil {
		return time.Time{}, apperr.Invalid("mtime must be an RFC 3339 timestamp")
	}
	return parsed, nil
}

type resolveRequest struct {
	IDs []int64 `json:"ids" maxItems:"500" doc:"File ids to look up"`
}

type resolveResponse struct {
	Entries []files.Entry `json:"entries" doc:"The files that still exist, in no particular order; ids that are gone are left out"`
}

func (a *API) resolveFiles(ctx context.Context, input *jsonBody[resolveRequest]) (*jsonBody[resolveResponse], error) {
	found, err := a.files.EntriesByID(ctx, currentUser(ctx).ID, input.Body.IDs)
	if err != nil {
		return nil, err
	}
	entries := make([]files.Entry, 0, len(found))
	for _, entry := range found {
		entries = append(entries, entry)
	}
	return respond(resolveResponse{Entries: entries}), nil
}

type linksInput struct {
	ID int64 `query:"id" doc:"The file's id"`
}

type linksResponse struct {
	Outgoing []links.Outgoing `json:"outgoing" doc:"What this file links to, in the order the links appear"`
	Incoming []links.Incoming `json:"incoming" doc:"Files that link to this one"`
}

func (a *API) fileLinks(ctx context.Context, input *linksInput) (*jsonBody[linksResponse], error) {
	owner := currentUser(ctx)
	entry, err := a.files.EntryByID(ctx, owner.ID, input.ID)
	if err != nil {
		return nil, err
	}
	outgoing, err := a.links.Outgoing(ctx, owner, entry.ID)
	if err != nil {
		return nil, err
	}
	incoming, err := a.links.Incoming(ctx, owner, entry)
	if err != nil {
		return nil, err
	}
	return respond(linksResponse{Outgoing: nonNil(outgoing), Incoming: nonNil(incoming)}), nil
}

func nonNil[T any](items []T) []T {
	if items == nil {
		return []T{}
	}
	return items
}
