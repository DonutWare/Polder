package recipes

import (
	"bytes"
	"net/url"
	"strings"

	"golang.org/x/net/html"
	"golang.org/x/net/html/atom"

	"polder-server/internal/apperr"
)

func Extract(body []byte, page *url.URL) (Recipe, error) {
	document, err := html.Parse(bytes.NewReader(body))
	if err != nil {
		return Recipe{}, apperr.Invalid("the page could not be read")
	}
	for _, read := range []func(*html.Node, *url.URL) (Recipe, bool){fromLinkedData, fromMicrodata, fromPageText} {
		if recipe, ok := read(document, page); ok && !recipe.isEmpty() {
			recipe.Name = fallback(recipe.Name, pageTitle(document))
			return recipe, nil
		}
	}
	return Recipe{}, apperr.Invalid("no recipe found on this page")
}

func Parse(content string, page *url.URL) (Recipe, error) {
	if looksLikeHTML(content) {
		return Extract([]byte(content), page)
	}
	if recipe, ok := fromText(content); ok {
		return recipe, nil
	}
	return Recipe{}, apperr.Invalid("no recipe found in the pasted text; it needs an ingredients and a steps heading")
}

func looksLikeHTML(content string) bool {
	start := strings.ToLower(content[:min(len(content), 4096)])
	for _, tag := range []string{"<!doctype", "<html", "<head", "<body", "<script", "<div", "<p>", "<li"} {
		if strings.Contains(start, tag) {
			return true
		}
	}
	return false
}

func fromPageText(document *html.Node, _ *url.URL) (Recipe, bool) {
	body := findFirst(document, func(node *html.Node) bool { return node.DataAtom == atom.Body })
	if body == nil {
		body = document
	}
	recipe, ok := fromText(textContent(body))
	recipe.Name = ""
	return recipe, ok
}

func pageTitle(document *html.Node) string {
	title := findFirst(document, func(node *html.Node) bool { return node.DataAtom == atom.Title })
	if title == nil {
		return ""
	}
	return cleanText(textContent(title))
}

func findFirst(root *html.Node, matches func(*html.Node) bool) *html.Node {
	if root.Type == html.ElementNode && matches(root) {
		return root
	}
	for child := root.FirstChild; child != nil; child = child.NextSibling {
		if found := findFirst(child, matches); found != nil {
			return found
		}
	}
	return nil
}

func findAll(root *html.Node, matches func(*html.Node) bool) []*html.Node {
	var found []*html.Node
	var visit func(*html.Node)
	visit = func(node *html.Node) {
		if node.Type == html.ElementNode && matches(node) {
			found = append(found, node)
		}
		for child := node.FirstChild; child != nil; child = child.NextSibling {
			visit(child)
		}
	}
	visit(root)
	return found
}

func attribute(node *html.Node, name string) string {
	for _, attr := range node.Attr {
		if strings.EqualFold(attr.Key, name) {
			return strings.TrimSpace(attr.Val)
		}
	}
	return ""
}

func fallback(value, otherwise string) string {
	if value != "" {
		return value
	}
	return otherwise
}

func resolve(page *url.URL, reference string) string {
	reference = strings.TrimSpace(reference)
	if reference == "" {
		return ""
	}
	parse := url.Parse
	if page != nil {
		parse = page.Parse
	}
	parsed, err := parse(reference)
	if err != nil || (parsed.Scheme != "http" && parsed.Scheme != "https") {
		return ""
	}
	return parsed.String()
}
