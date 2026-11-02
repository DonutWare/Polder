package httpapi

import (
	"html/template"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"

	"polder-server/internal/apperr"
	"polder-server/internal/caldav"
	"polder-server/internal/calendar"
	"polder-server/internal/dav"
)

const feedCacheSeconds = 300

func init() {
	for _, method := range caldav.Methods {
		chi.RegisterMethod(method)
	}
}

func (a *API) calDAVRoutes(router chi.Router) {
	if a.caldav == nil {
		return
	}
	router.Handle("/.well-known/caldav", http.HandlerFunc(a.wellKnownCalDAV))
	for _, pattern := range []string{"/dav", "/dav/", "/dav/principals", "/dav/principals/*", "/dav/calendars", "/dav/calendars/*"} {
		router.Handle(pattern, http.HandlerFunc(a.serveCalDAV))
	}
	router.Get(calendar.FeedPathPrefix+"{token}", a.serveCalendarFeed)
	router.Head(calendar.FeedPathPrefix+"{token}", a.serveCalendarFeed)
	router.Get("/calendar/rsvp/{token}", a.showInvitation)
	router.Post("/calendar/rsvp/{token}", a.answerInvitation)
}

func (a *API) wellKnownCalDAV(w http.ResponseWriter, r *http.Request) {
	if r.Method == caldav.MethodPropfind {
		r.URL.Path = caldav.Root
		a.serveCalDAV(w, r)
		return
	}
	http.Redirect(w, r, caldav.Root, http.StatusMovedPermanently)
}

func (a *API) serveCalDAV(w http.ResponseWriter, r *http.Request) {
	user, password, ok := a.davUser(w, r)
	if !ok {
		return
	}
	a.caldav.Serve(w, r, user, password.ReadOnly)
}

func (a *API) serveCalendarFeed(w http.ResponseWriter, r *http.Request) {
	address := clientAddress(r.RemoteAddr)
	keys := []string{"feed:" + address}
	if a.linkLimiter.blocked(keys...) {
		dav.WriteError(w, r, apperr.New(apperr.KindRateLimited, "too many failed attempts, try again in a minute"))
		return
	}
	feed, err := a.calendar.RenderFeed(r.Context(), chi.URLParam(r, "token"))
	if err != nil {
		if apperr.Is(err, apperr.KindNotFound) {
			a.linkLimiter.fail(keys...)
		}
		dav.WriteError(w, r, err)
		return
	}
	header := w.Header()
	header.Set("Content-Type", "text/calendar; charset=utf-8")
	header.Set("ETag", feed.ETag)
	header.Set("Last-Modified", feed.LastModified.UTC().Format(http.TimeFormat))
	header.Set("Cache-Control", "private, max-age="+strconv.Itoa(feedCacheSeconds))
	header.Set("X-Content-Type-Options", "nosniff")
	if r.Header.Get("If-None-Match") == feed.ETag {
		w.WriteHeader(http.StatusNotModified)
		return
	}
	header.Set("Content-Length", strconv.Itoa(len(feed.Data)))
	w.WriteHeader(http.StatusOK)
	if r.Method != http.MethodHead {
		_, _ = w.Write(feed.Data)
	}
}

var invitationPage = template.Must(template.New("invitation").Parse(`<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>{{.Invitation.Summary}}</title>
<style>body{font-family:system-ui,sans-serif;max-width:32rem;margin:3rem auto;padding:0 1rem;color:#1c2024}
h1{font-size:1.4rem}dl{display:grid;grid-template-columns:auto 1fr;gap:.4rem 1rem}dt{color:#60646c}
form{display:flex;gap:.5rem;flex-wrap:wrap;margin-top:1.5rem}button{font:inherit;padding:.5rem 1rem;border-radius:.4rem;border:1px solid #cdced6;background:#fff;cursor:pointer}
button[value=ACCEPTED]{background:#3e63dd;color:#fff;border-color:#3e63dd}.note{margin-top:1.5rem;color:#60646c}</style></head>
<body><h1>{{.Invitation.Summary}}</h1>
{{if .Invitation.Cancelled}}<p><strong>This event was cancelled.</strong></p>{{end}}
<dl><dt>When</dt><dd>{{.When}}</dd>
{{if .Invitation.Location}}<dt>Where</dt><dd>{{.Invitation.Location}}</dd>{{end}}
<dt>Organizer</dt><dd>{{.Invitation.Organizer}}</dd>
<dt>Invited</dt><dd>{{.Invitation.Attendee}}</dd>
<dt>Your answer</dt><dd>{{.Status}}</dd></dl>
{{if .Saved}}<p class="note">Thanks, your answer was sent to the organizer.</p>{{end}}
{{if not .Invitation.Cancelled}}<form method="post">
<button name="answer" value="ACCEPTED">Accept</button>
<button name="answer" value="TENTATIVE">Maybe</button>
<button name="answer" value="DECLINED">Decline</button></form>{{end}}
</body></html>`))

var answerLabels = map[string]string{
	calendar.PartstatNeedsAction: "Not answered yet",
	calendar.PartstatAccepted:    "Going",
	calendar.PartstatTentative:   "Maybe",
	calendar.PartstatDeclined:    "Not going",
}

type invitationView struct {
	Invitation calendar.Invitation
	When       string
	Status     string
	Saved      bool
}

func (a *API) showInvitation(w http.ResponseWriter, r *http.Request) {
	invitation, err := a.calendar.Invitation(r.Context(), chi.URLParam(r, "token"))
	a.renderInvitation(w, r, invitation, err, false)
}

func (a *API) answerInvitation(w http.ResponseWriter, r *http.Request) {
	r.Body = http.MaxBytesReader(w, r.Body, 4<<10)
	if err := r.ParseForm(); err != nil {
		dav.WriteError(w, r, apperr.Invalid("the answer cannot be read"))
		return
	}
	invitation, err := a.calendar.RespondToInvitation(r.Context(), chi.URLParam(r, "token"), r.PostForm.Get("answer"))
	a.renderInvitation(w, r, invitation, err, true)
}

func (a *API) renderInvitation(w http.ResponseWriter, r *http.Request, invitation calendar.Invitation, err error, saved bool) {
	if err != nil {
		dav.WriteError(w, r, err)
		return
	}
	view := invitationView{Invitation: invitation, When: describeWhen(invitation), Status: answerLabels[invitation.Status], Saved: saved}
	if view.Status == "" {
		view.Status = strings.ToLower(invitation.Status)
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Header().Set("Content-Security-Policy", "default-src 'none'; style-src 'unsafe-inline'; form-action 'self'")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.Header().Set("Referrer-Policy", "no-referrer")
	if err := invitationPage.Execute(w, view); err != nil {
		logger.Warn("render an invitation page", "error", err)
	}
}

func describeWhen(invitation calendar.Invitation) string {
	if invitation.AllDay {
		return invitation.Start.Format("Monday 2 January 2006") + " (all day)"
	}
	return invitation.Start.UTC().Format("Monday 2 January 2006 15:04") + " – " + invitation.End.UTC().Format("15:04") + " UTC"
}
