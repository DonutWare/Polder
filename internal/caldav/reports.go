package caldav

import (
	"net/http"
	"net/url"
	"strconv"
	"strings"

	"polder-server/internal/calendar"
	"polder-server/internal/dav"
)

const maxMultigetHrefs = 1000

func (h *Handler) calendarReport(req *request, c calendar.Calendar) error {
	root, err := dav.ReadBody(req.r)
	if err != nil {
		return err
	}
	if root == nil {
		return dav.ErrMalformedXML
	}
	switch root.Name {
	case calDAV("calendar-query"):
		return h.calendarQuery(req, c, root)
	case calDAV("calendar-multiget"):
		return h.calendarMultiget(req, c, root)
	case dav.DAV("sync-collection"):
		return h.syncCollection(req, c, root)
	case calDAV("free-busy-query"):
		return h.freeBusyQuery(req, c, root)
	}
	return dav.WithCondition(http.StatusForbidden, dav.DAV("supported-report"), "this report is not supported here")
}

func (h *Handler) calendarQuery(req *request, c calendar.Calendar, root *dav.Element) error {
	query, err := propsFrom(root.Child(dav.NamespaceDAV, "prop"))
	if err != nil {
		return err
	}
	filterElement := root.Child(dav.NamespaceCalDAV, "filter")
	if filterElement == nil {
		return dav.WithCondition(http.StatusForbidden, calDAV("valid-filter"), "a calendar-query needs a filter")
	}
	filter, err := parseCompFilter(filterElement.Child(dav.NamespaceCalDAV, "comp-filter"))
	if err != nil {
		return err
	}
	objects, err := h.calendars.Query(req.r.Context(), c, filter)
	if err != nil {
		return err
	}
	resources := make([]*resource, 0, len(objects))
	for _, object := range objects {
		resources = append(resources, h.objectResource(req, c, object, query.data))
	}
	writeMultistatus(req.w, resources, query, nil)
	return nil
}

func (h *Handler) calendarMultiget(req *request, c calendar.Calendar, root *dav.Element) error {
	query, err := propsFrom(root.Child(dav.NamespaceDAV, "prop"))
	if err != nil {
		return err
	}
	hrefs := root.ChildrenNamed(dav.NamespaceDAV, "href")
	if len(hrefs) > maxMultigetHrefs {
		return dav.ErrBodyTooLarge
	}
	collection := req.calendarHref(c)
	requested := map[string]string{}
	var uris, missing []string
	for _, element := range hrefs {
		href := strings.TrimSpace(element.Text)
		uri, inside := memberURI(collection, href)
		if !inside {
			missing = append(missing, href)
			continue
		}
		requested[uri] = href
		uris = append(uris, uri)
	}
	objects, err := h.calendars.ObjectsByURIs(req.r.Context(), c, uris)
	if err != nil {
		return err
	}
	resources := make([]*resource, 0, len(objects))
	for _, object := range objects {
		res := h.objectResource(req, c, object, query.data)
		res.href = requested[object.URI]
		resources = append(resources, res)
		delete(requested, object.URI)
	}
	for _, href := range requested {
		missing = append(missing, href)
	}
	writeMultistatus(req.w, resources, query, func(w *dav.Writer) {
		for _, href := range missing {
			writeStatusResponse(w, href, http.StatusNotFound)
		}
	})
	return nil
}

func memberURI(collection, href string) (string, bool) {
	parsed, err := url.Parse(href)
	if err != nil {
		return "", false
	}
	unescapedCollection, err := url.PathUnescape(collection)
	if err != nil {
		return "", false
	}
	name, inside := strings.CutPrefix(parsed.Path, unescapedCollection)
	if !inside || name == "" || strings.Contains(name, "/") {
		return "", false
	}
	return name, true
}

