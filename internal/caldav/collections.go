package caldav

import (
	"mime"
	"net/http"
	"strconv"
	"strings"

	"polder-server/internal/apperr"
	"polder-server/internal/calendar"
	"polder-server/internal/dav"
)

const (
	homeAllow       = "OPTIONS, PROPFIND, PROPPATCH"
	calendarAllow   = "OPTIONS, GET, HEAD, DELETE, PROPFIND, PROPPATCH, REPORT"
	newCalendarOnly = "OPTIONS, MKCALENDAR, MKCOL"
)

func (h *Handler) serveHome(req *request) error {
	switch req.r.Method {
	case http.MethodOptions:
		return options(req, homeAllow)
	case MethodPropfind:
		query, err := parsePropfind(req.r)
		if err != nil {
			return err
		}
		resources := []*resource{h.homeResource(req)}
		if depth(req.r) > 0 {
			children, err := h.homeChildren(req)
			if err != nil {
				return err
			}
			resources = append(resources, children...)
		}
		writeMultistatus(req.w, resources, query, nil)
		return nil
	case MethodProppatch:
		return rejectProppatch(req, req.home())
	case MethodReport:
		return h.principalReport(req)
	}
	return methodNotAllowed(req, homeAllow)
}

func (h *Handler) homeResource(req *request) *resource {
	home := newResource(req.home())
	home.resourceType("d:collection")
	home.element(dav.DAV("displayname"), true, req.user.ShownName())
	home.hrefProp(dav.DAV("owner"), false, req.principal())
	h.addIdentity(req, home)
	home.set(dav.DAV("current-user-privilege-set"), false, func(w *dav.Writer) { privileges(w, true, !req.readOnly) })
	return home
}

func (h *Handler) homeChildren(req *request) ([]*resource, error) {
	calendars, err := h.calendars.List(req.r.Context(), req.user)
	if err != nil {
		return nil, err
	}
	var children []*resource
	for _, c := range calendars {
		if c.Access.CanReadEvents() {
			children = append(children, h.calendarResource(req, c))
		}
	}
	defaultCalendar, err := h.calendars.DefaultCalendar(req.r.Context(), req.user)
	if err != nil {
		return nil, err
	}
	return append(children, h.inboxResource(req, defaultCalendar), h.outboxResource(req)), nil
}

func (h *Handler) calendarResource(req *request, c calendar.Calendar) *resource {
	res := newResource(req.calendarHref(c))
	res.resourceType("d:collection", "cal:calendar")
	res.element(dav.DAV("displayname"), true, c.Name)
	res.element(calDAV("calendar-description"), false, c.Description)
	res.element(appleICal("calendar-color"), false, c.Color)
	res.element(appleICal("calendar-order"), false, strconv.Itoa(c.Order))
	if c.Timezone != "" {
		res.element(calDAV("calendar-timezone"), false, calendar.TimezoneCalendar(c.Timezone))
	}
	res.set(calDAV("supported-calendar-component-set"), false, func(w *dav.Writer) {
		w.Start("cal:supported-calendar-component-set")
		w.Empty("cal:comp", "name", calendar.ComponentEvent)
		w.End("cal:supported-calendar-component-set")
	})
	res.set(calDAV("supported-calendar-data"), false, func(w *dav.Writer) {
		w.Start("cal:supported-calendar-data")
		w.Empty("cal:calendar-data", "content-type", "text/calendar", "version", "2.0")
		w.End("cal:supported-calendar-data")
	})
	res.element(calDAV("max-resource-size"), false, strconv.Itoa(h.calendars.MaxResourceBytes()))
	res.element(calServer("getctag"), false, ctag(c))
	res.element(dav.DAV("getetag"), false, ctag(c))
	res.element(dav.DAV("sync-token"), false, syncToken(c.SyncRevision))
	res.set(dav.DAV("supported-report-set"), false, func(w *dav.Writer) {
		supportedReports(w, "cal:calendar-query", "cal:calendar-multiget", "d:sync-collection", "cal:free-busy-query")
	})
	res.set(dav.DAV("current-user-privilege-set"), false, func(w *dav.Writer) {
		privileges(w, true, !c.ReadOnly() && !req.readOnly)
	})
	if c.Owner != nil {
		res.hrefProp(dav.DAV("owner"), false, calendar.PrincipalHref(c.Owner.Username))
	}
	res.set(calDAV("schedule-calendar-transp"), false, func(w *dav.Writer) {
		w.Start("cal:schedule-calendar-transp")
		w.Empty("cal:opaque")
		w.End("cal:schedule-calendar-transp")
	})
	if c.Kind == calendar.KindSubscription {
		res.hrefProp(calServer("source"), false, c.SourceURL)
	}
	return res
}

