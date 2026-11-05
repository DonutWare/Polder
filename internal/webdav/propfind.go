package webdav

import (
	"net/http"
	"strconv"
	"strings"
	"time"

	"polder-server/internal/dav"
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
	names []dav.Name
}

type liveProp struct {
	name    dav.Name
	allprop bool
	write   func(w *dav.Writer, space Space, res resource, locks *LockManager) bool
}

func oc(local string) dav.Name { return dav.Name{Space: dav.NamespaceOwnCloud, Local: local} }

var liveProps = []liveProp{
	{dav.DAV("resourcetype"), true, func(w *dav.Writer, _ Space, res resource, _ *LockManager) bool {
		if res.entry.IsDir {
			w.Start("d:resourcetype")
			w.Empty("d:collection")
			w.End("d:resourcetype")
		} else {
			w.Empty("d:resourcetype")
		}
		return true
	}},
	{dav.DAV("getcontentlength"), true, func(w *dav.Writer, _ Space, res resource, _ *LockManager) bool {
		if res.entry.IsDir {
			return false
		}
		w.Element("d:getcontentlength", strconv.FormatInt(res.entry.Size, 10))
		return true
	}},
	{dav.DAV("getlastmodified"), true, func(w *dav.Writer, _ Space, res resource, _ *LockManager) bool {
		w.Element("d:getlastmodified", lastModified(res.entry).UTC().Format(http.TimeFormat))
		return true
	}},
	{dav.DAV("getetag"), true, func(w *dav.Writer, _ Space, res resource, _ *LockManager) bool {
		w.Element("d:getetag", res.etag)
		return true
	}},
	{dav.DAV("getcontenttype"), true, func(w *dav.Writer, _ Space, res resource, _ *LockManager) bool {
		w.Element("d:getcontenttype", contentType(res.entry))
		return true
	}},
	{dav.DAV("displayname"), true, func(w *dav.Writer, _ Space, res resource, _ *LockManager) bool {
		if res.entry.Name == "" {
			return false
		}
		w.Element("d:displayname", res.entry.Name)
		return true
	}},
	{dav.DAV("supportedlock"), true, func(w *dav.Writer, _ Space, _ resource, _ *LockManager) bool {
		w.Start("d:supportedlock")
		for _, scope := range []string{lockScopeExclusive, lockScopeShared} {
			w.Start("d:lockentry")
			w.Start("d:lockscope")
			w.Empty("d:" + scope)
			w.End("d:lockscope")
			w.Start("d:locktype")
			w.Empty("d:write")
			w.End("d:locktype")
			w.End("d:lockentry")
		}
		w.End("d:supportedlock")
		return true
	}},
	{dav.DAV("lockdiscovery"), true, func(w *dav.Writer, space Space, res resource, locks *LockManager) bool {
		writeLockDiscovery(w, locks.Discover(space.key(res.absolute)))
		return true
	}},
	{dav.DAV("quota-used-bytes"), true, func(w *dav.Writer, space Space, res resource, _ *LockManager) bool {
		if !res.entry.IsDir || space.Quota == nil {
			return false
		}
		w.Element("d:quota-used-bytes", strconv.FormatInt(space.Quota.Used, 10))
		return true
	}},
	{dav.DAV("quota-available-bytes"), true, func(w *dav.Writer, space Space, res resource, _ *LockManager) bool {
		if !res.entry.IsDir || space.Quota == nil || space.Quota.Limit <= 0 {
			return false
		}
		w.Element("d:quota-available-bytes", strconv.FormatInt(max(space.Quota.Limit-space.Quota.Used, 0), 10))
		return true
	}},
	{oc("permissions"), false, func(w *dav.Writer, space Space, res resource, _ *LockManager) bool {
		w.Element("oc:permissions", ownCloudPermissions(space, res))
		return true
	}},
	{dav.Name{Space: dav.NamespaceOCM, Local: "share-permissions"}, false, func(w *dav.Writer, space Space, res resource, _ *LockManager) bool {
		w.Element("ocm:share-permissions", ocmPermissions(space))
		return true
	}},
	{dav.Name{Space: dav.NamespaceOCS, Local: "share-permissions"}, false, func(w *dav.Writer, space Space, res resource, _ *LockManager) bool {
		w.Element("ocs:share-permissions", strconv.Itoa(shareMask(space, res)))
		return true
	}},
}

