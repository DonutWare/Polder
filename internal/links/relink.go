package links

import (
	"context"
	"fmt"
	"io"
	"net/url"
	"path"
	"regexp"
	"strconv"
	"strings"
	"unicode/utf8"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/storage"
	"polder-server/internal/users"
)

var (
	inlineLink        = regexp.MustCompile(`(!?)\[((?:[^\[\]\\]|\\.)*)\]\(\s*(<[^>\n]*>|[^\s()]+)(?:\s+(?:"[^"]*"|'[^']*'))?\s*\)`)
	referenceLink     = regexp.MustCompile(`^ {0,3}\[(?:[^\[\]\\]|\\.)+\]:[ \t]*(<[^>\n]*>|\S+)`)
	fenceLine         = regexp.MustCompile("^ {0,3}(`{3,}|~{3,})")
	labelSpecialChars = regexp.MustCompile(`[\[\]]`)
)

type sourceLink struct {
	label            string
	labelStart       int
	destination      string
	destinationStart int
	isReference      bool
}

func (l sourceLink) labelEnd() int { return l.labelStart + len(l.label) }

func (l sourceLink) destinationEnd() int { return l.destinationStart + len(l.destination) }

func (g *Graph) FileMutation(_ context.Context, mutation files.Mutation) {
	if mutation.Kind != files.MutationMove || mutation.FromPath == "" || mutation.FromPath == mutation.Path {
		return
	}
	g.movesMutex.Lock()
	g.moves = append(g.moves, move{userID: mutation.Owner.ID, path: mutation.Path, from: mutation.FromPath})
	g.movesMutex.Unlock()
	select {
	case g.movesReady <- struct{}{}:
	default:
	}
}

func (g *Graph) takeMoves() []move {
	g.movesMutex.Lock()
	defer g.movesMutex.Unlock()
	taken := g.moves
	g.moves = nil
	return taken
}

func (g *Graph) relinkAfterMove(ctx context.Context, moved move) {
	owner, err := g.users.ByID(ctx, moved.userID)
	if err != nil {
		return
	}
	notes, err := g.notesAffectedByMove(ctx, moved.userID, moved.path)
	if err != nil {
		logger.Warn("find notes that link to a moved file", "path", moved.path, "error", err)
		return
	}
	for _, noteID := range notes {
		if ctx.Err() != nil {
			return
		}
		if err := g.relinkNote(ctx, owner, noteID, moved); err != nil {
			logger.Warn("update links after a move", "path", moved.path, "error", err)
		}
	}
}

func (g *Graph) notesAffectedByMove(ctx context.Context, userID int64, movedPath string) ([]int64, error) {
	prefix := movedPath + "/"
	rows, err := g.db.QueryContext(ctx,
		`SELECT l.source_id FROM file_links l JOIN files t ON t.id = l.target_id
		 WHERE l.user_id = $1 AND (t.path = $2 OR SUBSTR(t.path, 1, $3) = $4)
		 UNION
		 SELECT f.id FROM files f
		 WHERE f.user_id = $1 AND f.mime = $5 AND (f.path = $2 OR SUBSTR(f.path, 1, $3) = $4)`,
		userID, movedPath, utf8.RuneCountInString(prefix), prefix, files.MarkdownMime)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var notes []int64
	for rows.Next() {
		var noteID int64
		if err := rows.Scan(&noteID); err != nil {
			return nil, err
		}
		notes = append(notes, noteID)
	}
	return notes, rows.Err()
}