func (h *Handler) serveCalendar(req *request, segment string) error {
	c, err := h.calendars.HomeCalendar(req.r.Context(), req.user, segment)
	if apperr.Is(err, apperr.KindNotFound) {
		return h.serveMissingCalendar(req, segment)
	}
	if err != nil {
		return err
	}
	switch req.r.Method {
	case http.MethodOptions:
		return options(req, calendarAllow)
	case MethodPropfind:
		return h.propfindCalendar(req, c)
	case MethodProppatch:
		return h.proppatchCalendar(req, c)
	case MethodReport:
		return h.calendarReport(req, c)
	case http.MethodGet, http.MethodHead:
		return h.exportCalendar(req, c)
	case http.MethodDelete:
		if err := req.requireWrite(); err != nil {
			return err
		}
		if err := h.calendars.Delete(req.r.Context(), req.user, c.ID); err != nil {
			return err
		}
		req.w.WriteHeader(http.StatusNoContent)
		return nil
	case MethodMkcalendar, MethodMkcol:
		req.w.Header().Set("Allow", calendarAllow)
		return dav.WithCondition(http.StatusMethodNotAllowed, dav.DAV("resource-must-be-null"), "the calendar already exists")
	}
	return methodNotAllowed(req, calendarAllow)
}

func (h *Handler) serveMissingCalendar(req *request, segment string) error {
	switch req.r.Method {
	case MethodMkcalendar, MethodMkcol:
		return h.makeCalendar(req, segment)
	case http.MethodOptions:
		return options(req, newCalendarOnly)
	}
	return apperr.NotFound("no such calendar")
}

func (h *Handler) propfindCalendar(req *request, c calendar.Calendar) error {
	query, err := parsePropfind(req.r)
	if err != nil {
		return err
	}
	resources := []*resource{h.calendarResource(req, c)}
	if depth(req.r) > 0 && c.Access.CanReadEvents() {
		objects, err := h.calendars.ObjectMetas(req.r.Context(), c)
		if err != nil {
			return err
		}
		for _, object := range objects {
			resources = append(resources, h.objectResource(req, c, object, nil))
		}
	}
	writeMultistatus(req.w, resources, query, nil)
	return nil
}

func (h *Handler) exportCalendar(req *request, c calendar.Calendar) error {
	_, data, err := h.calendars.Export(req.r.Context(), req.user, c.ID)
	if err != nil {
		return err
	}
	header := req.w.Header()
	header.Set("Content-Type", "text/calendar; charset=utf-8")
	header.Set("ETag", ctag(c))
	header.Set("Content-Disposition", mime.FormatMediaType("attachment", map[string]string{"filename": c.URI + ".ics"}))
	header.Set("Content-Length", strconv.Itoa(len(data)))
	req.w.WriteHeader(http.StatusOK)
	if req.r.Method != http.MethodHead {
		_, _ = req.w.Write(data)
	}
	return nil
}

type collectionProps struct {
	change            calendar.CalendarChange
	accepted          []dav.Name
	forbidden         []dav.Name
	isCalendar        bool
	isPlainCollection bool
	components        []string
}

func readCollectionProps(prop *dav.Element, into *collectionProps, removing bool) {
	if prop == nil {
		return
	}
	for _, child := range prop.Children {
		if !applyCollectionProp(child, into, removing) {
			into.forbidden = append(into.forbidden, child.Name)
			continue
		}
		into.accepted = append(into.accepted, child.Name)
	}
}

func applyCollectionProp(child *dav.Element, into *collectionProps, removing bool) bool {
	text := strings.TrimSpace(child.Text)
	if removing {
		text = ""
	}
	switch child.Name {
	case dav.DAV("displayname"):
		into.change.Name = &text
	case calDAV("calendar-description"):
		into.change.Description = &child.Text
	case appleICal("calendar-color"):
		into.change.Color = &text
	case appleICal("calendar-order"):
		order, err := strconv.Atoi(text)
		if err != nil && text != "" {
			return false
		}
		into.change.Order = &order
	case calDAV("calendar-timezone"):
		zone := calendar.TimezoneName(child.Text)
		into.change.Timezone = &zone
	case dav.DAV("resourcetype"):
		into.isCalendar = child.Child(dav.NamespaceCalDAV, "calendar") != nil
		into.isPlainCollection = !into.isCalendar
	case calDAV("supported-calendar-component-set"):
		for _, comp := range child.ChildrenNamed(dav.NamespaceCalDAV, "comp") {
			into.components = append(into.components, strings.ToUpper(comp.Attribute("name")))
		}
	case calDAV("schedule-calendar-transp"), calServer("calendar-enabled"):
	default:
		return false
	}
	return true
}

