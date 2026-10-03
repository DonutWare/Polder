package httpapi

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/danielgtaylor/huma/v2"
	"github.com/danielgtaylor/huma/v2/adapters/humachi"

	"nomad-server/internal/apperr"
	"nomad-server/internal/files"
	"nomad-server/internal/preview"
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
	Path    string `query:"path" doc:"Where to store the file, such as /Photos/cat.jpg"`
	BaseRev int64  `query:"baseRev" default:"0" doc:"Revision this content replaces: 0 when the file must not exist yet, -1 to overwrite whatever is there"`
	Mtime   string `query:"mtime" format:"date-time" doc:"Modification time to record, as RFC 3339; defaults to now"`
	content io.Reader
}

func (i *uploadInput) Resolve(ctx huma.Context) []error {
	i.content = ctx.BodyReader()
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
	file, entry, err := a.files.Open(ctx, currentUser(ctx), input.Path)
	if err != nil {
		return nil, err
	}
	return &downloadOutput{
		ETag:        revisionETag(entry.Rev),
		Rev:         fmt.Sprint(entry.Rev),
		ContentType: entry.Mime,
		Body: func(ctx huma.Context) {
			defer file.Close()
			r, w := humachi.Unwrap(ctx)
			http.ServeContent(w, r, entry.Name, entry.Mtime, file)
		},
	}, nil
}

func (a *API) uploadFile(ctx context.Context, input *uploadInput) (*jsonBody[files.Entry], error) {
	mtime, err := optionalTime(input.Mtime)
	if err != nil {
		return nil, err
	}
	entry, err := a.files.Write(ctx, currentUser(ctx), files.WriteRequest{
		Path:    input.Path,
		BaseRev: input.BaseRev,
		Mtime:   mtime,
		Content: input.content,
	})
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
	size := int(input.Size)
	entry, err := a.files.Stat(ctx, currentUser(ctx), input.Path)
	if err != nil {
		return nil, err
	}
	if entry.PreviewState != files.PreviewReady || !a.previews.HasThumbnail(entry.Hash, size) {
		return nil, apperr.NotFound("no preview available")
	}
	return &previewOutput{
		ETag:         fmt.Sprintf(`"%s-%d"`, entry.Hash, size),
		CacheControl: "private, max-age=86400",
		ContentType:  "image/jpeg",
		Body: func(ctx huma.Context) {
			r, w := humachi.Unwrap(ctx)
			http.ServeFile(w, r, a.previews.ThumbnailPath(entry.Hash, size))
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
