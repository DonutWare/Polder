package preview

import (
	"bytes"
	"image"
	"image/color"
	"image/jpeg"
	"image/png"
	"os"
	"path/filepath"
	"testing"
)

func solidImage(alpha uint8) image.Image {
	img := image.NewNRGBA(image.Rect(0, 0, 40, 20))
	for y := 0; y < 20; y++ {
		for x := 0; x < 40; x++ {
			img.Set(x, y, color.NRGBA{R: 200, G: 40, B: 40, A: alpha})
		}
	}
	return img
}

func TestTransparentThumbnailsKeepAlphaAsPNG(t *testing.T) {
	base := filepath.Join(t.TempDir(), "ab", "abcdef-128")
	if err := writeThumbnail(decodedImage{image: solidImage(0)}, 128, base); err != nil {
		t.Fatal(err)
	}
	data, err := os.ReadFile(base + pngExtension)
	if err != nil {
		t.Fatalf("expected a png thumbnail: %v", err)
	}
	decoded, err := png.Decode(bytes.NewReader(data))
	if err != nil {
		t.Fatal(err)
	}
	if _, _, _, alpha := decoded.At(5, 5).RGBA(); alpha != 0 {
		t.Fatalf("transparency lost: alpha %d", alpha)
	}
	if _, err := os.Stat(base + jpegExtension); !os.IsNotExist(err) {
		t.Fatalf("no jpeg should exist, got %v", err)
	}
}

func TestOpaqueThumbnailsStayJPEGAndReplaceStalePNG(t *testing.T) {
	base := filepath.Join(t.TempDir(), "ab", "abcdef-128")
	if err := writeThumbnail(decodedImage{image: solidImage(0)}, 128, base); err != nil {
		t.Fatal(err)
	}
	if err := writeThumbnail(decodedImage{image: solidImage(255)}, 128, base); err != nil {
		t.Fatal(err)
	}
	data, err := os.ReadFile(base + jpegExtension)
	if err != nil {
		t.Fatalf("expected a jpeg thumbnail: %v", err)
	}
	if _, err := jpeg.Decode(bytes.NewReader(data)); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(base + pngExtension); !os.IsNotExist(err) {
		t.Fatalf("stale png should be removed, got %v", err)
	}
}

func TestThumbnailPathPrefersPNGAndReportsContentType(t *testing.T) {
	worker := &Worker{cacheDir: t.TempDir()}
	jpegPath := worker.ThumbnailPath("abcdef", 128)
	if filepath.Ext(jpegPath) != jpegExtension || ThumbnailContentType(jpegPath) != "image/jpeg" {
		t.Fatalf("unexpected default path %s", jpegPath)
	}
	if err := writeThumbnail(decodedImage{image: solidImage(128)}, 128, worker.thumbnailBase("abcdef", 128)); err != nil {
		t.Fatal(err)
	}
	pngPath := worker.ThumbnailPath("abcdef", 128)
	if filepath.Ext(pngPath) != pngExtension || ThumbnailContentType(pngPath) != "image/png" {
		t.Fatalf("expected png path, got %s", pngPath)
	}
	if !worker.HasThumbnail("abcdef", 128) {
		t.Fatal("expected the png thumbnail to count")
	}
}
