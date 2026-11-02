package sharing

import (
	"context"
	"io"
	"net/url"
	"path"
	"regexp"
	"strconv"
	"strings"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/storage"
)

const (
	MaxVisitorNoteBytes = 8 << 20
	embeddedFolder      = "embedded"
)

var (
	noteLinkPattern       = regexp.MustCompile(`(!?)\[([^\]]*)\]\(\s*(?:<([^>\n]*)>|([^)\s]*))(?:\s+(?:"[^"]*"|'[^']*'|\([^)]*\)))?\s*\)`)
	noteReferencePattern  = regexp.MustCompile(`(?m)^( {0,3}\[[^\]]+\]:[ \t]*)<?([^\s>]+)>?(.*)$`)
	externalSchemePattern = regexp.MustCompile(`^[a-zA-Z][a-zA-Z0-9+.-]*:`)
)

func IsNote(entry files.Entry) bool {
	return !entry.IsDir && entry.Mime == files.MarkdownMime
}

func (s *Service) VisitorNote(ctx context.Context, access Access, notePath string, content []byte) []byte {
	embeds := s.noteEmbeds(ctx, access, notePath, content)
	rewrite := func(destination string) (string, bool) {
		return visitorDestination(access, notePath, destination, embeds)
	}
	content = noteLinkPattern.ReplaceAllFunc(content, func(match []byte) []byte {
		parts := noteLinkPattern.FindSubmatch(match)
		bang, text := parts[1], parts[2]
		rewritten, kept := rewrite(linkDestination(parts))
		if !kept {
			return text
		}
		return []byte(string(bang) + "[" + string(text) + "](" + rewritten + ")")
	})
	return noteReferencePattern.ReplaceAllFunc(content, func(match []byte) []byte {
		parts := noteReferencePattern.FindSubmatch(match)
		rewritten, kept := rewrite(string(parts[2]))
		if !kept {
			return nil
		}
		return []byte(string(parts[1]) + rewritten + string(parts[3]))
	})
}

func linkDestination(parts [][]byte) string {
	if len(parts[3]) > 0 {
		return string(parts[3])
	}
	return string(parts[4])
}

func visitorDestination(access Access, notePath, destination string, embeds []string) (string, bool) {
	if externalSchemePattern.MatchString(destination) || strings.HasPrefix(destination, "#") {
		return destination, true
	}
	target, fragment, ok := noteTarget(notePath, destination)
	if !ok {
		return "", false
	}
	if access.Root.IsDir && storage.IsSameOrDescendant(target, access.Root.Path) {
		return escapedPath(access.RelativePath(target)) + fragment, true
	}
	for index, embedded := range embeds {
		if embedded == target {
			return embeddedFolder + "/" + strconv.Itoa(index+1) + "/" + url.PathEscape(path.Base(target)), true
		}
	}
	return "", false
}

func (s *Service) EmbeddedFile(ctx context.Context, access Access, relative string) (string, files.Entry, error) {
	index, name, ok := parseEmbedded(relative)
	if !ok || access.Link.ID == 0 || !IsNote(access.Root) {
		return "", files.Entry{}, notEmbedded(relative)
	}
	content, err := s.noteContent(ctx, access, access.Root.Path)
	if err != nil {
		return "", files.Entry{}, err
	}
	embeds := s.noteEmbeds(ctx, access, access.Root.Path, content)
	if index > len(embeds) || path.Base(embeds[index-1]) != name {
		return "", files.Entry{}, notEmbedded(relative)
	}
	target := embeds[index-1]
	entry, err := s.files.Stat(ctx, access.Owner, target)
	if err != nil {
		return "", files.Entry{}, notEmbedded(relative)
	}
	return target, entry, nil
}

func (s *Service) noteEmbeds(ctx context.Context, access Access, notePath string, content []byte) []string {
	if access.Link.ID == 0 || access.Root.IsDir || notePath != access.Root.Path {
		return nil
	}
	var embeds []string
	seen := map[string]bool{}
	for _, parts := range noteLinkPattern.FindAllSubmatch(content, -1) {
		target, _, ok := noteTarget(notePath, linkDestination(parts))
		if !ok || seen[target] || !storage.IsSameOrDescendant(target, path.Dir(notePath)) {
			continue
		}
		seen[target] = true
		entry, err := s.files.Stat(ctx, access.Owner, target)
		if err == nil && !entry.IsDir && embeddable(entry.Mime, len(parts[1]) > 0) {
			embeds = append(embeds, target)
		}
	}
	return embeds
}

func (s *Service) noteContent(ctx context.Context, access Access, notePath string) ([]byte, error) {
	note, _, err := s.files.Open(ctx, access.Owner, notePath)
	if err != nil {
		return nil, err
	}
	defer note.Close()
	return io.ReadAll(io.LimitReader(note, MaxVisitorNoteBytes))
}

func noteTarget(notePath, destination string) (string, string, bool) {
	parsed, err := url.Parse(destination)
	if err != nil || parsed.Scheme != "" || parsed.Host != "" || parsed.Path == "" {
		return "", "", false
	}
	fragment := ""
	if parsed.Fragment != "" {
		fragment = "#" + url.PathEscape(parsed.Fragment)
	}
	if strings.HasPrefix(parsed.Path, "/") {
		return path.Clean(parsed.Path), fragment, true
	}
	return path.Join(path.Dir(notePath), parsed.Path), fragment, true
}

func parseEmbedded(relative string) (int, string, bool) {
	parts := strings.Split(strings.TrimPrefix(relative, "/"), "/")
	if len(parts) != 3 || parts[0] != embeddedFolder {
		return 0, "", false
	}
	index, err := strconv.Atoi(parts[1])
	if err != nil || index < 1 {
		return 0, "", false
	}
	return index, parts[2], true
}

func escapedPath(relative string) string {
	segments := strings.Split(relative, "/")
	for i, segment := range segments {
		segments[i] = url.PathEscape(segment)
	}
	return strings.Join(segments, "/")
}

func embeddable(mime string, asImage bool) bool {
	if strings.HasPrefix(mime, "video/") {
		return true
	}
	return asImage && strings.HasPrefix(mime, "image/")
}

func notEmbedded(relative string) error {
	return apperr.NotFound("%s does not exist", relative)
}
