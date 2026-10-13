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

// Editor names the document editor this server works with. Both speak WOPI, so they share the
// endpoints, tokens, locks and conversions; they differ in where browsers reach them.
type Editor string

const (
	Collabora  Editor = "collabora"
	EuroOffice Editor = "eurooffice"
)

func (e Editor) String() string {
	if e == EuroOffice {
		return "Euro-Office"
	}
	return "Collabora"
}

// euroOfficePrefix is where browsers reach Euro-Office on this server. Its pages and assets sit
// at the root of its own server, under versioned paths, so it is proxied under a prefix of its own
// rather than path by path as Collabora is.
const euroOfficePrefix = "/eurooffice"

type Options struct {
	// CollaboraURL and EuroOfficeURL are both empty when there is no document editor, and at most
	// one is set.
	CollaboraURL  string
	EuroOfficeURL string
	WOPIBaseURL   string
}

type Service struct {
	kind   Editor
	editor *url.URL
	// prefix is the path browsers reach the editor's own pages under, empty when they sit at the
	// same paths as on the editor's server.
	prefix    string
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
	editorURL := options.CollaboraURL
	switch {
	case options.CollaboraURL != "" && options.EuroOfficeURL != "":
		return nil, fmt.Errorf("both Collabora and Euro-Office are set up; choose one document editor")
	case options.CollaboraURL != "":
		service.kind = Collabora
	case options.EuroOfficeURL != "":
		service.kind, service.prefix, editorURL = EuroOffice, euroOfficePrefix, options.EuroOfficeURL
	default:
		return service, nil
	}
	editor, err := url.Parse(editorURL)
	if err != nil {
		return nil, fmt.Errorf("%s URL: %w", service.kind, err)
	}
	service.editor = editor
	service.discovery = newDiscovery(editor)
	service.converter = &http.Client{Timeout: convertTimeout}
	return service, nil
}

func (s *Service) Enabled() bool {
	return s != nil && s.editor != nil
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
	App        string   `json:"app" doc:"The application, such as writer, calc or impress, named as Collabora names it whichever editor is used"`
	Extensions []string `json:"extensions" doc:"Lower case, without the dot, in the editor's order"`
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
		EditorURL:      s.prefix + editor.path + "?" + query.Encode(),
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
