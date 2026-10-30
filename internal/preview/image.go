package preview

import (
	"bytes"
	"errors"
	"image"
	_ "image/gif"
	"image/jpeg"
	"image/png"
	"io"
	"io/fs"
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
	exifSearchLimit  = 16 << 20
)

var exifMarker = []byte("Exif\x00\x00")

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
	pages       int
	duration    float64
}

func (d decodedImage) meta() map[string]any {
	meta := map[string]any{}
	if d.width > 0 {
		meta["width"], meta["height"] = d.width, d.height
	}
	if !d.takenAt.IsZero() {
		meta["takenAt"] = d.takenAt.UTC().Format(time.RFC3339)
	}
	if d.pages > 0 {
		meta["pages"] = d.pages
	}
	if d.duration > 0 {
		meta["duration"] = d.duration
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
	decoded.swapSidewaysDimensions()
	if _, err := file.Seek(0, io.SeekStart); err != nil {
		return decoded, err
	}
	decoded.image, _, err = image.Decode(file)
	return decoded, err
}

func DecodeUpright(file *os.File, maxEdge int) (image.Image, error) {
	decoded, err := decodeImage(file)
	if err != nil {
		return nil, err
	}
	return applyOrientation(scaleToFit(decoded.image, maxEdge), decoded.orientation), nil
}

func (d *decodedImage) readExif(file *os.File) {
	if metadata := exifAtStart(file); metadata != nil {
		d.applyExif(metadata, true)
	}
}

func (d *decodedImage) applyExif(metadata *exif.Exif, includeOrientation bool) {
	if takenAt, err := metadata.DateTime(); err == nil {
		d.takenAt = takenAt
	}
	if !includeOrientation {
		return
	}
	if tag, err := metadata.Get(exif.Orientation); err == nil {
		if value, err := tag.Int(0); err == nil {
			d.orientation = orientation(value)
		}
	}
}

func (d *decodedImage) swapSidewaysDimensions() {
	if d.orientation == orientationRotatedCW || d.orientation == orientationRotatedCCW {
		d.width, d.height = d.height, d.width
	}
}

func exifAtStart(file *os.File) *exif.Exif {
	if _, err := file.Seek(0, io.SeekStart); err != nil {
		return nil
	}
	metadata, err := exif.Decode(file)
	if err != nil {
		return nil
	}
	return metadata
}

func findExif(file *os.File) *exif.Exif {
	if metadata := exifAtStart(file); metadata != nil {
		return metadata
	}
	head := make([]byte, exifSearchLimit)
	read, _ := io.ReadFull(io.NewSectionReader(file, 0, exifSearchLimit), head)
	head = head[:read]
	for start := 0; ; {
		found := bytes.Index(head[start:], exifMarker)
		if found < 0 {
			return nil
		}
		payload := head[start+found+len(exifMarker):]
		if bytes.HasPrefix(payload, []byte("MM\x00*")) || bytes.HasPrefix(payload, []byte("II*\x00")) {
			if metadata, err := exif.Decode(bytes.NewReader(payload)); err == nil {
				return metadata
			}
		}
		start += found + len(exifMarker)
	}
}

func writeThumbnail(decoded decodedImage, maxEdge int, base string) error {
	thumbnail := applyOrientation(scaleToFit(decoded.image, maxEdge), decoded.orientation)
	var encoded bytes.Buffer
	extension, stale := jpegExtension, pngExtension
	if hasTransparency(thumbnail) {
		extension, stale = pngExtension, jpegExtension
		if err := png.Encode(&encoded, thumbnail); err != nil {
			return err
		}
	} else if err := jpeg.Encode(&encoded, thumbnail, &jpeg.Options{Quality: thumbnailQuality}); err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(base), 0o750); err != nil {
		return err
	}
	target := base + extension
	temp := target + ".tmp"
	if err := os.WriteFile(temp, encoded.Bytes(), 0o640); err != nil {
		return err
	}
	if err := os.Rename(temp, target); err != nil {
		return err
	}
	if err := os.Remove(base + stale); err != nil && !errors.Is(err, fs.ErrNotExist) {
		return err
	}
	return nil
}

func hasTransparency(source image.Image) bool {
	if opaque, ok := source.(interface{ Opaque() bool }); ok {
		return !opaque.Opaque()
	}
	bounds := source.Bounds()
	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
		for x := bounds.Min.X; x < bounds.Max.X; x++ {
			if _, _, _, alpha := source.At(x, y).RGBA(); alpha != 0xffff {
				return true
			}
		}
	}
	return false
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