func (h *Handler) syncCollection(req *request, c calendar.Calendar, root *dav.Element) error {
	query, err := propsFrom(root.Child(dav.NamespaceDAV, "prop"))
	if err != nil {
		return err
	}
	token := ""
	if element := root.Child(dav.NamespaceDAV, "sync-token"); element != nil {
		token = element.Text
	}
	since, valid := parseSyncToken(token)
	if !valid {
		return calendar.ErrSyncTokenExpired
	}
	limit := syncLimit(root)
	if since == 0 {
		return h.initialSync(req, c, query, limit)
	}
	changes, err := h.calendars.Changes(req.r.Context(), c, since)
	if err != nil {
		return err
	}
	return h.writeChanges(req, c, query, changes, limit)
}

func syncLimit(root *dav.Element) int {
	limit := root.Child(dav.NamespaceDAV, "limit")
	if limit == nil {
		return 0
	}
	results := limit.Child(dav.NamespaceDAV, "nresults")
	if results == nil {
		return 0
	}
	value, err := strconv.Atoi(strings.TrimSpace(results.Text))
	if err != nil || value < 0 {
		return 0
	}
	return value
}

func (h *Handler) initialSync(req *request, c calendar.Calendar, query propQuery, limit int) error {
	objects, err := h.syncObjects(req, c, query)
	if err != nil {
		return err
	}
	if limit > 0 && len(objects) > limit {
		return dav.WithCondition(http.StatusInsufficientStorage, dav.DAV("number-of-matches-within-limits"), "the calendar holds more events than the limit; sync without one")
	}
	resources := make([]*resource, 0, len(objects))
	for _, object := range objects {
		resources = append(resources, h.objectResource(req, c, object, query.data))
	}
	writeMultistatus(req.w, resources, query, func(w *dav.Writer) {
		w.Element("d:sync-token", syncToken(c.SyncRevision))
	})
	return nil
}

func (h *Handler) syncObjects(req *request, c calendar.Calendar, query propQuery) ([]calendar.Object, error) {
	for _, name := range query.names {
		if name == calDAV("calendar-data") {
			return h.calendars.Objects(req.r.Context(), c)
		}
	}
	return h.calendars.ObjectMetas(req.r.Context(), c)
}

func (h *Handler) writeChanges(req *request, c calendar.Calendar, query propQuery, changes []calendar.Change, limit int) error {
	truncated := limit > 0 && len(changes) > limit
	revision := c.SyncRevision
	if truncated {
		changes = changes[:limit]
		revision = changes[len(changes)-1].Revision
	}
	var present, removed []string
	for _, change := range changes {
		if change.Deleted {
			removed = append(removed, change.URI)
		} else {
			present = append(present, change.URI)
		}
	}
	objects, err := h.changedObjects(req, c, query, present)
	if err != nil {
		return err
	}
	resources := make([]*resource, 0, len(objects))
	found := map[string]bool{}
	for _, object := range objects {
		resources = append(resources, h.objectResource(req, c, object, query.data))
		found[object.URI] = true
	}
	for _, uri := range present {
		if !found[uri] {
			removed = append(removed, uri)
		}
	}
	writeMultistatus(req.w, resources, query, func(w *dav.Writer) {
		for _, uri := range removed {
			writeStatusResponse(w, req.objectHref(c, uri), http.StatusNotFound)
		}
		if truncated {
			writeStatusResponse(w, req.calendarHref(c), http.StatusInsufficientStorage)
		}
		w.Element("d:sync-token", syncToken(revision))
	})
	return nil
}

func (h *Handler) changedObjects(req *request, c calendar.Calendar, query propQuery, uris []string) ([]calendar.Object, error) {
	objects, err := h.calendars.ObjectsByURIs(req.r.Context(), c, uris)
	if err != nil {
		return nil, err
	}
	for _, name := range query.names {
		if name == calDAV("calendar-data") {
			return objects, nil
		}
	}
	for i := range objects {
		objects[i].Data = nil
	}
	return objects, nil
}

