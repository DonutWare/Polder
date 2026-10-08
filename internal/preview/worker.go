package preview

import (
	"context"
	"errors"
	"fmt"
	"io/fs"
	"maps"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"time"

	"polder-server/internal/files"
	"polder-server/internal/logging"
	"polder-server/internal/office"
	"polder-server/internal/users"
)

var logger = logging.For("preview")

var Sizes = []int{128, 256, 512}

const (
	queueCapacity    = 1024
	backlogInterval  = time.Minute
	backlogBatch     = 100
	pdfIdleTimeout   = 5 * time.Minute
	officeRetryDelay = 5 * time.Minute
)

var decodableImages = map[string]bool{"image/jpeg": true, "image/png": true, "image/gif": true, "image/webp": true}

type job struct {
	userID int64
	path   string
}

type Worker struct {
	files    *files.Service
	users    *users.Store
	cacheDir string
	queue    chan job
	cleanups chan struct{}
	pdf      pdfRenderer
	ffmpeg   ffmpegRenderer
	office   *office.Service

	officePausedUntil     time.Time
	requestedCapabilities string
}

func NewWorker(fileService *files.Service, userStore *users.Store, cacheDir string, ffmpeg FFmpegOptions, officeService *office.Service) *Worker {
	worker := &Worker{
		files:    fileService,
		users:    userStore,
		cacheDir: cacheDir,
		queue:    make(chan job, queueCapacity),
		cleanups: make(chan struct{}, 1),
		ffmpeg:   newFFmpegRenderer(ffmpeg),
		office:   officeService,
	}
	if !worker.ffmpeg.installed() {
		logger.Info("ffmpeg not found; videos and images Go cannot decode get no previews", "ffmpeg", ffmpeg.Path)
	}
	return worker
}

func (w *Worker) RequestCleanup() {
	select {
	case w.cleanups <- struct{}{}:
	default:
	}
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
	pdfIdle := time.NewTimer(pdfIdleTimeout)
	defer pdfIdle.Stop()
	defer w.pdf.close()
	w.removeUnusedThumbnails(ctx)
	w.processBacklog(ctx)
	for {
		select {
		case <-ctx.Done():
			return
		case next := <-w.queue:
			w.process(ctx, next)
		case <-w.cleanups:
			w.removeUnusedThumbnails(ctx)
		case <-ticker.C:
			w.processBacklog(ctx)
		case <-pdfIdle.C:
			w.pdf.close()
		}
		if w.pdf.used {
			w.pdf.used = false
			pdfIdle.Reset(pdfIdleTimeout)
		}
	}
}

