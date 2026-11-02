package caldav

import (
	"bytes"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"

	"github.com/emersion/go-ical"

	"polder-server/internal/calendar"
	"polder-server/internal/dav"
)

const (
	inboxAllow       = "OPTIONS, PROPFIND, REPORT"
	inboxItemAllow   = "OPTIONS, GET, HEAD, DELETE, PROPFIND"
	outboxAllow      = "OPTIONS, PROPFIND, POST"
	maxOutboxBytes   = 256 << 10
	maxFreeBusyPeers = 50
)

func (h *Handler) inboxResource(req *request, defaultCalendar calendar.Calendar) *resource {
	inbox := newResource(req.home() + inboxSegment + "/")
	inbox.resourceType("d:collection", "cal:schedule-inbox")
	inbox.element(dav.DAV("displayname"), true, "Inbox")
	inbox.hrefProp(calDAV("schedule-default-calendar-URL"), false, req.calendarHref(defaultCalendar))
	inbox.hrefProp(dav.DAV("owner"), false, req.principal())
	inbox.set(dav.DAV("current-user-privilege-set"), false, func(w *dav.Writer) { privileges(w, true, !req.readOnly) })
	inbox.set(dav.DAV("supported-report-set"), false, func(w *dav.Writer) { supportedReports(w, "cal:calendar-multiget") })
	return inbox
}

func (h *Handler) outboxResource(req *request) *resource {
	outbox := newResource(req.home() + outboxSegment + "/")
	outbox.resourceType("d:collection", "cal:schedule-outbox")
	outbox.element(dav.DAV("displayname"), true, "Outbox")
	outbox.hrefProp(dav.DAV("owner"), false, req.principal())
	outbox.set(dav.DAV("current-user-privilege-set"), false, func(w *dav.Writer) { privileges(w, true, !req.readOnly) })
	return outbox
}

func (h *Handler) inboxItemResource(req *request, item calendar.InboxItem, withData bool) *resource {
	res := newResource(req.home() + inboxSegment + "/" + url.PathEscape(item.URI))
	res.resourceType()
	res.element(dav.DAV("getetag"), true, item.ETag)
	res.element(dav.DAV("getcontenttype"), true, calendarContentType+"; method="+item.Method)
	res.element(dav.DAV("getcontentlength"), true, strconv.Itoa(len(item.Data)))
	res.element(dav.DAV("getlastmodified"), true, item.CreatedAt.Format(http.TimeFormat))
	if withData {
		res.set(calDAV("calendar-data"), false, func(w *dav.Writer) { w.Element("cal:calendar-data", string(item.Data)) })
	}
	return res
}

func (h *Handler) serveInbox(req *request) error {
	ctx := req.r.Context()
	switch req.r.Method {
	case http.MethodOptions:
		return options(req, inboxAllow)
	case MethodPropfind:
		query, err := parsePropfind(req.r)
		if err != nil {
			return err
		}
		defaultCalendar, err := h.calendars.DefaultCalendar(ctx, req.user)
		if err != nil {
			return err
		}
		resources := []*resource{h.inboxResource(req, defaultCalendar)}
		if depth(req.r) > 0 {
			items, err := h.calendars.Inbox(ctx, req.user)
			if err != nil {
				return err
			}
			for _, item := range items {
				resources = append(resources, h.inboxItemResource(req, item, query.data != nil))
			}
		}
		writeMultistatus(req.w, resources, query, nil)
		return nil
	case MethodReport:
		return h.inboxMultiget(req)
	}
	return methodNotAllowed(req, inboxAllow)
}

func (h *Handler) inboxMultiget(req *request) error {
	root, err := dav.ReadBody(req.r)
	if err != nil {
		return err
	}
	if root == nil || root.Name != calDAV("calendar-multiget") {
		return dav.WithCondition(http.StatusForbidden, dav.DAV("supported-report"), "the inbox only supports calendar-multiget")
	}
	query, err := propsFrom(root.Child(dav.NamespaceDAV, "prop"))
	if err != nil {
		return err
	}
	collection := req.home() + inboxSegment + "/"
	var resources []*resource
	var missing []string
	for _, element := range root.ChildrenNamed(dav.NamespaceDAV, "href") {
		href := strings.TrimSpace(element.Text)
		uri, inside := memberURI(collection, href)
		item, err := h.calendars.InboxItem(req.r.Context(), req.user, uri)
		if !inside || err != nil {
			missing = append(missing, href)
			continue
		}
		resources = append(resources, h.inboxItemResource(req, item, true))
	}
	writeMultistatus(req.w, resources, query, func(w *dav.Writer) {
		for _, href := range missing {
			writeStatusResponse(w, href, http.StatusNotFound)
		}
	})
	return nil
}

