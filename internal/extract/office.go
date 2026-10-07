package extract

import (
	"archive/zip"
	"encoding/xml"
	"errors"
	"io"
	"sort"
	"strings"
)

const maxZipPartBytes = 64 << 20

var errNoText = errors.New("no readable text")

// readZipDocument reads Office Open XML (docx, xlsx, pptx…) and OpenDocument (odt, ods, odp…) files.
// Office Open XML keeps visible text in <t> elements spread over many parts; OpenDocument keeps the
// whole body in content.xml.
func readZipDocument(reader io.ReaderAt, size int64) (string, error) {
	archive, err := zip.NewReader(reader, size)
	if err != nil {
		return "", errNoText
	}
	parts := map[string]*zip.File{}
	for _, part := range archive.File {
		parts[part.Name] = part
	}
	if _, ok := parts["[Content_Types].xml"]; ok {
		return readOfficeOpenXML(archive.File)
	}
	if content, ok := parts["content.xml"]; ok {
		return readXMLText(content, func(string) bool { return true })
	}
	return "", errNoText
}

func readOfficeOpenXML(parts []*zip.File) (string, error) {
	sorted := make([]*zip.File, 0, len(parts))
	for _, part := range parts {
		if strings.HasSuffix(part.Name, ".xml") {
			sorted = append(sorted, part)
		}
	}
	sort.SliceStable(sorted, func(i, j int) bool { return naturalLess(sorted[i].Name, sorted[j].Name) })
	var text strings.Builder
	for _, part := range sorted {
		found, err := readXMLText(part, func(element string) bool { return element == "t" })
		if err != nil {
			continue
		}
		if strings.TrimSpace(found) != "" {
			text.WriteString(found)
			text.WriteString("\n\n")
		}
		if text.Len() > MaxTextBytes {
			break
		}
	}
	return text.String(), nil
}

func readXMLText(part *zip.File, keepsText func(element string) bool) (string, error) {
	opened, err := part.Open()
	if err != nil {
		return "", err
	}
	defer opened.Close()
	decoder := xml.NewDecoder(io.LimitReader(opened, maxZipPartBytes))
	decoder.Strict = false
	var text strings.Builder
	var open []string
	for text.Len() <= MaxTextBytes {
		token, err := decoder.Token()
		if errors.Is(err, io.EOF) {
			break
		}
		if err != nil {
			return text.String(), err
		}
		switch element := token.(type) {
		case xml.StartElement:
			open = append(open, element.Name.Local)
			switch element.Name.Local {
			case "tab", "s":
				text.WriteByte(' ')
			case "br", "line-break":
				text.WriteByte('\n')
			}
		case xml.EndElement:
			if len(open) > 0 {
				open = open[:len(open)-1]
			}
			switch element.Name.Local {
			case "p", "h", "si", "tr", "list-item":
				text.WriteByte('\n')
			case "tc", "c", "table-cell":
				text.WriteByte('\t')
			}
		case xml.CharData:
			if len(open) > 0 && keepsText(open[len(open)-1]) {
				text.Write(element)
			}
		}
	}
	return text.String(), nil
}

func naturalLess(a, b string) bool {
	for a != "" && b != "" {
		aDigits, bDigits := leadingDigits(a), leadingDigits(b)
		if aDigits != "" && bDigits != "" {
			if len(aDigits) != len(bDigits) {
				return len(aDigits) < len(bDigits)
			}
			if aDigits != bDigits {
				return aDigits < bDigits
			}
			a, b = a[len(aDigits):], b[len(bDigits):]
			continue
		}
		if a[0] != b[0] {
			return a[0] < b[0]
		}
		a, b = a[1:], b[1:]
	}
	return len(a) < len(b)
}

func leadingDigits(text string) string {
	end := 0
	for end < len(text) && text[end] >= '0' && text[end] <= '9' {
		end++
	}
	return text[:end]
}