var livePropByName = func() map[dav.Name]liveProp {
	byName := make(map[dav.Name]liveProp, len(liveProps))
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
	root, err := dav.ReadBody(r)
	if err != nil || root == nil {
		return propfindRequest{mode: modeAllProp}, err
	}
	if root.Name != dav.DAV("propfind") {
		return propfindRequest{}, dav.ErrMalformedXML
	}
	if root.Child(dav.NamespaceDAV, "propname") != nil {
		return propfindRequest{mode: modePropName}, nil
	}
	prop := root.Child(dav.NamespaceDAV, "prop")
	if prop == nil {
		return propfindRequest{mode: modeAllProp}, nil
	}
	if len(prop.Children) > maxRequestedProps {
		return propfindRequest{}, dav.ErrBodyTooLarge
	}
	request := propfindRequest{mode: modeProp}
	for _, child := range prop.Children {
		if !child.Name.Valid() {
			return propfindRequest{}, dav.ErrMalformedXML
		}
		request.names = append(request.names, child.Name)
	}
	return request, nil
}

func (h *Handler) propfind(req *request) error {
	if err := req.space.Access.RequireRead(); err != nil {
		return err
	}
	depth := req.r.Header.Get("Depth")
	if depth != "0" && depth != "1" {
		return dav.WithStatus(http.StatusForbidden, "only Depth 0 and 1 are supported")
	}
	query, err := parsePropfind(req.r)
	if err != nil {
		return err
	}
	resources, err := h.resources(req, depth == "1")
	if err != nil {
		return err
	}
	body := dav.NewWriter()
	body.Start("d:multistatus", dav.NamespaceAttributes(dav.NamespaceDAV, dav.NamespaceOwnCloud, dav.NamespaceOCM, dav.NamespaceOCS)...)
	for _, res := range resources {
		h.writeResponse(body, req.space, res, query)
	}
	body.End("d:multistatus")
	body.WriteTo(req.w, http.StatusMultiStatus)
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

func (h *Handler) writeResponse(w *dav.Writer, space Space, res resource, query propfindRequest) {
	w.Start("d:response")
	w.Element("d:href", space.href(res.relative, res.entry.IsDir))
	found := &dav.Writer{}
	missing := &dav.Writer{}
	foreign := &dav.ForeignNames{}
	switch query.mode {
	case modePropName:
		for _, prop := range liveProps {
			if prop.write(&dav.Writer{}, space, res, h.locks) {
				name, attributes := foreign.Qualified(prop.name)
				found.Empty(name, attributes...)
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
			qualified, attributes := foreign.Qualified(name)
			missing.Empty(qualified, attributes...)
		}
	}
	dav.WritePropstat(w, found, http.StatusOK)
	dav.WritePropstat(w, missing, http.StatusNotFound)
	w.End("d:response")
}

func (h *Handler) proppatch(req *request) error {
	if !req.space.canWrite() {
		return dav.WithStatus(http.StatusForbidden, "this space is read-only")
	}
	root, err := dav.ReadBody(req.r)
	if err != nil {
		return err
	}
	if root == nil || root.Name != dav.DAV("propertyupdate") {
		return dav.ErrMalformedXML
	}
	entry, exists, err := h.stat(req, req.absolute)
	if err != nil {
		return err
	}
	if !exists {
		return dav.WithStatus(http.StatusNotFound, "no such resource")
	}
	if err := h.checkLocks(req, req.absolute, false, false); err != nil {
		return err
	}
	accepted := &dav.Writer{}
	protected := &dav.Writer{}
	foreign := &dav.ForeignNames{}
	count := 0
	for _, operation := range root.Children {
		if operation.Name.Space != dav.NamespaceDAV || (operation.Name.Local != "set" && operation.Name.Local != "remove") {
			continue
		}
		prop := operation.Child(dav.NamespaceDAV, "prop")
		if prop == nil {
			continue
		}
		for _, child := range prop.Children {
			if count++; count > maxRequestedProps || !child.Name.Valid() {
				return dav.ErrMalformedXML
			}
			name, attributes := foreign.Qualified(child.Name)
			if child.Name.Space == dav.NamespaceDAV {
				protected.Empty(name, attributes...)
			} else {
				accepted.Empty(name, attributes...)
			}
		}
	}
	body := dav.NewWriter()
	body.Start("d:multistatus", dav.NamespaceAttributes(dav.NamespaceDAV, dav.NamespaceOwnCloud, dav.NamespaceOCM, dav.NamespaceOCS)...)
	body.Start("d:response")
	body.Element("d:href", req.space.href(req.relative, entry.IsDir))
	if protected.Len() > 0 {
		dav.WritePropstat(body, protected, http.StatusForbidden)
		dav.WritePropstat(body, accepted, http.StatusFailedDependency)
	} else {
		dav.WritePropstat(body, accepted, http.StatusOK)
	}
	body.End("d:response")
	body.End("d:multistatus")
	body.WriteTo(req.w, http.StatusMultiStatus)
	return nil
}
