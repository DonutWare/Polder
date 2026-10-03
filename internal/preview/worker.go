package preview

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"time"

	"nomad-server/internal/files"
	"nomad-server/internal/users"
)

var Sizes = []int{128, 256, 512}

const (
	queueCapacity   = 1024
	backlogInterval = time.Minute
	backlogBatch    = 100
)

type job struct {
	userID int64
	path   string
}

type Worker struct {
	files    *files.Service
	users    *users.Store
	cacheDir string
	queue    chan job
}

func NewWorker(fileService *files.Service, userStore *users.Store, cacheDir string) *Worker {
	return &Worker{files: fileService, users: userStore, cacheDir: cacheDir, queue: make(chan job, queueCapacity)}
}

func (w *Worker) Enqueue(userID int64, cleanPath string) {
	select {
	case w.queue <- job{userID: userID, path: cleanPath}:
	default:
	}
}

func (w *Worker) Run(ctx context.Context) {
	ticker := time.NewTicker(backlogInterval)
	defer ticker.Stop()
	w.processBacklog(ctx)
	for {
		select {
		case <-ctx.Done():
			return
		case next := <-w.queue:
			w.process(ctx, next)
		case <-ticker.C:
			w.processBacklog(ctx)
		}
	}
}

func (w *Worker) processBacklog(ctx context.Context) {
	pending, err := w.files.EntriesAwaitingPreview(ctx, backlogBatch)
	if err != nil {
		slog.Warn("load preview backlog", "error", err)
		return
	}
	for _, entry := range pending {
		w.process(ctx, job{userID: entry.UserID, path: entry.Path})
	}
}

func (w *Worker) process(ctx context.Context, next job) {
	owner, err := w.users.ByID(ctx, next.userID)
	if err != nil {
		return
	}
	entry, err := w.files.Stat(ctx, owner, next.path)
	if err != nil || entry.IsDir || entry.PreviewState != files.PreviewPending {
		return
	}

	meta, state := w.generate(ctx, owner, entry)
	if err := w.files.UpdateDerivedFields(ctx, owner.ID, entry.Path, entry.Hash, meta, state); err != nil {
		slog.Warn("store preview state", "path", entry.Path, "error", err)
	}
}

func (w *Worker) generate(ctx context.Context, owner users.User, entry files.Entry) (map[string]any, files.PreviewState) {
	file, _, err := w.files.Open(ctx, owner, entry.Path)
	if err != nil {
		return entry.Meta, files.PreviewFailed
	}
	defer file.Close()

	decoded, err := decodeImage(file)
	if err != nil {
		slog.Debug("preview decode failed", "path", entry.Path, "error", err)
		return decoded.meta(), files.PreviewFailed
	}
	for _, size := range Sizes {
		if err := writeThumbnail(decoded, size, w.ThumbnailPath(entry.Hash, size)); err != nil {
			slog.Warn("write thumbnail", "path", entry.Path, "error", err)
			return decoded.meta(), files.PreviewFailed
		}
	}
	return decoded.meta(), files.PreviewReady
}

func (w *Worker) ThumbnailPath(contentHash string, size int) string {
	return filepath.Join(w.cacheDir, contentHash[:2], fmt.Sprintf("%s-%d.jpg", contentHash, size))
}

func (w *Worker) HasThumbnail(contentHash string, size int) bool {
	_, err := os.Stat(w.ThumbnailPath(contentHash, size))
	return err == nil
}

func IsSupportedSize(size int) bool {
	for _, supported := range Sizes {
		if supported == size {
			return true
		}
	}
	return false
}
