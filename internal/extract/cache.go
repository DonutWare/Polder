package extract

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"sync"

	"polder-server/internal/files"
)

const (
	cacheStateFile = "state.json"
	textSuffix     = ".txt"
)

// Cache keeps extracted text by content hash, so moving, renaming or copying a file never reads it again.
// Text from files OCR can apply to is also keyed by the OCR settings it was read with; changing those
// settings leaves the old text unused.
type Cache struct {
	dir string

	mu         sync.RWMutex
	appliedOCR string
}

type cacheState struct {
	OCR string `json:"ocr"`
}

func OpenCache(dir string) (cache *Cache, fresh bool, err error) {
	if err := os.MkdirAll(dir, 0o750); err != nil {
		return nil, false, err
	}
	cache = &Cache{dir: dir}
	raw, err := os.ReadFile(filepath.Join(dir, cacheStateFile))
	if errors.Is(err, fs.ErrNotExist) {
		return cache, true, nil
	}
	if err != nil {
		return nil, false, err
	}
	var state cacheState
	if err := json.Unmarshal(raw, &state); err != nil {
		return cache, true, nil
	}
	cache.appliedOCR = state.OCR
	return cache, false, nil
}

func (c *Cache) Text(entry files.Entry) (string, bool) {
	if entry.TextState != files.TextReady {
		return "", false
	}
	content, err := os.ReadFile(c.path(entry))
	if err != nil {
		return "", false
	}
	return string(content), true
}

func (c *Cache) store(entry files.Entry, text string) error {
	target := c.path(entry)
	if err := os.MkdirAll(filepath.Dir(target), 0o750); err != nil {
		return err
	}
	temp := target + ".tmp"
	if err := os.WriteFile(temp, []byte(text), 0o640); err != nil {
		return err
	}
	return os.Rename(temp, target)
}

func (c *Cache) path(entry files.Entry) string {
	name := entry.Hash + textSuffix
	if ocrApplies(entry.Mime) {
		name = entry.Hash + "." + c.ocrTag() + textSuffix
	}
	return filepath.Join(c.dir, shard(entry.Hash), name)
}

func shard(hash string) string {
	if len(hash) < 2 {
		return "_"
	}
	return hash[:2]
}

func (c *Cache) ocrTag() string {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return tagFor(c.appliedOCR)
}

func tagFor(fingerprint string) string {
	sum := sha256.Sum256([]byte(fingerprint))
	return hex.EncodeToString(sum[:6])
}

func (c *Cache) applied() string {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.appliedOCR
}

func (c *Cache) setApplied(fingerprint string) error {
	encoded, err := json.Marshal(cacheState{OCR: fingerprint})
	if err != nil {
		return err
	}
	temp := filepath.Join(c.dir, cacheStateFile+".tmp")
	if err := os.WriteFile(temp, encoded, 0o640); err != nil {
		return err
	}
	if err := os.Rename(temp, filepath.Join(c.dir, cacheStateFile)); err != nil {
		return err
	}
	c.mu.Lock()
	c.appliedOCR = fingerprint
	c.mu.Unlock()
	return nil
}

func (c *Cache) removeUnused(inUse map[string]bool) error {
	currentTag := c.ocrTag()
	err := filepath.WalkDir(c.dir, func(current string, entry fs.DirEntry, err error) error {
		if errors.Is(err, fs.ErrNotExist) {
			return nil
		}
		if err != nil || entry.IsDir() || !strings.HasSuffix(entry.Name(), textSuffix) {
			return err
		}
		hash, tag, tagged := strings.Cut(strings.TrimSuffix(entry.Name(), textSuffix), ".")
		if !inUse[hash] || tagged && tag != currentTag {
			return os.Remove(current)
		}
		return nil
	})
	if errors.Is(err, fs.ErrNotExist) {
		return nil
	}
	return err
}
