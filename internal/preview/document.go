package preview

import (
	"archive/zip"
	"context"
	"encoding/xml"
	"errors"
	"image"
	"io"
	"os"
	"path"
	"strconv"
	"strings"

	"polder-server/internal/files"
)

const (
	maxConvertedBytes           = 512 << 20
	maxZipPartBytes             = 64 << 20
	openDocumentPrefix          = "application/vnd.oasis.opendocument."
	officeOpenXMLPrefix         = "application/vnd.openxmlformats-officedocument."
	openDocumentThumbnail       = "Thumbnails/thumbnail.png"
	officeThumbnailRelationship = "http://schemas.openxmlformats.org/package/2006/relationships/metadata/thumbnail"
)

var (
	errNoThumbnail       = errors.New("the document holds no thumbnail")
	errConvertedTooLarge = errors.New("converted document is too large to preview")
)

func canCarryThumbnail(mimeType string) bool {
	return strings.HasPrefix(mimeType, openDocumentPrefix) || strings.HasPrefix(mimeType, officeOpenXMLPrefix)
}

func (w *Worker) renderDocument(ctx context.Context, file *os.File, entry files.Entry, convertible bool, maxEdge int) (decodedImage, error) {
	if canCarryThumbnail(entry.Mime) {
		decoded, err := embeddedThumbnail(file, entry.Size)
		if err == nil || !convertible {
			return decoded, err
		}
		if _, err := file.Seek(0, io.SeekStart); err != nil {
			return decodedImage{}, err
		}
	}
	return w.convertDocument(ctx, file, entry.Name, maxEdge)
}

func embeddedThumbnail(file io.ReaderAt, size int64) (decodedImage, error) {
	archive, err := zip.NewReader(file, size)
	if err != nil {
		return decodedImage{}, err
	}
	parts := map[string]*zip.File{}
	for _, part := range archive.File {
		parts[part.Name] = part
	}
	decoded := decodedImage{orientation: orientationNormal, pages: pageCount(parts)}
	thumbnail, ok := parts[openDocumentThumbnail]
	if !ok {
		thumbnail, ok = parts[officeThumbnailPath(parts)]
	}
	if !ok {
		return decoded, errNoThumbnail
	}
	opened, err := thumbnail.Open()
	if err != nil {
		return decoded, err
	}
	defer opened.Close()
	picture, _, err := image.Decode(io.LimitReader(opened, maxZipPartBytes))
	if err != nil {
		return decoded, errNoThumbnail
	}
	decoded.image = picture
	return decoded, nil
}

func officeThumbnailPath(parts map[string]*zip.File) string {
	relations, ok := parts["_rels/.rels"]
	if !ok {
		return ""
	}
	var document struct {
		Relationships []struct {
			Type   string `xml:"Type,attr"`
			Target string `xml:"Target,attr"`
		} `xml:"Relationship"`
	}
	if err := decodeXMLPart(relations, &document); err != nil {
		return ""
	}
	for _, relation := range document.Relationships {
		if relation.Type == officeThumbnailRelationship {
			return path.Clean(strings.TrimPrefix(relation.Target, "/"))
		}
	}
	return ""
}

func pageCount(parts map[string]*zip.File) int {
	if meta, ok := parts["meta.xml"]; ok {
		var document struct {
			Statistics struct {
				Pages string `xml:"page-count,attr"`
			} `xml:"meta>document-statistic"`
		}
		if decodeXMLPart(meta, &document) == nil {
			pages, _ := strconv.Atoi(document.Statistics.Pages)
			return pages
		}
	}
	if properties, ok := parts["docProps/app.xml"]; ok {
		var document struct {
			Pages  int `xml:"Pages"`
			Slides int `xml:"Slides"`
		}
		if decodeXMLPart(properties, &document) == nil {
			return max(document.Pages, document.Slides)
		}
	}
	return 0
}

func decodeXMLPart(part *zip.File, target any) error {
	opened, err := part.Open()
	if err != nil {
		return err
	}
	defer opened.Close()
	return xml.NewDecoder(io.LimitReader(opened, maxZipPartBytes)).Decode(target)
}

func (w *Worker) convertDocument(ctx context.Context, file *os.File, name string, maxEdge int) (decodedImage, error) {
	if err := os.MkdirAll(w.cacheDir, 0o750); err != nil {
		return decodedImage{}, err
	}
	converted, err := os.CreateTemp(w.cacheDir, "converted-*.pdf")
	if err != nil {
		return decodedImage{}, err
	}
	defer os.Remove(converted.Name())
	defer converted.Close()

	pdf, err := w.office.ConvertToPDF(ctx, name, file)
	if err != nil {
		return decodedImage{}, err
	}
	defer pdf.Close()
	size, err := io.Copy(converted, io.LimitReader(pdf, maxConvertedBytes+1))
	if err != nil {
		return decodedImage{}, err
	}
	if size > maxConvertedBytes {
		return decodedImage{}, errConvertedTooLarge
	}
	if _, err := converted.Seek(0, io.SeekStart); err != nil {
		return decodedImage{}, err
	}
	return w.pdf.render(converted, size, maxEdge)
}
