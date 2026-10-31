package recipes

import (
	"bytes"
	"context"
	"fmt"
	"net/url"
	"path"
	"strconv"
	"strings"
	"unicode"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/linkpreview"
	"polder-server/internal/users"
)

const (
	attachmentsFolder = "attachments"
	maxImages         = 12
	maxNameAttempts   = 100
	maxTitleLength    = 120
	maxSlugLength     = 60
	maxPastedBytes    = 5 << 20
)

var imageExtensions = map[string]string{
	"image/png":                ".png",
	"image/jpeg":               ".jpg",
	"image/gif":                ".gif",
	"image/webp":               ".webp",
	"image/bmp":                ".bmp",
	"image/x-icon":             ".ico",
	"image/vnd.microsoft.icon": ".ico",
}

type Fetcher interface {
	Document(ctx context.Context, owner int64, raw string) ([]byte, *url.URL, error)
	ImageAt(ctx context.Context, owner int64, raw string) (linkpreview.Asset, error)
}

type Writer interface {
	Write(ctx context.Context, owner users.User, request files.WriteRequest) (files.Entry, error)
}

type Service struct {
	fetcher Fetcher
	files   Writer
}

func NewService(fetcher Fetcher, writer Writer) *Service {
	return &Service{fetcher: fetcher, files: writer}
}

type Request struct {
	Source  string
	Content string
	Folder  string
}

func (s *Service) Import(ctx context.Context, owner users.User, request Request) (files.Entry, error) {
	source, err := sourceURL(request.Source)
	if err != nil {
		return files.Entry{}, err
	}
	recipe, err := s.read(ctx, owner, source, request.Content)
	if err != nil {
		return files.Entry{}, err
	}
	title := noteTitle(recipe.Name)
	images, err := s.saveImages(ctx, owner, recipe, request.Folder, slug(title))
	if err != nil {
		return files.Entry{}, err
	}
	content := []byte(Render(recipe, request.Source, images))
	return s.writeNew(ctx, owner, request.Folder, title, ".md", " ", content)
}

func (s *Service) read(ctx context.Context, owner users.User, source *url.URL, content string) (Recipe, error) {
	if strings.TrimSpace(content) != "" {
		if len(content) > maxPastedBytes {
			return Recipe{}, apperr.Invalid("the pasted recipe is too long")
		}
		return Parse(content, source)
	}
	if source == nil {
		return Recipe{}, apperr.Invalid("give a link to the recipe or paste it")
	}
	body, page, err := s.fetcher.Document(ctx, owner.ID, source.String())
	if err != nil {
		return Recipe{}, err
	}
	return Extract(body, page)
}

func sourceURL(raw string) (*url.URL, error) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return nil, nil
	}
	parsed, err := url.Parse(raw)
	if err != nil || (parsed.Scheme != "http" && parsed.Scheme != "https") || parsed.Host == "" {
		return nil, apperr.Invalid("only http and https links can be imported")
	}
	return parsed, nil
}

func (s *Service) saveImages(ctx context.Context, owner users.User, recipe Recipe, folder, base string) (map[string]string, error) {
	saved := map[string]string{}
	for index, source := range imageSources(recipe) {
		if err := ctx.Err(); err != nil {
			return nil, err
		}
		asset, err := s.fetcher.ImageAt(ctx, owner.ID, source)
		if err != nil {
			continue
		}
		name := base
		if index > 0 {
			name = fmt.Sprintf("%s-%d", base, index)
		}
		entry, err := s.writeNew(ctx, owner, path.Join(folder, attachmentsFolder), name, imageExtensions[asset.ContentType], "-", asset.Body)
		if err != nil {
			continue
		}
		saved[source] = attachmentDestination(entry)
	}
	return saved, nil
}

func imageSources(recipe Recipe) []string {
	seen := map[string]bool{}
	var sources []string
	add := func(source string) {
		if source != "" && !seen[source] && len(sources) < maxImages {
			seen[source] = true
			sources = append(sources, source)
		}
	}
	add(recipe.Image)
	for _, group := range recipe.Steps {
		for _, step := range group.Steps {
			add(step.Image)
		}
	}
	return sources
}

func attachmentDestination(entry files.Entry) string {
	return fmt.Sprintf("%s/%s?fileId=%d", attachmentsFolder, url.PathEscape(path.Base(entry.Path)), entry.ID)
}

func (s *Service) writeNew(ctx context.Context, owner users.User, folder, base, extension, separator string, content []byte) (files.Entry, error) {
	for attempt := 1; attempt <= maxNameAttempts; attempt++ {
		name := base
		if attempt > 1 {
			name += separator + strconv.Itoa(attempt)
		}
		entry, err := s.files.Write(ctx, owner, files.WriteRequest{
			Path:    path.Join(folder, name+extension),
			BaseRev: files.BaseRevMustNotExist,
			Content: bytes.NewReader(content),
		})
		if apperr.Is(err, apperr.KindConflict) {
			continue
		}
		return entry, err
	}
	return files.Entry{}, apperr.AlreadyExists("%s already exists", path.Join(folder, base+extension))
}

func noteTitle(name string) string {
	cleaned := strings.Map(func(r rune) rune {
		if r == '/' || r == '\\' || unicode.IsControl(r) {
			return ' '
		}
		return r
	}, name)
	cleaned = strings.Trim(strings.Join(strings.Fields(cleaned), " "), ". ")
	if cleaned == "" {
		return "Recipe"
	}
	return strings.TrimSpace(string([]rune(cleaned)[:min(len([]rune(cleaned)), maxTitleLength)]))
}

func slug(title string) string {
	var builder strings.Builder
	dash := false
	for _, r := range strings.ToLower(title) {
		if unicode.IsLetter(r) || unicode.IsDigit(r) {
			builder.WriteRune(r)
			dash = false
		} else if !dash && builder.Len() > 0 {
			builder.WriteRune('-')
			dash = true
		}
	}
	runes := []rune(strings.TrimSuffix(builder.String(), "-"))
	if len(runes) == 0 {
		return "recipe"
	}
	return strings.TrimSuffix(string(runes[:min(len(runes), maxSlugLength)]), "-")
}
