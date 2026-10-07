package extract

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"image"
	"io"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

const (
	pdfMime          = "application/pdf"
	modelSuffix      = ".traineddata"
	maxModelBytes    = 512 << 20
	recognizeTimeout = 5 * time.Minute
	downloadTimeout  = 30 * time.Minute
	connectTimeout   = 30 * time.Second
	firstRetryDelay  = time.Minute
	maxRetryDelay    = time.Hour
)

func ocrApplies(mimeType string) bool {
	return mimeType == pdfMime || strings.HasPrefix(mimeType, "image/")
}

var ocrMimePatterns = []string{pdfMime, "image/%"}

type tesseract struct {
	binary   string
	modelDir string
	modelURL string
	client   *http.Client
	failures map[string]failedDownload
}

type failedDownload struct {
	err   error
	retry time.Time
	delay time.Duration
}

func newTesseract(binary, modelDir, modelURL string) *tesseract {
	resolved, err := exec.LookPath(binary)
	if err != nil {
		resolved = ""
	}
	transport := http.DefaultTransport.(*http.Transport).Clone()
	transport.DialContext = (&net.Dialer{Timeout: connectTimeout}).DialContext
	transport.ResponseHeaderTimeout = connectTimeout
	return &tesseract{
		binary:   resolved,
		modelDir: modelDir,
		modelURL: strings.TrimSuffix(modelURL, "/"),
		client:   &http.Client{Timeout: downloadTimeout, Transport: transport},
		failures: map[string]failedDownload{},
	}
}

func (t *tesseract) installed() bool { return t.binary != "" }

func (t *tesseract) ensureModels(ctx context.Context, languages []string) error {
	for _, language := range languages {
		target := filepath.Join(t.modelDir, filepath.FromSlash(language)+modelSuffix)
		if _, err := os.Stat(target); err == nil {
			continue
		}
		failed, seen := t.failures[language]
		if seen && time.Now().Before(failed.retry) {
			return failed.err
		}
		if err := t.download(ctx, language, target); err != nil {
			if ctx.Err() != nil {
				return err
			}
			failed.delay = min(max(2*failed.delay, firstRetryDelay), maxRetryDelay)
			failed.err = fmt.Errorf("download OCR model %s: %w", language, err)
			failed.retry = time.Now().Add(failed.delay)
			t.failures[language] = failed
			return failed.err
		}
		delete(t.failures, language)
	}
	return nil
}

func (t *tesseract) download(ctx context.Context, language, target string) error {
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, t.modelURL+"/"+language+modelSuffix, nil)
	if err != nil {
		return err
	}
	response, err := t.client.Do(request)
	if err != nil {
		return err
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("%s", response.Status)
	}
	if err := os.MkdirAll(filepath.Dir(target), 0o750); err != nil {
		return err
	}
	temp, err := os.CreateTemp(filepath.Dir(target), ".download-*")
	if err != nil {
		return err
	}
	defer os.Remove(temp.Name())
	written, err := io.Copy(temp, io.LimitReader(response.Body, maxModelBytes+1))
	if closeErr := temp.Close(); err == nil {
		err = closeErr
	}
	if err != nil {
		return err
	}
	if written > maxModelBytes {
		return errors.New("model is larger than expected")
	}
	return os.Rename(temp.Name(), target)
}

func (t *tesseract) recognize(ctx context.Context, img image.Image, languages []string, dpi int) (string, error) {
	ctx, cancel := context.WithTimeout(ctx, recognizeTimeout)
	defer cancel()
	args := []string{"stdin", "stdout", "--tessdata-dir", t.modelDir, "-l", strings.Join(languages, "+"), "--psm", "3"}
	if dpi > 0 {
		args = append(args, "--dpi", strconv.Itoa(dpi))
	}
	command := exec.CommandContext(ctx, t.binary, args...)
	// Tesseract's own threads slow it down when pages are recognised one after another.
	command.Env = append(os.Environ(), "OMP_THREAD_LIMIT=1")
	command.Stdin = bytes.NewReader(grayscalePGM(img))
	var stdout, stderr bytes.Buffer
	command.Stdout, command.Stderr = &stdout, &stderr
	if err := command.Run(); err != nil {
		return "", fmt.Errorf("tesseract: %w: %s", err, strings.TrimSpace(stderr.String()))
	}
	return joinOCRSpacing(stdout.String()), nil
}

// grayscalePGM encodes img as binary PGM, flattened onto white, which Tesseract reads without any codec.
func grayscalePGM(img image.Image) []byte {
	bounds := img.Bounds()
	header := fmt.Sprintf("P5\n%d %d\n255\n", bounds.Dx(), bounds.Dy())
	encoded := make([]byte, len(header), len(header)+bounds.Dx()*bounds.Dy())
	copy(encoded, header)
	switch source := img.(type) {
	case *image.Gray:
		for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
			start := source.PixOffset(bounds.Min.X, y)
			encoded = append(encoded, source.Pix[start:start+bounds.Dx()]...)
		}
	case *image.YCbCr:
		for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
			start := source.YOffset(bounds.Min.X, y)
			encoded = append(encoded, source.Y[start:start+bounds.Dx()]...)
		}
	default:
		for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
			for x := bounds.Min.X; x < bounds.Max.X; x++ {
				r, g, b, a := img.At(x, y).RGBA()
				luminance := (19595*r + 38470*g + 7471*b + 1<<15) >> 16
				encoded = append(encoded, byte((luminance+0xffff-a)>>8))
			}
		}
	}
	return encoded
}
