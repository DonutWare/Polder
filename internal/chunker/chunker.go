package chunker

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"io"
)

const (
	MinSize = 256 << 10
	AvgSize = 1 << 20
	MaxSize = 4 << 20

	gearSeed        = 0x4D65436C6F756421
	strictMask      = uint64((1<<22)-1) << 42
	relaxedMask     = uint64((1<<18)-1) << 46
	splitmixGamma   = 0x9E3779B97F4A7C15
	splitmixFactor1 = 0xBF58476D1CE4E5B9
	splitmixFactor2 = 0x94D049BB133111EB
)

var gear = buildGearTable()

type Chunk struct {
	Offset int64  `json:"offset"`
	Size   int64  `json:"size"`
	Hash   string `json:"hash"`
}

func buildGearTable() [256]uint64 {
	var table [256]uint64
	state := uint64(gearSeed)
	for i := range table {
		state += splitmixGamma
		z := state
		z = (z ^ (z >> 30)) * splitmixFactor1
		z = (z ^ (z >> 27)) * splitmixFactor2
		table[i] = z ^ (z >> 31)
	}
	return table
}

func cutPoint(data []byte) int {
	length := len(data)
	if length <= MinSize {
		return length
	}
	length = min(length, MaxSize)
	normal := min(AvgSize, length)

	var fingerprint uint64
	i := MinSize
	for ; i < normal; i++ {
		fingerprint = (fingerprint << 1) + gear[data[i]]
		if fingerprint&strictMask == 0 {
			return i + 1
		}
	}
	for ; i < length; i++ {
		fingerprint = (fingerprint << 1) + gear[data[i]]
		if fingerprint&relaxedMask == 0 {
			return i + 1
		}
	}
	return length
}

// Split calls onChunk for every content-defined chunk of r. The data slice is
// only valid for the duration of the call.
func Split(r io.Reader, onChunk func(chunk Chunk, data []byte) error) error {
	buffer := make([]byte, MaxSize)
	filled := 0
	var offset int64
	reachedEOF := false

	for {
		if !reachedEOF {
			n, err := io.ReadFull(r, buffer[filled:])
			filled += n
			if errors.Is(err, io.EOF) || errors.Is(err, io.ErrUnexpectedEOF) {
				reachedEOF = true
			} else if err != nil {
				return err
			}
		}
		if filled == 0 {
			return nil
		}

		cut := cutPoint(buffer[:filled])
		data := buffer[:cut]
		sum := sha256.Sum256(data)
		chunk := Chunk{Offset: offset, Size: int64(cut), Hash: hex.EncodeToString(sum[:])}
		if err := onChunk(chunk, data); err != nil {
			return err
		}

		offset += int64(cut)
		filled = copy(buffer, buffer[cut:filled])
	}
}

type Manifest struct {
	Size   int64   `json:"size"`
	Hash   string  `json:"hash"`
	Chunks []Chunk `json:"chunks"`
}

func BuildManifest(r io.Reader) (Manifest, error) {
	fileHash := sha256.New()
	manifest := Manifest{Chunks: []Chunk{}}
	err := Split(io.TeeReader(r, fileHash), func(chunk Chunk, _ []byte) error {
		manifest.Chunks = append(manifest.Chunks, chunk)
		manifest.Size += chunk.Size
		return nil
	})
	if err != nil {
		return Manifest{}, err
	}
	manifest.Hash = hex.EncodeToString(fileHash.Sum(nil))
	return manifest, nil
}