func (h *Handler) serveInboxItem(req *request, uri string) error {
	ctx := req.r.Context()
	switch req.r.Method {
	case http.MethodOptions:
		return options(req, inboxItemAllow)
	case http.MethodGet, http.MethodHead:
		item, err := h.calendars.InboxItem(ctx, req.user, uri)
		if err != nil {
			return err
		}
		req.w.Header().Set("Content-Type", calendarContentType)
		req.w.Header().Set("ETag", item.ETag)
		req.w.Header().Set("Content-Length", strconv.Itoa(len(item.Data)))
		req.w.WriteHeader(http.StatusOK)
		if req.r.Method == http.MethodGet {
			_, _ = req.w.Write(item.Data)
		}
		return nil
	case http.MethodDelete:
		if err := req.requireWrite(); err != nil {
			return err
		}
		if err := h.calendars.DeleteInboxItem(ctx, req.user, uri); err != nil {
			return err
		}
		req.w.WriteHeader(http.StatusNoContent)
		return nil
	case MethodPropfind:
		query, err := parsePropfind(req.r)
		if err != nil {
			return err
		}
		item, err := h.calendars.InboxItem(ctx, req.user, uri)
		if err != nil {
			return err
		}
		writeMultistatus(req.w, []*resource{h.inboxItemResource(req, item, true)}, query, nil)
		return nil
	}
	return methodNotAllowed(req, inboxItemAllow)
}

func (h *Handler) serveOutbox(req *request) error {
	switch req.r.Method {
	case http.MethodOptions:
		return options(req, outboxAllow)
	case MethodPropfind:
		query, err := parsePropfind(req.r)
		if err != nil {
			return err
		}
		writeMultistatus(req.w, []*resource{h.outboxResource(req)}, query, nil)
		return nil
	case http.MethodPost:
		return h.outboxPost(req)
	}
	return methodNotAllowed(req, outboxAllow)
}

type freeBusyRequest struct {
	window    calendar.TimeRange
	organizer string
	attendees []string
	uid       string
}

func (h *Handler) outboxPost(req *request) error {
	data, err := io.ReadAll(io.LimitReader(req.r.Body, maxOutboxBytes+1))
	if err != nil {
		return err
	}
	if len(data) > maxOutboxBytes {
		return dav.ErrBodyTooLarge
	}
	request, err := parseFreeBusyRequest(data)
	if err != nil {
		return err
	}
	body := dav.NewWriter()
	body.Start("cal:schedule-response", multistatusNamespaces...)
	for _, attendee := range request.attendees {
		h.writeFreeBusyResponse(req, body, request, attendee)
	}
	body.End("cal:schedule-response")
	body.WriteTo(req.w, http.StatusOK)
	return nil
}

func (h *Handler) writeFreeBusyResponse(req *request, body *dav.Writer, request freeBusyRequest, attendee string) {
	body.Start("cal:response")
	body.Start("cal:recipient")
	body.Element("d:href", attendee)
	body.End("cal:recipient")
	periods, found, err := h.calendars.AddressBusy(req.r.Context(), attendee, request.window)
	if err != nil || !found {
		body.Element("cal:request-status", "3.7;Invalid calendar user")
		body.End("cal:response")
		return
	}
	data, err := calendar.FreeBusyCalendar("REPLY", request.window, periods, request.organizer, attendee, request.uid)
	if err != nil {
		body.Element("cal:request-status", "5.1;Service unavailable")
		body.End("cal:response")
		return
	}
	body.Element("cal:request-status", "2.0;Success")
	body.Element("cal:calendar-data", string(data))
	body.End("cal:response")
}

func parseFreeBusyRequest(data []byte) (freeBusyRequest, error) {
	invalid := dav.WithCondition(http.StatusBadRequest, calDAV("valid-calendar-data"), "the outbox accepts VFREEBUSY requests")
	cal, err := ical.NewDecoder(bytes.NewReader(data)).Decode()
	if err != nil || !strings.EqualFold(propValue(cal.Props, ical.PropMethod), "REQUEST") {
		return freeBusyRequest{}, invalid
	}
	for _, child := range cal.Children {
		if child.Name != ical.CompFreeBusy {
			continue
		}
		request := freeBusyRequest{organizer: propValue(child.Props, ical.PropOrganizer), uid: propValue(child.Props, ical.PropUID)}
		start, errStart := child.Props.DateTime(ical.PropDateTimeStart, nil)
		end, errEnd := child.Props.DateTime(ical.PropDateTimeEnd, nil)
		if errStart != nil || errEnd != nil {
			return freeBusyRequest{}, invalid
		}
		request.window = calendar.TimeRange{Start: start.UTC(), End: end.UTC()}
		if err := calendar.ValidateWindow(request.window); err != nil {
			return freeBusyRequest{}, err
		}
		for _, attendee := range child.Props.Values(ical.PropAttendee) {
			request.attendees = append(request.attendees, attendee.Value)
		}
		if len(request.attendees) > maxFreeBusyPeers {
			return freeBusyRequest{}, dav.ErrBodyTooLarge
		}
		return request, nil
	}
	return freeBusyRequest{}, invalid
}

func propValue(props ical.Props, name string) string {
	if prop := props.Get(name); prop != nil {
		return prop.Value
	}
	return ""
}
