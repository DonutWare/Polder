package extract

import (
	"archive/zip"
	"bytes"
	"image"
	"image/color"
	"strings"
	"testing"
	"unicode/utf16"
)

func TestLooksLikeText(t *testing.T) {
	for _, test := range []struct {
		name string
		head []byte
		want bool
	}{
		{"ascii", []byte("hello"), true},
		{"utf8 cut mid character", []byte("caf\xc3"), true},
		{"utf16 with BOM", append([]byte{0xFF, 0xFE}, 'h', 0, 'i', 0), true},
		{"nul bytes", []byte{'a', 0, 'b'}, false},
		{"latin1", []byte("caf\xe9 au lait"), false},
	} {
		if got := looksLikeText(test.head); got != test.want {
			t.Errorf("%s: looksLikeText = %v, want %v", test.name, got, test.want)
		}
	}
}

func TestReadPlainTextDecodesUTF16(t *testing.T) {
	encoded := []byte{0xFE, 0xFF}
	for _, unit := range utf16.Encode([]rune("ナス")) {
		encoded = append(encoded, byte(unit>>8), byte(unit))
	}
	if got, _ := readPlainText(bytes.NewReader(encoded)); got != "ナス" {
		t.Fatalf("readPlainText = %q", got)
	}
}

func TestNormalizeText(t *testing.T) {
	got := normalizeText("請求 書\r\n\n\n\nMeeting in 東京 on\tMonday\x00")
	want := "請求 書\n\nMeeting in 東京 on Monday"
	if got != want {
		t.Fatalf("normalizeText = %q, want %q", got, want)
	}
}

func TestJoinOCRSpacing(t *testing.T) {
	got := joinOCRSpacing("請求 書 の 番号 in 東京 on 안녕하세요 세계")
	want := "請求書の番号 in 東京 on 안녕하세요 세계"
	if got != want {
		t.Fatalf("joinOCRSpacing = %q, want %q", got, want)
	}
}

func TestTruncateKeepsWholeCharacters(t *testing.T) {
	if got := truncateUTF8("aé", 2); got != "a" {
		t.Fatalf("truncateUTF8 = %q", got)
	}
}

func zipOf(t *testing.T, parts map[string]string) []byte {
	t.Helper()
	var archive bytes.Buffer
	writer := zip.NewWriter(&archive)
	for name, content := range parts {
		part, err := writer.Create(name)
		if err != nil {
			t.Fatal(err)
		}
		part.Write([]byte(content))
	}
	writer.Close()
	return archive.Bytes()
}

func TestReadZipDocument(t *testing.T) {
	odt := zipOf(t, map[string]string{
		"mimetype": "application/vnd.oasis.opendocument.text",
		"content.xml": `<office:document-content xmlns:office="o" xmlns:text="t"><office:automatic-styles/>` +
			`<office:body><text:h>Title</text:h><text:p>first<text:s/>line</text:p></office:body></office:document-content>`,
	})
	pptx := zipOf(t, map[string]string{
		"[Content_Types].xml":    `<Types/>`,
		"ppt/slides/slide10.xml": `<p:sld xmlns:p="p" xmlns:a="a"><a:p><a:r><a:t>tenth</a:t></a:r></a:p></p:sld>`,
		"ppt/slides/slide2.xml":  `<p:sld xmlns:p="p" xmlns:a="a"><a:p><a:r><a:t>second</a:t></a:r></a:p></p:sld>`,
		"ppt/theme/theme1.xml":   `<a:theme xmlns:a="a" name="Office"><a:font typeface="Calibri"/></a:theme>`,
	})
	for name, test := range map[string]struct {
		archive []byte
		want    string
	}{
		"odt":  {odt, "Title\nfirst line"},
		"pptx": {pptx, "second\n\ntenth"},
	} {
		got, err := readZipDocument(bytes.NewReader(test.archive), int64(len(test.archive)))
		if err != nil {
			t.Fatalf("%s: %v", name, err)
		}
		if got := normalizeText(got); got != test.want {
			t.Errorf("%s: text = %q, want %q", name, got, test.want)
		}
	}
	plain := zipOf(t, map[string]string{"photo.jpg": "jpeg"})
	if _, err := readZipDocument(bytes.NewReader(plain), int64(len(plain))); err != errNoText {
		t.Fatalf("a plain zip should have no text, got %v", err)
	}
}

func TestGrayscalePGMFlattensOntoWhite(t *testing.T) {
	img := image.NewNRGBA(image.Rect(0, 0, 2, 1))
	img.Set(1, 0, color.NRGBA{A: 255})
	encoded := grayscalePGM(img)
	if !strings.HasPrefix(string(encoded), "P5\n2 1\n255\n") {
		t.Fatalf("header = %q", encoded)
	}
	if pixels := encoded[len(encoded)-2:]; pixels[0] != 255 || pixels[1] != 0 {
		t.Fatalf("pixels = %v, want transparent as white and black as black", pixels)
	}
}
