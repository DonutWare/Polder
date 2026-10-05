package httpapi

import (
	"context"
	"io"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/activity"
	"polder-server/internal/files"
	"polder-server/internal/storage"
	"polder-server/internal/syncing"
	"polder-server/internal/users"
)

type changesInput struct {
	Cursor int64 `query:"cursor" default:"0" doc:"Cursor from the previous page; 0 starts from the beginning"`
	Limit  int   `query:"limit" default:"1000" doc:"Maximum number of changes to return; the server caps it"`
}

type uploadPath struct {
	UploadID string `path:"uploadID"`
}

type chunkInput struct {
	UploadID  string `path:"uploadID"`
	ChunkHash string `path:"chunkHash" doc:"Lowercase hex SHA-256 of the chunk"`
	content   io.Reader
}

func (i *chunkInput) Resolve(ctx huma.Context) []error {
	i.content = ctx.BodyReader()
	return nil
}

func (a *API) changes(ctx context.Context, input *changesInput) (*jsonBody[files.ChangePage], error) {
	page, err := a.files.Changes(ctx, currentUser(ctx).ID, input.Cursor, input.Limit)
	if err != nil {
		return nil, err
	}
	return respond(page), nil
}

func (a *API) manifest(ctx context.Context, input *pathQuery) (*jsonBody[syncing.Manifest], error) {
	manifest, err := a.sync.Manifest(ctx, currentUser(ctx), input.Path)
	if err != nil {
		return nil, err
	}
	return respond(manifest), nil
}

func (a *API) createUpload(ctx context.Context, input *jsonBody[syncing.UploadRequest]) (*jsonBody[syncing.UploadStatus], error) {
	owner := currentUser(ctx)
	status, err := a.sync.CreateUpload(ctx, owner, input.Body)
	if err != nil {
		return nil, err
	}
	if missing := syncing.MissingBytes(input.Body.Chunks, status.Missing); missing > 0 {
		cleanPath, _ := storage.CleanPath(input.Body.Path)
		a.activity.Start(ctx, activity.TransferSpec{
			ID: status.UploadID, Owner: owner, Direction: activity.DirectionUpload, Path: cleanPath, Total: &missing,
		})
	}
	return respond(status), nil
}

func (a *API) uploadStatus(ctx context.Context, input *uploadPath) (*jsonBody[syncing.UploadStatus], error) {
	status, err := a.sync.UploadStatus(ctx, currentUser(ctx), input.UploadID)
	if err != nil {
		return nil, err
	}
	return respond(status), nil
}

func (a *API) putChunk(ctx context.Context, input *chunkInput) (*struct{}, error) {
	owner := currentUser(ctx)
	transfer, err := a.uploadTransfer(ctx, owner, input.UploadID)
	if err != nil {
		return nil, err
	}
	defer transfer.Hold()()
	body := transfer.Reader(input.content)
	if err := a.sync.PutChunk(ctx, owner, input.UploadID, input.ChunkHash, body); err != nil {
		body.Undo()
		return nil, err
	}
	return nil, nil
}

func (a *API) uploadTransfer(ctx context.Context, owner users.User, uploadID string) (*activity.Transfer, error) {
	if transfer := a.ownTransfer(owner, uploadID); transfer != nil {
		return transfer, nil
	}
	path, remaining, err := a.sync.Remaining(ctx, owner, uploadID)
	if err != nil {
		return nil, err
	}
	return a.activity.Start(ctx, activity.TransferSpec{
		ID: uploadID, Owner: owner, Direction: activity.DirectionUpload, Path: path, Total: &remaining,
	}), nil
}

func (a *API) ownTransfer(owner users.User, id string) *activity.Transfer {
	transfer := a.activity.Lookup(id)
	if transfer == nil || transfer.UserID() != owner.ID {
		return nil
	}
	return transfer
}

func (a *API) commitUpload(ctx context.Context, input *uploadPath) (*jsonBody[files.Entry], error) {
	transfer := a.ownTransfer(currentUser(ctx), input.UploadID)
	if transfer != nil {
		defer transfer.Hold()()
	}
	entry, err := a.sync.CommitUpload(activity.WithTransfer(ctx, transfer), currentUser(ctx), input.UploadID)
	if transfer != nil {
		a.activity.Finish(ctx, transfer, err)
	}
	if err != nil {
		return nil, err
	}
	return respond(entry), nil
}

func (a *API) abortUpload(ctx context.Context, input *uploadPath) (*struct{}, error) {
	if err := a.sync.AbortUpload(ctx, currentUser(ctx), input.UploadID); err != nil {
		return nil, err
	}
	if transfer := a.ownTransfer(currentUser(ctx), input.UploadID); transfer != nil {
		a.activity.Finish(ctx, transfer, context.Canceled)
	}
	return nil, nil
}
