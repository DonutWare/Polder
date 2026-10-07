package office

import (
	_ "embed"
	"net/http"
	"net/http/httputil"

	"github.com/go-chi/chi/v5"
)

const editorPagePath = "/office/editor"

// editorPage embeds Collabora in a frame and relays its messages to the app. The access token
// arrives after the # so it never reaches a server or its logs.
//
//go:embed editor.html
var editorPage []byte

// Routes mounts what Collabora and the editor page need outside the API: the WOPI endpoints
// Collabora calls, Collabora's own pages proxied so clients only need this server's address,
// and the page that embeds the editor.
func (s *Service) Routes(router chi.Router) {
	if !s.Enabled() {
		return
	}
	router.Get("/wopi/files/{fileID}", s.checkFileInfo)
	router.Post("/wopi/files/{fileID}", s.fileOperation)
	router.Get("/wopi/files/{fileID}/contents", s.getFile)
	router.Post("/wopi/files/{fileID}/contents", s.putFile)

	proxy := s.proxy()
	for _, prefix := range []string{"/browser/*", "/cool/*", "/hosting/*"} {
		router.Handle(prefix, proxy)
	}
	router.Get(editorPagePath, func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		w.Header().Set("Cache-Control", "no-cache")
		w.Header().Set("Referrer-Policy", "no-referrer")
		_, _ = w.Write(editorPage)
	})
}

// proxy passes requests, websockets included, to Collabora with the Host the client used, which
// Collabora builds its own links from.
func (s *Service) proxy() http.Handler {
	return &httputil.ReverseProxy{
		Rewrite: func(r *httputil.ProxyRequest) {
			proto := r.In.Header.Get("X-Forwarded-Proto")
			r.SetURL(s.collabora)
			r.SetXForwarded()
			r.Out.Host = r.In.Host
			if proto != "" {
				r.Out.Header.Set("X-Forwarded-Proto", proto)
			}
		},
		ErrorHandler: func(w http.ResponseWriter, r *http.Request, err error) {
			logger.Warn("proxy to Collabora", "path", r.URL.Path, "error", err)
			w.WriteHeader(http.StatusBadGateway)
		},
	}
}