func (h *Handler) makeCalendar(req *request, segment string) error {
	if err := req.requireWrite(); err != nil {
		return err
	}
	root, err := dav.ReadBody(req.r)
	if err != nil {
		return err
	}
	props := collectionProps{isCalendar: req.r.Method == MethodMkcalendar}
	if root != nil {
		for _, set := range root.ChildrenNamed(dav.NamespaceDAV, "set") {
			readCollectionProps(set.Child(dav.NamespaceDAV, "prop"), &props, false)
		}
	}
	if !props.isCalendar || props.isPlainCollection {
		return dav.WithCondition(http.StatusForbidden, dav.DAV("valid-resourcetype"), "only calendars can be created here")
	}
	for _, component := range props.components {
		if component != calendar.ComponentEvent {
			return dav.WithCondition(http.StatusForbidden, calDAV("supported-calendar-component"), "calendars hold only events")
		}
	}
	if len(props.forbidden) > 0 {
		return dav.WithCondition(http.StatusForbidden, dav.DAV("cannot-modify-protected-property"), "some properties cannot be set")
	}
	request := calendar.NewCalendar{URI: segment, Name: segment}
	change := props.change
	if change.Name != nil && *change.Name != "" {
		request.Name = *change.Name
	}
	if change.Description != nil {
		request.Description = *change.Description
	}
	if change.Color != nil {
		request.Color = *change.Color
	}
	if change.Timezone != nil {
		request.Timezone = *change.Timezone
	}
	if _, err := h.calendars.Create(req.r.Context(), req.user, request); err != nil {
		return err
	}
	req.w.Header().Set("Content-Length", "0")
	req.w.WriteHeader(http.StatusCreated)
	return nil
}

func (h *Handler) proppatchCalendar(req *request, c calendar.Calendar) error {
	if err := req.requireWrite(); err != nil {
		return err
	}
	root, err := dav.ReadBody(req.r)
	if err != nil {
		return err
	}
	if root == nil || root.Name != dav.DAV("propertyupdate") {
		return dav.ErrMalformedXML
	}
	var props collectionProps
	for _, operation := range root.Children {
		if operation.Name != dav.DAV("set") && operation.Name != dav.DAV("remove") {
			continue
		}
		readCollectionProps(operation.Child(dav.NamespaceDAV, "prop"), &props, operation.Name == dav.DAV("remove"))
	}
	if !c.Access.IsOwner() && (props.change.Description != nil || props.change.Timezone != nil) {
		props.forbidden = append(props.forbidden, props.accepted...)
		props.accepted = nil
	}
	if len(props.forbidden) == 0 {
		if _, err := h.calendars.Update(req.r.Context(), req.user, c.ID, props.change); err != nil {
			return err
		}
	}
	writeProppatchResult(req, req.calendarHref(c), props.accepted, props.forbidden)
	return nil
}

func rejectProppatch(req *request, href string) error {
	root, err := dav.ReadBody(req.r)
	if err != nil {
		return err
	}
	if root == nil || root.Name != dav.DAV("propertyupdate") {
		return dav.ErrMalformedXML
	}
	var forbidden []dav.Name
	for _, operation := range root.Children {
		if prop := operation.Child(dav.NamespaceDAV, "prop"); prop != nil {
			for _, child := range prop.Children {
				forbidden = append(forbidden, child.Name)
			}
		}
	}
	writeProppatchResult(req, href, nil, forbidden)
	return nil
}

func writeProppatchResult(req *request, href string, accepted, forbidden []dav.Name) {
	foreign := &dav.ForeignNames{}
	names := func(list []dav.Name) *dav.Writer {
		props := &dav.Writer{}
		for _, name := range list {
			tag, attributes := foreign.Qualified(name)
			props.Empty(tag, attributes...)
		}
		return props
	}
	body := dav.NewWriter()
	body.Start("d:multistatus", multistatusNamespaces...)
	body.Start("d:response")
	body.Element("d:href", href)
	if len(forbidden) > 0 {
		dav.WritePropstat(body, names(forbidden), http.StatusForbidden)
		dav.WritePropstat(body, names(accepted), http.StatusFailedDependency)
	} else {
		dav.WritePropstat(body, names(accepted), http.StatusOK)
	}
	body.End("d:response")
	body.End("d:multistatus")
	body.WriteTo(req.w, http.StatusMultiStatus)
}
