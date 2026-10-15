package syncing

import (
	"context"
	"errors"
	"os"
	"regexp"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/chunker"
	"polder-server/internal/files"
	"polder-server/internal/logging"
	"polder-server/internal/storage"
	"polder-server/internal/users"
)

var logger = logging.For("sync")

const (
	UploadLifetime = 24 * time.Hour
	MaxBatchFiles  = 1000
)

var sha256Pattern = regexp.MustCompile(`^[0-9a-f]{64}$`)

type ChunkRef struct {
	Hash string `json:"hash"`
	Size int64  `json:"size"`
}

type UploadRequest struct {
	Path    string     `json:"path"`
	BaseRev int64      `json:"baseRev" required:"false" doc:"Revision this upload replaces: 0 when the file must not exist yet, -1 to overwrite whatever is there"`
	Size    int64      `json:"size"`
	Hash    string     `json:"hash" doc:"Lowercase hex SHA-256 of the whole file"`
	Mtime   time.Time  `json:"mtime" required:"false"`
	Chunks  []ChunkRef `json:"chunks" doc:"The file's chunks in order"`
}

type BatchRequest struct {
	Files []UploadRequest `json:"files" minItems:"1" maxItems:"1000" doc:"The files to upload; each path at most once"`
}

type FileError struct {
	Code    string       `json:"code" doc:"Machine-readable error code, such as conflict or quota_exceeded"`
	Message string       `json:"message"`
	Current *files.Entry `json:"current,omitempty" required:"false" doc:"The server's current entry, sent with conflict and already_exists errors"`
}

type FileResult struct {
	Path  string       `json:"path"`
	Entry *files.Entry `json:"entry,omitempty" required:"false" doc:"The stored file, when it was committed"`
	Error *FileError   `json:"error,omitempty" required:"false" doc:"Why the file was not stored"`
}

type BatchStatus struct {
	BatchID string       `json:"batchId"`
	Missing []ChunkRef   `json:"missing" doc:"The chunks the server still needs, in the order to stream them"`
	Results []FileResult `json:"results" doc:"The files that are finished, stored or failed; the batch is gone once every file is here"`
}

type batch struct {
	id     string
	userID int64
	files  []batchFile
}

type batchFile struct {
	idx     int
	request UploadRequest
	result  *FileResult
}

func (b batch) unfinishedFiles() []batchFile {
	var unfinished []batchFile
	for _, file := range b.files {
		if file.result == nil {
			unfinished = append(unfinished, file)
		}
	}
	return unfinished
}

func (b batch) results() []FileResult {
	results := []FileResult{}
	for _, file := range b.files {
		if file.result != nil {
			results = append(results, *file.result)
		}
	}
	return results
}

func (r *UploadRequest) validate() error {
	cleanPath, err := storage.CleanPath(r.Path)
	if err != nil {
		return err
	}
	if cleanPath == storage.RootPath {
		return apperr.Invalid("cannot upload to the root directory")
	}
	r.Path = cleanPath
	if !sha256Pattern.MatchString(r.Hash) {
		return apperr.Invalid("hash must be a lowercase sha256 hex string")
	}
	var total int64
	for _, chunk := range r.Chunks {
		if !sha256Pattern.MatchString(chunk.Hash) || chunk.Size <= 0 || chunk.Size > chunker.MaxSize {
			return apperr.Invalid("invalid chunk %q", chunk.Hash)
		}
		total += chunk.Size
	}
	if total != r.Size {
		return apperr.Invalid("chunk sizes add up to %d, expected %d for %s", total, r.Size, r.Path)
	}
	return nil
}

func (r *BatchRequest) validate() error {
	if len(r.Files) == 0 || len(r.Files) > MaxBatchFiles {
		return apperr.Invalid("a batch holds 1 to %d files", MaxBatchFiles)
	}
	seen := make(map[string]bool, len(r.Files))
	for i := range r.Files {
		if err := r.Files[i].validate(); err != nil {
			return err
		}
		if seen[r.Files[i].Path] {
			return apperr.Invalid("%s is in the batch more than once", r.Files[i].Path)
		}
		seen[r.Files[i].Path] = true
	}
	return nil
}

