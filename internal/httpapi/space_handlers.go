package httpapi

import (
	"context"
	"fmt"
	"io"
	"os"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/sharing"
)

const sandboxPolicy = "sandbox; default-src 'none'; img-src 'self' data:; media-src 'self'; style-src 'unsafe-inline'"

type sharedContentOutput struct {
	ETag               string `header:"ETag"`
	Rev                string `header:"X-Polder-Rev"`
	ContentType        string `header:"Content-Type"`
	ContentDisposition string `header:"Content-Disposition"`
	NoSniff            string `header:"X-Content-Type-Options"`
	Policy             string `header:"Content-Security-Policy"`
	Body               func(huma.Context)
}

type writeTarget struct {
	path    string
	baseRev int64
	mtime   string
	content io.Reader
	size    *int64
	client  string
}

func actingThrough(ctx context.Context, access sharing.Access, device string) context.Context {
	if device == "" {
		device = activity.ActorFrom(ctx).Device
	}
	return activity.WithActor(ctx, activity.Actor{Device: device, Via: access.Via})
}

func (a *API) spaceList(ctx context.Context, access sharing.Access, relative string) (_ *jsonBody[listResponse], err error) {
	defer access.Scrub(&err)
	if err := access.RequireRead(); err != nil {
		return nil, err
	}
	absolute, err := access.Path(relative)
	if err != nil {
		return nil, err
	}
	if !access.Root.IsDir {
		return respond(listResponse{Path: "/", Entries: []files.Entry{access.Relative(access.Root)}}), nil
	}
	listedPath, entries, err := a.files.List(ctx, access.Owner, absolute)
	if err != nil {
		return nil, err
	}
	return respond(listResponse{
		Path: access.RelativePath(listedPath), Entries: access.RelativeEntries(entries), Indexing: a.files.IsIndexing(access.Owner.ID),
	}), nil
}

func (a *API) statIn(ctx context.Context, access sharing.Access, relative string, allowed func() error) (string, files.Entry, error) {
	if err := allowed(); err != nil {
		return "", files.Entry{}, err
	}
	absolute, err := access.Path(relative)
	if err != nil {
		return "", files.Entry{}, err
	}
	entry, err := a.files.Stat(ctx, access.Owner, absolute)
	return absolute, entry, err
}

func (a *API) spaceStat(ctx context.Context, access sharing.Access, relative string) (_ *jsonBody[files.Entry], err error) {
	defer access.Scrub(&err)
	_, entry, err := a.statIn(ctx, access, relative, access.RequireRead)
	if err != nil {
		return nil, err
	}
	return respond(access.Relative(entry)), nil
}

func (a *API) spaceDownload(ctx context.Context, access sharing.Access, relative string, ranged, asAttachment bool) (_ *sharedContentOutput, err error) {
	defer access.Scrub(&err)
	if err := access.RequireDownload(); err != nil {
		return nil, err
	}
	absolute, err := access.Path(relative)
	if err != nil {
		return nil, err
	}
	file, entry, err := a.files.Open(ctx, access.Owner, absolute)
	if err != nil {
		return nil, err
	}
	output := &sharedContentOutput{
		ETag:        revisionETag(entry.Rev),
		Rev:         fmt.Sprint(entry.Rev),
		ContentType: entry.Mime,
		NoSniff:     "nosniff",
		Policy:      sandboxPolicy,
		Body:        a.serveFile(ctx, access.Owner, file, entry, ranged),
	}
	if asAttachment {
		output.ContentDisposition = attachment(entry.Name)
	}
	return output, nil
}

func (a *API) spacePreview(ctx context.Context, access sharing.Access, relative string, size previewSize) (_ *previewOutput, err error) {
	defer access.Scrub(&err)
	_, entry, err := a.statIn(ctx, access, relative, access.RequireRead)
	if err != nil {
		return nil, err
	}
	return a.thumbnail(entry.Hash, entry.PreviewState, int(size))
}

