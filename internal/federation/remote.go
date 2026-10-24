package federation

import (
	"bytes"
	"context"
	"encoding/json"
	"encoding/xml"
	"hash/fnv"
	"io"
	"net/http"
	"net/url"
	"slices"
	"strconv"
	"strings"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
	"polder-server/internal/files"
	"polder-server/internal/sharing"
	"polder-server/internal/storage"
	"polder-server/internal/users"
)

const (
	maxPropfindBytes = 8 << 20
	maxRemoteEntries = 10000
	remotePropfind   = `<?xml version="1.0" encoding="UTF-8"?>
<d:propfind xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns" xmlns:ocm="http://open-cloud-mesh.org/ns">
<d:prop><d:getlastmodified/><d:getcontentlength/><d:resourcetype/><d:getetag/><oc:permissions/><oc:size/><ocm:share-permissions/></d:prop>
</d:propfind>`
)

type RemoteEntry struct {
	Path        string                   `json:"path" doc:"Path inside the share"`
	Name        string                   `json:"name"`
	IsDir       bool                     `json:"isDir"`
	Size        int64                    `json:"size"`
	Mtime       time.Time                `json:"mtime"`
	ETag        string                   `json:"etag"`
	Rev         int64                    `json:"rev" doc:"Changes whenever the item does; send it back as baseRev to write only over this version"`
	Mime        string                   `json:"mime"`
	Permissions sharing.SharePermissions `json:"permissions"`
}

const (
	authBearer = "bearer"
	authBasic  = "basic"
)

type remoteShare struct {
	client   *http.Client
	base     *url.URL
	secret   string
	basePath string
	scheme   string
	remember func(scheme string)
}

func (s *Service) remote(row incomingRow) (*remoteShare, error) {
	secret, err := s.box.open(row.secretSealed, row.sealContext())
	if err != nil {
		return nil, err
	}
	base, err := requireHTTPS(row.resourceURL())
	if err != nil {
		return nil, apperr.Unavailable("the remote server has no usable WebDAV address")
	}
	return &remoteShare{
		client: s.clients.For(row.server.AllowPrivateNetwork), base: base, secret: secret, basePath: base.Path, scheme: row.authScheme,
		remember: func(scheme string) {
			_, _ = s.db.ExecContext(context.Background(), `UPDATE federated_shares_in SET auth_scheme = $1 WHERE id = $2`, scheme, row.id)
		},
	}, nil
}

func (r incomingRow) resourceURL() string {
	root := r.server.webdavBase()
	switch {
	case r.webdavURI == "":
		return root
	case strings.Contains(r.webdavURI, "://"):
		return r.webdavURI
	case strings.HasPrefix(r.webdavURI, "/"):
		endPoint, err := url.Parse(r.server.ocmEndpoint)
		if err != nil {
			return ""
		}
		return "https://" + endPoint.Host + r.webdavURI
	}
	return root + "/" + r.webdavURI
}

func (r *remoteShare) authorize(request *http.Request) {
	if r.scheme == authBasic {
		request.SetBasicAuth(r.secret, "")
		return
	}
	request.Header.Set("Authorization", "Bearer "+r.secret)
}

func (r *remoteShare) negotiate(ctx context.Context) error {
	if r.scheme != "" {
		return nil
	}
	for _, scheme := range []string{authBearer, authBasic} {
		r.scheme = scheme
		response, err := r.send(ctx, "PROPFIND", storage.RootPath, strings.NewReader(remotePropfind), map[string]string{"Depth": "0"})
		if err != nil {
			r.scheme = ""
			return err
		}
		response.Body.Close()
		if response.StatusCode == http.StatusMultiStatus {
			r.remember(scheme)
			return nil
		}
		if response.StatusCode != http.StatusUnauthorized {
			r.scheme = ""
			return remoteFailure(response)
		}
	}
	r.scheme = ""
	return apperr.Forbidden("the remote server refused access")
}

