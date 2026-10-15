package preview

import (
	"image"
	"image/color"
	"os"
	"time"

	"github.com/klippa-app/go-pdfium"
	"github.com/klippa-app/go-pdfium/requests"
	"golang.org/x/image/draw"

	"polder-server/internal/pdfpool"
)

const (
	pdfMime            = "application/pdf"
	pdfInstanceTimeout = 30 * time.Second
)

type pdfRenderer struct {
	pool pdfium.Pool
	used bool
}

func (r *pdfRenderer) instance() (pdfium.Pdfium, error) {
	r.used = true
	if r.pool == nil {
		pool, err := pdfpool.New()
		if err != nil {
			return nil, err
		}
		r.pool = pool
	}
	return r.pool.GetInstance(pdfInstanceTimeout)
}

func (r *pdfRenderer) close() {
	if r.pool != nil {
		_ = r.pool.Close()
		r.pool = nil
	}
}

func (r *pdfRenderer) render(file *os.File, size int64, maxEdge int) (decodedImage, error) {
	instance, err := r.instance()
	if err != nil {
		return decodedImage{}, err
	}
	defer instance.Close()

	document, err := instance.OpenDocument(&requests.OpenDocument{FileReader: file, FileReaderSize: size})
	if err != nil {
		return decodedImage{}, err
	}
	defer instance.FPDF_CloseDocument(&requests.FPDF_CloseDocument{Document: document.Document})

	decoded := decodedImage{orientation: orientationNormal}
	if count, err := instance.FPDF_GetPageCount(&requests.FPDF_GetPageCount{Document: document.Document}); err == nil {
		decoded.pages = count.PageCount
	}
	rendered, err := instance.RenderPageInPixels(&requests.RenderPageInPixels{
		Page:   requests.Page{ByIndex: &requests.PageByIndex{Document: document.Document, Index: 0}},
		Width:  maxEdge,
		Height: maxEdge,
	})
	if err != nil {
		return decoded, err
	}
	defer rendered.Cleanup()

	page := rendered.Result.RenderedImage
	onWhite := image.NewRGBA(page.Bounds())
	draw.Draw(onWhite, onWhite.Bounds(), image.NewUniform(color.White), image.Point{}, draw.Src)
	draw.Draw(onWhite, onWhite.Bounds(), page, page.Bounds().Min, draw.Over)
	decoded.image = onWhite
	return decoded, nil
}
