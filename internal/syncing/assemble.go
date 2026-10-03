package syncing

import (
	"context"
	"errors"
	"io"
	"io/fs"
	"os"

	"nomad-server/internal/apperr"
	"nomad-server/internal/users"
)

type chunkSource struct {
	stagedPath string
	offset     int64
	size       int64
}

func (source chunkSource) fromCurrentFile() bool {
	return source.stagedPath == ""
}

func (s *Service) availableChunkSources(ctx context.Context, owner users.User, target upload) (map[string]chunkSource, error) {
	sources := map[string]chunkSource{}
	if err := s.addCurrentFileChunks(ctx, owner, target.request.Path, sources); err != nil {
		return nil, err
	}
	for _, chunk := range target.request.Chunks {
		stagedPath := s.stagedChunkPath(target.id, chunk.Hash)
		if _, err := os.Stat(stagedPath); err == nil {
			sources[chunk.Hash] = chunkSource{stagedPath: stagedPath, size: chunk.Size}
		}
	}
	return sources, nil
}

func (s *Service) addCurrentFileChunks(ctx context.Context, owner users.User, cleanPath string, sources map[string]chunkSource) error {
	current, exists, err := s.currentEntry(ctx, owner, cleanPath)
	if err != nil || !exists || current.IsDir {
		return err
	}
	manifest, err := s.Manifest(ctx, owner, cleanPath)
	if err != nil {
		return err
	}
	for _, chunk := range manifest.Chunks {
		sources[chunk.Hash] = chunkSource{offset: chunk.Offset, size: chunk.Size}
	}
	return nil
}

func (s *Service) assemble(ctx context.Context, owner users.User, target upload, sources map[string]chunkSource) (io.ReadCloser, error) {
	ordered := make([]chunkSource, 0, len(target.request.Chunks))
	needsCurrentFile := false
	for _, chunk := range target.request.Chunks {
		source, available := sources[chunk.Hash]
		if !available {
			return nil, apperr.Invalid("chunk %s has not been uploaded yet", chunk.Hash)
		}
		needsCurrentFile = needsCurrentFile || source.fromCurrentFile()
		ordered = append(ordered, source)
	}

	var currentFile *os.File
	if needsCurrentFile {
		file, _, err := s.files.Open(ctx, owner, target.request.Path)
		if err != nil {
			return nil, err
		}
		currentFile = file
	}
	return &chunkSequenceReader{sources: ordered, currentFile: currentFile}, nil
}

type chunkSequenceReader struct {
	sources     []chunkSource
	currentFile *os.File
	active      io.Reader
	activeFile  *os.File
}

func (r *chunkSequenceReader) Read(buffer []byte) (int, error) {
	for {
		if r.active == nil {
			if len(r.sources) == 0 {
				return 0, io.EOF
			}
			if err := r.openNext(); err != nil {
				return 0, err
			}
		}
		n, err := r.active.Read(buffer)
		if errors.Is(err, io.EOF) {
			r.closeActive()
			if n > 0 {
				return n, nil
			}
			continue
		}
		return n, err
	}
}

func (r *chunkSequenceReader) openNext() error {
	source := r.sources[0]
	r.sources = r.sources[1:]
	if source.fromCurrentFile() {
		r.active = io.NewSectionReader(r.currentFile, source.offset, source.size)
		return nil
	}
	file, err := os.Open(source.stagedPath)
	if errors.Is(err, fs.ErrNotExist) {
		return apperr.Invalid("staged chunk disappeared, resume the upload")
	}
	if err != nil {
		return err
	}
	r.active, r.activeFile = file, file
	return nil
}

func (r *chunkSequenceReader) closeActive() {
	if r.activeFile != nil {
		r.activeFile.Close()
	}
	r.active, r.activeFile = nil, nil
}

func (r *chunkSequenceReader) Close() error {
	r.closeActive()
	if r.currentFile != nil {
		return r.currentFile.Close()
	}
	return nil
}
