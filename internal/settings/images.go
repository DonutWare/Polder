package settings

import (
	"bytes"
	"cmp"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"slices"
	"strings"
	"sync"

	"polder-server/internal/apperr"
)

const (
	MaxBackgrounds = 12

	// sniffLength covers the XML prolog and comments an SVG may start with.
	sniffLength = 4096
)

var imageIDPattern = regexp.MustCompile(`^[0-9a-f]{16}$`)

type Images struct {
	dir         string
	mu          sync.RWMutex
	icon        *ImageInfo
	backgrounds []ImageInfo
}

type ImageInfo struct {
	ID          string `json:"id"`
	ContentType string `json:"contentType" doc:"Such as image/png or image/svg+xml"`
}

type Image struct {
	ImageInfo
	Content []byte
}

func OpenImages(dir string) (*Images, error) {
	images := &Images{dir: dir}
	if content, err := os.ReadFile(images.iconPath()); err == nil {
		info := infoOf(content)
		images.icon = &info
	} else if !errors.Is(err, os.ErrNotExist) {
		return nil, err
	}
	entries, err := os.ReadDir(images.backgroundDir())
	if err != nil && !errors.Is(err, os.ErrNotExist) {
		return nil, err
	}
	type found struct {
		id    string
		order int64
	}
	var backgrounds []found
	for _, entry := range entries {
		info, err := entry.Info()
		if err != nil || !imageIDPattern.MatchString(entry.Name()) {
			continue
		}
		backgrounds = append(backgrounds, found{entry.Name(), info.ModTime().UnixNano()})
	}
	slices.SortFunc(backgrounds, func(a, b found) int { return cmp.Compare(a.order, b.order) })
	for _, background := range backgrounds {
		head, err := readHead(filepath.Join(images.backgroundDir(), background.id))
		if err != nil {
			return nil, err
		}
		contentType, _ := imageType(head)
		images.backgrounds = append(images.backgrounds, ImageInfo{ID: background.id, ContentType: contentType})
	}
	return images, nil
}

// Icon is nil while the server has no icon of its own.
func (i *Images) Icon() *ImageInfo {
	i.mu.RLock()
	defer i.mu.RUnlock()
	return i.icon
}

func (i *Images) Backgrounds() []ImageInfo {
	i.mu.RLock()
	defer i.mu.RUnlock()
	return append([]ImageInfo{}, i.backgrounds...)
}

func (i *Images) ReadIcon(id string) (Image, error) {
	i.mu.RLock()
	defer i.mu.RUnlock()
	if i.icon == nil || i.icon.ID != id {
		return Image{}, apperr.NotFound("no such icon")
	}
	return read(*i.icon, i.iconPath())
}

func (i *Images) ReadBackground(id string) (Image, error) {
	i.mu.RLock()
	defer i.mu.RUnlock()
	index := i.backgroundIndex(id)
	if index < 0 {
		return Image{}, apperr.NotFound("no such background")
	}
	return read(i.backgrounds[index], filepath.Join(i.backgroundDir(), id))
}

func (i *Images) SetIcon(content []byte) (ImageInfo, error) {
	if err := checkImage(content); err != nil {
		return ImageInfo{}, err
	}
	i.mu.Lock()
	defer i.mu.Unlock()
	if err := write(i.iconPath(), content); err != nil {
		return ImageInfo{}, err
	}
	info := infoOf(content)
	i.icon = &info
	return info, nil
}

func (i *Images) RemoveIcon() error {
	i.mu.Lock()
	defer i.mu.Unlock()
	if err := os.Remove(i.iconPath()); err != nil && !errors.Is(err, os.ErrNotExist) {
		return err
	}
	i.icon = nil
	return nil
}

func (i *Images) AddBackground(content []byte) (ImageInfo, error) {
	if err := checkImage(content); err != nil {
		return ImageInfo{}, err
	}
	info := infoOf(content)
	i.mu.Lock()
	defer i.mu.Unlock()
	if i.backgroundIndex(info.ID) >= 0 {
		return info, nil
	}
	if len(i.backgrounds) >= MaxBackgrounds {
		return ImageInfo{}, apperr.Invalid("there can be at most %d backgrounds", MaxBackgrounds)
	}
	if err := write(filepath.Join(i.backgroundDir(), info.ID), content); err != nil {
		return ImageInfo{}, err
	}
	i.backgrounds = append(i.backgrounds, info)
	return info, nil
}

func (i *Images) RemoveBackground(id string) error {
	i.mu.Lock()
	defer i.mu.Unlock()
	index := i.backgroundIndex(id)
	if index < 0 {
		return apperr.NotFound("no such background")
	}
	if err := os.Remove(filepath.Join(i.backgroundDir(), id)); err != nil && !errors.Is(err, os.ErrNotExist) {
		return err
	}
	i.backgrounds = slices.Delete(i.backgrounds, index, index+1)
	return nil
}

func (i *Images) backgroundIndex(id string) int {
	return slices.IndexFunc(i.backgrounds, func(info ImageInfo) bool { return info.ID == id })
}

func (i *Images) iconPath() string {
	return filepath.Join(i.dir, "icon")
}

func (i *Images) backgroundDir() string {
	return filepath.Join(i.dir, "backgrounds")
}

func read(info ImageInfo, path string) (Image, error) {
	content, err := os.ReadFile(path)
	if err != nil {
		return Image{}, err
	}
	return Image{ImageInfo: info, Content: content}, nil
}

func readHead(path string) ([]byte, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	head := make([]byte, sniffLength)
	n, err := io.ReadFull(file, head)
	if err != nil && !errors.Is(err, io.ErrUnexpectedEOF) && !errors.Is(err, io.EOF) {
		return nil, err
	}
	return head[:n], nil
}

func write(path string, content []byte) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	temporary := path + ".tmp"
	if err := os.WriteFile(temporary, content, 0o644); err != nil {
		return err
	}
	return os.Rename(temporary, path)
}

func checkImage(content []byte) error {
	if _, ok := imageType(content); !ok {
		return apperr.Invalid("not an image")
	}
	return nil
}

// imageType sniffs the content; SVG needs its own check because sniffing only sees XML or text.
func imageType(content []byte) (string, bool) {
	content = content[:min(len(content), sniffLength)]
	detected := http.DetectContentType(content)
	if strings.HasPrefix(detected, "image/") {
		return detected, true
	}
	if (strings.HasPrefix(detected, "text/xml") || strings.HasPrefix(detected, "text/plain")) && bytes.Contains(content, []byte("<svg")) {
		return "image/svg+xml", true
	}
	return "", false
}

func infoOf(content []byte) ImageInfo {
	sum := sha256.Sum256(content)
	contentType, _ := imageType(content)
	return ImageInfo{ID: hex.EncodeToString(sum[:8]), ContentType: contentType}
}
