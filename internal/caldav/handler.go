package caldav

import (
	"errors"
	"net/http"
	"net/url"
	"strconv"
	"strings"

	"polder-server/internal/apperr"
	"polder-server/internal/calendar"
	"polder-server/internal/dav"
	"polder-server/internal/users"
)

const (
	Root           = "/dav/"
	CalendarsPath  = "/dav/calendars/"
	PrincipalsPath = calendar.PrincipalsPath

	MethodPropfind   = "PROPFIND"
	MethodProppatch  = "PROPPATCH"
	MethodReport     = "REPORT"
	MethodMkcalendar = "MKCALENDAR"
	MethodMkcol      = "MKCOL"

	inboxSegment  = "inbox"
	outboxSegment = "outbox"

	davCapabilities = "1, 2, 3, calendar-access, calendar-auto-schedule, calendar-schedule, extended-mkcol"
	syncTokenPrefix = "http://polder.dev/ns/sync/"
)

var Methods = []string{MethodPropfind, MethodProppatch, MethodReport, MethodMkcalendar, MethodMkcol}

type Handler struct {
	calendars *calendar.Service
}

func NewHandler(calendars *calendar.Service) *Handler {
	return &Handler{calendars: calendars}
}

type request struct {
	w        http.ResponseWriter
	r        *http.Request
	user     users.User
	readOnly bool
}

func (req *request) home() string {
	return CalendarsPath + url.PathEscape(req.user.Username) + "/"
}

func (req *request) principal() string {
	return calendar.PrincipalHref(req.user.Username)
}

func (req *request) calendarHref(c calendar.Calendar) string {
	return req.home() + url.PathEscape(calendar.HomeSegment(c)) + "/"
}

func (req *request) requireWrite() error {
	if req.readOnly {
		return apperr.Forbidden("this app password is read-only")
	}
	return nil
}

func (h *Handler) Serve(w http.ResponseWriter, r *http.Request, user users.User, readOnly bool) {
	w.Header().Set("DAV", davCapabilities)
	req := &request{w: w, r: r, user: user, readOnly: readOnly}
	if err := h.route(req); err != nil {
		writeError(w, r, err)
	}
}

func (h *Handler) route(req *request) error {
	path := req.r.URL.Path + "/"
	switch {
	case path == "/dav/" || path == Root+"/":
		return h.serveRoot(req)
	case strings.HasPrefix(path, PrincipalsPath):
		return h.servePrincipals(req, strings.Trim(strings.TrimPrefix(path, PrincipalsPath), "/"))
	case strings.HasPrefix(path, CalendarsPath):
		return h.serveCalendars(req, strings.Trim(strings.TrimPrefix(path, CalendarsPath), "/"))
	}
	return apperr.NotFound("no such resource")
}

func (h *Handler) serveCalendars(req *request, rest string) error {
	segments := strings.Split(rest, "/")
	if rest == "" {
		return h.serveCollectionRoot(req)
	}
	if segments[0] != req.user.Username {
		return apperr.NotFound("no such calendar home")
	}
	switch len(segments) {
	case 1:
		return h.serveHome(req)
	case 2:
		return h.serveHomeChild(req, segments[1])
	case 3:
		return h.serveMember(req, segments[1], segments[2])
	}
	return apperr.NotFound("no such resource")
}

func (h *Handler) serveHomeChild(req *request, segment string) error {
	switch segment {
	case inboxSegment:
		return h.serveInbox(req)
	case outboxSegment:
		return h.serveOutbox(req)
	}
	return h.serveCalendar(req, segment)
}

func (h *Handler) serveMember(req *request, segment, name string) error {
	switch segment {
	case inboxSegment:
		return h.serveInboxItem(req, name)
	case outboxSegment:
		return apperr.NotFound("the outbox holds nothing")
	}
	return h.serveObject(req, segment, name)
}

func options(req *request, allow string) error {
	req.w.Header().Set("Allow", allow)
	req.w.Header().Set("Content-Length", "0")
	req.w.WriteHeader(http.StatusOK)
	return nil
}

func methodNotAllowed(req *request, allow string) error {
	req.w.Header().Set("Allow", allow)
	return dav.WithStatus(http.StatusMethodNotAllowed, "method not allowed")
}

func depth(r *http.Request) int {
	switch r.Header.Get("Depth") {
	case "0":
		return 0
	}
	return 1
}

func writeError(w http.ResponseWriter, r *http.Request, err error) {
	var violation *calendar.Violation
	if errors.As(err, &violation) {
		status := http.StatusForbidden
		if violation.Condition == calendar.ConditionNoUIDConflict {
			status = http.StatusConflict
		}
		dav.WriteError(w, r, dav.WithCondition(status, dav.Name{Space: dav.NamespaceCalDAV, Local: string(violation.Condition)}, violation.Err.Message))
		return
	}
	if errors.Is(err, calendar.ErrSyncTokenExpired) {
		dav.WriteError(w, r, dav.WithCondition(http.StatusForbidden, dav.DAV("valid-sync-token"), calendar.ErrSyncTokenExpired.Message))
		return
	}
	dav.WriteError(w, r, err)
}

func syncToken(revision int64) string {
	return syncTokenPrefix + strconv.FormatInt(revision, 10)
}

func parseSyncToken(token string) (int64, bool) {
	token = strings.TrimSpace(token)
	if token == "" {
		return 0, true
	}
	revision, err := strconv.ParseInt(strings.TrimPrefix(token, syncTokenPrefix), 10, 64)
	return revision, err == nil && strings.HasPrefix(token, syncTokenPrefix) && revision >= 0
}

func ctag(c calendar.Calendar) string {
	return `"` + strconv.FormatInt(c.SyncRevision, 10) + `"`
}