func (h *Handler) freeBusyQuery(req *request, c calendar.Calendar, root *dav.Element) error {
	rangeElement := root.Child(dav.NamespaceCalDAV, "time-range")
	if rangeElement == nil {
		return dav.WithCondition(http.StatusBadRequest, calDAV("valid-filter"), "a free-busy-query needs a time-range")
	}
	window, err := parseTimeRange(rangeElement)
	if err != nil {
		return err
	}
	if err := calendar.ValidateWindow(window); err != nil {
		return err
	}
	periods, err := h.calendars.CalendarBusy(req.r.Context(), req.user, c, window)
	if err != nil {
		return err
	}
	data, err := calendar.FreeBusyCalendar("", window, periods, "", "", "")
	if err != nil {
		return err
	}
	req.w.Header().Set("Content-Type", calendarContentType)
	req.w.Header().Set("Content-Length", strconv.Itoa(len(data)))
	req.w.WriteHeader(http.StatusOK)
	_, _ = req.w.Write(data)
	return nil
}

func parseCompFilter(element *dav.Element) (calendar.CompFilter, error) {
	if element == nil {
		return calendar.CompFilter{}, dav.WithCondition(http.StatusForbidden, calDAV("valid-filter"), "a filter needs a comp-filter")
	}
	filter := calendar.CompFilter{Name: strings.ToUpper(element.Attribute("name"))}
	if filter.Name == "" {
		return calendar.CompFilter{}, dav.WithCondition(http.StatusForbidden, calDAV("valid-filter"), "a comp-filter needs a name")
	}
	for _, child := range element.Children {
		if child.Name.Space != dav.NamespaceCalDAV {
			continue
		}
		if err := addCompChild(&filter, child); err != nil {
			return calendar.CompFilter{}, err
		}
	}
	return filter, nil
}

func addCompChild(filter *calendar.CompFilter, child *dav.Element) error {
	switch child.Name.Local {
	case "is-not-defined":
		filter.IsNotDefined = true
	case "time-range":
		window, err := parseTimeRange(child)
		if err != nil {
			return err
		}
		filter.TimeRange = &window
	case "prop-filter":
		prop, err := parsePropFilter(child)
		if err != nil {
			return err
		}
		filter.Props = append(filter.Props, prop)
	case "comp-filter":
		comp, err := parseCompFilter(child)
		if err != nil {
			return err
		}
		filter.Comps = append(filter.Comps, comp)
	}
	return nil
}

func parsePropFilter(element *dav.Element) (calendar.PropFilter, error) {
	filter := calendar.PropFilter{Name: strings.ToUpper(element.Attribute("name"))}
	for _, child := range element.Children {
		switch child.Name {
		case calDAV("is-not-defined"):
			filter.IsNotDefined = true
		case calDAV("time-range"):
			window, err := parseTimeRange(child)
			if err != nil {
				return calendar.PropFilter{}, err
			}
			filter.TimeRange = &window
		case calDAV("text-match"):
			match, err := parseTextMatch(child)
			if err != nil {
				return calendar.PropFilter{}, err
			}
			filter.TextMatch = &match
		case calDAV("param-filter"):
			param, err := parseParamFilter(child)
			if err != nil {
				return calendar.PropFilter{}, err
			}
			filter.Params = append(filter.Params, param)
		}
	}
	return filter, nil
}

func parseParamFilter(element *dav.Element) (calendar.ParamFilter, error) {
	filter := calendar.ParamFilter{Name: strings.ToUpper(element.Attribute("name"))}
	if element.Child(dav.NamespaceCalDAV, "is-not-defined") != nil {
		filter.IsNotDefined = true
	}
	if child := element.Child(dav.NamespaceCalDAV, "text-match"); child != nil {
		match, err := parseTextMatch(child)
		if err != nil {
			return calendar.ParamFilter{}, err
		}
		filter.TextMatch = &match
	}
	return filter, nil
}

func parseTextMatch(element *dav.Element) (calendar.TextMatch, error) {
	match := calendar.TextMatch{
		Text:      element.Text,
		Collation: element.Attribute("collation"),
		Negate:    strings.EqualFold(element.Attribute("negate-condition"), "yes"),
	}
	if !calendar.SupportedCollation(match.Collation) {
		return calendar.TextMatch{}, dav.WithCondition(http.StatusForbidden, calDAV("supported-collation"), "the collation is not supported")
	}
	return match, nil
}