func (g *Graph) relinkNote(ctx context.Context, owner users.User, noteID int64, moved move) error {
	note, err := g.files.EntryByID(ctx, owner.ID, noteID)
	if apperr.Is(err, apperr.KindNotFound) || note.IsDir || note.Mime != files.MarkdownMime {
		return nil
	}
	if err != nil {
		return err
	}
	previousNotePath := note.Path
	if storage.IsSameOrDescendant(note.Path, moved.path) {
		previousNotePath = moved.from + strings.TrimPrefix(note.Path, moved.path)
	}
	file, _, err := g.files.Open(ctx, owner, note.Path)
	if err != nil {
		return err
	}
	content, err := io.ReadAll(file)
	_ = file.Close()
	if err != nil {
		return err
	}
	source := string(content)
	updated, err := g.rewriteLinks(ctx, owner, note, source, previousNotePath)
	if err != nil || updated == source {
		return err
	}
	_, err = g.files.Write(ctx, owner, files.WriteRequest{
		Path:         note.Path,
		BaseRev:      note.Rev,
		Content:      strings.NewReader(updated),
		Housekeeping: true,
	})
	if apperr.Is(err, apperr.KindConflict) || apperr.Is(err, apperr.KindNotFound) {
		return nil
	}
	return err
}

func (g *Graph) rewriteLinks(ctx context.Context, owner users.User, note files.Entry, source, previousNotePath string) (string, error) {
	links := findSourceLinks(source)
	if len(links) == 0 {
		return source, nil
	}
	previousTargets, err := g.linkedTargetsByPath(ctx, note.ID)
	if err != nil {
		return "", err
	}
	var builder strings.Builder
	copied := 0
	for _, link := range links {
		previous, ok := resolveDestination(previousNotePath, link.destination)
		if !ok {
			continue
		}
		target, found := g.currentTarget(ctx, owner, previous, previousTargets)
		if !found {
			continue
		}
		if label, changed := labelAfterRename(link.label, path.Base(previous.TargetPath), target); changed && !link.isReference {
			builder.WriteString(source[copied:link.labelStart])
			builder.WriteString(label)
			copied = link.labelEnd()
		}
		if current, ok := resolveDestination(note.Path, link.destination); !ok || current.TargetPath != target.Path {
			builder.WriteString(source[copied:link.destinationStart])
			builder.WriteString(destinationFor(target, note.Path, fragmentOf(link.destination)))
			copied = link.destinationEnd()
		}
	}
	if copied == 0 {
		return source, nil
	}
	builder.WriteString(source[copied:])
	return builder.String(), nil
}

