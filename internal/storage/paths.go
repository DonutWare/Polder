package storage

import (
	"path"
	"strings"
	"unicode/utf8"

	"polder-server/internal/apperr"
)

const (
	RootPath       = "/"
	ReservedPrefix = ".polder"
	maxPathLength  = 4096
	maxNameLength  = 255
)

func CleanPath(raw string) (string, error) {
	if raw == "" || raw == RootPath {
		return RootPath, nil
	}
	if !utf8.ValidString(raw) || len(raw) > maxPathLength || strings.ContainsAny(raw, "\\\x00") {
		return "", apperr.Invalid("invalid path %q", raw)
	}
	if !strings.HasPrefix(raw, "/") {
		raw = "/" + raw
	}
	for _, segment := range strings.Split(strings.Trim(raw, "/"), "/") {
		if err := validateSegment(segment); err != nil {
			return "", err
		}
	}
	return path.Clean(raw), nil
}

func validateSegment(segment string) error {
	switch {
	case segment == "", segment == ".", segment == "..":
		return apperr.Invalid("invalid path segment %q", segment)
	case len(segment) > maxNameLength:
		return apperr.Invalid("name too long")
	case strings.HasPrefix(segment, ReservedPrefix):
		return apperr.Invalid("names starting with %s are reserved", ReservedPrefix)
	}
	return nil
}

func IsReservedName(name string) bool {
	return strings.HasPrefix(name, ReservedPrefix)
}

var systemFileNames = map[string]bool{".DS_Store": true, "Thumbs.db": true, "desktop.ini": true}

// IsSystemFile reports OS clutter (Finder, Explorer) that appears when the data directory is browsed locally.
func IsSystemFile(name string) bool {
	return systemFileNames[name] || strings.HasPrefix(name, "._")
}

func ParentPath(cleanPath string) string {
	return path.Dir(cleanPath)
}

func BaseName(cleanPath string) string {
	if cleanPath == RootPath {
		return ""
	}
	return path.Base(cleanPath)
}

func IsSameOrDescendant(candidate, ancestor string) bool {
	if ancestor == RootPath {
		return true
	}
	return candidate == ancestor || strings.HasPrefix(candidate, ancestor+"/")
}

func Ancestors(cleanPath string) []string {
	var ancestors []string
	for current := ParentPath(cleanPath); current != RootPath; current = ParentPath(current) {
		ancestors = append([]string{current}, ancestors...)
	}
	return ancestors
}