func (a *API) spaceArchive(ctx context.Context, access sharing.Access, relative string) (_ *attachmentOutput, err error) {
	defer access.Scrub(&err)
	absolute, entry, err := a.statIn(ctx, access, relative, access.RequireDownload)
	if err != nil {
		return nil, err
	}
	if !entry.IsDir {
		return nil, apperr.Invalid("only folders can be downloaded as a zip")
	}
	onDisk, err := a.files.Disk().Resolve(access.Owner.Username, absolute)
	if err != nil {
		return nil, err
	}
	if _, err := os.Stat(onDisk); err != nil {
		return nil, apperr.NotFound("%s does not exist", relative)
	}
	select {
	case a.archiveSlots <- struct{}{}:
	default:
		return nil, apperr.New(apperr.KindRateLimited, "too many zip downloads at once, try again shortly")
	}
	return &attachmentOutput{
		ContentType:        "application/zip",
		ContentDisposition: attachment(entry.Name + ".zip"),
		Body: func(humaCtx huma.Context) {
			defer func() { <-a.archiveSlots }()
			if err := writeZip(humaCtx.BodyWriter(), onDisk); err != nil {
				logger.Warn("zip shared folder", "owner", access.Owner.Username, "via", access.Via, "error", err)
			}
		},
	}, nil
}

func (a *API) spaceWrite(ctx context.Context, access sharing.Access, target writeTarget) (_ *jsonBody[files.Entry], err error) {
	defer access.Scrub(&err)
	mtime, err := optionalTime(target.mtime)
	if err != nil {
		return nil, err
	}
	absolute, baseRev, err := a.writePath(ctx, access, target)
	if err != nil {
		return nil, err
	}
	entry, err := a.trackedWrite(ctx, access.Owner, files.WriteRequest{
		Path:    absolute,
		BaseRev: baseRev,
		Mtime:   mtime,
		Content: target.content,
	}, target.size, target.client)
	if err != nil {
		return nil, err
	}
	return respond(access.Relative(entry)), nil
}

func (a *API) writePath(ctx context.Context, access sharing.Access, target writeTarget) (string, int64, error) {
	if access.CanCreate || access.CanEdit {
		return a.sharedWritePath(ctx, access, target)
	}
	if err := access.RequireDrop(); err != nil {
		return "", 0, err
	}
	absolute, err := access.Inner(target.path)
	if err != nil {
		return "", 0, err
	}
	free, err := a.files.FreeName(ctx, access.Owner, absolute)
	return free, files.BaseRevMustNotExist, err
}

func (a *API) sharedWritePath(ctx context.Context, access sharing.Access, target writeTarget) (string, int64, error) {
	absolute, err := access.Path(target.path)
	if err != nil {
		return "", 0, err
	}
	_, err = a.files.Stat(ctx, access.Owner, absolute)
	switch {
	case err == nil:
		return absolute, target.baseRev, access.RequireEdit()
	case apperr.Is(err, apperr.KindNotFound):
		baseRev := target.baseRev
		if !access.CanEdit {
			baseRev = files.BaseRevMustNotExist
		}
		return absolute, baseRev, access.RequireCreate()
	default:
		return "", 0, err
	}
}

func (a *API) spaceMkdir(ctx context.Context, access sharing.Access, relative string) (_ *jsonBody[files.Entry], err error) {
	defer access.Scrub(&err)
	if err := access.RequireCreate(); err != nil {
		return nil, err
	}
	absolute, err := access.Inner(relative)
	if err != nil {
		return nil, err
	}
	entry, err := a.files.Mkdir(ctx, access.Owner, absolute)
	if err != nil {
		return nil, err
	}
	return respond(access.Relative(entry)), nil
}

func (a *API) spaceMove(ctx context.Context, access sharing.Access, request moveRequest, copying bool) (_ *jsonBody[files.Entry], err error) {
	defer access.Scrub(&err)
	from, err := access.Inner(request.From)
	if err != nil {
		return nil, err
	}
	to, err := access.Inner(request.To)
	if err != nil {
		return nil, err
	}
	if err := access.RequireMove(from, to, copying); err != nil {
		return nil, err
	}
	var entry files.Entry
	if copying {
		entry, err = a.files.Copy(ctx, access.Owner, from, to)
	} else {
		entry, err = a.files.Move(ctx, access.Owner, from, to, request.BaseRev)
	}
	if err != nil {
		return nil, err
	}
	return respond(access.Relative(entry)), nil
}

func (a *API) spaceDelete(ctx context.Context, access sharing.Access, relative string, baseRev int64) (err error) {
	defer access.Scrub(&err)
	if err := access.RequireDelete(); err != nil {
		return err
	}
	absolute, err := access.Inner(relative)
	if err != nil {
		return err
	}
	return a.files.Delete(ctx, access.Owner, absolute, baseRev)
}
