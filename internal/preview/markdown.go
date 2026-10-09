package preview

import (
	"bytes"
	"errors"
	"image"
	"image/color"
	"image/draw"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"sync"
	"unicode"
	"unicode/utf8"

	"github.com/go-text/typesetting/bidi"
	"github.com/go-text/typesetting/di"
	"github.com/go-text/typesetting/font"
	"github.com/go-text/typesetting/font/opentype"
	"github.com/go-text/typesetting/fontscan"
	"github.com/go-text/typesetting/shaping"
	"github.com/yuin/goldmark/ast"
	extensionast "github.com/yuin/goldmark/extension/ast"
	"golang.org/x/image/math/fixed"
	"golang.org/x/image/vector"

	"polder-server/internal/markdown"
)

const (
	markdownPageWidth    = 512
	markdownPageHeight   = 724
	markdownMargin       = 36
	markdownIndent       = 18
	markdownPreviewBytes = 8 << 10
	markdownBodySize     = 14.0
	markdownCodeSize     = 12.0
	markdownLineSpacing  = 1.45
)

var (
	markdownInk        = color.RGBA{R: 0x22, G: 0x22, B: 0x22, A: 0xff}
	markdownMutedInk   = color.RGBA{R: 0x6b, G: 0x6b, B: 0x6b, A: 0xff}
	markdownAccent     = color.RGBA{R: 0x2f, G: 0x6f, B: 0xd6, A: 0xff}
	markdownRule       = color.RGBA{R: 0xd4, G: 0xd4, B: 0xd4, A: 0xff}
	markdownCodeShade  = color.RGBA{R: 0xf1, G: 0xf1, B: 0xf1, A: 0xff}
	markdownImageShade = color.RGBA{R: 0xe6, G: 0xe6, B: 0xe6, A: 0xff}
	calloutHeader      = regexp.MustCompile(`^\[!([^\]\s]+)\][+-]?\s*`)
)

type markdownRenderer struct {
	fontIndexDir string
	loadFonts    sync.Once
	fonts        *fontscan.FontMap
	shaper       shaping.HarfbuzzShaper
	segmenter    shaping.Segmenter
	wrapper      shaping.LineWrapper
	paragraph    bidi.Paragraph
	mutex        sync.Mutex
}

type discardFontLog struct{}

func (discardFontLog) Printf(string, ...any) {}

func newMarkdownRenderer(cacheDir string) *markdownRenderer {
	return &markdownRenderer{fontIndexDir: filepath.Join(cacheDir, "fonts")}
}

func (r *markdownRenderer) installed() bool {
	r.loadFonts.Do(func() {
		fonts := fontscan.NewFontMap(discardFontLog{})
		if err := fonts.UseSystemFonts(r.fontIndexDir); err != nil {
			logger.Info("no system fonts found; notes get no previews", "error", err)
			return
		}
		fonts.SetQuery(fontscan.Query{Families: []string{fontscan.SansSerif}})
		if fonts.ResolveFace(' ') == nil {
			logger.Info("no usable system fonts found; notes get no previews")
			return
		}
		r.fonts = fonts
	})
	return r.fonts != nil
}

type textStyle struct {
	size      float64
	bold      bool
	monospace bool
	ink       color.RGBA
}

type markerKind int

const (
	noMarker markerKind = iota
	bulletMarker
	numberMarker
	openTaskMarker
	doneTaskMarker
)

type pageBlock struct {
	text        string
	style       textStyle
	indent      int
	marker      markerKind
	number      string
	bars        []color.RGBA
	shaded      bool
	image       bool
	rule        bool
	spaceBefore float64
}

func (r *markdownRenderer) render(file *os.File) (decodedImage, error) {
	if !r.installed() {
		return decodedImage{}, errors.New("no fonts to draw text with")
	}
	source, err := io.ReadAll(io.LimitReader(file, markdownPreviewBytes))
	if err != nil {
		return decodedImage{}, err
	}
	if cut := bytes.LastIndexByte(source, '\n'); len(source) == markdownPreviewBytes && cut > 0 {
		source = source[:cut]
	}
	document := markdown.Parse(source)
	var blocks []pageBlock
	collectBlocks(document, document.Root, 0, nil, &blocks)

	r.mutex.Lock()
	defer r.mutex.Unlock()
	page := image.NewRGBA(image.Rect(0, 0, markdownPageWidth, markdownPageHeight))
	draw.Draw(page, page.Bounds(), image.White, image.Point{}, draw.Src)
	r.drawBlocks(page, blocks)
	return decodedImage{image: page, orientation: orientationNormal}, nil
}

