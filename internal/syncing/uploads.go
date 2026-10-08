package syncing

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/chunker"
	"polder-server/internal/files"
	"polder-server/internal/storage"
	"polder-server/internal/users"
)

const UploadLifetime = 24 * time.Hour

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

type UploadStatus struct {
	UploadID string   `json:"uploadId"`
	Missing  []string `json:"missing"`
}

type upload struct {
	id      string
	userID  int64
	request UploadRequest
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
		return apperr.Invalid("chunk sizes add up to %d, expected %d", total, r.Size)
	}
	return nil
}

func (s *Service) CreateUpload(ctx context.Context, owner users.User, request UploadRequest) (UploadStatus, error) {
	if err := request.validate(); err != nil {
		return UploadStatus{}, err
	}
	if err := s.checkUploadAllowed(ctx, owner, request); err != nil {
		return UploadStatus{}, err
	}
	created := upload{id: storage.NewID(), userID: owner.ID, request: request}
	if err := os.MkdirAll(s.stagingDir(created.id), 0o750); err != nil {
		return UploadStatus{}, err
	}
	if err := s.insertUpload(ctx, created); err != nil {
		return UploadStatus{}, err
	}
	return s.status(ctx, owner, created)
}

func (s *Service) checkUploadAllowed(ctx context.Context, owner users.User, request UploadRequest) error {
	current, exists, err := s.currentEntry(ctx, owner, request.Path)
	if err != nil {
		return err
	}
	if err := files.CheckWritePreconditions(current, exists, request.BaseRev); err != nil {
		return err
	}
	if owner.HasUnlimitedQuota() {
		return nil
	}
	used, err := s.files.FileBytes(ctx, owner.ID)
	if err != nil {
		return err
	}
	if used-current.Size+request.Size > owner.QuotaBytes {
		return apperr.QuotaExceeded("this upload exceeds your storage quota")
	}
	return nil
}

func (s *Service) currentEntry(ctx context.Context, owner users.User, cleanPath string) (files.Entry, bool, error) {
	entry, err := s.files.Stat(ctx, owner, cleanPath)
	if apperr.Is(err, apperr.KindNotFound) {
		return files.Entry{}, false, nil
	}
	return entry, err == nil, err
}

func (s *Service) UploadStatus(ctx context.Context, owner users.User, uploadID string) (UploadStatus, error) {
	found, err := s.loadUpload(ctx, owner, uploadID)
	if err != nil {
		return UploadStatus{}, err
	}
	return s.status(ctx, owner, found)
}

func (s *Service) status(ctx context.Context, owner users.User, target upload) (UploadStatus, error) {
	sources, err := s.availableChunkSources(ctx, owner, target)
	if err != nil {
		return UploadStatus{}, err
	}
	missing := []string{}
	seen := map[string]bool{}
	for _, chunk := range target.request.Chunks {
		if _, available := sources[chunk.Hash]; !available && !seen[chunk.Hash] {
			missing = append(missing, chunk.Hash)
			seen[chunk.Hash] = true
		}
	}
	return UploadStatus{UploadID: target.id, Missing: missing}, nil
}

func (s *Service) Remaining(ctx context.Context, owner users.User, uploadID string) (string, int64, error) {
	found, err := s.loadUpload(ctx, owner, uploadID)
	if err != nil {
		return "", 0, err
	}
	status, err := s.status(ctx, owner, found)
	if err != nil {
		return "", 0, err
	}
	return found.request.Path, MissingBytes(found.request.Chunks, status.Missing), nil
}

func MissingBytes(chunks []ChunkRef, missing []string) int64 {
	wanted := make(map[string]bool, len(missing))
	for _, hash := range missing {
		wanted[hash] = true
	}
	var total int64
	for _, chunk := range chunks {
		if wanted[chunk.Hash] {
			total += chunk.Size
			delete(wanted, chunk.Hash)
		}
	}
	return total
}

func (s *Service) PutChunk(ctx context.Context, owner users.User, uploadID, chunkHash string, body io.Reader) error {
	target, err := s.loadUpload(ctx, owner, uploadID)
	if err != nil {
		return err
	}
	if !target.expectsChunk(chunkHash) {
		return apperr.Invalid("chunk %s is not part of this upload", chunkHash)
	}
	return s.storeVerifiedChunk(target.id, chunkHash, body)
}

func (u upload) expectsChunk(chunkHash string) bool {
	for _, chunk := range u.request.Chunks {
		if chunk.Hash == chunkHash {
			return true
		}
	}
	return false
}

