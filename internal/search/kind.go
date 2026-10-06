package search

import (
	"path"
	"strings"
)

// Folder and file are the only kinds the search defines itself; every other kind is the top-level MIME
// type the system MIME database reports, such as image or application.
const (
	kindFolder = "folder"
	kindFile   = "file"
)

func extensionOf(name string) string {
	return strings.TrimPrefix(strings.ToLower(path.Ext(name)), ".")
}

func kindOf(isDir bool, mimeType string) string {
	if isDir {
		return kindFolder
	}
	major, _, _ := strings.Cut(mimeType, "/")
	return major
}

func subtypeOf(mimeType string) string {
	_, minor, _ := strings.Cut(mimeType, "/")
	return minor
}