func collectBlocks(document markdown.Document, parent ast.Node, indent int, bars []color.RGBA, blocks *[]pageBlock) {
	body := textStyle{size: markdownBodySize, ink: markdownInk}
	for node := parent.FirstChild(); node != nil; node = node.NextSibling() {
		switch typed := node.(type) {
		case *ast.Heading:
			size := map[int]float64{1: 24, 2: 20, 3: 17}[typed.Level]
			if size == 0 {
				size = 15
			}
			*blocks = append(*blocks, pageBlock{
				text: document.PlainText(typed), style: textStyle{size: size, bold: true, ink: markdownInk},
				indent: indent, bars: bars, spaceBefore: size * 0.6,
			})
		case *ast.Paragraph, *ast.TextBlock:
			if onlyImage(node) {
				*blocks = append(*blocks, pageBlock{image: true, indent: indent, bars: bars, spaceBefore: 6})
				continue
			}
			*blocks = append(*blocks, pageBlock{text: strings.Join(document.Lines(node), "\n"), style: body, indent: indent, bars: bars, spaceBefore: 6})
		case *ast.Blockquote:
			collectQuote(document, typed, indent, bars, blocks)
		case *ast.List:
			collectList(document, typed, indent, bars, blocks)
		case *ast.FencedCodeBlock, *ast.CodeBlock, *ast.HTMLBlock:
			lines := node.Lines()
			for i := 0; i < lines.Len(); i++ {
				segment := lines.At(i)
				code := pageBlock{
					text:   strings.TrimRight(string(segment.Value(document.Body)), "\r\n"),
					style:  textStyle{size: markdownCodeSize, monospace: true, ink: markdownInk},
					indent: indent, bars: bars, shaded: true,
				}
				if i == 0 {
					code.spaceBefore = 6
				}
				*blocks = append(*blocks, code)
			}
		case *ast.ThematicBreak:
			*blocks = append(*blocks, pageBlock{rule: true, indent: indent, bars: bars, spaceBefore: 8})
		case *extensionast.Table:
			collectTable(document, typed, indent, bars, blocks)
		default:
			collectBlocks(document, node, indent, bars, blocks)
		}
	}
}

func onlyImage(paragraph ast.Node) bool {
	child := paragraph.FirstChild()
	if child == nil || child.NextSibling() != nil {
		return false
	}
	if link, isLink := child.(*ast.Link); isLink {
		child = link.FirstChild()
		if child == nil || child.NextSibling() != nil {
			return false
		}
	}
	_, isImage := child.(*ast.Image)
	return isImage
}

func collectQuote(document markdown.Document, quote *ast.Blockquote, indent int, bars []color.RGBA, blocks *[]pageBlock) {
	first := len(*blocks)
	collectBlocks(document, quote, indent+markdownIndent/2, append(append([]color.RGBA{}, bars...), markdownRule), blocks)
	if first >= len(*blocks) {
		return
	}
	opening := &(*blocks)[first]
	header := calloutHeader.FindStringSubmatch(opening.text)
	if header == nil {
		for i := first; i < len(*blocks); i++ {
			(*blocks)[i].style.ink = markdownMutedInk
		}
		return
	}
	for i := first; i < len(*blocks); i++ {
		(*blocks)[i].bars[len(bars)] = markdownAccent
	}
	title, body, _ := strings.Cut(opening.text[len(header[0]):], "\n")
	if title = strings.TrimSpace(title); title == "" {
		title = capitalized(header[1])
	}
	heading := *opening
	heading.text, heading.style.bold, heading.style.ink = title, true, markdownAccent
	opening.text, opening.spaceBefore = body, 2
	*blocks = append((*blocks)[:first], append([]pageBlock{heading}, (*blocks)[first:]...)...)
}

func collectList(document markdown.Document, list *ast.List, indent int, bars []color.RGBA, blocks *[]pageBlock) {
	number := list.Start
	for item := list.FirstChild(); item != nil; item = item.NextSibling() {
		first := len(*blocks)
		collectBlocks(document, item, indent+markdownIndent, bars, blocks)
		if first >= len(*blocks) {
			continue
		}
		opening := &(*blocks)[first]
		opening.marker = taskMarker(item)
		if opening.marker == noMarker && list.IsOrdered() {
			opening.marker, opening.number = numberMarker, strconv.Itoa(number)+string(list.Marker)
		} else if opening.marker == noMarker {
			opening.marker = bulletMarker
		}
		number++
	}
}

