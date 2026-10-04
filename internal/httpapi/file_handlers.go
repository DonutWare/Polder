package httpapi

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"time"

	"github.com/danielgtaylor/huma/v2"
	"github.com/danielgtaylor/huma/v2/adapters/humachi"

	"nomad-server/internal/activity"
	"nomad-server/internal/apperr"
	"nomad-server/internal/files"
	"nomad-server/internal/preview"
	"nomad-server/internal/storage"
	"nomad-server/internal/users"
)

type listResponse struct {
	Path    string        `json:"path"`
	Entries []files.Entry `json:"entries"`
}

type pathRequest struct {
	Path string `json:"path"`
}

type moveRequest struct {
	From    string `json:"from"`
	To      string `json:"to"`
	BaseRev int64  `json:"baseRev" required:"false" doc:"Revision the client last saw of the source; 0 or -1 skips the check"`
}

// Huma reads parameters only from an input's own fields, not from embedded structs.
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
	Path       string `query:"path" doc:"Where to store the file, such as /Photos/cat.jpg"`
	BaseRev    int64  `query:"baseRev" default:"0" doc:"Revision this content replaces: 0 when the file must not exist yet, -1 to overwrite whatever is there"`
	Mtime      string `query:"mtime" format:"date-time" doc:"Modification time to record, as RFC 3339; defaults to now"`
	TransferID string `header:"X-Nomad-Transfer-Id" doc:"Any ID the client picks; live transfer events echo it back as clientId"`
	content    io.Reader
	size       *int64
}

func (i *uploadInput) Resolve(ctx huma.Context) []error {
	i.content = ctx.BodyReader()
	if length, err := strconv.ParseInt(ctx.Header("Content-Length"), 10, 64); err == nil && length >= 0 {
		i.size = &length
	}
	return nil
}

type deleteInput struct {
	Path    string `query:"path"`
	BaseRev int64  `query:"baseRev" default:"-1" doc:"Revision the client last saw; -1 deletes whatever is there"`
}

type previewInput struct {
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
	Rev         string `header:"X-Nomad-Rev" doc:"The file's revision"`
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
	listedPath, entries, err := a.files.List(ctx, currentUser(ctx), input.Path)
	if err != nil {
		return nil, err
	}
	return respond(listResponse{Path: listedPath, Entries: entries}), nil
}

func (a *API) statFile(ctx context.Context, input *pathQuery) (*jsonBody[files.Entry], error) {
	entry, err := a.files.Stat(ctx, currentUser(ctx), input.Path)
	if err != nil {
		return nil, err
	}
	return respond(entry), nil
}

func (a *API) downloadFile(ctx context.Context, input *downloadInput) (*downloadOutput, error) {
	owner := currentUser(ctx)
	file, entry, err := a.files.Open(ctx, owner, input.Path)
	if err != nil {
		return nil, err
	}
	ranged := input.Range != ""
	return &downloadOutput{
		ETag:        revisionETag(entry.Rev),
		Rev:         fmt.Sprint(entry.Rev),
		ContentType: entry.Mime,
		Body: func(humaCtx huma.Context) {
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
		},
	}, nil
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
	owner := currentUser(ctx)
	transfer := a.activity.Start(ctx, activity.TransferSpec{
		Owner: owner, Direction: activity.DirectionUpload, Path: cleanPath, Total: input.size, ClientID: input.TransferID,
	})
	defer transfer.Hold()()
	entry, err := a.files.Write(activity.WithTransfer(ctx, transfer), owner, files.WriteRequest{
		Path:    cleanPath,
		BaseRev: input.BaseRev,
		Mtime:   mtime,
		Content: transfer.Reader(input.content),
	})
	a.activity.Finish(ctx, transfer, err)
	if err != nil {
		return nil, err
	}
	return respond(entry), nil
}

func (a *API) makeDirectory(ctx context.Context, input *jsonBody[pathRequest]) (*jsonBody[files.Entry], error) {
	entry, err := a.files.Mkdir(ctx, currentUser(ctx), input.Body.Path)
	if err != nil {
		return nil, err
	}
	return respond(entry), nil
}

func (a *API) moveFile(ctx context.Context, input *jsonBody[moveRequest]) (*jsonBody[files.Entry], error) {
	entry, err := a.files.Move(ctx, currentUser(ctx), input.Body.From, input.Body.To, input.Body.BaseRev)
	if err != nil {
		return nil, err
	}
	return respond(entry), nil
}

func (a *API) deleteFile(ctx context.Context, input *deleteInput) (*struct{}, error) {
	return nil, a.files.Delete(ctx, currentUser(ctx), input.Path, input.BaseRev)
}

func (a *API) previewFile(ctx context.Context, input *previewInput) (*previewOutput, error) {
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
	return &previewOutput{
		ETag:         fmt.Sprintf(`"%s-%d"`, contentHash, size),
		CacheControl: "private, max-age=86400",
		ContentType:  "image/jpeg",
		Body: func(ctx huma.Context) {
			r, w := humachi.Unwrap(ctx)
			http.ServeFile(w, r, a.previews.ThumbnailPath(contentHash, size))
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