func (s *Service) CreateBatch(ctx context.Context, owner users.User, request BatchRequest) (BatchStatus, error) {
	if err := request.validate(); err != nil {
		return BatchStatus{}, err
	}
	accepted, err := s.rejectDisallowedFiles(ctx, owner, request.Files)
	if err != nil {
		return BatchStatus{}, err
	}
	created := batch{id: storage.NewID(), userID: owner.ID, files: accepted}
	if err := os.MkdirAll(s.stagingDir(created.id), 0o750); err != nil {
		return BatchStatus{}, err
	}
	if err := s.adoptChunksStagedByOtherBatches(ctx, owner, created); err != nil {
		return BatchStatus{}, err
	}
	if err := s.insertBatch(ctx, created); err != nil {
		return BatchStatus{}, err
	}
	return s.status(ctx, owner, created)
}

func (s *Service) rejectDisallowedFiles(ctx context.Context, owner users.User, requests []UploadRequest) ([]batchFile, error) {
	remaining, err := s.remainingQuota(ctx, owner)
	if err != nil {
		return nil, err
	}
	checked := make([]batchFile, 0, len(requests))
	for i, request := range requests {
		file := batchFile{idx: i, request: request}
		if err := s.checkFileAllowed(ctx, owner, request, &remaining); err != nil {
			result, err := resultForError(request.Path, err)
			if err != nil {
				return nil, err
			}
			file.result = &result
		}
		checked = append(checked, file)
	}
	return checked, nil
}

const unlimitedQuota int64 = -1

func (s *Service) remainingQuota(ctx context.Context, owner users.User) (int64, error) {
	if owner.HasUnlimitedQuota() {
		return unlimitedQuota, nil
	}
	used, err := s.files.FileBytes(ctx, owner.ID)
	if err != nil {
		return 0, err
	}
	return owner.QuotaBytes - used, nil
}

func (s *Service) checkFileAllowed(ctx context.Context, owner users.User, request UploadRequest, remainingQuota *int64) error {
	current, exists, err := s.currentEntry(ctx, owner, request.Path)
	if err != nil {
		return err
	}
	if err := files.CheckWritePreconditions(current, exists, request.BaseRev); err != nil {
		return err
	}
	if *remainingQuota == unlimitedQuota {
		return nil
	}
	growth := request.Size - current.Size
	if growth > *remainingQuota {
		return apperr.QuotaExceeded("%s exceeds your storage quota", request.Path)
	}
	*remainingQuota -= growth
	return nil
}

func (s *Service) currentEntry(ctx context.Context, owner users.User, cleanPath string) (files.Entry, bool, error) {
	entry, err := s.files.Stat(ctx, owner, cleanPath)
	if apperr.Is(err, apperr.KindNotFound) {
		return files.Entry{}, false, nil
	}
	return entry, err == nil, err
}

func resultForError(filePath string, err error) (FileResult, error) {
	appErr, ok := errors.AsType[*apperr.Error](err)
	if !ok {
		return FileResult{}, err
	}
	failure := &FileError{Code: string(appErr.Kind), Message: appErr.Message}
	if current, ok := appErr.Current.(files.Entry); ok {
		failure.Current = &current
	}
	return FileResult{Path: filePath, Error: failure}, nil
}

func (s *Service) BatchStatus(ctx context.Context, owner users.User, batchID string) (BatchStatus, error) {
	found, err := s.loadBatch(ctx, owner, batchID)
	if err != nil {
		return BatchStatus{}, err
	}
	return s.status(ctx, owner, found)
}

func (s *Service) status(ctx context.Context, owner users.User, target batch) (BatchStatus, error) {
	plan, err := s.planBatch(ctx, owner, target)
	if err != nil {
		return BatchStatus{}, err
	}
	return BatchStatus{BatchID: target.id, Missing: plan.missing, Results: target.results()}, nil
}

func (s *Service) AbortBatch(ctx context.Context, owner users.User, batchID string) error {
	if _, err := s.loadBatch(ctx, owner, batchID); err != nil {
		return err
	}
	return s.removeBatch(ctx, batchID)
}