func (s *Service) openRemote(ctx context.Context, user users.User, id int64) (*remoteShare, incomingRow, error) {
	if err := s.requireEnabled(ctx); err != nil {
		return nil, incomingRow{}, err
	}
	row, err := s.ownIncoming(ctx, user, id)
	if err != nil {
		return nil, incomingRow{}, err
	}
	if row.state != StateAccepted {
		return nil, incomingRow{}, apperr.Forbidden("accept the share before opening it")
	}
	remote, err := s.remote(row)
	if err != nil {
		return nil, incomingRow{}, err
	}
	return remote, row, remote.negotiate(ctx)
}

func (r *remoteShare) url(relative string) (string, error) {
	clean, err := storage.CleanPath(relative)
	if err != nil {
		return "", err
	}
	target := *r.base
	escaped := strings.TrimSuffix(r.base.EscapedPath(), "/")
	for _, segment := range strings.Split(strings.Trim(clean, "/"), "/") {
		if segment != "" {
			escaped += "/" + url.PathEscape(segment)
		}
	}
	if clean == storage.RootPath {
		escaped += "/"
	}
	target.RawPath = escaped
	target.Path, _ = url.PathUnescape(escaped)
	return target.String(), nil
}

func (r *remoteShare) do(ctx context.Context, method, relative string, body io.Reader, headers map[string]string) (*http.Response, error) {
	return r.send(ctx, method, relative, body, headers)
}

func (r *remoteShare) send(ctx context.Context, method, relative string, body io.Reader, headers map[string]string) (*http.Response, error) {
	target, err := r.url(relative)
	if err != nil {
		return nil, err
	}
	request, err := http.NewRequestWithContext(ctx, method, target, body)
	if err != nil {
		return nil, err
	}
	r.authorize(request)
	for name, value := range headers {
		request.Header.Set(name, value)
	}
	response, err := r.client.Do(request)
	if err != nil {
		return nil, apperr.Unavailable("the remote server cannot be reached")
	}
	return response, nil
}

func remoteFailure(response *http.Response) error {
	switch response.StatusCode {
	case http.StatusUnauthorized, http.StatusForbidden:
		return apperr.Forbidden("the remote server refused access")
	case http.StatusNotFound:
		return apperr.NotFound("the item does not exist on the remote server")
	case http.StatusPreconditionFailed:
		return apperr.New(apperr.KindPrecondition, "the item changed on the remote server")
	case http.StatusLocked, http.StatusConflict, http.StatusMethodNotAllowed:
		return apperr.Conflict(nil, "the remote server could not do this (status %d)", response.StatusCode)
	case http.StatusInsufficientStorage:
		return apperr.QuotaExceeded("the remote server is out of space")
	}
	return apperr.Unavailable("the remote server answered with status %d", response.StatusCode)
}

type davMultistatus struct {
	Responses []struct {
		Href      string `xml:"href"`
		Propstats []struct {
			Status string `xml:"status"`
			Prop   struct {
				LastModified  string `xml:"getlastmodified"`
				ContentLength string `xml:"getcontentlength"`
				ETag          string `xml:"getetag"`
				Permissions   string `xml:"http://owncloud.org/ns permissions"`
				FolderSize    string `xml:"http://owncloud.org/ns size"`
				OCMPerms      string `xml:"http://open-cloud-mesh.org/ns share-permissions"`
				ResourceType  struct {
					Collection *struct{} `xml:"collection"`
				} `xml:"resourcetype"`
			} `xml:"prop"`
		} `xml:"propstat"`
	} `xml:"response"`
}

