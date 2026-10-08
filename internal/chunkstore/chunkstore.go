package chunkstore

import (
	"bytes"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"sync"

	"github.com/klauspost/compress/zstd"

	"polder-server/internal/storage"
)

type Stored struct {
	Size       int64
	Compressed bool
}

var (
	encoderOnce sync.Once
	encoder     *zstd.Encoder
	decoderOnce sync.Once
	decoder     *zstd.Decoder
)

func sharedEncoder() *zstd.Encoder {
	encoderOnce.Do(func() {
		encoder, _ = zstd.NewWriter(nil, zstd.WithEncoderLevel(zstd.SpeedDefault), zstd.WithEncoderConcurrency(1))
	})
	return encoder
}

func sharedDecoder() *zstd.Decoder {
	decoderOnce.Do(func() {
		decoder, _ = zstd.NewReader(nil, zstd.WithDecoderConcurrency(0))
	})
	return decoder
}

func Write(path string, data []byte) (Stored, error) {
	compressed := sharedEncoder().EncodeAll(data, make([]byte, 0, len(data)))
	stored := Stored{Size: int64(len(data))}
	content := data
	if len(compressed) < len(data) {
		stored = Stored{Size: int64(len(compressed)), Compressed: true}
		content = compressed
	}
	if err := storage.MakeDirs(filepath.Dir(path)); err != nil {
		return Stored{}, err
	}
	if err := storage.WriteFileAtomically(path, content); err != nil {
		return Stored{}, err
	}
	return stored, nil
}

func Exists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}

func Read(path string, compressed bool) ([]byte, error) {
	content, err := os.ReadFile(path)
	if errors.Is(err, fs.ErrNotExist) {
		return nil, fmt.Errorf("chunk %s is missing", filepath.Base(path))
	}
	if err != nil || !compressed {
		return content, err
	}
	return sharedDecoder().DecodeAll(content, nil)
}

type Part struct {
	Path       string
	Compressed bool
}

type sequenceReader struct {
	parts   []Part
	current *bytes.Reader
}

func NewSequenceReader(parts []Part) io.ReadCloser {
	return &sequenceReader{parts: parts}
}

func (r *sequenceReader) Read(buffer []byte) (int, error) {
	for {
		if r.current == nil {
			if len(r.parts) == 0 {
				return 0, io.EOF
			}
			content, err := Read(r.parts[0].Path, r.parts[0].Compressed)
			if err != nil {
				return 0, err
			}
			r.parts = r.parts[1:]
			r.current = bytes.NewReader(content)
		}
		n, err := r.current.Read(buffer)
		if errors.Is(err, io.EOF) {
			r.current = nil
			if n > 0 {
				return n, nil
			}
			continue
		}
		return n, err
	}
}

func (r *sequenceReader) Close() error {
	r.parts, r.current = nil, nil
	return nil
}
