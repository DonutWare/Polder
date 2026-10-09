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

type TextState string

const (
	TextNone    TextState = "none"
	TextPending TextState = "pending"
	TextReady   TextState = "ready"
	TextSkipped TextState = "skipped"
	TextFailed  TextState = "failed"
)

const (
	directoryMime = "inode/directory"
	fallbackMime  = "application/octet-stream"
	MarkdownMime  = "text/markdown"
)

type Entry struct {
	ID           int64          `json:"id" doc:"Stable while the file exists, across renames, moves and overwrites"`
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
	TextState    TextState      `json:"-"`
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
		TextState:    TextNone,
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
		PreviewState: PreviewPending,
		TextState:    TextPending,
	}
}

func init() {
	for _, extension := range []string{".md", ".markdown"} {
		_ = mime.AddExtensionType(extension, MarkdownMime)
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