func (w *Worker) processBacklog(ctx context.Context) {
	w.requestNewlyPreviewable(ctx)
	pending, err := w.files.EntriesAwaitingPreview(ctx, backlogBatch)
	if err != nil {
		logger.Warn("load preview backlog", "error", err)
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

	meta, state := w.generate(ctx, owner, entry, w.currentCapabilities(ctx))
	if err := w.files.UpdateDerivedFields(ctx, owner.ID, entry.Path, entry.Hash, meta, state); err != nil {
		logger.Warn("store preview state", "path", entry.Path, "error", err)
	}
}

type render func(ctx context.Context, file *os.File, entry files.Entry) (decodedImage, error)

type capabilities struct {
	ffmpeg      bool
	convertible map[string]bool
}

func (w *Worker) currentCapabilities(ctx context.Context) capabilities {
	current := capabilities{ffmpeg: w.ffmpeg.installed()}
	if time.Now().After(w.officePausedUntil) {
		current.convertible = w.office.ConvertibleMimes(ctx)
	}
	return current
}

func (w *Worker) rendererFor(available capabilities, mimeType string) render {
	largestSize := Sizes[len(Sizes)-1]
	switch {
	case decodableImages[mimeType]:
		return func(_ context.Context, file *os.File, _ files.Entry) (decodedImage, error) {
			return decodeImage(file)
		}
	case mimeType == pdfMime:
		return func(_ context.Context, file *os.File, entry files.Entry) (decodedImage, error) {
			return w.pdf.render(file, entry.Size, largestSize)
		}
	case available.ffmpeg && strings.HasPrefix(mimeType, "image/"):
		return func(ctx context.Context, file *os.File, _ files.Entry) (decodedImage, error) {
			return w.ffmpeg.renderStillImage(ctx, file, largestSize)
		}
	case available.ffmpeg && strings.HasPrefix(mimeType, "video/"):
		return func(ctx context.Context, file *os.File, _ files.Entry) (decodedImage, error) {
			return w.ffmpeg.renderVideo(ctx, file, largestSize)
		}
	case canCarryThumbnail(mimeType) || available.convertible[mimeType]:
		convertible := available.convertible[mimeType]
		return func(ctx context.Context, file *os.File, entry files.Entry) (decodedImage, error) {
			return w.renderDocument(ctx, file, entry, convertible, largestSize)
		}
	}
	return nil
}

func (w *Worker) requestNewlyPreviewable(ctx context.Context) {
	available := w.currentCapabilities(ctx)
	signature := fmt.Sprint(available.ffmpeg, slices.Sorted(maps.Keys(available.convertible)))
	if signature == w.requestedCapabilities {
		return
	}
	mimes, err := w.files.MimesWithoutPreview(ctx)
	if err != nil {
		logger.Warn("load types without a preview", "error", err)
		return
	}
	for _, mimeType := range mimes {
		if w.rendererFor(available, mimeType) == nil {
			continue
		}
		requested, err := w.files.RequestPreviews(ctx, mimeType)
		if err != nil {
			logger.Warn("request previews", "mime", mimeType, "error", err)
			return
		}
		logger.Info("requested previews", "mime", mimeType, "files", requested)
	}
	w.requestedCapabilities = signature
}

func (w *Worker) generate(ctx context.Context, owner users.User, entry files.Entry, available capabilities) (map[string]any, files.PreviewState) {
	render := w.rendererFor(available, entry.Mime)
	if render == nil {
		return entry.Meta, files.PreviewNone
	}
	file, _, err := w.files.Open(ctx, owner, entry.Path)
	if err != nil {
		return entry.Meta, files.PreviewFailed
	}
	defer file.Close()

	decoded, err := render(ctx, file, entry)
	if errors.Is(err, office.ErrUnavailable) {
		logger.Warn("document previews paused", "error", err, "retry", officeRetryDelay)
		w.officePausedUntil = time.Now().Add(officeRetryDelay)
		return entry.Meta, files.PreviewNone
	}
	if errors.Is(err, errNoThumbnail) {
		return decoded.meta(), files.PreviewNone
	}
	if err != nil {
		logger.Debug("preview decode failed", "path", entry.Path, "error", err)
		return decoded.meta(), files.PreviewFailed
	}
	for _, size := range Sizes {
		if err := writeThumbnail(decoded, size, w.ThumbnailPath(entry.Hash, size)); err != nil {
			logger.Warn("write thumbnail", "path", entry.Path, "error", err)
			return decoded.meta(), files.PreviewFailed
		}
	}
	return decoded.meta(), files.PreviewReady
}

func (w *Worker) removeUnusedThumbnails(ctx context.Context) {
	inUse, err := w.files.HashesInUse(ctx)
	if err != nil {
		logger.Warn("load hashes for thumbnail cleanup", "error", err)
		return
	}
	err = filepath.WalkDir(w.cacheDir, func(current string, entry fs.DirEntry, err error) error {
		if errors.Is(err, fs.ErrNotExist) {
			return nil
		}
		if err != nil || entry.IsDir() {
			return err
		}
		contentHash, _, isThumbnail := strings.Cut(entry.Name(), "-")
		if isThumbnail && !inUse[contentHash] {
			return os.Remove(current)
		}
		return nil
	})
	if err != nil {
		logger.Warn("remove unused thumbnails", "error", err)
	}
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