func taskMarker(item ast.Node) markerKind {
	block := item.FirstChild()
	if block == nil {
		return noMarker
	}
	checkbox, isTask := block.FirstChild().(*extensionast.TaskCheckBox)
	switch {
	case !isTask:
		return noMarker
	case checkbox.IsChecked:
		return doneTaskMarker
	default:
		return openTaskMarker
	}
}

func capitalized(word string) string {
	first, size := utf8.DecodeRuneInString(word)
	return string(unicode.ToTitle(first)) + word[size:]
}

func collectTable(document markdown.Document, table *extensionast.Table, indent int, bars []color.RGBA, blocks *[]pageBlock) {
	for row := table.FirstChild(); row != nil; row = row.NextSibling() {
		var cells []string
		for cell := row.FirstChild(); cell != nil; cell = cell.NextSibling() {
			cells = append(cells, document.PlainText(cell))
		}
		_, isHeader := row.(*extensionast.TableHeader)
		tableRow := pageBlock{
			text:   strings.Join(cells, "  │  "),
			style:  textStyle{size: markdownBodySize - 1, bold: isHeader, ink: markdownInk},
			indent: indent, bars: bars, spaceBefore: 2,
		}
		if isHeader {
			tableRow.spaceBefore = 6
		}
		*blocks = append(*blocks, tableRow)
	}
}

func (r *markdownRenderer) drawBlocks(page *image.RGBA, blocks []pageBlock) {
	bottom := float64(markdownPageHeight - markdownMargin)
	y := float64(markdownMargin)
	for index, block := range blocks {
		if index > 0 {
			y += block.spaceBefore
		}
		left := markdownMargin + block.indent
		width := markdownPageWidth - markdownMargin - left
		top := y
		switch {
		case block.rule:
			fill(page, image.Rect(left, int(y)+4, left+width, int(y)+5), markdownRule)
			y += 10
		case block.image:
			height := 80.0
			fill(page, image.Rect(left, int(y), left+min(width, 200), int(y+height)), markdownImageShade)
			y += height
		default:
			if block.text == "" && block.marker == noMarker {
				continue
			}
			lineHeight := block.style.size * markdownLineSpacing
			rightToLeft := r.startsRightToLeft([]rune(block.text))
			if y+lineHeight <= bottom {
				r.drawMarker(page, block, left, width, y, lineHeight, rightToLeft)
			}
			lines := r.layout(block.text, block.style, width, rightToLeft)
			if len(lines) == 0 {
				y += lineHeight
			}
			for _, line := range lines {
				if y+lineHeight > bottom {
					return
				}
				if block.shaded {
					fill(page, image.Rect(left-6, int(y), left+width, int(y+lineHeight)+1), markdownCodeShade)
				}
				r.drawLine(page, line, left, width, int(y+block.style.size*1.1), rightToLeft, block.style.ink)
				y += lineHeight
			}
		}
		barTop := top
		if index > 0 && len(blocks[index-1].bars) >= len(block.bars) {
			barTop -= block.spaceBefore
		}
		for depth, bar := range block.bars {
			x := markdownMargin + block.indent - markdownIndent/2*(len(block.bars)-depth) - 2
			fill(page, image.Rect(x, int(barTop), x+3, int(y)), bar)
		}
		if y > bottom {
			return
		}
	}
}

func (r *markdownRenderer) drawMarker(page *image.RGBA, block pageBlock, left, width int, y, lineHeight float64, rightToLeft bool) {
	centre := int(y + lineHeight/2)
	x := left - markdownIndent + 4
	if rightToLeft {
		x = left + width + 4
	}
	switch block.marker {
	case bulletMarker:
		fill(page, image.Rect(x+2, centre-2, x+6, centre+2), markdownInk)
	case openTaskMarker, doneTaskMarker:
		box := image.Rect(x, centre-5, x+10, centre+5)
		fill(page, box, markdownMutedInk)
		if block.marker == openTaskMarker {
			fill(page, box.Inset(1), color.RGBA{R: 0xff, G: 0xff, B: 0xff, A: 0xff})
		}
	case numberMarker:
		numberStyle := textStyle{size: block.style.size, ink: markdownMutedInk}
		lines := r.layout(block.number, numberStyle, markdownIndent*2, false)
		if len(lines) > 0 {
			r.drawLine(page, lines[0], x-8, markdownIndent, int(y+block.style.size*1.1), !rightToLeft, markdownMutedInk)
		}
	}
}

