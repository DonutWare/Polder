package extract

import (
	"bytes"
	"encoding/binary"
	"io"
	"strings"
	"unicode"
	"unicode/utf16"
	"unicode/utf8"
)

const (
	MaxTextBytes = 1 << 20
	sniffBytes   = 8 << 10
)

var (
	utf8BOM    = []byte{0xEF, 0xBB, 0xBF}
	utf16LEBOM = []byte{0xFF, 0xFE}
	utf16BEBOM = []byte{0xFE, 0xFF}
)

func looksLikeText(head []byte) bool {
	if bytes.HasPrefix(head, utf16LEBOM) || bytes.HasPrefix(head, utf16BEBOM) {
		return true
	}
	if bytes.IndexByte(head, 0) >= 0 {
		return false
	}
	for cut := 0; cut < utf8.UTFMax && cut < len(head); cut++ {
		if utf8.Valid(head[:len(head)-cut]) {
			return true
		}
	}
	return false
}

func readPlainText(reader io.Reader) (string, error) {
	raw, err := io.ReadAll(io.LimitReader(reader, 2*MaxTextBytes))
	if err != nil {
		return "", err
	}
	switch {
	case bytes.HasPrefix(raw, utf16LEBOM):
		return decodeUTF16(raw[len(utf16LEBOM):], binary.LittleEndian), nil
	case bytes.HasPrefix(raw, utf16BEBOM):
		return decodeUTF16(raw[len(utf16BEBOM):], binary.BigEndian), nil
	default:
		return strings.ToValidUTF8(string(bytes.TrimPrefix(raw, utf8BOM)), ""), nil
	}
}

func decodeUTF16(raw []byte, order binary.ByteOrder) string {
	units := make([]uint16, len(raw)/2)
	for i := range units {
		units[i] = order.Uint16(raw[2*i:])
	}
	return string(utf16.Decode(units))
}

func normalizeText(text string) string {
	text = strings.ReplaceAll(text, "\r\n", "\n")
	var out strings.Builder
	out.Grow(len(text))
	runes := []rune(text)
	for i := 0; i < len(runes); i++ {
		r := runes[i]
		if isBlank(r) {
			for i+1 < len(runes) && isBlank(runes[i+1]) {
				i++
			}
			out.WriteRune(' ')
			continue
		}
		if r == '\n' || !unicode.IsControl(r) && r != utf8.RuneError {
			out.WriteRune(r)
		}
	}
	return truncateUTF8(strings.TrimSpace(collapseBlankLines(out.String())), MaxTextBytes)
}

func isBlank(r rune) bool { return r == ' ' || r == '\t' || r == '　' }

// joinOCRSpacing undoes the space Tesseract puts between every Chinese and Japanese character, which would
// split words the search matches as a whole.
func joinOCRSpacing(text string) string {
	var out strings.Builder
	out.Grow(len(text))
	runes := []rune(text)
	for i := 0; i < len(runes); i++ {
		if isBlank(runes[i]) {
			end := i
			for end < len(runes) && isBlank(runes[end]) {
				end++
			}
			if i > 0 && end < len(runes) && isUnspaced(runes[i-1]) && isUnspaced(runes[end]) {
				i = end - 1
				continue
			}
		}
		out.WriteRune(runes[i])
	}
	return out.String()
}

func isUnspaced(r rune) bool {
	return unicode.In(r, unicode.Han, unicode.Hiragana, unicode.Katakana)
}

func collapseBlankLines(text string) string {
	lines := strings.Split(text, "\n")
	kept := lines[:0]
	blank := false
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			if !blank && len(kept) > 0 {
				kept = append(kept, "")
			}
			blank = true
			continue
		}
		kept = append(kept, line)
		blank = false
	}
	return strings.Join(kept, "\n")
}

func truncateUTF8(text string, limit int) string {
	if len(text) <= limit {
		return text
	}
	cut := limit
	for cut > 0 && !utf8.RuneStart(text[cut]) {
		cut--
	}
	return text[:cut]
}

func hasWords(text string) bool {
	return strings.IndexFunc(text, func(r rune) bool { return unicode.IsLetter(r) || unicode.IsDigit(r) }) >= 0
}
