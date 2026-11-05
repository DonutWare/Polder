package caldav

import (
	"io"
	"net/http"
	"net/url"
	"strconv"
	"time"

	"polder-server/internal/calendar"
	"polder-server/internal/dav"
)

const (
	objectAllow         = "OPTIONS, GET, HEAD, PUT, DELETE, PROPFIND"
	calendarContentType = "text/calendar; charset=utf-8"
)

type dataRequest struct {
	expand *calendar.TimeRange
}

func parseDataRequest(element *dav.Element) (dataRequest, error) {
	var request dataRequest
	if expand := element.Child(dav.NamespaceCalDAV, "expand"); expand != nil {
		window, err := parseTimeRange(expand)
		if err != nil {
			return dataRequest{}, err
		}
		if window.Start.IsZero() || window.End.IsZero() {
			return dataRequest{}, dav.WithCondition(http.StatusBadRequest, calDAV("valid-filter"), "expand needs a start and an end")
		}
		request.expand = &window
	}
	return request, nil
}

func (req *request) objectHref(c calendar.Calendar, uri string) string {
	return req.calendarHref(c) + url.PathEscape(uri)
}

func (h *Handler) objectResource(req *request, c calendar.Calendar, object calendar.Object, data *dataRequest) *resource {
	res := newResource(req.objectHref(c, object.URI))
	res.resourceType()
	res.element(dav.DAV("getetag"), true, object.ETag)
	res.element(dav.DAV("getcontenttype"), true, calendarContentType+"; component=vevent")
	res.element(dav.DAV("getcontentlength"), true, strconv.FormatInt(object.Size, 10))
	res.element(dav.DAV("getlastmodified"), true, object.UpdatedAt.UTC().Format(http.TimeFormat))
	res.element(dav.DAV("displayname"), false, object.Summary)
	if object.ScheduleTag != "" {
		res.element(calDAV("schedule-tag"), false, object.ScheduleTag)
	}
	res.set(dav.DAV("current-user-privilege-set"), false, func(w *dav.Writer) {
		privileges(w, true, !c.ReadOnly() && !req.readOnly)
	})
	if object.Data != nil {
		res.set(calDAV("calendar-data"), false, func(w *dav.Writer) {
			w.Element("cal:calendar-data", string(calendarData(c, object, data)))
		})
	}
	return res
}

func calendarData(c calendar.Calendar, object calendar.Object, data *dataRequest) []byte {
	if data == nil || data.expand == nil {
		return object.Data
	}
	resource, err := calendar.Parse(object.Data, c.Location())
	if err != nil {
		return object.Data
	}
	expanded, err := calendar.ExpandedData(resource, *data.expand)
	if err != nil {
		return object.Data
	}
	return expanded
}

func (h *Handler) serveObject(req *request, segment, name string) error {
	c, err := h.calendars.HomeCalendar(req.r.Context(), req.user, segment)
	if err != nil {
		return err
	}
	switch req.r.Method {
	case http.MethodOptions:
		return options(req, objectAllow)
	case http.MethodGet, http.MethodHead:
		return h.getObject(req, c, name)
	case http.MethodPut:
		return h.putObject(req, c, name)
	case http.MethodDelete:
		if err := req.requireWrite(); err != nil {
			return err
		}
		if err := h.calendars.DeleteObject(req.r.Context(), req.user, c, name, preconditions(req.r)); err != nil {
			return err
		}
		req.w.WriteHeader(http.StatusNoContent)
		return nil
	case MethodPropfind:
		query, err := parsePropfind(req.r)
		if err != nil {
			return err
		}
		object, err := h.calendars.Object(req.r.Context(), c, name)
		if err != nil {
			return err
		}
		writeMultistatus(req.w, []*resource{h.objectResource(req, c, object, query.data)}, query, nil)
		return nil
	}
	return methodNotAllowed(req, objectAllow)
}

func preconditions(r *http.Request) calendar.Preconditions {
	return calendar.Preconditions{
		IfMatch:            r.Header.Get("If-Match"),
		IfNoneMatch:        r.Header.Get("If-None-Match"),
		IfScheduleTagMatch: r.Header.Get("If-Schedule-Tag-Match"),
	}
}

func (h *Handler) getObject(req *request, c calendar.Calendar, name string) error {
	object, err := h.calendars.Object(req.r.Context(), c, name)
	if err != nil {
		return err
	}
	header := req.w.Header()
	header.Set("Content-Type", calendarContentType)
	header.Set("ETag", object.ETag)
	header.Set("Last-Modified", object.UpdatedAt.UTC().Format(http.TimeFormat))
	if object.ScheduleTag != "" {
		header.Set("Schedule-Tag", object.ScheduleTag)
	}
	if match := req.r.Header.Get("If-None-Match"); match != "" && match == object.ETag {
		req.w.WriteHeader(http.StatusNotModified)
		return nil
	}
	header.Set("Content-Length", strconv.Itoa(len(object.Data)))
	req.w.WriteHeader(http.StatusOK)
	if req.r.Method != http.MethodHead {
		_, _ = req.w.Write(object.Data)
	}
	return nil
}

func (h *Handler) putObject(req *request, c calendar.Calendar, name string) error {
	if err := req.requireWrite(); err != nil {
		return err
	}
	limit := int64(h.calendars.MaxResourceBytes())
	data, err := io.ReadAll(io.LimitReader(req.r.Body, limit+1))
	if err != nil {
		return err
	}
	if int64(len(data)) > limit {
		return dav.WithCondition(http.StatusForbidden, calDAV("max-resource-size"), "the event is too large")
	}
	result, err := h.calendars.PutObject(req.r.Context(), req.user, c, name, data, preconditions(req.r))
	if err != nil {
		return err
	}
	header := req.w.Header()
	if !result.Rewritten {
		header.Set("ETag", result.Object.ETag)
	}
	if result.Object.ScheduleTag != "" {
		header.Set("Schedule-Tag", result.Object.ScheduleTag)
	}
	header.Set("Last-Modified", result.Object.UpdatedAt.UTC().Format(http.TimeFormat))
	header.Set("Content-Length", "0")
	if result.Created {
		header.Set("Location", req.objectHref(c, name))
		req.w.WriteHeader(http.StatusCreated)
		return nil
	}
	req.w.WriteHeader(http.StatusNoContent)
	return nil
}

func parseTimeRange(element *dav.Element) (calendar.TimeRange, error) {
	var window calendar.TimeRange
	for attribute, target := range map[string]*time.Time{"start": &window.Start, "end": &window.End} {
		value := element.Attribute(attribute)
		if value == "" {
			continue
		}
		parsed, err := time.Parse("20060102T150405Z", value)
		if err != nil {
			return calendar.TimeRange{}, dav.WithCondition(http.StatusBadRequest, calDAV("valid-filter"), "time-range values are UTC date-times such as 20250101T000000Z")
		}
		*target = parsed
	}
	if !window.Start.IsZero() && !window.End.IsZero() && !window.End.After(window.Start) {
		return calendar.TimeRange{}, dav.WithCondition(http.StatusBadRequest, calDAV("valid-filter"), "a time-range ends after it starts")
	}
	return window, nil
}
