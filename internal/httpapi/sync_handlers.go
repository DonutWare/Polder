package httpapi

import (
	"context"
	"io"

	"github.com/danielgtaylor/huma/v2"

	"nomad-server/internal/files"
	"nomad-server/internal/syncing"
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
	status, err := a.sync.CreateUpload(ctx, currentUser(ctx), input.Body)
	if err != nil {
		return nil, err
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
	return nil, a.sync.PutChunk(ctx, currentUser(ctx), input.UploadID, input.ChunkHash, input.content)
}

func (a *API) commitUpload(ctx context.Context, input *uploadPath) (*jsonBody[files.Entry], error) {
	entry, err := a.sync.CommitUpload(ctx, currentUser(ctx), input.UploadID)
	if err != nil {
		return nil, err
	}
	return respond(entry), nil
}

func (a *API) abortUpload(ctx context.Context, input *uploadPath) (*struct{}, error) {
	return nil, a.sync.AbortUpload(ctx, currentUser(ctx), input.UploadID)
}
