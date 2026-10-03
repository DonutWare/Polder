package chunker

import (
	"bytes"
	"testing"
)

func xorshiftTestData(size int) []byte {
	out := make([]byte, size)
	x := uint64(1)
	for i := 0; i < size; i += 8 {
		x ^= x >> 12
		x ^= x << 25
		x ^= x >> 27
		value := x * 0x2545F4914F6CDD1D
		for j := 0; j < 8 && i+j < size; j++ {
			out[i+j] = byte(value >> (8 * j))
		}
	}
	return out
}

func TestGearTableMatchesProtocol(t *testing.T) {
	expected := map[int]uint64{0: 0x508530c361960c3c, 1: 0x452929d50b3206af, 255: 0xe15c986498e07891}
	for index, value := range expected {
		if gear[index] != value {
			t.Errorf("gear[%d] = %#016x, want %#016x", index, gear[index], value)
		}
	}
}

func TestManifestMatchesProtocolVectors(t *testing.T) {
	manifest, err := BuildManifest(bytes.NewReader(xorshiftTestData(8 << 20)))
	if err != nil {
		t.Fatal(err)
	}

	expectedOffsets := []int64{0, 1253242, 2964301, 4034138, 5319580, 6665121}
	if len(manifest.Chunks) != len(expectedOffsets) {
		t.Fatalf("got %d chunks, want %d", len(manifest.Chunks), len(expectedOffsets))
	}
	for i, chunk := range manifest.Chunks {
		if chunk.Offset != expectedOffsets[i] {
			t.Errorf("chunk %d offset = %d, want %d", i, chunk.Offset, expectedOffsets[i])
		}
	}
	if manifest.Chunks[0].Hash[:16] != "af0abd0190233db4" {
		t.Errorf("first chunk hash = %s", manifest.Chunks[0].Hash)
	}
	if manifest.Hash != "759d208d2614cac1f212124b443399413c6334224d3ae2dbf6b4f660787f4546" {
		t.Errorf("file hash = %s", manifest.Hash)
	}
}

func TestSmallFileIsSingleChunk(t *testing.T) {
	manifest, err := BuildManifest(bytes.NewReader([]byte("hello")))
	if err != nil {
		t.Fatal(err)
	}
	if len(manifest.Chunks) != 1 || manifest.Chunks[0].Size != 5 {
		t.Fatalf("unexpected chunks %+v", manifest.Chunks)
	}
}

func TestEmptyFileHasNoChunks(t *testing.T) {
	manifest, err := BuildManifest(bytes.NewReader(nil))
	if err != nil {
		t.Fatal(err)
	}
	if len(manifest.Chunks) != 0 || manifest.Size != 0 {
		t.Fatalf("unexpected manifest %+v", manifest)
	}
}

func TestLocalEditKeepsMostChunks(t *testing.T) {
	original := xorshiftTestData(32 << 20)
	edited := bytes.Clone(original)
	copy(edited[16<<20:], bytes.Repeat([]byte{0xAB}, 1000))

	before, _ := BuildManifest(bytes.NewReader(original))
	after, _ := BuildManifest(bytes.NewReader(edited))

	known := map[string]bool{}
	for _, chunk := range before.Chunks {
		known[chunk.Hash] = true
	}
	var changedBytes int64
	for _, chunk := range after.Chunks {
		if !known[chunk.Hash] {
			changedBytes += chunk.Size
		}
	}
	if changedBytes > 2*MaxSize {
		t.Fatalf("edit of 1000 bytes changed %d bytes of chunks", changedBytes)
	}
}
