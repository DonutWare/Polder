package files

import (
	"mime"
	"path"
	"strings"
	"time"

	"github.com/danielgtaylor/huma/v2"
)

type PreviewState string

const (
	PreviewNone    PreviewState = "none"
	PreviewPending PreviewState = "pending"
	PreviewReady   PreviewState = "ready"
	PreviewFailed  PreviewState = "failed"
)

func (PreviewState) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(PreviewNone), string(PreviewPending), string(PreviewReady), string(PreviewFailed)}
	return s
}

const (
	directoryMime = "inode/directory"
	fallbackMime  = "application/octet-stream"
)

var previewableMimes = map[string]bool{
	"image/jpeg":      true,
	"image/png":       true,
	"image/gif":       true,
	"image/webp":      true,
	"application/pdf": true,
}

type Entry struct {
	ID           int64          `json:"-"`
	UserID       int64          `json:"-"`
	Path         string         `json:"path"`
	Name         string         `json:"name"`
	IsDir        bool           `json:"isDir"`
	Size         int64          `json:"size"`
	Mtime        time.Time      `json:"mtime"`
	Rev          int64          `json:"rev"`
	Hash         string         `json:"hash"`
	Mime         string         `json:"mime"`
	Meta         map[string]any `json:"meta"`
	PreviewState PreviewState   `json:"previewState"`
}

func newDirectoryEntry(userID int64, cleanPath string, mtime time.Time) Entry {
	return Entry{
		UserID:       userID,
		Path:         cleanPath,
		Name:         path.Base(cleanPath),
		IsDir:        true,
		Mtime:        mtime,
		Mime:         directoryMime,
		Meta:         map[string]any{},
		PreviewState: PreviewNone,
	}
}

func newFileEntry(userID int64, cleanPath string, size int64, mtime time.Time, hash string) Entry {
	mimeType := mimeFor(cleanPath)
	return Entry{
		UserID:       userID,
		Path:         cleanPath,
		Name:         path.Base(cleanPath),
		Size:         size,
		Mtime:        mtime,
		Hash:         hash,
		Mime:         mimeType,
		Meta:         map[string]any{},
		PreviewState: initialPreviewState(mimeType),
	}
}

func mimeFor(filePath string) string {
	detected := mime.TypeByExtension(strings.ToLower(path.Ext(filePath)))
	if detected == "" {
		return fallbackMime
	}
	mediaType, _, err := mime.ParseMediaType(detected)
	if err != nil {
		return fallbackMime
	}
	return mediaType
}

func initialPreviewState(mimeType string) PreviewState {
	if previewableMimes[mimeType] {
		return PreviewPending
	}
	return PreviewNone
}