func fill(page *image.RGBA, area image.Rectangle, shade color.RGBA) {
	draw.Draw(page, area.Intersect(page.Bounds()), image.NewUniform(shade), image.Point{}, draw.Src)
}

func (r *markdownRenderer) layout(text string, style textStyle, width int, rightToLeft bool) []shaping.Line {
	runes := []rune(strings.ReplaceAll(text, "\n", " "))
	if len(runes) == 0 || width <= 0 {
		return nil
	}
	family := fontscan.SansSerif
	if style.monospace {
		family = fontscan.Monospace
	}
	aspect := font.Aspect{}
	if style.bold {
		aspect.Weight = font.WeightBold
	}
	r.fonts.SetQuery(fontscan.Query{Families: []string{family}, Aspect: aspect})

	direction := di.DirectionLTR
	if rightToLeft {
		direction = di.DirectionRTL
	}
	input := shaping.Input{Text: runes, RunEnd: len(runes), Direction: direction, Size: fixed.Int26_6(style.size * 64)}
	var shaped []shaping.Output
	for _, run := range r.segmenter.Split(input, r.fonts) {
		if run.Face != nil {
			shaped = append(shaped, r.shaper.Shape(run))
		}
	}
	if len(shaped) == 0 {
		return nil
	}
	lines, _ := r.wrapper.WrapParagraph(shaping.WrapConfig{Direction: direction}, width, runes, shaping.NewSliceIterator(shaped))
	return lines
}

func (r *markdownRenderer) startsRightToLeft(runes []rune) bool {
	runs := r.paragraph.Segment(runes, bidi.Neutral)
	if runs.NumRuns() == 0 {
		return false
	}
	lowest := runs.Run(0).Level
	for i := 1; i < runs.NumRuns(); i++ {
		lowest = min(lowest, runs.Run(i).Level)
	}
	return lowest%2 == 1
}

func (r *markdownRenderer) drawLine(page *image.RGBA, line shaping.Line, left, width, baseline int, rightToLeft bool, ink color.RGBA) {
	runs := append(shaping.Line{}, line...)
	sort.Slice(runs, func(i, j int) bool { return runs[i].VisualIndex < runs[j].VisualIndex })
	var lineWidth fixed.Int26_6
	for _, run := range runs {
		lineWidth += run.Advance
	}
	dot := float32(left)
	if rightToLeft {
		dot = float32(left+width) - float32(lineWidth)/64
	}
	bounds := page.Bounds()
	rasterizer := vector.NewRasterizer(bounds.Dx(), bounds.Dy())
	rasterizer.DrawOp = draw.Over
	drawn := false
	for _, run := range runs {
		for _, glyph := range run.Glyphs {
			outline, hasOutline := run.Face.GlyphDataOutline(glyph.GlyphID)
			if hasOutline {
				originX := dot + float32(glyph.XOffset)/64
				originY := float32(baseline) - float32(glyph.YOffset)/64
				addOutline(rasterizer, &run, outline, originX, originY)
				drawn = true
			}
			dot += float32(glyph.Advance) / 64
		}
	}
	if drawn {
		rasterizer.Draw(page, bounds, image.NewUniform(ink), image.Point{})
	}
}

func addOutline(rasterizer *vector.Rasterizer, run *shaping.Output, outline font.GlyphOutline, originX, originY float32) {
	point := func(segmentPoint opentype.SegmentPoint) (float32, float32) {
		return originX + float32(run.FromFontUnit(segmentPoint.X))/64, originY - float32(run.FromFontUnit(segmentPoint.Y))/64
	}
	open := false
	for _, segment := range outline.Segments {
		switch segment.Op {
		case opentype.SegmentOpMoveTo:
			if open {
				rasterizer.ClosePath()
			}
			rasterizer.MoveTo(point(segment.Args[0]))
			open = true
		case opentype.SegmentOpLineTo:
			rasterizer.LineTo(point(segment.Args[0]))
		case opentype.SegmentOpQuadTo:
			controlX, controlY := point(segment.Args[0])
			endX, endY := point(segment.Args[1])
			rasterizer.QuadTo(controlX, controlY, endX, endY)
		case opentype.SegmentOpCubeTo:
			firstX, firstY := point(segment.Args[0])
			secondX, secondY := point(segment.Args[1])
			endX, endY := point(segment.Args[2])
			rasterizer.CubeTo(firstX, firstY, secondX, secondY, endX, endY)
		}
	}
	if open {
		rasterizer.ClosePath()
	}
}
