package office

import (
	"context"
	"encoding/xml"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"path"
	"regexp"
	"slices"
	"strings"
	"sync"
	"time"
)

const (
	discoveryLifetime   = time.Hour
	discoveryRetryAfter = 30 * time.Second
	discoveryTimeout    = 10 * time.Second
)

type action struct {
	editable bool
	// path is the editor page on the editor's server, which this server proxies under the same
	// path, after the service's prefix.
	path string
}

// apps is what the editor's discovery document says it can open, by MIME type and by extension, and
// the extensions it can start a new file in, by Collabora app such as writer or calc.
type apps struct {
	byMime      map[string]action
	byExtension map[string]action
	creatable   map[string][]string
}

func (a apps) find(mimeType, name string) (action, bool) {
	if found, ok := a.byMime[mimeType]; ok {
		return found, true
	}
	extension := strings.TrimPrefix(strings.ToLower(path.Ext(name)), ".")
	found, ok := a.byExtension[extension]
	return found, ok && extension != ""
}

type discovery struct {
	endpoint string
	client   *http.Client

	mu        sync.Mutex
	apps      apps
	err       error
	fetchedAt time.Time
}

func newDiscovery(editor *url.URL) *discovery {
	return &discovery{
		endpoint: editor.JoinPath("hosting", "discovery").String(),
		client:   &http.Client{Timeout: discoveryTimeout},
	}
}

// get returns the cached discovery, fetching it again once it is old, and soon after a failure
// since the editor usually starts after this server.
func (d *discovery) get(ctx context.Context) (apps, error) {
	d.mu.Lock()
	defer d.mu.Unlock()
	age := time.Since(d.fetchedAt)
	if (d.err == nil && age < discoveryLifetime && d.apps.byMime != nil) || (d.err != nil && age < discoveryRetryAfter) {
		return d.apps, d.err
	}
	fetched, err := d.fetch(ctx)
	d.fetchedAt = time.Now()
	if err != nil {
		d.err = err
		if d.apps.byMime != nil {
			logger.Warn("refresh editor discovery; keeping the previous one", "error", err)
			return d.apps, nil
		}
		return apps{}, err
	}
	d.apps, d.err = fetched, nil
	return fetched, nil
}

func (d *discovery) fetch(ctx context.Context) (apps, error) {
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, d.endpoint, nil)
	if err != nil {
		return apps{}, err
	}
	response, err := d.client.Do(request)
	if err != nil {
		return apps{}, fmt.Errorf("fetch editor discovery: %w", err)
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		return apps{}, fmt.Errorf("fetch editor discovery: status %d", response.StatusCode)
	}
	return parseDiscovery(response.Body)
}

type discoveryDocument struct {
	Zones []struct {
		Apps []struct {
			Name    string `xml:"name,attr"`
			Actions []struct {
				Name   string `xml:"name,attr"`
				Ext    string `xml:"ext,attr"`
				URLSrc string `xml:"urlsrc,attr"`
			} `xml:"action"`
		} `xml:"app"`
	} `xml:"net-zone"`
}

func parseDiscovery(body io.Reader) (apps, error) {
	var document discoveryDocument
	if err := xml.NewDecoder(body).Decode(&document); err != nil {
		return apps{}, fmt.Errorf("parse editor discovery: %w", err)
	}
	found := apps{byMime: map[string]action{}, byExtension: map[string]action{}, creatable: map[string][]string{}}
	for _, zone := range document.Zones {
		for _, app := range zone.Apps {
			for _, raw := range app.Actions {
				if raw.Name == "editnew" && raw.Ext != "" {
					name, extension := creatableApp(app.Name), strings.ToLower(raw.Ext)
					if !slices.Contains(found.creatable[name], extension) {
						found.creatable[name] = append(found.creatable[name], extension)
					}
					continue
				}
				if raw.Name != "edit" && raw.Name != "view" {
					continue
				}
				editorPath, err := editorPath(raw.URLSrc)
				if err != nil {
					return apps{}, err
				}
				current := action{editable: raw.Name == "edit", path: editorPath}
				if !isDocument(app.Name, raw.Ext, current.editable) {
					continue
				}
				if strings.Contains(app.Name, "/") {
					merge(found.byMime, app.Name, current)
				}
				if raw.Ext != "" {
					merge(found.byExtension, strings.ToLower(raw.Ext), current)
				}
			}
		}
	}
	return found, nil
}

// Euro-Office names its applications after Microsoft's; clients know them by Collabora's names.
var collaboraApps = map[string]string{"word": "writer", "excel": "calc", "powerpoint": "impress"}

func creatableApp(name string) string {
	name = strings.ToLower(name)
	if collabora, ok := collaboraApps[name]; ok {
		return collabora
	}
	return name
}

var mediaExtensions = map[string]bool{
	"bmp": true, "emf": true, "gif": true, "heic": true, "jpe": true, "jpeg": true, "jpg": true, "png": true,
	"svg": true, "svgz": true, "tif": true, "tiff": true, "webp": true, "wmf": true,
}

func isDocument(appName, extension string, editable bool) bool {
	mimeType := strings.ToLower(appName)
	extension = strings.ToLower(extension)
	for _, prefix := range []string{"image/", "audio/", "video/"} {
		if strings.HasPrefix(mimeType, prefix) {
			return false
		}
	}
	if mediaExtensions[extension] {
		return false
	}
	return editable || (mimeType != "application/pdf" && extension != "pdf")
}

func merge(into map[string]action, key string, next action) {
	if existing, ok := into[key]; ok && existing.editable {
		return
	}
	into[key] = next
}

var placeholders = regexp.MustCompile(`<[^>]*>`)

// editorPath keeps only the path of an urlsrc such as http://collabora:9980/browser/abc/cool.html?<ui=UI_LLCC&>
// or http://eurooffice/hosting/wopi/word/edit?<rs=DC_LLCC&>, since browsers reach the editor through this server.
func editorPath(urlsrc string) (string, error) {
	parsed, err := url.Parse(placeholders.ReplaceAllString(urlsrc, ""))
	if err != nil || parsed.Path == "" {
		return "", fmt.Errorf("parse editor discovery: bad urlsrc %q", urlsrc)
	}
	return parsed.EscapedPath(), nil
}

func sortedKeys(byKey map[string]action, editable bool) []string {
	keys := make([]string, 0, len(byKey))
	for key, found := range byKey {
		if found.editable == editable {
			keys = append(keys, key)
		}
	}
	slices.Sort(keys)
	return keys
}
