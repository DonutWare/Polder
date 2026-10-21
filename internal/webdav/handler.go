package webdav

import (
	"net/http"
	"net/url"
	"regexp"
	"strconv"
	"strings"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/sharing"
	"polder-server/internal/storage"
)

const (
	MethodPropfind  = "PROPFIND"
	MethodProppatch = "PROPPATCH"
	MethodMkcol     = "MKCOL"
	MethodMove      = "MOVE"
	MethodCopy      = "COPY"
	MethodLock      = "LOCK"
	MethodUnlock    = "UNLOCK"

	contentPolicy = "sandbox; default-src 'none'"
)

var Methods = []string{MethodPropfind, MethodProppatch, MethodMkcol, MethodMove, MethodCopy, MethodLock, MethodUnlock}

var allowedMethods = strings.Join([]string{
	http.MethodOptions, http.MethodGet, http.MethodHead, http.MethodPut, http.MethodDelete,
	MethodPropfind, MethodProppatch, MethodMkcol, MethodMove, MethodCopy, MethodLock, MethodUnlock,
}, ", ")

type Quota struct {
	Used  int64
	Limit int64
}

type Space struct {
	Access    sharing.Access
	Root      string
	Principal string
	Quota     *Quota
}

type Handler struct {
	files *files.Service
	locks *LockManager
}

func NewHandler(fileService *files.Service) *Handler {
	return &Handler{files: fileService, locks: NewLockManager()}
}

type request struct {
	w        http.ResponseWriter
	r        *http.Request
	space    Space
	relative string
	absolute string
}

func (h *Handler) Serve(w http.ResponseWriter, r *http.Request, space Space) {
	w.Header().Set("DAV", "1, 2")
	w.Header().Set("MS-Author-Via", "DAV")
	relative, found := space.relativePath(r.URL.Path)
	if !found {
		WriteError(w, r, apperr.NotFound("no such resource"))
		return
	}
	absolute, err := space.Access.Path(relative)
	if err != nil {
		h.fail(w, r, space, err)
		return
	}
	req := &request{w: w, r: r, space: space, relative: relative, absolute: absolute}
	if err := h.dispatch(req); err != nil {
		h.fail(w, r, space, err)
	}
}

func (h *Handler) dispatch(req *request) error {
	switch req.r.Method {
	case http.MethodOptions:
		return h.options(req)
	case http.MethodGet, http.MethodHead:
		return h.get(req)
	case http.MethodPut:
		return h.put(req)
	case http.MethodDelete:
		return h.delete(req)
	case MethodPropfind:
		return h.propfind(req)
	case MethodProppatch:
		return h.proppatch(req)
	case MethodMkcol:
		return h.mkcol(req)
	case MethodMove:
		return h.moveOrCopy(req, false)
	case MethodCopy:
		return h.moveOrCopy(req, true)
	case MethodLock:
		return h.lock(req)
	case MethodUnlock:
		return h.unlock(req)
	}
	req.w.Header().Set("Allow", allowedMethods)
	return withStatus(http.StatusMethodNotAllowed, "method not allowed")
}

func (h *Handler) fail(w http.ResponseWriter, r *http.Request, space Space, err error) {
	space.Access.Scrub(&err)
	WriteError(w, r, err)
}

func (h *Handler) options(req *request) error {
	req.w.Header().Set("Allow", allowedMethods)
	req.w.Header().Set("Accept-Ranges", "bytes")
	req.w.Header().Set("Content-Length", "0")
	req.w.WriteHeader(http.StatusOK)
	return nil
}

func (s Space) relativePath(urlPath string) (string, bool) {
	if urlPath == s.Root {
		return storage.RootPath, true
	}
	rest, found := strings.CutPrefix(urlPath, s.Root+"/")
	if !found {
		return "", false
	}
	return "/" + strings.TrimSuffix(rest, "/"), true
}

func (s Space) href(relative string, isDir bool) string {
	var b strings.Builder
	b.WriteString(s.Root)
	for _, segment := range strings.Split(strings.Trim(relative, "/"), "/") {
		if segment == "" {
			continue
		}
		b.WriteByte('/')
		b.WriteString(url.PathEscape(segment))
	}
	if isDir || relative == storage.RootPath {
		b.WriteByte('/')
	}
	return b.String()
}

func (s Space) key(absolute string) lockKey {
	return lockKey{ownerID: s.Access.Owner.ID, path: absolute}
}

func (s Space) canWrite() bool {
	return s.Access.CanCreate || s.Access.CanEdit || s.Access.CanDelete
}

func (h *Handler) stat(req *request, absolute string) (files.Entry, bool, error) {
	entry, err := h.files.Stat(req.r.Context(), req.space.Access.Owner, absolute)
	if apperr.Is(err, apperr.KindNotFound) {
		return files.Entry{}, false, nil
	}
	return entry, err == nil, err
}

func (h *Handler) requireParent(req *request, absolute string) error {
	if absolute == req.space.Access.Root.Path {
		return nil
	}
	parent, exists, err := h.stat(req, storage.ParentPath(absolute))
	if err != nil {
		return err
	}
	if !exists || !parent.IsDir {
		return errParentMissing
	}
	return nil
}

func (h *Handler) checkLocks(req *request, absolute string, includeDescendants, changesMembership bool) error {
	tokens := submittedLockTokens(req.r.Header.Get("If"))
	if err := h.locks.Check(req.space.Principal, req.space.key(absolute), tokens, includeDescendants); err != nil {
		return err
	}
	if changesMembership && absolute != req.space.Access.Root.Path {
		return h.locks.Check(req.space.Principal, req.space.key(storage.ParentPath(absolute)), tokens, false)
	}
	return nil
}

var lockTokenPattern = regexp.MustCompile(`<((?:urn:uuid:|opaquelocktoken:)[^>]{1,128})>`)

func submittedLockTokens(ifHeader string) []string {
	if ifHeader == "" || len(ifHeader) > 8<<10 {
		return nil
	}
	var tokens []string
	for _, match := range lockTokenPattern.FindAllStringSubmatch(ifHeader, 64) {
		tokens = append(tokens, match[1])
	}
	return tokens
}

func fileETag(entry files.Entry) string {
	return `"` + strconv.FormatInt(entry.Rev, 10) + `"`
}

func parseETag(value string) (int64, bool) {
	value = strings.TrimSpace(value)
	value = strings.TrimPrefix(value, "W/")
	if len(value) < 2 || value[0] != '"' || value[len(value)-1] != '"' {
		return 0, false
	}
	rev, err := strconv.ParseInt(value[1:len(value)-1], 10, 64)
	if err != nil || rev <= 0 {
		return 0, false
	}
	return rev, true
}

func baseRevision(req *request, current files.Entry, exists bool) (int64, error) {
	ifMatch := strings.TrimSpace(req.r.Header.Get("If-Match"))
	ifNoneMatch := strings.TrimSpace(req.r.Header.Get("If-None-Match"))
	switch {
	case ifNoneMatch == "*":
		if exists {
			return 0, withStatus(http.StatusPreconditionFailed, "the resource already exists")
		}
		return files.BaseRevMustNotExist, nil
	case ifMatch == "":
		return files.BaseRevAny, nil
	case !exists:
		return 0, withStatus(http.StatusPreconditionFailed, "the resource does not exist")
	case ifMatch == "*":
		return current.Rev, nil
	}
	first, _, _ := strings.Cut(ifMatch, ",")
	rev, ok := parseETag(first)
	if !ok || rev != current.Rev {
		return 0, withStatus(http.StatusPreconditionFailed, "the resource has changed")
	}
	return rev, nil
}
