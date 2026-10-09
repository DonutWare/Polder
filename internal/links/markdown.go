package links

import (
	"io"
	"net/url"
	"path"
	"strconv"
	"strings"

	"github.com/yuin/goldmark/ast"

	"polder-server/internal/files"
	"polder-server/internal/markdown"
	"polder-server/internal/storage"
)

const (
	markdownKind    = "markdown"
	fileIDParameter = "fileId"
)

type Markdown struct{}

func (Markdown) Kind() string { return markdownKind }

func (Markdown) Mimes() []string { return []string{files.MarkdownMime} }

func (Markdown) Extract(entry files.Entry, content io.Reader) ([]Link, error) {
	source, err := io.ReadAll(content)
	if err != nil {
		return nil, err
	}
	return readMarkdown(entry.Path, source), nil
}

func readMarkdown(notePath string, source []byte) []Link {
	document := markdown.Parse(source)
	var links []Link
	_ = ast.Walk(document.Root, func(node ast.Node, entering bool) (ast.WalkStatus, error) {
		if !entering {
			return ast.WalkContinue, nil
		}
		var destination string
		switch typed := node.(type) {
		case *ast.Link:
			destination = string(typed.Destination)
		case *ast.Image:
			destination = string(typed.Destination)
		default:
			return ast.WalkContinue, nil
		}
		if link, ok := resolveDestination(notePath, destination); ok {
			link.Title = document.PlainText(node)
			links = append(links, link)
		}
		return ast.WalkContinue, nil
	})
	return links
}

func resolveDestination(notePath, destination string) (Link, bool) {
	parsed, err := url.Parse(strings.TrimSpace(destination))
	if err != nil || parsed.Scheme != "" || parsed.Host != "" {
		return Link{}, false
	}
	var link Link
	if id, err := strconv.ParseInt(parsed.Query().Get(fileIDParameter), 10, 64); err == nil && id > 0 {
		link.TargetID = id
	}
	if parsed.Path != "" {
		target := parsed.Path
		if !strings.HasPrefix(target, "/") {
			target = path.Join(storage.ParentPath(notePath), target)
		}
		if clean, err := storage.CleanPath(target); err == nil {
			link.TargetPath = clean
		}
	}
	return link, link.TargetID != 0 || link.TargetPath != ""
}
