// Package webui serves the Flutter web client, so a browser pointed at the server gets the app.
//
// A built client copied into dist/ is embedded in the binary. Without one, the server serves only the API.
package webui

import (
	"crypto/sha256"
	"embed"
	"encoding/hex"
	"errors"
	"io"
	"io/fs"
	"net/http"
	"path"
	"strings"
)

const indexFile = "index.html"

//go:embed all:dist
var embedded embed.FS

// Embedded returns the web client compiled into this binary, or false when it was built without one.
func Embedded() (fs.FS, bool) {
	dist, err := fs.Sub(embedded, "dist")
	if err != nil {
		return nil, false
	}
	return dist, HasClient(dist)
}

// HasClient reports whether fsys holds a built web client.
func HasClient(fsys fs.FS) bool {
	info, err := fs.Stat(fsys, indexFile)
	return err == nil && !info.IsDir()
}

// Handler serves files from fsys. Paths without a file extension that don't exist get index.html,
// so client-side routes like /files or /admin/users survive a reload or a shared link.
//
// Flutter's output names aren't content-hashed, so every response is revalidated: by modification
// time for files on disk, by a content hash for the embedded client (which has no times).
func Handler(fsys fs.FS) (http.Handler, error) {
	if !HasClient(fsys) {
		return nil, errors.New("web client has no index.html")
	}
	etags, err := hashUndatedFiles(fsys)
	if err != nil {
		return nil, err
	}
	return &handler{fsys: fsys, etags: etags}, nil
}

type handler struct {
	fsys  fs.FS
	etags map[string]string
}

func (h *handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet && r.Method != http.MethodHead {
		w.Header().Set("Allow", "GET, HEAD")
		http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
		return
	}
	name := strings.TrimPrefix(path.Clean("/"+r.URL.Path), "/")
	if name == "" {
		name = indexFile
	}
	if info, err := fs.Stat(h.fsys, name); err != nil || info.IsDir() {
		if path.Ext(name) != "" {
			http.NotFound(w, r)
			return
		}
		name = indexFile
	}
	h.serveFile(w, r, name)
}

func (h *handler) serveFile(w http.ResponseWriter, r *http.Request, name string) {
	file, err := h.fsys.Open(name)
	if err != nil {
		http.NotFound(w, r)
		return
	}
	defer file.Close()
	info, err := file.Stat()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	content, ok := file.(io.ReadSeeker)
	if !ok {
		http.Error(w, "web client file is not seekable", http.StatusInternalServerError)
		return
	}
	header := w.Header()
	if etag, ok := h.etags[name]; ok && info.ModTime().IsZero() {
		header.Set("ETag", etag)
	}
	header.Set("Cache-Control", "no-cache")
	header.Set("X-Content-Type-Options", "nosniff")
	if name == indexFile {
		header.Set("X-Frame-Options", "DENY")
		header.Set("Referrer-Policy", "same-origin")
	}
	http.ServeContent(w, r, name, info.ModTime(), content)
}

func hashUndatedFiles(fsys fs.FS) (map[string]string, error) {
	etags := map[string]string{}
	err := fs.WalkDir(fsys, ".", func(name string, entry fs.DirEntry, err error) error {
		if err != nil || entry.IsDir() {
			return err
		}
		info, err := entry.Info()
		if err != nil || !info.ModTime().IsZero() {
			return err
		}
		content, err := fs.ReadFile(fsys, name)
		if err != nil {
			return err
		}
		sum := sha256.Sum256(content)
		etags[name] = `"` + hex.EncodeToString(sum[:12]) + `"`
		return nil
	})
	return etags, err
}
