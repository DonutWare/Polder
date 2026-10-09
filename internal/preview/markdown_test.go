package preview

import (
	"image"
	"os"
	"path/filepath"
	"testing"
)

const markdownFixture = `---
title: Fixture
---
# 会议记录 Meeting notes

A paragraph with **bold**, *italic*, a [link](other.md?fileId=3) and ` + "`code`" + `.

## قائمة المهام

- [ ] مهمة مفتوحة
- [x] Done task
- Nested list
  1. हिन्दी पाठ
  2. Ελληνικά

> [!WARNING] Careful
> Callout body text.

> A plain quote.

` + "```go\nfunc main() {}\n```" + `

| Name | Value |
|------|------:|
| a    | 1     |

---

![diagram](diagram.png)
`

func renderFixture(t *testing.T, source string) image.Image {
	t.Helper()
	renderer := newMarkdownRenderer(t.TempDir())
	if !renderer.installed() {
		t.Skip("no system fonts to draw text with")
	}
	path := filepath.Join(t.TempDir(), "note.md")
	if err := os.WriteFile(path, []byte(source), 0o600); err != nil {
		t.Fatal(err)
	}
	file, err := os.Open(path)
	if err != nil {
		t.Fatal(err)
	}
	defer file.Close()
	decoded, err := renderer.render(file)
	if err != nil {
		t.Fatal(err)
	}
	return decoded.image
}

func inkedRows(picture image.Image) int {
	bounds := picture.Bounds()
	rows := 0
	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
		for x := bounds.Min.X; x < bounds.Max.X; x++ {
			if red, _, _, _ := picture.At(x, y).RGBA(); red < 0x8000 {
				rows++
				break
			}
		}
	}
	return rows
}

func TestMarkdownPreviewDrawsEveryScript(t *testing.T) {
	picture := renderFixture(t, markdownFixture)
	if picture.Bounds().Dx() != markdownPageWidth || picture.Bounds().Dy() != markdownPageHeight {
		t.Fatalf("page is %v", picture.Bounds())
	}
	if rows := inkedRows(picture); rows < 150 {
		t.Fatalf("only %d rows have ink", rows)
	}
	for _, script := range []string{"# 日本語", "مرحبا بالعالم", "नमस्ते दुनिया", "Привет"} {
		if rows := inkedRows(renderFixture(t, script)); rows == 0 {
			t.Errorf("%q drew nothing", script)
		}
	}
}

func TestEmptyMarkdownPreviewIsBlankPage(t *testing.T) {
	if rows := inkedRows(renderFixture(t, "")); rows != 0 {
		t.Fatalf("empty note drew %d rows", rows)
	}
}