func (r *remoteShare) propfind(ctx context.Context, relative, depth string) ([]RemoteEntry, error) {
	response, err := r.do(ctx, "PROPFIND", relative, strings.NewReader(remotePropfind),
		map[string]string{"Depth": depth, "Content-Type": "application/xml; charset=utf-8"})
	if err != nil {
		return nil, err
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusMultiStatus {
		return nil, remoteFailure(response)
	}
	content, err := readLimited(response.Body, maxPropfindBytes)
	if err != nil {
		return nil, apperr.Unavailable("the remote folder listing is too large")
	}
	decoder := xml.NewDecoder(bytes.NewReader(content))
	decoder.Strict = true
	var parsed davMultistatus
	if err := decoder.Decode(&parsed); err != nil {
		return nil, apperr.Unavailable("the remote server sent an unreadable listing")
	}
	if len(parsed.Responses) > maxRemoteEntries {
		return nil, apperr.Unavailable("the remote folder has too many items")
	}
	entries := make([]RemoteEntry, 0, len(parsed.Responses))
	for _, item := range parsed.Responses {
		relativePath, ok := r.relativeHref(item.Href)
		if !ok {
			continue
		}
		entry := RemoteEntry{Path: relativePath, Name: storage.BaseName(relativePath)}
		for _, propstat := range item.Propstats {
			if !strings.Contains(propstat.Status, " 200") {
				continue
			}
			prop := propstat.Prop
			entry.IsDir = prop.ResourceType.Collection != nil
			entry.Size, _ = strconv.ParseInt(strings.TrimSpace(prop.ContentLength), 10, 64)
			if folderSize, err := strconv.ParseInt(strings.TrimSpace(prop.FolderSize), 10, 64); err == nil && entry.IsDir {
				entry.Size = folderSize
			}
			entry.Mtime, _ = http.ParseTime(strings.TrimSpace(prop.LastModified))
			entry.ETag = truncate(strings.Trim(strings.TrimSpace(prop.ETag), `"`), 128)
			entry.Rev = revisionOf(entry.ETag)
			entry.Permissions = remotePermissions(prop.Permissions, prop.OCMPerms)
		}
		if !entry.IsDir {
			entry.Mime = files.MimeFor(entry.Name)
		}
		entries = append(entries, entry)
	}
	requested, _ := storage.CleanPath(relative)
	if len(entries) == 0 || entries[0].Path != requested {
		return nil, apperr.Unavailable("the remote server sent an unexpected listing")
	}
	return entries, nil
}

func (r *remoteShare) relativeHref(href string) (string, bool) {
	parsed, err := url.Parse(strings.TrimSpace(href))
	if err != nil || (parsed.Host != "" && !sameHost(parsed.Host, r.base.Host)) {
		return "", false
	}
	if parsed.Path == strings.TrimSuffix(r.basePath, "/") {
		return storage.RootPath, true
	}
	rest, found := strings.CutPrefix(parsed.Path, strings.TrimSuffix(r.basePath, "/")+"/")
	if !found {
		return "", false
	}
	clean, err := storage.CleanPath("/" + strings.TrimSuffix(rest, "/"))
	return clean, err == nil
}

func remotePermissions(letters, ocmNames string) sharing.SharePermissions {
	if letters == "" {
		var names []string
		if json.Unmarshal([]byte(ocmNames), &names) == nil {
			write := slices.Contains(names, "write")
			return sharing.SharePermissions{Edit: write, Create: write, Delete: write}
		}
	}
	return sharing.SharePermissions{
		Edit:   strings.Contains(letters, "W") || strings.Contains(letters, "N"),
		Create: strings.Contains(letters, "CK"),
		Delete: strings.Contains(letters, "D"),
	}
}

func (r *remoteShare) stat(ctx context.Context, relative string) (RemoteEntry, error) {
	entries, err := r.propfind(ctx, relative, "0")
	if err != nil {
		return RemoteEntry{}, err
	}
	return entries[0], nil
}

func (s *Service) RemoteList(ctx context.Context, user users.User, id int64, relative string) (RemoteEntry, []RemoteEntry, error) {
	remote, row, err := s.openRemote(ctx, user, id)
	if err != nil {
		return RemoteEntry{}, nil, err
	}
	entries, err := remote.propfind(ctx, relative, "1")
	if err != nil {
		return RemoteEntry{}, nil, err
	}
	self, children := entries[0], entries[1:]
	if self.Path != storage.RootPath {
		return self, children, nil
	}
	s.rememberRoot(ctx, &row, self)
	if self.IsDir {
		return row.withShareName(self), children, nil
	}
	self = row.withShareName(self)
	return self, []RemoteEntry{self}, nil
}

func (s *Service) RemoteStat(ctx context.Context, user users.User, id int64, relative string) (RemoteEntry, error) {
	remote, row, err := s.openRemote(ctx, user, id)
	if err != nil {
		return RemoteEntry{}, err
	}
	entry, err := remote.stat(ctx, relative)
	if err != nil {
		return RemoteEntry{}, err
	}
	if entry.Path != storage.RootPath {
		return entry, nil
	}
	s.rememberRoot(ctx, &row, entry)
	return row.withShareName(entry), nil
}

func (s *Service) rememberRoot(ctx context.Context, row *incomingRow, root RemoteEntry) {
	permissions := maskFromPermissions(root.Permissions)
	mtime := unixOrZero(root.Mtime)
	stored := int64(0)
	if row.remoteMtime != nil {
		stored = row.remoteMtime.Unix()
	}
	if root.IsDir == row.isDir && permissions == row.permissions && root.Size == row.remoteSize && mtime == stored {
		return
	}
	row.isDir, row.permissions, row.remoteSize, row.remoteMtime = root.IsDir, permissions, root.Size, nil
	if mtime != 0 {
		changed := time.Unix(mtime, 0)
		row.remoteMtime = &changed
	}
	_, _ = s.db.ExecContext(ctx, `UPDATE federated_shares_in SET is_dir = $1, permissions = $2, remote_size = $3, remote_mtime = $4 WHERE id = $5`,
		root.IsDir, permissions, root.Size, database.NullIfZero(mtime), row.id)
}

func unixOrZero(moment time.Time) int64 {
	if moment.IsZero() {
		return 0
	}
	return moment.Unix()
}

func (r incomingRow) withShareName(root RemoteEntry) RemoteEntry {
	root.Name = r.name
	if !root.IsDir {
		root.Mime = files.MimeFor(r.name)
	}
	return root
}

func (r incomingRow) nameAt(relative string) string {
	if clean, err := storage.CleanPath(relative); err == nil && clean == storage.RootPath {
		return r.name
	}
	return storage.BaseName(relative)
}

type RemoteContent struct {
	Status        int
	Body          io.ReadCloser
	ContentLength string
	ContentRange  string
	ETag          string
	LastModified  string
	Name          string
	Mime          string
}

func (s *Service) RemoteOpen(ctx context.Context, user users.User, id int64, relative, rangeHeader, ifNoneMatch string) (RemoteContent, error) {
	remote, row, err := s.openRemote(ctx, user, id)
	if err != nil {
		return RemoteContent{}, err
	}
	headers := map[string]string{}
	if rangeHeader != "" && len(rangeHeader) < 256 {
		headers["Range"] = rangeHeader
	}
	if ifNoneMatch != "" && len(ifNoneMatch) < 256 {
		headers["If-None-Match"] = ifNoneMatch
	}
	response, err := remote.do(ctx, http.MethodGet, relative, nil, headers)
	if err != nil {
		return RemoteContent{}, err
	}
	switch response.StatusCode {
	case http.StatusOK, http.StatusPartialContent, http.StatusNotModified:
	default:
		response.Body.Close()
		return RemoteContent{}, remoteFailure(response)
	}
	name := row.nameAt(relative)
	return RemoteContent{
		Status: response.StatusCode, Body: response.Body, ContentLength: response.Header.Get("Content-Length"),
		ContentRange: response.Header.Get("Content-Range"), ETag: response.Header.Get("ETag"),
		LastModified: response.Header.Get("Last-Modified"), Name: name, Mime: files.MimeFor(name),
	}, nil
}

func revisionOf(etag string) int64 {
	if etag == "" {
		return 0
	}
	hash := fnv.New64a()
	_, _ = hash.Write([]byte(etag))
	return int64(hash.Sum64()>>(64-maxSafeRevisionBits)) | 1
}

const maxSafeRevisionBits = 53

const (
	RemoteMustNotExist int64 = 0
	RemoteOverwrite    int64 = -1
)

func (s *Service) RemoteWrite(ctx context.Context, user users.User, id int64, relative string, content io.Reader, size, baseRev int64) error {
	remote, row, err := s.openRemote(ctx, user, id)
	if err != nil {
		return err
	}
	if size < 0 {
		return apperr.Invalid("uploads into a federated share need a Content-Length")
	}
	headers := map[string]string{}
	switch {
	case baseRev == RemoteMustNotExist:
		headers["If-None-Match"] = "*"
	case baseRev > 0:
		current, err := remote.stat(ctx, relative)
		if err != nil {
			return err
		}
		if current.Path == storage.RootPath {
			current = row.withShareName(current)
		}
		if current.Rev != baseRev {
			return apperr.Conflict(current, "%s changed on the remote server", row.nameAt(relative))
		}
		headers["If-Match"] = `"` + current.ETag + `"`
	}
	target, err := remote.url(relative)
	if err != nil {
		return err
	}
	request, err := http.NewRequestWithContext(ctx, http.MethodPut, target, content)
	if err != nil {
		return err
	}
	request.ContentLength = size
	remote.authorize(request)
	for name, value := range headers {
		request.Header.Set(name, value)
	}
	response, err := remote.client.Do(request)
	if err != nil {
		return apperr.Unavailable("the remote server cannot be reached")
	}
	defer response.Body.Close()
	if response.StatusCode == http.StatusPreconditionFailed && baseRev > 0 {
		return apperr.Conflict(nil, "%s changed on the remote server", row.nameAt(relative))
	}
	if response.StatusCode != http.StatusCreated && response.StatusCode != http.StatusNoContent && response.StatusCode != http.StatusOK {
		return remoteFailure(response)
	}
	return nil
}

func (s *Service) RemoteMkdir(ctx context.Context, user users.User, id int64, relative string) error {
	return s.simpleRemote(ctx, user, id, "MKCOL", relative, nil, http.StatusCreated)
}

func (s *Service) RemoteDelete(ctx context.Context, user users.User, id int64, relative string) error {
	if clean, err := storage.CleanPath(relative); err != nil || clean == storage.RootPath {
		return apperr.Invalid("the shared item itself cannot be deleted; remove the share instead")
	}
	return s.simpleRemote(ctx, user, id, http.MethodDelete, relative, nil, http.StatusNoContent)
}

func (s *Service) RemoteMove(ctx context.Context, user users.User, id int64, from, to string, copying bool) error {
	remote, _, err := s.openRemote(ctx, user, id)
	if err != nil {
		return err
	}
	for _, path := range []string{from, to} {
		if clean, err := storage.CleanPath(path); err != nil || clean == storage.RootPath {
			return apperr.Invalid("the shared item itself cannot be moved")
		}
	}
	destination, err := remote.url(to)
	if err != nil {
		return err
	}
	method := "MOVE"
	if copying {
		method = "COPY"
	}
	response, err := remote.do(ctx, method, from, nil, map[string]string{"Destination": destination, "Overwrite": "F"})
	if err != nil {
		return err
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusCreated && response.StatusCode != http.StatusNoContent {
		return remoteFailure(response)
	}
	return nil
}

func (s *Service) simpleRemote(ctx context.Context, user users.User, id int64, method, relative string, body io.Reader, want int) error {
	remote, _, err := s.openRemote(ctx, user, id)
	if err != nil {
		return err
	}
	response, err := remote.do(ctx, method, relative, body, nil)
	if err != nil {
		return err
	}
	defer response.Body.Close()
	if response.StatusCode != want {
		return remoteFailure(response)
	}
	return nil
}
