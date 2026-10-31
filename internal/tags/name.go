package tags

import (
	"regexp"
	"strings"
	"unicode"
)

const maxNameLength = 64

var (
	namePattern  = regexp.MustCompile(`^[\p{L}\p{N}_\-/]+$`)
	colorPattern = regexp.MustCompile(`^#[0-9a-f]{6}$`)
)

var palette = []string{
	"#e5484d", "#f76b15", "#ffc53d", "#46a758", "#12a594",
	"#0090ff", "#3e63dd", "#8e4ec6", "#d6409f", "#8d8d8d",
}

func ValidName(name string) bool {
	return namePattern.MatchString(name) &&
		len([]rune(name)) <= maxNameLength &&
		strings.IndexFunc(name, unicode.IsLetter) >= 0
}

func Key(name string) string {
	return strings.ToLower(name)
}

func ValidColor(color string) bool {
	return colorPattern.MatchString(color)
}

func NormalizeColor(color string) string {
	return strings.ToLower(strings.TrimSpace(color))
}

func paletteColor(index int) string {
	return palette[index%len(palette)]
}
