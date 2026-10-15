package syncing

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"io/fs"
	"os"
	"path/filepath"
	"sync"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

func (s *Service) insertBatch(ctx context.Context, created batch) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	_, err = tx.ExecContext(ctx, `INSERT INTO upload_batches (id, user_id, created_at) VALUES ($1, $2, $3)`,
		created.id, created.userID, time.Now().Unix())
	if err != nil {
		return err
	}
	for _, file := range created.files {
		if err := insertBatchFile(ctx, tx, created.id, file); err != nil {
			return err
		}
	}
	return tx.Commit()
}

func insertBatchFile(ctx context.Context, tx *sql.Tx, batchID string, file batchFile) error {
	requestJSON, err := json.Marshal(file.request)
	if err != nil {
		return err
	}
	resultJSON, err := marshalResult(file.result)
	if err != nil {
		return err
	}
	_, err = tx.ExecContext(ctx,
		`INSERT INTO upload_batch_files (batch_id, idx, request_json, result_json) VALUES ($1, $2, $3, $4)`,
		batchID, file.idx, string(requestJSON), resultJSON)
	return err
}

func marshalResult(result *FileResult) (sql.NullString, error) {
	if result == nil {
		return sql.NullString{}, nil
	}
	encoded, err := json.Marshal(result)
	return sql.NullString{String: string(encoded), Valid: true}, err
}

func (s *Service) saveResult(ctx context.Context, batchID string, idx int, result FileResult) error {
	resultJSON, err := marshalResult(&result)
	if err != nil {
		return err
	}
	_, err = s.db.ExecContext(ctx, `UPDATE upload_batch_files SET result_json = $1 WHERE batch_id = $2 AND idx = $3`,
		resultJSON, batchID, idx)
	return err
}

func (s *Service) loadBatch(ctx context.Context, owner users.User, batchID string) (batch, error) {
	found := batch{id: batchID}
	err := s.db.QueryRowContext(ctx, `SELECT user_id FROM upload_batches WHERE id = $1`, batchID).Scan(&found.userID)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && found.userID != owner.ID) {
		return batch{}, apperr.NotFound("upload batch not found")
	}
	if err != nil {
		return batch{}, err
	}
	found.files, err = s.loadBatchFiles(ctx, batchID)
	return found, err
}

func (s *Service) loadBatchFiles(ctx context.Context, batchID string) ([]batchFile, error) {
	rows, err := s.db.QueryContext(ctx,
		`SELECT idx, request_json, result_json FROM upload_batch_files WHERE batch_id = $1 ORDER BY idx`, batchID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var loaded []batchFile
	for rows.Next() {
		file, err := scanBatchFile(rows)
		if err != nil {
			return nil, err
		}
		loaded = append(loaded, file)
	}
	return loaded, rows.Err()
}

func scanBatchFile(rows *sql.Rows) (batchFile, error) {
	var file batchFile
	var requestJSON string
	var resultJSON sql.NullString
	if err := rows.Scan(&file.idx, &requestJSON, &resultJSON); err != nil {
		return batchFile{}, err
	}
	if err := json.Unmarshal([]byte(requestJSON), &file.request); err != nil {
		return batchFile{}, err
	}
	if !resultJSON.Valid {
		return file, nil
	}
	file.result = &FileResult{}
	return file, json.Unmarshal([]byte(resultJSON.String), file.result)
}

func (s *Service) removeBatch(ctx context.Context, batchID string) error {
	if _, err := s.db.ExecContext(ctx, `DELETE FROM upload_batches WHERE id = $1`, batchID); err != nil {
		return err
	}
	err := os.RemoveAll(s.stagingDir(batchID))
	if errors.Is(err, fs.ErrNotExist) {
		return nil
	}
	return err
}

func (s *Service) RemoveExpiredUploads(ctx context.Context) error {
	cutoff := time.Now().Add(-UploadLifetime)
	expired, err := s.expiredBatchIDs(ctx, cutoff.Unix())
	if err != nil {
		return err
	}
	for _, id := range expired {
		if err := s.removeBatch(ctx, id); err != nil {
			return err
		}
	}
	return s.removeStagingWithoutBatch(ctx, cutoff)
}

func (s *Service) expiredBatchIDs(ctx context.Context, cutoff int64) ([]string, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT id FROM upload_batches WHERE created_at < $1`, cutoff)
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

func (s *Service) removeStagingWithoutBatch(ctx context.Context, cutoff time.Time) error {
	entries, err := os.ReadDir(s.files.Disk().UploadsDir())
	if errors.Is(err, fs.ErrNotExist) {
		return nil
	}
	if err != nil {
		return err
	}
	for _, entry := range entries {
		info, err := entry.Info()
		if err != nil || !entry.IsDir() || info.ModTime().After(cutoff) {
			continue
		}
		if err := s.removeStagingIfUnowned(ctx, entry.Name()); err != nil {
			return err
		}
	}
	return nil
}

func (s *Service) removeStagingIfUnowned(ctx context.Context, batchID string) error {
	var owned bool
	err := s.db.QueryRowContext(ctx, `SELECT EXISTS (SELECT 1 FROM upload_batches WHERE id = $1)`, batchID).Scan(&owned)
	if err != nil || owned {
		return err
	}
	return os.RemoveAll(s.stagingDir(batchID))
}

func (s *Service) adoptChunksStagedByOtherBatches(ctx context.Context, owner users.User, adopting batch) error {
	others, err := s.batchIDsOf(ctx, owner.ID)
	if err != nil || len(others) == 0 {
		return err
	}
	for _, file := range adopting.unfinishedFiles() {
		for _, chunk := range file.request.Chunks {
			s.adoptChunk(adopting.id, chunk.Hash, others)
		}
	}
	return nil
}

func (s *Service) adoptChunk(batchID, chunkHash string, otherBatchIDs []string) {
	target := s.stagedChunkPath(batchID, chunkHash)
	if _, err := os.Stat(target); err == nil {
		return
	}
	for _, other := range otherBatchIDs {
		if os.Link(s.stagedChunkPath(other, chunkHash), target) == nil {
			return
		}
	}
}

func (s *Service) batchIDsOf(ctx context.Context, userID int64) ([]string, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT id FROM upload_batches WHERE user_id = $1`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, rows.Err()
}

func (s *Service) stagingDir(batchID string) string {
	return filepath.Join(s.files.Disk().UploadsDir(), batchID)
}

func (s *Service) stagedChunkPath(batchID, chunkHash string) string {
	return filepath.Join(s.stagingDir(batchID), chunkHash)
}

type streamLocks struct {
	mu   sync.Mutex
	held map[string]bool
}

func (l *streamLocks) acquire(batchID string) (release func(), ok bool) {
	l.mu.Lock()
	defer l.mu.Unlock()
	if l.held == nil {
		l.held = map[string]bool{}
	}
	if l.held[batchID] {
		return nil, false
	}
	l.held[batchID] = true
	var once sync.Once
	return func() {
		once.Do(func() {
			l.mu.Lock()
			defer l.mu.Unlock()
			delete(l.held, batchID)
		})
	}, true
}
