package office

import (
	"bytes"
	_ "embed"
	"net/http"
	"net/http/httputil"
	"strings"

	"github.com/go-chi/chi/v5"
)

const editorPagePath = "/office/editor"

// editorPage embeds the editor in a frame and relays its messages to the app. The access token
// arrives after the # so it never reaches a server or its logs.
//
//go:embed editor.html
var editorPage []byte

// collaboraPaths are where Collabora serves the pages and sockets browsers need.
var collaboraPaths = []string{"/browser/*", "/cool/*", "/hosting/*"}

// Routes mounts what the editor and the editor page need outside the API: the WOPI endpoints the
// editor calls, the editor's own pages proxied so clients only need this server's address, and
// the page that embeds the editor.
func (s *Service) Routes(router chi.Router) {
	if !s.Enabled() {
		return
	}
	router.Get("/wopi/files/{fileID}", s.checkFileInfo)
	router.Post("/wopi/files/{fileID}", s.fileOperation)
	router.Get("/wopi/files/{fileID}/contents", s.getFile)
	router.Post("/wopi/files/{fileID}/contents", s.putFile)

	proxy := s.proxy()
	if s.prefix != "" {
		router.Handle(s.prefix+"/*", proxy)
	} else {
		for _, prefix := range collaboraPaths {
			router.Handle(prefix, proxy)
		}
	}
	page := bytes.Replace(editorPage, []byte(`<html>`), []byte(`<html data-editor="`+string(s.kind)+`">`), 1)
	router.Get(editorPagePath, func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		w.Header().Set("Cache-Control", "no-cache")
		w.Header().Set("Referrer-Policy", "no-referrer")
		_, _ = w.Write(page)
	})
}

// proxy passes requests, websockets included, to the editor with the Host the client used, which
// the editor builds its own links from. Under a prefix, the editor learns it from
// X-Forwarded-Prefix and puts it in front of those links.
func (s *Service) proxy() http.Handler {
	return &httputil.ReverseProxy{
		Rewrite: func(r *httputil.ProxyRequest) {
			proto := r.In.Header.Get("X-Forwarded-Proto")
			if s.prefix != "" {
				r.Out.URL.Path = strings.TrimPrefix(r.Out.URL.Path, s.prefix)
				r.Out.URL.RawPath = strings.TrimPrefix(r.Out.URL.RawPath, s.prefix)
				r.Out.Header.Set("X-Forwarded-Prefix", s.prefix)
			}
			r.SetURL(s.editor)
			r.SetXForwarded()
			r.Out.Host = r.In.Host
			if proto != "" {
				r.Out.Header.Set("X-Forwarded-Proto", proto)
			}
		},
		ErrorHandler: func(w http.ResponseWriter, r *http.Request, err error) {
			logger.Warn("proxy to the document editor", "editor", s.kind.String(), "path", r.URL.Path, "error", err)
			w.WriteHeader(http.StatusBadGateway)
		},
	}
}
