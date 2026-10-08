package office

import (
	"context"
	"fmt"
	"maps"
	"net/http"
	"net/url"
	"slices"
	"strings"
	"time"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/auth"
	"polder-server/internal/files"
	"polder-server/internal/logging"
	"polder-server/internal/users"
)

var logger = logging.For("office")

type Options struct {
	// CollaboraURL is empty when there is no document editor.
	CollaboraURL string
	WOPIBaseURL  string
}

type Service struct {
	collabora *url.URL
	wopiBase  string
	discovery *discovery
	converter *http.Client
	tokens    *tokens
	locks     *locks
	files     *files.Service
	auth      *auth.Service
}

func New(options Options, fileService *files.Service, authService *auth.Service, signing *auth.AccessTokens) (*Service, error) {
	service := &Service{
		wopiBase: strings.TrimSuffix(options.WOPIBaseURL, "/"),
		tokens:   &tokens{key: signing.DerivedKey(tokenIssuer), now: time.Now},
		locks:    newLocks(time.Now),
		files:    fileService,
		auth:     authService,
	}
	if options.CollaboraURL == "" {
		return service, nil
	}
	collabora, err := url.Parse(options.CollaboraURL)
	if err != nil {
		return nil, fmt.Errorf("collabora URL: %w", err)
	}
	service.collabora = collabora
	service.discovery = newDiscovery(collabora)
	service.converter = &http.Client{Timeout: convertTimeout}
	return service, nil
}

func (s *Service) Enabled() bool {
	return s != nil && s.collabora != nil
}

type EditorCapabilities struct {
	Enabled            bool           `json:"enabled" doc:"Whether a document editor is set up and reachable"`
	EditableMimes      []string       `json:"editableMimes"`
	EditableExtensions []string       `json:"editableExtensions" doc:"Lower case, without the dot"`
	ViewableMimes      []string       `json:"viewableMimes" doc:"Types the editor can only show, not change"`
	ViewableExtensions []string       `json:"viewableExtensions"`
	Creatable          []CreatableApp `json:"creatable" doc:"What the editor can start new files in; an empty file with one of these extensions opens as a new document"`
}

type CreatableApp struct {
	App        string   `json:"app" doc:"Collabora's name for the application, such as writer, calc or impress"`
	Extensions []string `json:"extensions" doc:"Lower case, without the dot, in Collabora's order"`
}

func (s *Service) Capabilities(ctx context.Context) EditorCapabilities {
	none := EditorCapabilities{
		EditableMimes: []string{}, EditableExtensions: []string{}, ViewableMimes: []string{}, ViewableExtensions: []string{},
		Creatable: []CreatableApp{},
	}
	if !s.Enabled() {
		return none
	}
	found, err := s.discovery.get(ctx)
	if err != nil {
		logger.Warn("document editor unavailable", "error", err)
		return none
	}
	return EditorCapabilities{
		Enabled:            true,
		EditableMimes:      sortedKeys(found.byMime, true),
		EditableExtensions: sortedKeys(found.byExtension, true),
		ViewableMimes:      sortedKeys(found.byMime, false),
		ViewableExtensions: sortedKeys(found.byExtension, false),
		Creatable:          creatableApps(found.creatable),
	}
}

func creatableApps(byApp map[string][]string) []CreatableApp {
	created := make([]CreatableApp, 0, len(byApp))
	for _, app := range slices.Sorted(maps.Keys(byApp)) {
		created = append(created, CreatableApp{App: app, Extensions: byApp[app]})
	}
	return created
}

type EditorSession struct {
	EditorURL      string `json:"editorUrl" doc:"Path and query on this server to post the access token to, in a form with access_token and access_token_ttl"`
	HostPage       string `json:"hostPage" doc:"Path on this server of a page that embeds the editor; pass the form fields after # as a query string, plus src=editorUrl"`
	AccessToken    string `json:"accessToken"`
	AccessTokenTTL int64  `json:"accessTokenTtl" doc:"When the access token expires, in milliseconds since the Unix epoch"`
	ReadOnly       bool   `json:"readOnly"`
}

// StartSession grants the editor access to one file. Origin is the origin of the page that embeds
// the editor: the address the client uses for this server.
func (s *Service) StartSession(ctx context.Context, owner users.User, rawPath, origin string, versionID int64) (EditorSession, error) {
	if !s.Enabled() {
		return EditorSession{}, apperr.NotFound("no document editor is set up on this server")
	}
	cleanOrigin, err := parseOrigin(origin)
	if err != nil {
		return EditorSession{}, err
	}
	entry, err := s.files.Stat(ctx, owner, rawPath)
	if err != nil {
		return EditorSession{}, err
	}
	if entry.IsDir {
		return EditorSession{}, apperr.Invalid("%s is a directory", entry.Path)
	}
	found, err := s.discovery.get(ctx)
	if err != nil {
		logger.Warn("document editor unavailable", "error", err)
		return EditorSession{}, apperr.Unavailable("the document editor cannot be reached")
	}
	editor, ok := found.find(entry.Mime, entry.Name)
	if !ok {
		return EditorSession{}, apperr.Invalid("the document editor cannot open %s", entry.Name)
	}
	if versionID != 0 {
		if _, versionEntry, err := s.files.FindVersion(ctx, owner, versionID); err != nil {
			return EditorSession{}, err
		} else if versionEntry.ID != entry.ID {
			return EditorSession{}, apperr.NotFound("no such version of %s", entry.Path)
		}
	}
	var generation int64
	if versionID == 0 {
		if generation, err = s.files.RestoreCount(ctx, entry.ID); err != nil {
			return EditorSession{}, err
		}
	}
	actor := activity.ActorFrom(ctx)
	token, issued, err := s.tokens.issue(grant{
		UserID:     owner.ID,
		FileID:     entry.ID,
		VersionID:  versionID,
		Generation: generation,
		SessionID:  actor.SessionID,
		Device:     actor.Device,
		ReadOnly:   !editor.editable || versionID != 0,
		Origin:     cleanOrigin,
	})
	if err != nil {
		return EditorSession{}, err
	}
	query := url.Values{"WOPISrc": {fmt.Sprintf("%s/wopi/files/%s", s.wopiBase, wopiFileID(entry.ID, generation, versionID))}}
	return EditorSession{
		EditorURL:      editor.path + "?" + query.Encode(),
		HostPage:       editorPagePath,
		AccessToken:    token,
		AccessTokenTTL: issued.ExpiresAt.UnixMilli(),
		ReadOnly:       issued.ReadOnly,
	}, nil
}

func parseOrigin(origin string) (string, error) {
	parsed, err := url.Parse(origin)
	if err != nil || (parsed.Scheme != "http" && parsed.Scheme != "https") || parsed.Host == "" {
		return "", apperr.Invalid("origin must be an http(s) origin such as https://polder.example.com")
	}
	return parsed.Scheme + "://" + parsed.Host, nil
}
