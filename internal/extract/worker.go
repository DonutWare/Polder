package extract

import (
	"bytes"
	"context"
	"errors"
	"image"
	"io"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/files"
	"polder-server/internal/logging"
	"polder-server/internal/preview"
	"polder-server/internal/settings"
	"polder-server/internal/users"
)

var logger = logging.For("extract")

const (
	queueCapacity   = 1024
	backlogInterval = time.Minute
	backlogBatch    = 20
	pdfIdleTimeout  = 5 * time.Minute
	ocrOff          = "off"
)

// DefaultOCRLanguages reads every major writing system, so no language has to be assumed.
var DefaultOCRLanguages = []string{
	"script/Latin", "script/Cyrillic", "script/Arabic", "script/Devanagari",
	"script/HanS", "script/HanT", "script/Japanese", "script/Hangul",
}

const DefaultOCRMaxPages = 50

type OCRState string

const (
	OCROff         OCRState = "off"
	OCRReady       OCRState = "ready"
	OCRUnavailable OCRState = "unavailable"
)

func (OCRState) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(OCROff), string(OCRReady), string(OCRUnavailable)}
	return s
}

type ExtractionStatus struct {
	Pending    int      `json:"pending" doc:"Files whose text has not been read yet"`
	OCR        OCRState `json:"ocr"`
	OCRProblem string   `json:"ocrProblem,omitempty" required:"false" doc:"Why OCR is unavailable"`
}

type Options struct {
	CacheDir      string
	ModelDir      string
	TesseractPath string
	ModelURL      string
}

type ExtractedFunc func(ctx context.Context, entry files.Entry)

type job struct {
	userID int64
	path   string
}

type plan struct {
	ocrLanguages []string
	maxOCRPages  int
	holdOCR      bool
}

type Worker struct {
	files    *files.Service
	users    *users.Store
	settings *settings.Store
	cache    *Cache
	fresh    bool
	ocr      *tesseract
	pdf      pdfReader
	queue    chan job
	cleanups chan struct{}

	extracted []ExtractedFunc

	mu         sync.Mutex
	ocrState   OCRState
	ocrProblem string
}

func NewWorker(fileService *files.Service, userStore *users.Store, settingsStore *settings.Store, options Options) (*Worker, error) {
	cache, fresh, err := OpenCache(options.CacheDir)
	if err != nil {
		return nil, err
	}
	return &Worker{
		files:    fileService,
		users:    userStore,
		settings: settingsStore,
		cache:    cache,
		fresh:    fresh,
		ocr:      newTesseract(options.TesseractPath, options.ModelDir, options.ModelURL),
		queue:    make(chan job, queueCapacity),
		cleanups: make(chan struct{}, 1),
		ocrState: OCROff,
	}, nil
}

func (w *Worker) Cache() *Cache { return w.cache }

func (w *Worker) OnExtracted(callback ExtractedFunc) {
	w.extracted = append(w.extracted, callback)
}

func (w *Worker) Enqueue(userID int64, cleanPath string) {
	select {
	case w.queue <- job{userID: userID, path: cleanPath}:
	default:
	}
}

func (w *Worker) RequestCleanup() {
	select {
	case w.cleanups <- struct{}{}:
	default:
	}
}

func (w *Worker) Status(ctx context.Context) (ExtractionStatus, error) {
	pending, err := w.files.CountAwaitingText(ctx)
	w.mu.Lock()
	defer w.mu.Unlock()
	return ExtractionStatus{Pending: pending, OCR: w.ocrState, OCRProblem: w.ocrProblem}, err
}

func (w *Worker) Run(ctx context.Context) {
	if w.fresh {
		if err := w.files.RequeueText(ctx); err != nil {
			logger.Warn("queue files for text extraction", "error", err)
		} else if err := w.cache.setApplied(""); err != nil {
			logger.Warn("store text cache state", "error", err)
		}
	}
	w.removeUnused(ctx)
	sweep := time.NewTimer(0)
	defer sweep.Stop()
	pdfIdle := time.NewTimer(pdfIdleTimeout)
	defer pdfIdle.Stop()
	defer w.pdf.close()
	for {
		select {
		case <-ctx.Done():
			return
		case next := <-w.queue:
			if current, enabled := w.plan(ctx); enabled {
				w.processPath(ctx, current, next.userID, next.path)
			}
		case <-w.cleanups:
			w.removeUnused(ctx)
		case <-sweep.C:
			if w.sweep(ctx) {
				sweep.Reset(0)
			} else {
				sweep.Reset(backlogInterval)
			}
		case <-pdfIdle.C:
			w.pdf.close()
		}
		if w.pdf.used {
			w.pdf.used = false
			pdfIdle.Reset(pdfIdleTimeout)
		}
	}
}

func (w *Worker) sweep(ctx context.Context) (more bool) {
	current, enabled := w.plan(ctx)
	if !enabled {
		return false
	}
	var held []string
	if current.holdOCR {
		held = ocrMimePatterns
	}
	pending, err := w.files.EntriesAwaitingText(ctx, backlogBatch, held...)
	if err != nil {
		logger.Warn("load text extraction backlog", "error", err)
		return false
	}
	for _, entry := range pending {
		if ctx.Err() != nil {
			return false
		}
		w.processPath(ctx, current, entry.UserID, entry.Path)
	}
	return len(pending) == backlogBatch
}

