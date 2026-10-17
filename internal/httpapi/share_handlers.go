package httpapi

import (
	"context"

	"polder-server/internal/files"
	"polder-server/internal/logging"
	"polder-server/internal/sharing"
)

var shareLog = logging.For("sharing")

type sharePath struct {
	ShareID int64 `path:"shareID"`
}

type outgoingSharesInput struct {
	FileID int64 `query:"fileId" doc:"Only shares of this file; 0 or absent for all"`
}

type updateShareInput struct {
	ShareID int64 `path:"shareID"`
	Body    sharing.ShareChanges
}

type sharePathQuery struct {
	ShareID int64  `path:"shareID"`
	Path    string `query:"path" doc:"Path inside the share; / or empty is the shared item itself"`
}

type shareDownloadInput struct {
	ShareID  int64  `path:"shareID"`
	Path     string `query:"path" doc:"Path inside the share"`
	Range    string `header:"Range" doc:"Byte range to send, such as bytes=0-1023"`
	Download bool   `query:"download" doc:"Ask the browser to save the file instead of showing it"`
}

type sharePreviewInput struct {
	ShareID int64 `path:"shareID"`
	PreviewInput
}

type shareUploadInput struct {
	ShareID int64  `path:"shareID"`
	Path    string `query:"path" doc:"Where to store the file inside the share"`
	UploadContent
}

type shareMkdirInput struct {
	ShareID int64 `path:"shareID"`
	Body    pathRequest
}

type shareMoveInput struct {
	ShareID int64 `path:"shareID"`
	Body    moveRequest
}

type shareCopyInput struct {
	ShareID int64 `path:"shareID"`
	Body    copyRequest
}

type shareDeleteInput struct {
	ShareID int64 `path:"shareID"`
	DeleteInput
}

func (a *API) listOutgoingShares(ctx context.Context, input *outgoingSharesInput) (*jsonBody[[]sharing.Share], error) {
	list, err := a.sharing.Outgoing(ctx, currentUser(ctx), input.FileID)
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) createShare(ctx context.Context, input *jsonBody[sharing.NewShare]) (*jsonBody[sharing.Share], error) {
	share, err := a.sharing.Share(ctx, currentUser(ctx), input.Body)
	if err != nil {
		return nil, err
	}
	shareLog.Info("shared", "owner", share.Owner.Username, "file", share.File.Path, "with", share.Recipient.Kind, "recipient", share.Recipient.ID, "permissions", share.Permissions)
	return respond(share), nil
}

func (a *API) updateShare(ctx context.Context, input *updateShareInput) (*jsonBody[sharing.Share], error) {
	share, err := a.sharing.UpdateShare(ctx, currentUser(ctx), input.ShareID, input.Body)
	if err != nil {
		return nil, err
	}
	return respond(share), nil
}

func (a *API) deleteShare(ctx context.Context, input *sharePath) (*struct{}, error) {
	return nil, a.sharing.RemoveShare(ctx, currentUser(ctx), input.ShareID)
}

func (a *API) listIncomingShares(ctx context.Context, _ *struct{}) (*jsonBody[[]sharing.IncomingShare], error) {
	list, err := a.sharing.Incoming(ctx, currentUser(ctx))
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) recipientAccess(ctx context.Context, shareID int64) (context.Context, sharing.Access, error) {
	access, err := a.sharing.ForRecipient(ctx, currentUser(ctx), shareID)
	if err != nil {
		return ctx, access, err
	}
	return actingThrough(ctx, access, ""), access, nil
}

func (a *API) listShareFiles(ctx context.Context, input *sharePathQuery) (*jsonBody[listResponse], error) {
	ctx, access, err := a.recipientAccess(ctx, input.ShareID)
	if err != nil {
		return nil, err
	}
	return a.spaceList(ctx, access, input.Path)
}

func (a *API) statShareFile(ctx context.Context, input *sharePathQuery) (*jsonBody[files.Entry], error) {
	ctx, access, err := a.recipientAccess(ctx, input.ShareID)
	if err != nil {
		return nil, err
	}
	return a.spaceStat(ctx, access, input.Path)
}

func (a *API) downloadShareFile(ctx context.Context, input *shareDownloadInput) (*sharedContentOutput, error) {
	ctx, access, err := a.recipientAccess(ctx, input.ShareID)
	if err != nil {
		return nil, err
	}
	return a.spaceDownload(ctx, access, input.Path, input.Range != "", input.Download)
}

func (a *API) previewShareFile(ctx context.Context, input *sharePreviewInput) (*previewOutput, error) {
	ctx, access, err := a.recipientAccess(ctx, input.ShareID)
	if err != nil {
		return nil, err
	}
	return a.spacePreview(ctx, access, input.Path, input.Size)
}

func (a *API) downloadShareArchive(ctx context.Context, input *sharePathQuery) (*attachmentOutput, error) {
	ctx, access, err := a.recipientAccess(ctx, input.ShareID)
	if err != nil {
		return nil, err
	}
	return a.spaceArchive(ctx, access, input.Path)
}

func (a *API) uploadShareFile(ctx context.Context, input *shareUploadInput) (*jsonBody[files.Entry], error) {
	ctx, access, err := a.recipientAccess(ctx, input.ShareID)
	if err != nil {
		return nil, err
	}
	return a.spaceWrite(ctx, access, writeTarget{
		path: input.Path, baseRev: input.BaseRev, mtime: input.Mtime, content: input.content, size: input.size, client: input.TransferID,
	})
}

func (a *API) makeShareDirectory(ctx context.Context, input *shareMkdirInput) (*jsonBody[files.Entry], error) {
	ctx, access, err := a.recipientAccess(ctx, input.ShareID)
	if err != nil {
		return nil, err
	}
	return a.spaceMkdir(ctx, access, input.Body.Path)
}

func (a *API) moveShareFile(ctx context.Context, input *shareMoveInput) (*jsonBody[files.Entry], error) {
	ctx, access, err := a.recipientAccess(ctx, input.ShareID)
	if err != nil {
		return nil, err
	}
	return a.spaceMove(ctx, access, input.Body, false)
}

func (a *API) copyShareFile(ctx context.Context, input *shareCopyInput) (*jsonBody[files.Entry], error) {
	ctx, access, err := a.recipientAccess(ctx, input.ShareID)
	if err != nil {
		return nil, err
	}
	return a.spaceMove(ctx, access, moveRequest{From: input.Body.From, To: input.Body.To}, true)
}

func (a *API) deleteShareFile(ctx context.Context, input *shareDeleteInput) (*struct{}, error) {
	ctx, access, err := a.recipientAccess(ctx, input.ShareID)
	if err != nil {
		return nil, err
	}
	return nil, a.spaceDelete(ctx, access, input.Path, input.BaseRev)
}
