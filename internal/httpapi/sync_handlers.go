package httpapi

import (
	"context"
	"io"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/activity"
	"polder-server/internal/files"
	"polder-server/internal/syncing"
)

type changesInput struct {
	Cursor int64 `query:"cursor" default:"0" doc:"Cursor from the previous page; 0 starts from the beginning, -1 returns no changes and only the latest cursor"`
	Limit  int   `query:"limit" default:"1000" doc:"Maximum number of changes to return; the server caps it"`
}

type batchPath struct {
	BatchID string `path:"batchID"`
}

type batchStreamInput struct {
	BatchID string `path:"batchID"`
	content io.Reader
}

func (i *batchStreamInput) Resolve(ctx huma.Context) []error {
	i.content = ctx.BodyReader()
	return nil
}

type downloadBatchOutput struct {
	ContentType string `header:"Content-Type"`
	Body        func(huma.Context)
}

type transferWriter struct {
	target   io.Writer
	transfer *activity.Transfer
}

func (w transferWriter) Write(p []byte) (int, error) {
	n, err := w.target.Write(p)
	w.transfer.Add(int64(n))
	return n, err
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

func (a *API) createUploadBatch(ctx context.Context, input *jsonBody[syncing.BatchRequest]) (*jsonBody[syncing.BatchStatus], error) {
	status, err := a.sync.CreateBatch(ctx, currentUser(ctx), input.Body)
	if err != nil {
		return nil, err
	}
	return respond(status), nil
}

func (a *API) uploadBatchStatus(ctx context.Context, input *batchPath) (*jsonBody[syncing.BatchStatus], error) {
	status, err := a.sync.BatchStatus(ctx, currentUser(ctx), input.BatchID)
	if err != nil {
		return nil, err
	}
	return respond(status), nil
}

func (a *API) streamUploadBatch(ctx context.Context, input *batchStreamInput) (*jsonBody[syncing.BatchStatus], error) {
	owner := currentUser(ctx)
	stream, err := a.sync.OpenStream(ctx, owner, input.BatchID)
	if err != nil {
		return nil, err
	}
	defer stream.Close()

	body := input.content
	if total := stream.MissingBytes(); total > 0 {
		transfer := a.activity.Start(ctx, activity.TransferSpec{
			Owner: owner, Direction: activity.DirectionUpload, Path: stream.TransferPath(), Total: &total,
		})
		defer a.activity.Discard(transfer)
		defer transfer.Hold()()
		body = transfer.Reader(body)
	}
	status, err := stream.Receive(ctx, body)
	if err != nil {
		return nil, err
	}
	return respond(status), nil
}

func (a *API) abortUploadBatch(ctx context.Context, input *batchPath) (*struct{}, error) {
	if err := a.sync.AbortBatch(ctx, currentUser(ctx), input.BatchID); err != nil {
		return nil, err
	}
	return nil, nil
}

func (a *API) downloadBatch(ctx context.Context, input *jsonBody[syncing.DownloadRequest]) (*downloadBatchOutput, error) {
	owner := currentUser(ctx)
	paths := make([]string, 0, len(input.Body.Files))
	for _, file := range input.Body.Files {
		paths = append(paths, file.Path)
	}
	return &downloadBatchOutput{
		ContentType: "application/octet-stream",
		Body: func(humaCtx huma.Context) {
			transfer := a.activity.Start(ctx, activity.TransferSpec{
				Owner: owner, Direction: activity.DirectionDownload, Path: syncing.CommonFolder(paths),
			})
			err := a.sync.WriteFiles(ctx, owner, input.Body.Files, transferWriter{target: humaCtx.BodyWriter(), transfer: transfer})
			a.activity.Finish(ctx, transfer, err)
		},
	}, nil
}