func (s *Service) storeVerifiedChunk(uploadID, chunkHash string, body io.Reader) error {
	temp, err := os.CreateTemp(s.stagingDir(uploadID), "incoming-*")
	if err != nil {
		return err
	}
	defer os.Remove(temp.Name())

	hasher := sha256.New()
	written, copyErr := io.Copy(io.MultiWriter(temp, hasher), io.LimitReader(body, chunker.MaxSize+1))
	if err := errors.Join(copyErr, temp.Close()); err != nil {
		return fmt.Errorf("store chunk: %w", err)
	}
	if written > chunker.MaxSize {
		return apperr.Invalid("chunk is larger than %d bytes", chunker.MaxSize)
	}
	if actual := hex.EncodeToString(hasher.Sum(nil)); actual != chunkHash {
		return apperr.Invalid("chunk hash mismatch: got %s", actual)
	}
	return os.Rename(temp.Name(), s.stagedChunkPath(uploadID, chunkHash))
}

func (s *Service) CommitUpload(ctx context.Context, owner users.User, uploadID string) (files.Entry, error) {
	target, err := s.loadUpload(ctx, owner, uploadID)
	if err != nil {
		return files.Entry{}, err
	}
	sources, err := s.availableChunkSources(ctx, owner, target)
	if err != nil {
		return files.Entry{}, err
	}
	content, err := s.assemble(ctx, owner, target, sources)
	if err != nil {
		return files.Entry{}, err
	}
	defer content.Close()

	entry, err := s.files.Write(ctx, owner, files.WriteRequest{
		Path:         target.request.Path,
		BaseRev:      target.request.BaseRev,
		Mtime:        target.request.Mtime,
		ExpectedHash: target.request.Hash,
		Content:      content,
	})
	if err != nil {
		return files.Entry{}, err
	}
	return entry, s.removeUpload(ctx, target.id)
}

func (s *Service) AbortUpload(ctx context.Context, owner users.User, uploadID string) error {
	target, err := s.loadUpload(ctx, owner, uploadID)
	if err != nil {
		return err
	}
	return s.removeUpload(ctx, target.id)
}

func (s *Service) RemoveExpiredUploads(ctx context.Context) error {
	expired, err := s.expiredUploadIDs(ctx)
	if err != nil {
		return err
	}
	for _, id := range expired {
		if err := s.removeUpload(ctx, id); err != nil {
			return err
		}
	}
	return nil
}

func (s *Service) expiredUploadIDs(ctx context.Context) ([]string, error) {
	cutoff := time.Now().Add(-UploadLifetime).Unix()
	rows, err := s.db.QueryContext(ctx, `SELECT id FROM uploads WHERE created_at < $1`, cutoff)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var expired []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		expired = append(expired, id)
	}
	return expired, rows.Err()
}

func (s *Service) insertUpload(ctx context.Context, created upload) error {
	chunksJSON, err := json.Marshal(created.request.Chunks)
	if err != nil {
		return err
	}
	request := created.request
	_, err = s.db.ExecContext(ctx,
		`INSERT INTO uploads (id, user_id, path, base_rev, size, hash, mtime_ns, chunks_json, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
		created.id, created.userID, request.Path, request.BaseRev, request.Size, request.Hash, unixNanosOrZero(request.Mtime),
		string(chunksJSON), time.Now().Unix())
	return err
}

func (s *Service) loadUpload(ctx context.Context, owner users.User, uploadID string) (upload, error) {
	found := upload{id: uploadID}
	var mtimeNanos int64
	var chunksJSON string
	err := s.db.QueryRowContext(ctx,
		`SELECT user_id, path, base_rev, size, hash, mtime_ns, chunks_json FROM uploads WHERE id = $1`, uploadID).
		Scan(&found.userID, &found.request.Path, &found.request.BaseRev, &found.request.Size, &found.request.Hash, &mtimeNanos, &chunksJSON)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && found.userID != owner.ID) {
		return upload{}, apperr.NotFound("upload not found")
	}
	if err != nil {
		return upload{}, err
	}
	if mtimeNanos != 0 {
		found.request.Mtime = time.Unix(0, mtimeNanos).UTC()
	}
	return found, json.Unmarshal([]byte(chunksJSON), &found.request.Chunks)
}

func (s *Service) removeUpload(ctx context.Context, uploadID string) error {
	if _, err := s.db.ExecContext(ctx, `DELETE FROM uploads WHERE id = $1`, uploadID); err != nil {
		return err
	}
	err := os.RemoveAll(s.stagingDir(uploadID))
	if errors.Is(err, fs.ErrNotExist) {
		return nil
	}
	return err
}

func (s *Service) stagingDir(uploadID string) string {
	return filepath.Join(s.files.Disk().UploadsDir(), uploadID)
}

func (s *Service) stagedChunkPath(uploadID, chunkHash string) string {
	return filepath.Join(s.stagingDir(uploadID), chunkHash)
}

func unixNanosOrZero(moment time.Time) int64 {
	if moment.IsZero() {
		return 0
	}
	return moment.UnixNano()
}