// plan reads the settings for the next extraction. A change to the OCR settings queues every file OCR
// applies to again, once the models it needs are on disk; until then those files wait.
func (w *Worker) plan(ctx context.Context) (plan, bool) {
	server, err := w.settings.Get(ctx)
	if err != nil {
		logger.Warn("load settings for text extraction", "error", err)
		return plan{}, false
	}
	if !server.SearchContentEnabled {
		return plan{}, false
	}
	wanted := server.OCREnabled && len(server.OCRLanguages) > 0
	desired := ocrOff
	if wanted && w.ocr.installed() {
		desired = ocrFingerprint(server.OCRLanguages, server.OCRMaxPages)
		if err := w.ocr.ensureModels(ctx, server.OCRLanguages); err != nil {
			w.setOCR(OCRUnavailable, err.Error())
			return plan{holdOCR: true}, true
		}
	}
	if desired != w.cache.applied() {
		if err := w.files.RequeueText(ctx, ocrMimePatterns...); err != nil {
			logger.Warn("queue files for OCR", "error", err)
			return plan{holdOCR: true}, true
		}
		if err := w.cache.setApplied(desired); err != nil {
			logger.Warn("store text cache state", "error", err)
			return plan{holdOCR: true}, true
		}
		w.RequestCleanup()
	}
	switch {
	case desired != ocrOff:
		w.setOCR(OCRReady, "")
		return plan{ocrLanguages: server.OCRLanguages, maxOCRPages: server.OCRMaxPages}, true
	case wanted:
		w.setOCR(OCRUnavailable, "tesseract is not installed")
	default:
		w.setOCR(OCROff, "")
	}
	return plan{}, true
}

func ocrFingerprint(languages []string, maxPages int) string {
	return strings.Join(languages, "+") + ":" + strconv.Itoa(maxPages)
}

func (w *Worker) setOCR(state OCRState, problem string) {
	w.mu.Lock()
	defer w.mu.Unlock()
	if state == OCRUnavailable && problem != w.ocrProblem {
		logger.Warn("OCR unavailable", "reason", problem)
	}
	w.ocrState, w.ocrProblem = state, problem
}

func (w *Worker) processPath(ctx context.Context, current plan, userID int64, cleanPath string) {
	owner, err := w.users.ByID(ctx, userID)
	if err != nil {
		return
	}
	entry, err := w.files.Stat(ctx, owner, cleanPath)
	if err != nil || entry.IsDir || entry.TextState != files.TextPending {
		return
	}
	if current.holdOCR && ocrApplies(entry.Mime) {
		return
	}
	state := w.extract(ctx, owner, entry, current)
	if ctx.Err() != nil {
		return
	}
	if err := w.files.UpdateTextState(ctx, owner.ID, entry.Path, entry.Hash, state); err != nil {
		logger.Warn("store text extraction state", "path", entry.Path, "error", err)
		return
	}
	// Callbacks also run when no text was found, so text from an earlier read is dropped.
	entry.TextState = state
	for _, callback := range w.extracted {
		callback(ctx, entry)
	}
}

func (w *Worker) extract(ctx context.Context, owner users.User, entry files.Entry, current plan) files.TextState {
	ready := entry
	ready.TextState = files.TextReady
	if _, cached := w.cache.Text(ready); cached {
		return files.TextReady
	}
	file, _, err := w.files.Open(ctx, owner, entry.Path)
	if err != nil {
		return files.TextFailed
	}
	defer file.Close()

	text, err := w.read(ctx, file, entry, current)
	text = normalizeText(text)
	switch {
	case errors.Is(err, errNoText):
		return files.TextSkipped
	case err != nil && !hasWords(text):
		logger.Debug("text extraction failed", "path", entry.Path, "error", err)
		return files.TextFailed
	case !hasWords(text):
		return files.TextSkipped
	}
	if err := w.cache.store(ready, text); err != nil {
		logger.Warn("store extracted text", "path", entry.Path, "error", err)
		return files.TextFailed
	}
	return files.TextReady
}

func (w *Worker) read(ctx context.Context, file *os.File, entry files.Entry, current plan) (string, error) {
	head := make([]byte, sniffBytes)
	read, err := file.ReadAt(head, 0)
	if err != nil && !errors.Is(err, io.EOF) {
		return "", err
	}
	head = head[:read]
	var recognize recognizePage
	if len(current.ocrLanguages) > 0 && ocrApplies(entry.Mime) {
		recognize = func(page image.Image, dpi int) (string, error) {
			return w.ocr.recognize(ctx, page, current.ocrLanguages, dpi)
		}
	}
	switch {
	case bytes.HasPrefix(head, []byte("%PDF-")):
		return w.pdf.read(file, entry.Size, recognize, current.maxOCRPages)
	case bytes.HasPrefix(head, []byte("PK\x03\x04")):
		return readZipDocument(file, entry.Size)
	case looksLikeText(head):
		return readPlainText(io.NewSectionReader(file, 0, entry.Size))
	case recognize != nil:
		if _, _, err := image.DecodeConfig(bytes.NewReader(head)); err != nil && !errors.Is(err, io.ErrUnexpectedEOF) {
			return "", errNoText
		}
		if _, err := file.Seek(0, io.SeekStart); err != nil {
			return "", err
		}
		upright, err := preview.DecodeUpright(file, maxOCREdge)
		if err != nil {
			return "", errNoText
		}
		return recognize(upright, 0)
	default:
		return "", errNoText
	}
}

func (w *Worker) removeUnused(ctx context.Context) {
	inUse, err := w.files.HashesInUse(ctx)
	if err != nil {
		logger.Warn("load hashes for text cache cleanup", "error", err)
		return
	}
	if err := w.cache.removeUnused(inUse); err != nil {
		logger.Warn("remove unused extracted text", "error", err)
	}
}
