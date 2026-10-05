package syncing

import (
	"context"
	"database/sql"

	"polder-server/internal/apperr"
	"polder-server/internal/chunker"
	"polder-server/internal/files"
	"polder-server/internal/users"
)

type Manifest struct {
	Path   string          `json:"path"`
	Rev    int64           `json:"rev"`
	Size   int64           `json:"size"`
	Hash   string          `json:"hash"`
	Chunks []chunker.Chunk `json:"chunks"`
}

type Service struct {
	db    *sql.DB
	files *files.Service
}

func NewService(db *sql.DB, fileService *files.Service) *Service {
	return &Service{db: db, files: fileService}
}

func (s *Service) Manifest(ctx context.Context, owner users.User, rawPath string) (Manifest, error) {
	entry, err := s.files.Stat(ctx, owner, rawPath)
	if err != nil {
		return Manifest{}, err
	}
	if entry.IsDir {
		return Manifest{}, apperr.Invalid("%s is a directory", entry.Path)
	}
	chunks, err := s.cachedChunks(ctx, entry)
	if err != nil {
		return Manifest{}, err
	}
	if chunks == nil {
		chunks, err = s.computeAndCacheChunks(ctx, owner, entry)
		if err != nil {
			return Manifest{}, err
		}
	}
	return Manifest{Path: entry.Path, Rev: entry.Rev, Size: entry.Size, Hash: entry.Hash, Chunks: chunks}, nil
}

func (s *Service) cachedChunks(ctx context.Context, entry files.Entry) ([]chunker.Chunk, error) {
	rows, err := s.db.QueryContext(ctx,
		`SELECT hash, offset_bytes, size FROM file_chunks WHERE file_id = ? AND rev = ? ORDER BY idx`, entry.ID, entry.Rev)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var chunks []chunker.Chunk
	for rows.Next() {
		var chunk chunker.Chunk
		if err := rows.Scan(&chunk.Hash, &chunk.Offset, &chunk.Size); err != nil {
			return nil, err
		}
		chunks = append(chunks, chunk)
	}
	if chunks == nil && entry.Size == 0 {
		return []chunker.Chunk{}, rows.Err()
	}
	return chunks, rows.Err()
}

func (s *Service) computeAndCacheChunks(ctx context.Context, owner users.User, entry files.Entry) ([]chunker.Chunk, error) {
	file, opened, err := s.files.Open(ctx, owner, entry.Path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	manifest, err := chunker.BuildManifest(file)
	if err != nil {
		return nil, err
	}
	if manifest.Hash != opened.Hash || opened.Rev != entry.Rev {
		return nil, apperr.New(apperr.KindPrecondition, "%s changed while it was being read, retry", entry.Path)
	}
	return manifest.Chunks, s.storeChunks(ctx, entry, manifest.Chunks)
}

func (s *Service) storeChunks(ctx context.Context, entry files.Entry, chunks []chunker.Chunk) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	if _, err := tx.ExecContext(ctx, `DELETE FROM file_chunks WHERE file_id = ?`, entry.ID); err != nil {
		return err
	}
	for index, chunk := range chunks {
		_, err := tx.ExecContext(ctx,
			`INSERT INTO file_chunks (file_id, rev, idx, hash, offset_bytes, size) VALUES (?, ?, ?, ?, ?, ?)`,
			entry.ID, entry.Rev, index, chunk.Hash, chunk.Offset, chunk.Size)
		if err != nil {
			return err
		}
	}
	return tx.Commit()
}
