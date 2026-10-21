package webdav

import (
	"net/http"
	"strconv"
	"strings"
	"time"

	"polder-server/internal/files"
)

const maxRequestedProps = 256

type resource struct {
	relative string
	absolute string
	entry    files.Entry
	etag     string
	isRoot   bool
}

type propfindMode int

const (
	modeAllProp propfindMode = iota
	modePropName
	modeProp
)

type propfindRequest struct {
	mode  propfindMode
	names []propName
}

type liveProp struct {
	name    propName
	allprop bool
	write   func(w *xmlWriter, space Space, res resource, locks *LockManager) bool
}

func dav(local string) propName { return propName{Space: nsDAV, Local: local} }
func oc(local string) propName  { return propName{Space: nsOwnCloud, Local: local} }

var liveProps = []liveProp{
	{dav("resourcetype"), true, func(w *xmlWriter, _ Space, res resource, _ *LockManager) bool {
		if res.entry.IsDir {
			w.start("d:resourcetype")
			w.empty("d:collection")
			w.end("d:resourcetype")
		} else {
			w.empty("d:resourcetype")
		}
		return true
	}},
	{dav("getcontentlength"), true, func(w *xmlWriter, _ Space, res resource, _ *LockManager) bool {
		if res.entry.IsDir {
			return false
		}
		w.element("d:getcontentlength", strconv.FormatInt(res.entry.Size, 10))
		return true
	}},
	{dav("getlastmodified"), true, func(w *xmlWriter, _ Space, res resource, _ *LockManager) bool {
		w.element("d:getlastmodified", lastModified(res.entry).UTC().Format(http.TimeFormat))
		return true
	}},
	{dav("getetag"), true, func(w *xmlWriter, _ Space, res resource, _ *LockManager) bool {
		w.element("d:getetag", res.etag)
		return true
	}},
	{dav("getcontenttype"), true, func(w *xmlWriter, _ Space, res resource, _ *LockManager) bool {
		w.element("d:getcontenttype", contentType(res.entry))
		return true
	}},
	{dav("displayname"), true, func(w *xmlWriter, _ Space, res resource, _ *LockManager) bool {
		if res.entry.Name == "" {
			return false
		}
		w.element("d:displayname", res.entry.Name)
		return true
	}},
	{dav("supportedlock"), true, func(w *xmlWriter, _ Space, _ resource, _ *LockManager) bool {
		w.start("d:supportedlock")
		for _, scope := range []string{lockScopeExclusive, lockScopeShared} {
			w.start("d:lockentry")
			w.start("d:lockscope")
			w.empty("d:" + scope)
			w.end("d:lockscope")
			w.start("d:locktype")
			w.empty("d:write")
			w.end("d:locktype")
			w.end("d:lockentry")
		}
		w.end("d:supportedlock")
		return true
	}},
	{dav("lockdiscovery"), true, func(w *xmlWriter, space Space, res resource, locks *LockManager) bool {
		writeLockDiscovery(w, locks.Discover(space.key(res.absolute)))
		return true
	}},
	{dav("quota-used-bytes"), true, func(w *xmlWriter, space Space, res resource, _ *LockManager) bool {
		if !res.entry.IsDir || space.Quota == nil {
			return false
		}
		w.element("d:quota-used-bytes", strconv.FormatInt(space.Quota.Used, 10))
		return true
	}},
	{dav("quota-available-bytes"), true, func(w *xmlWriter, space Space, res resource, _ *LockManager) bool {
		if !res.entry.IsDir || space.Quota == nil || space.Quota.Limit <= 0 {
			return false
		}
		w.element("d:quota-available-bytes", strconv.FormatInt(max(space.Quota.Limit-space.Quota.Used, 0), 10))
		return true
	}},
	{oc("permissions"), false, func(w *xmlWriter, space Space, res resource, _ *LockManager) bool {
		w.element("oc:permissions", ownCloudPermissions(space, res))
		return true
	}},
	{propName{Space: nsOCM, Local: "share-permissions"}, false, func(w *xmlWriter, space Space, res resource, _ *LockManager) bool {
		w.element("ocm:share-permissions", ocmPermissions(space))
		return true
	}},
	{propName{Space: nsOCS, Local: "share-permissions"}, false, func(w *xmlWriter, space Space, res resource, _ *LockManager) bool {
		w.element("ocs:share-permissions", strconv.Itoa(shareMask(space, res)))
		return true
	}},
}

