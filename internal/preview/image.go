package preview

import (
	"bytes"
	"errors"
	"image"
	_ "image/gif"
	"image/jpeg"
	_ "image/png"
	"io"
	"os"
	"path/filepath"
	"time"

	"github.com/rwcarlsen/goexif/exif"
	"golang.org/x/image/draw"
	_ "golang.org/x/image/webp"
)

const (
	maxDecodedPixels = 100_000_000
	thumbnailQuality = 80
)

type orientation int

const (
	orientationNormal     orientation = 1
	orientationUpsideDown orientation = 3
	orientationRotatedCW  orientation = 6
	orientationRotatedCCW orientation = 8
)

type decodedImage struct {
	image       image.Image
	width       int
	height      int
	takenAt     time.Time
	orientation orientation
}

func (d decodedImage) meta() map[string]any {
	meta := map[string]any{}
	if d.width > 0 {
		meta["width"], meta["height"] = d.width, d.height
	}
	if !d.takenAt.IsZero() {
		meta["takenAt"] = d.takenAt.UTC().Format(time.RFC3339)
	}
	return meta
}

func decodeImage(file *os.File) (decodedImage, error) {
	config, _, err := image.DecodeConfig(file)
	if err != nil {
		return decodedImage{}, err
	}
	decoded := decodedImage{width: config.Width, height: config.Height, orientation: orientationNormal}
	if config.Width*config.Height > maxDecodedPixels {
		return decoded, errors.New("image is too large to preview")
	}

	decoded.readExif(file)
	if decoded.orientation == orientationRotatedCW || decoded.orientation == orientationRotatedCCW {
		decoded.width, decoded.height = decoded.height, decoded.width
	}
	if _, err := file.Seek(0, io.SeekStart); err != nil {
		return decoded, err
	}
	decoded.image, _, err = image.Decode(file)
	return decoded, err
}

func (d *decodedImage) readExif(file *os.File) {
	if _, err := file.Seek(0, io.SeekStart); err != nil {
		return
	}
	metadata, err := exif.Decode(file)
	if err != nil {
		return
	}
	if takenAt, err := metadata.DateTime(); err == nil {
		d.takenAt = takenAt
	}
	if tag, err := metadata.Get(exif.Orientation); err == nil {
		if value, err := tag.Int(0); err == nil {
			d.orientation = orientation(value)
		}
	}
}

func writeThumbnail(decoded decodedImage, maxEdge int, target string) error {
	thumbnail := applyOrientation(scaleToFit(decoded.image, maxEdge), decoded.orientation)
	var encoded bytes.Buffer
	if err := jpeg.Encode(&encoded, thumbnail, &jpeg.Options{Quality: thumbnailQuality}); err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(target), 0o750); err != nil {
		return err
	}
	temp := target + ".tmp"
	if err := os.WriteFile(temp, encoded.Bytes(), 0o640); err != nil {
		return err
	}
	return os.Rename(temp, target)
}

func scaleToFit(source image.Image, maxEdge int) image.Image {
	bounds := source.Bounds()
	width, height := bounds.Dx(), bounds.Dy()
	if width <= maxEdge && height <= maxEdge {
		return source
	}
	scale := float64(maxEdge) / float64(max(width, height))
	targetWidth, targetHeight := max(int(float64(width)*scale), 1), max(int(float64(height)*scale), 1)
	scaled := image.NewRGBA(image.Rect(0, 0, targetWidth, targetHeight))
	draw.CatmullRom.Scale(scaled, scaled.Bounds(), source, bounds, draw.Src, nil)
	return scaled
}

func applyOrientation(source image.Image, rotation orientation) image.Image {
	switch rotation {
	case orientationUpsideDown:
		return transform(source, false, func(x, y, w, h int) (int, int) { return w - 1 - x, h - 1 - y })
	case orientationRotatedCW:
		return transform(source, true, func(x, y, w, h int) (int, int) { return h - 1 - y, x })
	case orientationRotatedCCW:
		return transform(source, true, func(x, y, w, h int) (int, int) { return y, w - 1 - x })
	default:
		return source
	}
}

func transform(source image.Image, swapsAxes bool, mapPixel func(x, y, width, height int) (int, int)) image.Image {
	bounds := source.Bounds()
	width, height := bounds.Dx(), bounds.Dy()
	targetBounds := image.Rect(0, 0, width, height)
	if swapsAxes {
		targetBounds = image.Rect(0, 0, height, width)
	}
	target := image.NewRGBA(targetBounds)
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			targetX, targetY := mapPixel(x, y, width, height)
			target.Set(targetX, targetY, source.At(bounds.Min.X+x, bounds.Min.Y+y))
		}
	}
	return target
}
