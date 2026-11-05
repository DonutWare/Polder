package caldav

import (
	"net/http"

	"polder-server/internal/dav"
)

const maxRequestedProps = 256

type propWriter func(w *dav.Writer)

type resource struct {
	href    string
	props   map[dav.Name]propWriter
	allprop []dav.Name
}

func newResource(href string) *resource {
	return &resource{href: href, props: map[dav.Name]propWriter{}}
}

func (r *resource) set(name dav.Name, inAllprop bool, write propWriter) {
	if _, exists := r.props[name]; !exists && inAllprop {
		r.allprop = append(r.allprop, name)
	}
	r.props[name] = write
}

func (r *resource) element(name dav.Name, inAllprop bool, value string) {
	r.set(name, inAllprop, func(w *dav.Writer) { w.Element(qualified(name), value) })
}

func (r *resource) hrefProp(name dav.Name, inAllprop bool, hrefs ...string) {
	r.set(name, inAllprop, func(w *dav.Writer) {
		tag := qualified(name)
		w.Start(tag)
		for _, href := range hrefs {
			w.Element("d:href", href)
		}
		w.End(tag)
	})
}

func (r *resource) resourceType(types ...string) {
	r.set(dav.DAV("resourcetype"), true, func(w *dav.Writer) {
		if len(types) == 0 {
			w.Empty("d:resourcetype")
			return
		}
		w.Start("d:resourcetype")
		for _, kind := range types {
			w.Empty(kind)
		}
		w.End("d:resourcetype")
	})
}

func qualified(name dav.Name) string {
	tag, _ := (&dav.ForeignNames{}).Qualified(name)
	return tag
}

func calDAV(local string) dav.Name { return dav.Name{Space: dav.NamespaceCalDAV, Local: local} }
func calServer(local string) dav.Name {
	return dav.Name{Space: dav.NamespaceCalendarServer, Local: local}
}
func appleICal(local string) dav.Name { return dav.Name{Space: dav.NamespaceAppleICal, Local: local} }

type propfindMode int

const (
	modeAllProp propfindMode = iota
	modePropName
	modeProp
)

type propQuery struct {
	mode  propfindMode
	names []dav.Name
	data  *dataRequest
}

func parsePropfind(r *http.Request) (propQuery, error) {
	root, err := dav.ReadBody(r)
	if err != nil || root == nil {
		return propQuery{mode: modeAllProp}, err
	}
	if root.Name != dav.DAV("propfind") {
		return propQuery{}, dav.ErrMalformedXML
	}
	if root.Child(dav.NamespaceDAV, "propname") != nil {
		return propQuery{mode: modePropName}, nil
	}
	prop := root.Child(dav.NamespaceDAV, "prop")
	if prop == nil {
		return propQuery{mode: modeAllProp}, nil
	}
	return propsFrom(prop)
}

func propsFrom(prop *dav.Element) (propQuery, error) {
	if prop == nil {
		return propQuery{mode: modeAllProp}, nil
	}
	if len(prop.Children) > maxRequestedProps {
		return propQuery{}, dav.ErrBodyTooLarge
	}
	query := propQuery{mode: modeProp}
	for _, child := range prop.Children {
		if !child.Name.Valid() {
			return propQuery{}, dav.ErrMalformedXML
		}
		query.names = append(query.names, child.Name)
		if child.Name == calDAV("calendar-data") {
			data, err := parseDataRequest(child)
			if err != nil {
				return propQuery{}, err
			}
			query.data = &data
		}
	}
	return query, nil
}

var multistatusNamespaces = dav.NamespaceAttributes(dav.NamespaceDAV, dav.NamespaceCalDAV, dav.NamespaceCalendarServer, dav.NamespaceAppleICal)

func writeMultistatus(rw http.ResponseWriter, resources []*resource, query propQuery, extra func(w *dav.Writer)) {
	body := dav.NewWriter()
	body.Start("d:multistatus", multistatusNamespaces...)
	for _, res := range resources {
		writeResponse(body, res, query)
	}
	if extra != nil {
		extra(body)
	}
	body.End("d:multistatus")
	body.WriteTo(rw, http.StatusMultiStatus)
}

func writeResponse(w *dav.Writer, res *resource, query propQuery) {
	w.Start("d:response")
	w.Element("d:href", res.href)
	found := &dav.Writer{}
	missing := &dav.Writer{}
	foreign := &dav.ForeignNames{}
	switch query.mode {
	case modePropName:
		for _, name := range res.allprop {
			tag, attributes := foreign.Qualified(name)
			found.Empty(tag, attributes...)
		}
	case modeAllProp:
		for _, name := range res.allprop {
			res.props[name](found)
		}
	case modeProp:
		for _, name := range query.names {
			if write, known := res.props[name]; known {
				write(found)
				continue
			}
			tag, attributes := foreign.Qualified(name)
			missing.Empty(tag, attributes...)
		}
	}
	dav.WritePropstat(w, found, http.StatusOK)
	dav.WritePropstat(w, missing, http.StatusNotFound)
	w.End("d:response")
}

func writeStatusResponse(w *dav.Writer, href string, status int) {
	w.Start("d:response")
	w.Element("d:href", href)
	w.Element("d:status", dav.StatusLine(status))
	w.End("d:response")
}

func privileges(w *dav.Writer, read, write bool) {
	w.Start("d:current-user-privilege-set")
	names := []string{}
	if read {
		names = append(names, "d:read", "d:read-current-user-privilege-set", "cal:read-free-busy")
	}
	if write {
		names = append(names, "d:write", "d:write-properties", "d:write-content", "d:bind", "d:unbind")
	}
	for _, name := range names {
		w.Start("d:privilege")
		w.Empty(name)
		w.End("d:privilege")
	}
	w.End("d:current-user-privilege-set")
}

func supportedReports(w *dav.Writer, reports ...string) {
	w.Start("d:supported-report-set")
	for _, report := range reports {
		w.Start("d:supported-report")
		w.Start("d:report")
		w.Empty(report)
		w.End("d:report")
		w.End("d:supported-report")
	}
	w.End("d:supported-report-set")
}
