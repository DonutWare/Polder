package syncing

import (
	"context"
	"encoding/json"
	"io"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

type DownloadRequest struct {
	Files []DownloadFile `json:"files" minItems:"1" maxItems:"1000" doc:"The files to send, in this order"`
}

type DownloadFile struct {
	Path string `json:"path"`
	Rev  int64  `json:"rev" required:"false" doc:"Fail this file with precondition_failed unless it still has this revision; 0 sends whatever is there"`
}

type DownloadHeader struct {
	Path  string     `json:"path"`
	Rev   int64      `json:"rev,omitempty"`
	Size  int64      `json:"size"`
	Hash  string     `json:"hash,omitempty"`
	Error *FileError `json:"error,omitempty"`
}

func (s *Service) WriteFiles(ctx context.Context, owner users.User, wanted []DownloadFile, w io.Writer) error {
	for _, file := range wanted {
		if err := s.writeFile(ctx, owner, file, w); err != nil {
			return err
		}
	}
	return nil
}

func (s *Service) writeFile(ctx context.Context, owner users.User, wanted DownloadFile, w io.Writer) error {
	file, entry, err := s.files.Open(ctx, owner, wanted.Path)
	if err == nil && wanted.Rev > 0 && entry.Rev != wanted.Rev {
		file.Close()
		err = apperr.New(apperr.KindPrecondition, "%s changed since revision %d", entry.Path, wanted.Rev)
	}
	if err != nil {
		result, unexpected := resultForError(wanted.Path, err)
		if unexpected != nil {
			return unexpected
		}
		return writeHeader(w, DownloadHeader{Path: wanted.Path, Error: result.Error})
	}
	defer file.Close()
	if err := writeHeader(w, DownloadHeader{Path: entry.Path, Rev: entry.Rev, Size: entry.Size, Hash: entry.Hash}); err != nil {
		return err
	}
	_, err = io.CopyN(w, file, entry.Size)
	return err
}

func writeHeader(w io.Writer, header DownloadHeader) error {
	line, err := json.Marshal(header)
	if err != nil {
		return err
	}
	_, err = w.Write(append(line, '\n'))
	return err
}