var livePropByName = func() map[propName]liveProp {
	byName := make(map[propName]liveProp, len(liveProps))
	for _, prop := range liveProps {
		byName[prop.name] = prop
	}
	return byName
}()

func lastModified(entry files.Entry) time.Time {
	if entry.Mtime.IsZero() {
		return time.Unix(0, 0)
	}
	return entry.Mtime
}

func contentType(entry files.Entry) string {
	switch {
	case entry.IsDir:
		return "httpd/unix-directory"
	case entry.Mime == "":
		return "application/octet-stream"
	}
	return entry.Mime
}

func ownCloudPermissions(space Space, res resource) string {
	access := space.Access
	var b strings.Builder
	if access.CanRead {
		b.WriteString("G")
	}
	if !res.isRoot && access.CanDelete {
		b.WriteString("D")
	}
	if !res.isRoot && access.CanEdit {
		b.WriteString("N")
	}
	if !res.isRoot && access.CanCreate && access.CanDelete {
		b.WriteString("V")
	}
	if access.CanEdit {
		b.WriteString("W")
	}
	if res.entry.IsDir && access.CanCreate {
		b.WriteString("CK")
	}
	return b.String()
}

func shareMask(space Space, res resource) int {
	access := space.Access
	mask := 1
	if access.CanEdit {
		mask |= 2
	}
	if res.entry.IsDir && access.CanCreate {
		mask |= 4
	}
	if access.CanDelete {
		mask |= 8
	}
	return mask
}

func ocmPermissions(space Space) string {
	access := space.Access
	names := []string{`"read"`}
	if access.CanCreate || access.CanEdit || access.CanDelete {
		names = append(names, `"write"`)
	}
	return "[" + strings.Join(names, ",") + "]"
}

func parsePropfind(r *http.Request) (propfindRequest, error) {
	root, err := readXMLBody(r)
	if err != nil || root == nil {
		return propfindRequest{mode: modeAllProp}, err
	}
	if root.name != dav("propfind") {
		return propfindRequest{}, errMalformedXML
	}
	if root.child(nsDAV, "propname") != nil {
		return propfindRequest{mode: modePropName}, nil
	}
	prop := root.child(nsDAV, "prop")
	if prop == nil {
		return propfindRequest{mode: modeAllProp}, nil
	}
	if len(prop.children) > maxRequestedProps {
		return propfindRequest{}, errBodyTooLarge
	}
	request := propfindRequest{mode: modeProp}
	for _, child := range prop.children {
		if !child.name.valid() {
			return propfindRequest{}, errMalformedXML
		}
		request.names = append(request.names, child.name)
	}
	return request, nil
}

func (h *Handler) propfind(req *request) error {
	if err := req.space.Access.RequireRead(); err != nil {
		return err
	}
	depth := req.r.Header.Get("Depth")
	if depth != "0" && depth != "1" {
		return withStatus(http.StatusForbidden, "only Depth 0 and 1 are supported")
	}
	query, err := parsePropfind(req.r)
	if err != nil {
		return err
	}
	resources, err := h.resources(req, depth == "1")
	if err != nil {
		return err
	}
	body := newXMLWriter()
	body.start("d:multistatus", namespaceAttributes(nsDAV, nsOwnCloud, nsOCM, nsOCS)...)
	for _, res := range resources {
		h.writeResponse(body, req.space, res, query)
	}
	body.end("d:multistatus")
	body.writeTo(req.w, http.StatusMultiStatus)
	return nil
}

