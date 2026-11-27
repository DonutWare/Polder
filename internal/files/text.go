package files

import (
	"path"
	"strings"
)

var textMimes = map[string]bool{
	"application/json":          true,
	"application/ld+json":       true,
	"application/xml":           true,
	"application/yaml":          true,
	"application/x-yaml":        true,
	"application/toml":          true,
	"application/javascript":    true,
	"application/x-javascript":  true,
	"application/typescript":    true,
	"application/x-sh":          true,
	"application/x-shellscript": true,
	"application/sql":           true,
	"application/graphql":       true,
	"application/x-httpd-php":   true,
	"application/x-python":      true,
	"application/x-ruby":        true,
	"application/x-perl":        true,
	"application/x-tex":         true,
	"application/x-latex":       true,
	"application/x-subrip":      true,
	"application/x-ndjson":      true,
	"image/svg+xml":             true,
}

var textExtensions = setOf(
	"txt", "text", "md", "markdown", "rst", "adoc", "org", "tex", "log", "csv", "tsv", "json", "jsonc", "json5",
	"ndjson", "yaml", "yml", "toml", "ini", "cfg", "conf", "config", "properties", "env", "xml", "svg", "html",
	"htm", "css", "scss", "sass", "less", "js", "mjs", "cjs", "jsx", "ts", "tsx", "dart", "go", "rs", "py", "rb",
	"php", "java", "kt", "kts", "swift", "c", "h", "cc", "cpp", "hpp", "cs", "m", "mm", "scala", "lua", "pl", "r",
	"sql", "graphql", "gql", "sh", "bash", "zsh", "fish", "ps1", "bat", "cmd", "gradle", "cmake", "make", "mk",
	"dockerfile", "gitignore", "gitattributes", "editorconfig", "srt", "vtt", "ics", "vcf", "diff", "patch", "nfo",
)

var textNames = setOf("dockerfile", "makefile", "license", "readme", "changelog", "authors", "codeowners")

func setOf(values ...string) map[string]bool {
	set := make(map[string]bool, len(values))
	for _, value := range values {
		set[value] = true
	}
	return set
}

func IsTextMime(mimeType string) bool {
	return strings.HasPrefix(mimeType, "text/") || textMimes[mimeType] || strings.HasSuffix(mimeType, "+json")
}

func IsTextName(name string) bool {
	lower := strings.ToLower(path.Base(name))
	extension := strings.TrimPrefix(path.Ext(lower), ".")
	if extension != "" && extension != strings.TrimPrefix(lower, ".") {
		return textExtensions[extension]
	}
	return textNames[lower] || (strings.HasPrefix(lower, ".") && textExtensions[strings.TrimPrefix(lower, ".")])
}

func IsText(name, mimeType string) bool {
	return IsTextMime(mimeType) || IsTextName(name)
}

func (e Entry) IsText() bool {
	return !e.IsDir && IsText(e.Name, e.Mime)
}
