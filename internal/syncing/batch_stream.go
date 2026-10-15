package syncing

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"os"
	"path"
	"strings"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/storage"
	"polder-server/internal/users"
)

type BatchStream struct {
	service   *Service
	owner     users.User
	batch     batch
	plan      batchPlan
	release   func()
	committed chan struct{}
}

func (s *Service) OpenStream(ctx context.Context, owner users.User, batchID string) (*BatchStream, error) {
	release, ok := s.streaming.acquire(batchID)
	if !ok {
		return nil, apperr.Conflict(nil, "this batch is already being uploaded")
	}
	found, err := s.loadBatch(ctx, owner, batchID)
	if err != nil {
		release()
		return nil, err
	}
	plan, err := s.planBatch(ctx, owner, found)
	if err != nil {
		release()
		return nil, err
	}
	return &BatchStream{service: s, owner: owner, batch: found, plan: plan, release: release}, nil
}

func (b *BatchStream) Close() {
	b.release()
}

func (b *BatchStream) MissingBytes() int64 {
	return b.plan.missingBytes()
}

func (b *BatchStream) TransferPath() string {
	var paths []string
	for _, file := range b.batch.unfinishedFiles() {
		paths = append(paths, file.request.Path)
	}
	return CommonFolder(paths)
}

func CommonFolder(paths []string) string {
	if len(paths) == 0 {
		return storage.RootPath
	}
	if len(paths) == 1 {
		return paths[0]
	}
	folder := path.Dir(paths[0])
	for _, other := range paths[1:] {
		for folder != storage.RootPath && !isInside(other, folder) {
			folder = path.Dir(folder)
		}
	}
	return folder
}

func isInside(filePath, folder string) bool {
	return filePath == folder || strings.HasPrefix(filePath, folder+"/")
}

func (b *BatchStream) Receive(ctx context.Context, body io.Reader) (BatchStatus, error) {
	commits := b.startCommitting(context.WithoutCancel(ctx))
	receiveErr := b.receiveChunks(ctx, body, commits)
	close(commits)
	<-b.committed

	if receiveErr != nil {
		return BatchStatus{}, receiveErr
	}
	if len(b.batch.unfinishedFiles()) > 0 {
		return b.service.status(ctx, b.owner, b.batch)
	}
	status := BatchStatus{BatchID: b.batch.id, Missing: []ChunkRef{}, Results: b.batch.results()}
	return status, b.service.removeBatch(context.WithoutCancel(ctx), b.batch.id)
}

func (b *BatchStream) startCommitting(ctx context.Context) chan<- int {
	var complete []int
	for _, file := range b.batch.unfinishedFiles() {
		if b.plan.isComplete(file.idx) {
			complete = append(complete, file.idx)
		}
	}
	commits := make(chan int, len(b.batch.files))
	for _, idx := range complete {
		commits <- idx
	}
	b.committed = make(chan struct{})
	go func() {
		defer close(b.committed)
		for idx := range commits {
			request := b.batch.files[idx].request
			b.recordResult(ctx, idx, b.service.commitFile(ctx, b.owner, request, b.plan.sources[idx]))
		}
	}()
	return commits
}

func (b *BatchStream) receiveChunks(ctx context.Context, body io.Reader, commits chan<- int) error {
	for _, chunk := range b.plan.missing {
		stagedPath, err := b.service.stageChunk(b.batch.id, chunk, body)
		switch {
		case errors.Is(err, io.ErrUnexpectedEOF):
			return apperr.Invalid("the stream ended before all missing chunks arrived")
		case apperr.Is(err, apperr.KindInvalid):
			b.failFilesNeeding(ctx, chunk.Hash)
		case err != nil:
			return err
		default:
			b.chunkArrived(chunk, stagedPath, commits)
		}
	}
	if n, _ := body.Read(make([]byte, 1)); n > 0 {
		return apperr.Invalid("the stream is longer than the missing chunks")
	}
	return nil
}

func (b *BatchStream) chunkArrived(chunk ChunkRef, stagedPath string, commits chan<- int) {
	for _, idx := range b.plan.neededBy[chunk.Hash] {
		if !b.plan.isWaiting(idx) {
			continue
		}
		b.plan.markArrived(idx, chunk, stagedPath)
		if b.plan.isComplete(idx) {
			b.plan.stopWaiting(idx)
			commits <- idx
		}
	}
}

func (b *BatchStream) failFilesNeeding(ctx context.Context, chunkHash string) {
	changed := apperr.New(apperr.KindPrecondition, "content changed while it was being uploaded")
	for _, idx := range b.plan.neededBy[chunkHash] {
		if !b.plan.isWaiting(idx) {
			continue
		}
		b.plan.stopWaiting(idx)
		result, _ := resultForError(b.batch.files[idx].request.Path, changed)
		b.recordResult(ctx, idx, result)
	}
}

func (b *BatchStream) recordResult(ctx context.Context, idx int, result FileResult) {
	b.batch.files[idx].result = &result
	if err := b.service.saveResult(context.WithoutCancel(ctx), b.batch.id, idx, result); err != nil {
		logger.Warn("save upload result", "batch", b.batch.id, "path", result.Path, "error", err)
	}
}

func (s *Service) commitFile(ctx context.Context, owner users.User, request UploadRequest, sources map[string]chunkSource) FileResult {
	entry, err := s.writeFromChunks(ctx, owner, request, sources)
	if err == nil {
		return FileResult{Path: request.Path, Entry: &entry}
	}
	result, unexpected := resultForError(request.Path, err)
	if unexpected != nil {
		logger.Error("commit upload", "path", request.Path, "error", unexpected)
		return FileResult{Path: request.Path, Error: &FileError{Code: "internal", Message: "internal server error"}}
	}
	return result
}

func (s *Service) writeFromChunks(ctx context.Context, owner users.User, request UploadRequest, sources map[string]chunkSource) (files.Entry, error) {
	content, err := s.assemble(ctx, owner, request, sources)
	if err != nil {
		return files.Entry{}, err
	}
	defer content.Close()
	return s.files.Write(ctx, owner, files.WriteRequest{
		Path:         request.Path,
		BaseRev:      request.BaseRev,
		Mtime:        request.Mtime,
		ExpectedHash: request.Hash,
		Content:      content,
	})
}

func (s *Service) stageChunk(batchID string, chunk ChunkRef, body io.Reader) (string, error) {
	temp, err := os.CreateTemp(s.stagingDir(batchID), "incoming-*")
	if err != nil {
		return "", err
	}
	defer os.Remove(temp.Name())

	hasher := sha256.New()
	written, copyErr := io.Copy(io.MultiWriter(temp, hasher), io.LimitReader(body, chunk.Size))
	if err := errors.Join(copyErr, temp.Close()); err != nil {
		return "", fmt.Errorf("store chunk: %w", err)
	}
	if written < chunk.Size {
		return "", io.ErrUnexpectedEOF
	}
	if actual := hex.EncodeToString(hasher.Sum(nil)); actual != chunk.Hash {
		return "", apperr.Invalid("chunk hash mismatch: got %s", actual)
	}
	stagedPath := s.stagedChunkPath(batchID, chunk.Hash)
	return stagedPath, os.Rename(temp.Name(), stagedPath)
}