func (h *Handler) resources(req *request, withChildren bool) ([]resource, error) {
	ctx := req.r.Context()
	access := req.space.Access
	entry, err := h.files.Stat(ctx, access.Owner, req.absolute)
	if err != nil {
		return nil, err
	}
	self := resource{relative: req.relative, absolute: req.absolute, entry: entry, etag: fileETag(entry), isRoot: req.absolute == access.Root.Path}
	if !entry.IsDir {
		return []resource{self}, nil
	}
	selfTag, childTags, err := h.files.TreeTags(ctx, access.Owner, entry)
	if err != nil {
		return nil, err
	}
	self.etag = selfTag.ETag()
	resources := []resource{self}
	if !withChildren {
		return resources, nil
	}
	_, children, err := h.files.List(ctx, access.Owner, req.absolute)
	if err != nil {
		return nil, err
	}
	for _, child := range children {
		res := resource{relative: access.RelativePath(child.Path), absolute: child.Path, entry: child, etag: fileETag(child)}
		if child.IsDir {
			res.etag = childTags[child.Name].ETag()
		}
		resources = append(resources, res)
	}
	return resources, nil
}

func (h *Handler) writeResponse(w *xmlWriter, space Space, res resource, query propfindRequest) {
	w.start("d:response")
	w.element("d:href", space.href(res.relative, res.entry.IsDir))
	found := &xmlWriter{}
	missing := &xmlWriter{}
	foreign := &foreignNames{}
	switch query.mode {
	case modePropName:
		for _, prop := range liveProps {
			if prop.write(&xmlWriter{}, space, res, h.locks) {
				name, attributes := foreign.qualified(prop.name)
				found.empty(name, attributes...)
			}
		}
	case modeAllProp:
		for _, prop := range liveProps {
			if prop.allprop {
				prop.write(found, space, res, h.locks)
			}
		}
	case modeProp:
		for _, name := range query.names {
			prop, known := livePropByName[name]
			if known && prop.write(found, space, res, h.locks) {
				continue
			}
			qualified, attributes := foreign.qualified(name)
			missing.empty(qualified, attributes...)
		}
	}
	writePropstat(w, found, http.StatusOK)
	writePropstat(w, missing, http.StatusNotFound)
	w.end("d:response")
}

func writePropstat(w *xmlWriter, props *xmlWriter, status int) {
	if props.buffer.Len() == 0 {
		return
	}
	w.start("d:propstat")
	w.start("d:prop")
	w.buffer.Write(props.buffer.Bytes())
	w.end("d:prop")
	w.element("d:status", statusLine(status))
	w.end("d:propstat")
}

func statusLine(status int) string {
	return "HTTP/1.1 " + strconv.Itoa(status) + " " + http.StatusText(status)
}

func (h *Handler) proppatch(req *request) error {
	if !req.space.canWrite() {
		return withStatus(http.StatusForbidden, "this space is read-only")
	}
	root, err := readXMLBody(req.r)
	if err != nil {
		return err
	}
	if root == nil || root.name != dav("propertyupdate") {
		return errMalformedXML
	}
	entry, exists, err := h.stat(req, req.absolute)
	if err != nil {
		return err
	}
	if !exists {
		return withStatus(http.StatusNotFound, "no such resource")
	}
	if err := h.checkLocks(req, req.absolute, false, false); err != nil {
		return err
	}
	accepted := &xmlWriter{}
	protected := &xmlWriter{}
	foreign := &foreignNames{}
	count := 0
	for _, operation := range root.children {
		if operation.name.Space != nsDAV || (operation.name.Local != "set" && operation.name.Local != "remove") {
			continue
		}
		prop := operation.child(nsDAV, "prop")
		if prop == nil {
			continue
		}
		for _, child := range prop.children {
			if count++; count > maxRequestedProps || !child.name.valid() {
				return errMalformedXML
			}
			name, attributes := foreign.qualified(child.name)
			if child.name.Space == nsDAV {
				protected.empty(name, attributes...)
			} else {
				accepted.empty(name, attributes...)
			}
		}
	}
	body := newXMLWriter()
	body.start("d:multistatus", namespaceAttributes(nsDAV, nsOwnCloud, nsOCM, nsOCS)...)
	body.start("d:response")
	body.element("d:href", req.space.href(req.relative, entry.IsDir))
	if protected.buffer.Len() > 0 {
		writePropstat(body, protected, http.StatusForbidden)
		writePropstat(body, accepted, http.StatusFailedDependency)
	} else {
		writePropstat(body, accepted, http.StatusOK)
	}
	body.end("d:response")
	body.end("d:multistatus")
	body.writeTo(req.w, http.StatusMultiStatus)
	return nil
}
