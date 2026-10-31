package recipes

import (
	"html"
	"strings"

	nethtml "golang.org/x/net/html"
	"golang.org/x/net/html/atom"
)

const (
	maxDescriptionLength = 600
	maxLineLength        = 2000
)

var blockElements = map[atom.Atom]bool{
	atom.P: true, atom.Div: true, atom.Li: true, atom.Br: true, atom.Ol: true, atom.Ul: true,
	atom.H1: true, atom.H2: true, atom.H3: true, atom.H4: true, atom.H5: true, atom.H6: true,
	atom.Tr: true, atom.Section: true, atom.Article: true,
}

func cleanText(value string) string {
	return limit(strings.Join(strings.Fields(unescape(value)), " "), maxLineLength)
}

func cleanLines(value string) []string {
	var lines []string
	for _, line := range strings.Split(htmlToText(value), "\n") {
		if cleaned := cleanText(line); cleaned != "" {
			lines = append(lines, cleaned)
		}
	}
	return lines
}

func unescape(value string) string {
	for range 3 {
		unescaped := html.UnescapeString(value)
		if unescaped == value {
			break
		}
		value = unescaped
	}
	return value
}

func htmlToText(value string) string {
	if !strings.ContainsAny(value, "<&") {
		return value
	}
	nodes, err := nethtml.ParseFragment(strings.NewReader(unescape(value)), &nethtml.Node{Type: nethtml.ElementNode, Data: "div", DataAtom: atom.Div})
	if err != nil {
		return value
	}
	var text strings.Builder
	for _, node := range nodes {
		writeLines(&text, node)
	}
	return text.String()
}

func textContent(node *nethtml.Node) string {
	var text strings.Builder
	writeLines(&text, node)
	return text.String()
}

func writeLines(text *strings.Builder, node *nethtml.Node) {
	switch node.Type {
	case nethtml.TextNode:
		text.WriteString(node.Data)
		return
	case nethtml.ElementNode:
		if node.DataAtom == atom.Script || node.DataAtom == atom.Style {
			return
		}
	}
	block := node.Type == nethtml.ElementNode && blockElements[node.DataAtom]
	if block {
		text.WriteString("\n")
	}
	for child := node.FirstChild; child != nil; child = child.NextSibling {
		writeLines(text, child)
	}
	if block {
		text.WriteString("\n")
	}
}

func limit(value string, length int) string {
	runes := []rune(value)
	if len(runes) <= length {
		return value
	}
	return strings.TrimSpace(string(runes[:length])) + "…"
}
