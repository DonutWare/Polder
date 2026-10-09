package markdown

import (
	"regexp"
	"strings"

	"github.com/yuin/goldmark"
	"github.com/yuin/goldmark/ast"
	"github.com/yuin/goldmark/extension"
	"github.com/yuin/goldmark/text"
)

var parser = goldmark.New(goldmark.WithExtensions(extension.GFM, extension.Footnote)).Parser()

type Document struct {
	Body []byte
	Root ast.Node
}

var (
	frontMatterOpen  = regexp.MustCompile(`\A---[ \t]*\r?\n`)
	frontMatterClose = regexp.MustCompile(`(?m)^(?:---|\.\.\.)[ \t]*(?:\r?\n|\z)`)
)

func Parse(source []byte) Document {
	body := withoutFrontMatter(source)
	return Document{Body: body, Root: parser.Parse(text.NewReader(body))}
}

func withoutFrontMatter(source []byte) []byte {
	opening := frontMatterOpen.Find(source)
	if opening == nil {
		return source
	}
	closing := frontMatterClose.FindIndex(source[len(opening):])
	if closing == nil {
		return source
	}
	return source[len(opening)+closing[1]:]
}

func (d Document) PlainText(node ast.Node) string {
	return strings.Join(d.Lines(node), " ")
}

func (d Document) Lines(node ast.Node) []string {
	var builder strings.Builder
	_ = ast.Walk(node, func(child ast.Node, entering bool) (ast.WalkStatus, error) {
		if !entering {
			return ast.WalkContinue, nil
		}
		switch typed := child.(type) {
		case *ast.Text:
			builder.Write(typed.Segment.Value(d.Body))
			if typed.SoftLineBreak() || typed.HardLineBreak() {
				builder.WriteByte('\n')
			}
		case *ast.String:
			builder.Write(typed.Value)
		case *ast.CodeBlock, *ast.FencedCodeBlock:
			lines := typed.Lines()
			for i := 0; i < lines.Len(); i++ {
				segment := lines.At(i)
				builder.Write(segment.Value(d.Body))
			}
		}
		return ast.WalkContinue, nil
	})
	var lines []string
	for _, line := range strings.Split(builder.String(), "\n") {
		if line = strings.TrimSpace(line); line != "" {
			lines = append(lines, line)
		}
	}
	return lines
}
