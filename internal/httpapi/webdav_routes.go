package httpapi

import (
	"net"
	"net/http"
	"net/netip"
	"strconv"

	"github.com/go-chi/chi/v5"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/auth"
	"polder-server/internal/logging"
	"polder-server/internal/sharing"
	"polder-server/internal/users"
	"polder-server/internal/webdav"
)

const (
	davFilesPrefix  = "/dav/files"
	davDevicePrefix = "WebDAV · "
)

var davLog = logging.For("webdav")

func init() {
	for _, method := range webdav.Methods {
		chi.RegisterMethod(method)
	}
}

func (a *API) webDAVRoutes(router chi.Router) {
	router.Handle(davFilesPrefix+"/{username}", http.HandlerFunc(a.serveOwnFiles))
	router.Handle(davFilesPrefix+"/{username}/*", http.HandlerFunc(a.serveOwnFiles))
}

func (a *API) serveOwnFiles(w http.ResponseWriter, r *http.Request) {
	user, password, ok := a.davUser(w, r)
	if !ok {
		return
	}
	if chi.URLParam(r, "username") != user.Username {
		webdav.WriteError(w, r, apperr.NotFound("no such resource"))
		return
	}
	root := davFilesPrefix + "/" + user.Username
	rootEntry, err := a.files.Stat(r.Context(), user, "/")
	if err != nil {
		webdav.WriteError(w, r, err)
		return
	}
	writable := !password.ReadOnly
	space := webdav.Space{
		Access: sharing.Access{
			Owner: user, Root: rootEntry,
			CanRead: true, CanDownload: true, CanCreate: writable, CanEdit: writable, CanDelete: writable,
		},
		Root:      root,
		Principal: "user:" + strconv.FormatInt(user.ID, 10),
		Quota:     &webdav.Quota{Used: user.UsedBytes, Limit: user.QuotaBytes},
	}
	ctx := activity.WithActor(r.Context(), activity.Actor{Device: davDevicePrefix + password.Name})
	a.webdav.Serve(w, r.WithContext(ctx), space)
}

func (a *API) davUser(w http.ResponseWriter, r *http.Request) (users.User, auth.AppPassword, bool) {
	if !a.secureTransport(r) {
		webdav.WriteError(w, r, apperr.Forbidden("WebDAV needs HTTPS; behind a reverse proxy, add the proxy to trustedProxies"))
		return users.User{}, auth.AppPassword{}, false
	}
	username, token, ok := r.BasicAuth()
	if !ok {
		webdav.WriteError(w, r, apperr.Unauthorized("log in with your username and an app password"))
		return users.User{}, auth.AppPassword{}, false
	}
	address := clientAddress(r.RemoteAddr)
	keys := []string{"dav:" + address, "dav-user:" + username}
	if a.limiter.blocked(keys...) {
		davLog.Warn("WebDAV login refused: too many failed attempts", "user", username, "address", address)
		webdav.WriteError(w, r, apperr.New(apperr.KindRateLimited, "too many failed attempts, try again in a minute"))
		return users.User{}, auth.AppPassword{}, false
	}
	user, password, err := a.auth.AuthenticateAppPassword(r.Context(), username, token, address)
	if err != nil {
		if apperr.Is(err, apperr.KindUnauthorized) {
			a.limiter.fail(keys...)
			davLog.Warn("WebDAV login failed", "user", username, "address", address)
		}
		webdav.WriteError(w, r, err)
		return users.User{}, auth.AppPassword{}, false
	}
	noteUsername(r.Context(), user.Username)
	return user, password, true
}

func (a *API) secureTransport(r *http.Request) bool {
	if a.webdavAllowInsecure || r.TLS != nil {
		return true
	}
	if proto, proxied := forwardedProto(r); proxied {
		return proto == forwardedHTTPS
	}
	if proto := r.Header.Get("X-Forwarded-Proto"); proto != "" && proto != forwardedHTTPS {
		return false
	}
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return false
	}
	address, err := netip.ParseAddr(host)
	return err == nil && address.IsLoopback()
}
