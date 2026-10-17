package httpapi

import (
	"context"
	"io"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/sharing"
)

const linkDevice = "link"

type linkPath struct {
	LinkID int64 `path:"linkID"`
}

type shareLinksInput struct {
	FileID int64 `query:"fileId" doc:"Only links to this file; 0 or absent for all"`
}

type updateLinkInput struct {
	LinkID int64 `path:"linkID"`
	Body   sharing.LinkChanges
}

type codePath struct {
	Code string `path:"code" maxLength:"32"`
}

type unlockRequest struct {
	Password string `json:"password,omitempty" required:"false" maxLength:"256"`
}

type unlockInput struct {
	Code    string `path:"code" maxLength:"32"`
	Body    unlockRequest
	address string
}

func (i *unlockInput) Resolve(ctx huma.Context) []error {
	i.address = clientAddress(ctx.RemoteAddr())
	return nil
}

type LinkToken struct {
	Token       string `query:"token" doc:"The token from unlocking, for requests that cannot send headers"`
	HeaderToken string `header:"X-Polder-Share-Token" doc:"The token from unlocking"`
}

type linkPathQuery struct {
	Code string `path:"code" maxLength:"32"`
	Path string `query:"path" doc:"Path inside the link; / or empty is the linked item itself"`
	LinkToken
}

type linkDownloadInput struct {
	Code string `path:"code" maxLength:"32"`
	Path string `query:"path"`
	LinkToken
	Range    string `header:"Range" doc:"Byte range to send, such as bytes=0-1023"`
	Download bool   `query:"download" doc:"Ask the browser to save the file instead of showing it"`
}

type linkPreviewInput struct {
	Code string `path:"code" maxLength:"32"`
	Path string `query:"path"`
	LinkToken
	Size previewSize `query:"size" default:"256" doc:"Thumbnail width and height in pixels"`
}

type linkUploadInput struct {
	Code        string `path:"code" maxLength:"32"`
	Path        string `query:"path" doc:"Where to put the file inside the linked folder; a number is added to the name when it is taken"`
	Mtime       string `query:"mtime" format:"date-time" doc:"Modification time to record, as RFC 3339; defaults to now"`
	HeaderToken string `header:"X-Polder-Share-Token" doc:"The token from unlocking"`
	TransferID  string `header:"X-Polder-Transfer-Id"`
	content     io.Reader
	size        *int64
}

func (i *linkUploadInput) Resolve(ctx huma.Context) []error {
	i.content, i.size = ctx.BodyReader(), contentLength(ctx)
	return nil
}

func (a *API) listShareLinks(ctx context.Context, input *shareLinksInput) (*jsonBody[[]sharing.ShareLink], error) {
	list, err := a.sharing.Links(ctx, currentUser(ctx), input.FileID)
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) createShareLink(ctx context.Context, input *jsonBody[sharing.NewShareLink]) (*jsonBody[sharing.ShareLink], error) {
	owner := currentUser(ctx)
	link, err := a.sharing.CreateLink(ctx, owner, input.Body)
	if err != nil {
		return nil, err
	}
	shareLog.Info("link created", "owner", owner.Username, "file", link.File.Path, "permissions", link.Permissions, "password", link.HasPassword)
	return respond(link), nil
}

func (a *API) updateShareLink(ctx context.Context, input *updateLinkInput) (*jsonBody[sharing.ShareLink], error) {
	link, err := a.sharing.UpdateLink(ctx, currentUser(ctx), input.LinkID, input.Body)
	if err != nil {
		return nil, err
	}
	return respond(link), nil
}

func (a *API) deleteShareLink(ctx context.Context, input *linkPath) (*struct{}, error) {
	return nil, a.sharing.RemoveLink(ctx, currentUser(ctx), input.LinkID)
}

func (a *API) matchShareLink(ctx context.Context, input *codePath) (*jsonBody[sharing.LinkMatch], error) {
	match, err := a.sharing.MatchLink(ctx, currentUser(ctx), input.Code)
	if err != nil {
		return nil, err
	}
	return respond(match), nil
}

func (a *API) getPublicLink(ctx context.Context, input *codePath) (*jsonBody[sharing.LinkInfo], error) {
	info, err := a.sharing.PublicInfo(ctx, input.Code)
	if err != nil {
		return nil, err
	}
	return respond(info), nil
}

func (a *API) unlockPublicLink(ctx context.Context, input *unlockInput) (*jsonBody[sharing.LinkUnlock], error) {
	done, allowed := a.linkLimiter.attempt("address:"+input.address, "link:"+input.Code)
	if !allowed {
		shareLog.Warn("link unlock refused: too many failed attempts", "address", input.address, "code", input.Code)
		return nil, apperr.New(apperr.KindRateLimited, "too many wrong passwords, try again in a minute")
	}
	unlocked, err := a.sharing.Unlock(ctx, input.Code, input.Body.Password)
	done(apperr.Is(err, apperr.KindUnauthorized))
	if err != nil {
		return nil, err
	}
	return respond(unlocked), nil
}

func (a *API) visitorAccess(ctx context.Context, code, queryToken, headerToken string) (context.Context, sharing.Access, error) {
	token := headerToken
	if token == "" {
		token = queryToken
	}
	access, err := a.sharing.ForLink(ctx, code, token)
	if err != nil {
		return ctx, access, err
	}
	return actingThrough(ctx, access, linkDevice), access, nil
}

func (a *API) listPublicLinkFiles(ctx context.Context, input *linkPathQuery) (*jsonBody[listResponse], error) {
	ctx, access, err := a.visitorAccess(ctx, input.Code, input.Token, input.HeaderToken)
	if err != nil {
		return nil, err
	}
	return a.spaceList(ctx, access, input.Path)
}

func (a *API) downloadPublicLinkFile(ctx context.Context, input *linkDownloadInput) (*sharedContentOutput, error) {
	ctx, access, err := a.visitorAccess(ctx, input.Code, input.Token, input.HeaderToken)
	if err != nil {
		return nil, err
	}
	return a.spaceDownload(ctx, access, input.Path, input.Range != "", input.Download)
}

func (a *API) previewPublicLinkFile(ctx context.Context, input *linkPreviewInput) (*previewOutput, error) {
	ctx, access, err := a.visitorAccess(ctx, input.Code, input.Token, input.HeaderToken)
	if err != nil {
		return nil, err
	}
	return a.spacePreview(ctx, access, input.Path, input.Size)
}

func (a *API) downloadPublicLinkArchive(ctx context.Context, input *linkPathQuery) (*attachmentOutput, error) {
	ctx, access, err := a.visitorAccess(ctx, input.Code, input.Token, input.HeaderToken)
	if err != nil {
		return nil, err
	}
	return a.spaceArchive(ctx, access, input.Path)
}

func (a *API) uploadPublicLinkFile(ctx context.Context, input *linkUploadInput) (*jsonBody[files.Entry], error) {
	ctx, access, err := a.visitorAccess(ctx, input.Code, "", input.HeaderToken)
	if err != nil {
		return nil, err
	}
	return a.spaceWrite(ctx, access, writeTarget{
		path: input.Path, mtime: input.Mtime, content: input.content, size: input.size, client: input.TransferID,
	})
}
