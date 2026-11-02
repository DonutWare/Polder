package caldav

import (
	"net/http"

	"polder-server/internal/apperr"
	"polder-server/internal/calendar"
	"polder-server/internal/dav"
)

const discoveryAllow = "OPTIONS, PROPFIND, REPORT"

func (h *Handler) serveRoot(req *request) error {
	return h.serveDiscovery(req, func() []*resource {
		root := newResource(Root)
		root.resourceType("d:collection")
		h.addIdentity(req, root)
		return []*resource{root}
	})
}

func (h *Handler) servePrincipals(req *request, rest string) error {
	switch rest {
	case "":
		return h.serveDiscovery(req, func() []*resource {
			collection := newResource(PrincipalsPath)
			collection.resourceType("d:collection")
			h.addIdentity(req, collection)
			resources := []*resource{collection}
			if depth(req.r) > 0 {
				resources = append(resources, h.principalResource(req))
			}
			return resources
		})
	case req.user.Username:
		return h.serveDiscovery(req, func() []*resource { return []*resource{h.principalResource(req)} })
	}
	return apperr.NotFound("no such principal")
}

func (h *Handler) serveCollectionRoot(req *request) error {
	return h.serveDiscovery(req, func() []*resource {
		collection := newResource(CalendarsPath)
		collection.resourceType("d:collection")
		h.addIdentity(req, collection)
		return []*resource{collection}
	})
}

func (h *Handler) serveDiscovery(req *request, build func() []*resource) error {
	switch req.r.Method {
	case http.MethodOptions:
		return options(req, discoveryAllow)
	case MethodPropfind:
		query, err := parsePropfind(req.r)
		if err != nil {
			return err
		}
		writeMultistatus(req.w, build(), query, nil)
		return nil
	case MethodReport:
		return h.principalReport(req)
	}
	return methodNotAllowed(req, discoveryAllow)
}

func (h *Handler) addIdentity(req *request, res *resource) {
	res.hrefProp(dav.DAV("current-user-principal"), false, req.principal())
	res.hrefProp(dav.DAV("principal-collection-set"), false, PrincipalsPath)
	res.hrefProp(calDAV("calendar-home-set"), false, req.home())
	res.set(dav.DAV("current-user-privilege-set"), false, func(w *dav.Writer) { privileges(w, true, false) })
}

func (h *Handler) principalResource(req *request) *resource {
	principal := newResource(req.principal())
	principal.resourceType("d:principal")
	principal.element(dav.DAV("displayname"), true, req.user.ShownName())
	principal.hrefProp(dav.DAV("principal-URL"), false, req.principal())
	principal.hrefProp(dav.DAV("owner"), false, req.principal())
	h.addIdentity(req, principal)
	principal.hrefProp(calDAV("calendar-user-address-set"), false, calendar.Addresses(req.user)...)
	principal.hrefProp(calDAV("schedule-inbox-URL"), false, req.home()+inboxSegment+"/")
	principal.hrefProp(calDAV("schedule-outbox-URL"), false, req.home()+outboxSegment+"/")
	principal.element(calDAV("calendar-user-type"), false, "INDIVIDUAL")
	principal.set(dav.DAV("supported-report-set"), false, func(w *dav.Writer) {
		supportedReports(w, "d:principal-property-search", "d:principal-search-property-set", "d:expand-property")
	})
	if req.user.Profile.Email != "" {
		principal.set(calServer("email-address-set"), false, func(w *dav.Writer) {
			w.Start("cs:email-address-set")
			w.Element("cs:email-address", req.user.Profile.Email)
			w.End("cs:email-address-set")
		})
	}
	return principal
}

func (h *Handler) principalReport(req *request) error {
	root, err := dav.ReadBody(req.r)
	if err != nil {
		return err
	}
	if root == nil {
		return dav.ErrMalformedXML
	}
	switch root.Name {
	case dav.DAV("principal-search-property-set"):
		body := dav.NewWriter()
		body.Start("d:principal-search-property-set", multistatusNamespaces...)
		body.Start("d:principal-search-property")
		body.Start("d:prop")
		body.Empty("d:displayname")
		body.End("d:prop")
		body.Element("d:description", "Display name")
		body.End("d:principal-search-property")
		body.End("d:principal-search-property-set")
		body.WriteTo(req.w, http.StatusOK)
		return nil
	case dav.DAV("principal-property-search"), dav.DAV("expand-property"):
		query, err := propsFrom(root.Child(dav.NamespaceDAV, "prop"))
		if err != nil {
			return err
		}
		writeMultistatus(req.w, []*resource{h.principalResource(req)}, query, nil)
		return nil
	}
	return dav.WithCondition(http.StatusForbidden, dav.DAV("supported-report"), "this report is not supported here")
}
