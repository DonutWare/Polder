package extract

import (
	"image"
	"image/color"
	"os"
	"strings"
	"time"

	"github.com/klippa-app/go-pdfium"
	"github.com/klippa-app/go-pdfium/requests"
	"github.com/klippa-app/go-pdfium/webassembly"
	"golang.org/x/image/draw"
)

const (
	pdfInstanceTimeout = 30 * time.Minute
	ocrDPI             = 300
	maxOCREdge         = 5000
	pointsPerInch      = 72
)

type pdfReader struct {
	pool pdfium.Pool
	used bool
}

func (r *pdfReader) instance() (pdfium.Pdfium, error) {
	r.used = true
	if r.pool == nil {
		pool, err := webassembly.Init(webassembly.Config{MinIdle: 0, MaxIdle: 1, MaxTotal: 1})
		if err != nil {
			return nil, err
		}
		r.pool = pool
	}
	return r.pool.GetInstance(pdfInstanceTimeout)
}

func (r *pdfReader) close() {
	if r.pool != nil {
		_ = r.pool.Close()
		r.pool = nil
	}
}

// recognizePage returns the text OCR finds on a rendered page; it is nil when OCR is off.
type recognizePage func(page image.Image, dpi int) (string, error)

func (r *pdfReader) read(file *os.File, size int64, recognize recognizePage, maxOCRPages int) (string, error) {
	instance, err := r.instance()
	if err != nil {
		return "", err
	}
	defer instance.Close()

	document, err := instance.OpenDocument(&requests.OpenDocument{FileReader: file, FileReaderSize: size})
	if err != nil {
		return "", err
	}
	defer instance.FPDF_CloseDocument(&requests.FPDF_CloseDocument{Document: document.Document})
	count, err := instance.FPDF_GetPageCount(&requests.FPDF_GetPageCount{Document: document.Document})
	if err != nil {
		return "", err
	}

	var text strings.Builder
	recognized := 0
	for index := 0; index < count.PageCount && text.Len() <= MaxTextBytes; index++ {
		page := requests.Page{ByIndex: &requests.PageByIndex{Document: document.Document, Index: index}}
		layer, err := instance.GetPageText(&requests.GetPageText{Page: page})
		if err == nil && hasWords(layer.Text) {
			text.WriteString(layer.Text)
			text.WriteString("\n\n")
			continue
		}
		if recognize == nil || recognized >= maxOCRPages {
			continue
		}
		recognized++
		rendered, dpi, err := renderForOCR(instance, page)
		if err != nil {
			return text.String(), err
		}
		found, err := recognize(rendered, dpi)
		if err != nil {
			return text.String(), err
		}
		text.WriteString(found)
		text.WriteString("\n\n")
	}
	return text.String(), nil
}

func renderForOCR(instance pdfium.Pdfium, page requests.Page) (image.Image, int, error) {
	dpi := ocrDPI
	if size, err := instance.GetPageSize(&requests.GetPageSize{Page: page}); err == nil {
		if longest := max(size.Width, size.Height); longest > 0 {
			dpi = min(dpi, int(maxOCREdge*pointsPerInch/longest))
		}
	}
	rendered, err := instance.RenderPageInDPI(&requests.RenderPageInDPI{Page: page, DPI: max(dpi, 1)})
	if err != nil {
		return nil, 0, err
	}
	defer rendered.Cleanup()
	source := rendered.Result.Image
	onWhite := image.NewGray(source.Bounds())
	draw.Draw(onWhite, onWhite.Bounds(), image.NewUniform(color.White), image.Point{}, draw.Src)
	draw.Draw(onWhite, onWhite.Bounds(), source, source.Bounds().Min, draw.Over)
	return onWhite, dpi, nil
}