func (g *Graph) linkedTargetsByPath(ctx context.Context, noteID int64) (map[string]int64, error) {
	rows, err := g.db.QueryContext(ctx,
		`SELECT target_path, target_id FROM file_links WHERE source_id = $1 AND target_id IS NOT NULL`, noteID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	targets := map[string]int64{}
	for rows.Next() {
		var targetPath string
		var targetID int64
		if err := rows.Scan(&targetPath, &targetID); err != nil {
			return nil, err
		}
		targets[targetPath] = targetID
	}
	return targets, rows.Err()
}

func (g *Graph) currentTarget(ctx context.Context, owner users.User, link Link, previousTargets map[string]int64) (files.Entry, bool) {
	targetID := link.TargetID
	if targetID == 0 {
		targetID = previousTargets[link.TargetPath]
	}
	if targetID != 0 {
		if target, err := g.files.EntryByID(ctx, owner.ID, targetID); err == nil {
			return target, true
		}
	}
	if link.TargetID != 0 || link.TargetPath == "" {
		return files.Entry{}, false
	}
	target, err := g.files.Stat(ctx, owner, link.TargetPath)
	return target, err == nil
}

func findSourceLinks(source string) []sourceLink {
	var links []sourceLink
	offset := 0
	fence := ""
	for _, line := range strings.Split(source, "\n") {
		if marker := fenceLine.FindStringSubmatch(line); marker != nil {
			if fence == "" {
				fence = marker[1]
			} else if marker[1][0] == fence[0] && len(marker[1]) >= len(fence) {
				fence = ""
			}
		} else if fence == "" {
			links = append(links, linksInLine(line, offset)...)
		}
		offset += len(line) + 1
	}
	return links
}

func linksInLine(line string, offset int) []sourceLink {
	if match := referenceLink.FindStringSubmatchIndex(line); match != nil {
		start, end := withoutAngleBrackets(line, match[2], match[3])
		return []sourceLink{{destination: line[start:end], destinationStart: offset + start, isReference: true}}
	}
	code := codeSpans(line)
	var links []sourceLink
	for _, match := range inlineLink.FindAllStringSubmatchIndex(line, -1) {
		if insideAny(match[0], code) {
			continue
		}
		start, end := withoutAngleBrackets(line, match[6], match[7])
		links = append(links, sourceLink{
			label:            line[match[4]:match[5]],
			labelStart:       offset + match[4],
			destination:      line[start:end],
			destinationStart: offset + start,
		})
	}
	return links
}

func withoutAngleBrackets(line string, start, end int) (int, int) {
	if line[start] == '<' {
		return start + 1, end - 1
	}
	return start, end
}

func codeSpans(line string) [][2]int {
	var spans [][2]int
	for i := 0; i < len(line); {
		if line[i] != '`' {
			i++
			continue
		}
		run := backtickRun(line, i)
		closing := -1
		for j := i + run; j < len(line); {
			if line[j] != '`' {
				j++
				continue
			}
			length := backtickRun(line, j)
			if length == run {
				closing = j + length
				break
			}
			j += length
		}
		if closing < 0 {
			i += run
			continue
		}
		spans = append(spans, [2]int{i, closing})
		i = closing
	}
	return spans
}

func backtickRun(line string, start int) int {
	end := start
	for end < len(line) && line[end] == '`' {
		end++
	}
	return end - start
}

func insideAny(position int, spans [][2]int) bool {
	for _, span := range spans {
		if position >= span[0] && position < span[1] {
			return true
		}
	}
	return false
}

func labelAfterRename(label, previousName string, target files.Entry) (string, bool) {
	name := target.Name
	if target.Mime == files.MarkdownMime {
		name = withoutExtension(name)
	}
	if label == "" {
		return escapeLabel(name), true
	}
	var followed string
	switch label {
	case escapeLabel(previousName):
		followed = target.Name
	case escapeLabel(withoutExtension(previousName)):
		followed = withoutExtension(target.Name)
	default:
		return label, false
	}
	escaped := escapeLabel(followed)
	return escaped, escaped != label
}

func withoutExtension(name string) string {
	if dot := strings.LastIndex(name, "."); dot > 0 {
		return name[:dot]
	}
	return name
}

func escapeLabel(label string) string {
	return labelSpecialChars.ReplaceAllStringFunc(label, func(special string) string { return `\` + special })
}

func fragmentOf(destination string) string {
	parsed, err := url.Parse(strings.TrimSpace(destination))
	if err != nil {
		return ""
	}
	return parsed.Fragment
}

func destinationFor(target files.Entry, notePath, fragment string) string {
	segments := strings.Split(relativePath(storage.ParentPath(notePath), target.Path), "/")
	for i, segment := range segments {
		if segment != ".." {
			segments[i] = escapePathSegment(segment)
		}
	}
	destination := strings.Join(segments, "/") + "?" + fileIDParameter + "=" + strconv.FormatInt(target.ID, 10)
	if fragment != "" {
		destination += "#" + fragment
	}
	return destination
}

func relativePath(fromDirectory, to string) string {
	from := pathSegments(fromDirectory)
	target := pathSegments(to)
	shared := 0
	for shared < len(from) && shared < len(target)-1 && from[shared] == target[shared] {
		shared++
	}
	var parts []string
	for range from[shared:] {
		parts = append(parts, "..")
	}
	return strings.Join(append(parts, target[shared:]...), "/")
}

func pathSegments(cleanPath string) []string {
	trimmed := strings.Trim(cleanPath, "/")
	if trimmed == "" {
		return nil
	}
	return strings.Split(trimmed, "/")
}

func escapePathSegment(segment string) string {
	var builder strings.Builder
	for _, b := range []byte(segment) {
		if isUnreserved(b) {
			builder.WriteByte(b)
		} else {
			fmt.Fprintf(&builder, "%%%02X", b)
		}
	}
	return builder.String()
}

func isUnreserved(b byte) bool {
	return b >= 'A' && b <= 'Z' || b >= 'a' && b <= 'z' || b >= '0' && b <= '9' || b == '-' || b == '_' || b == '.' || b == '~'
}
