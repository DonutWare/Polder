package office

import (
	"bytes"
	"cmp"
	"encoding/json"
	"hash/fnv"
	"io"
	"net/http"
	"path"
	"strconv"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/users"
)

// Collabora sends back the LastModifiedTime it was given to detect saves over newer content.
// Euro-Office does not, and saves only once everyone has closed the document.
const wopiTime = "2006-01-02T15:04:05.000000Z"

// documentChanged makes Collabora ask whether to overwrite the newer file or reload it.
const documentChanged = `{"COOLStatusCode":1010}`

type access struct {
	grant   grant
	user    users.User
	actor   users.User
	entry   files.Entry
	version *files.Version
}

func (a access) isRemote() bool {
	return a.grant.RemoteShareID != 0
}

func (a access) activityActor() activity.Actor {
	actor := activity.Actor{SessionID: a.grant.SessionID, Device: a.grant.Device}
	if a.actor.ID != a.user.ID {
		actor.Via = a.actor.Username
	}
	return actor
}

const (
	versionFileIDPrefix = "version-"
	remoteFileIDPrefix  = "remote-"
)

func (g grant) wopiID() string {
	if g.RemoteShareID != 0 {
		hash := fnv.New64a()
		_, _ = hash.Write([]byte(g.RemotePath))
		return remoteFileIDPrefix + strconv.FormatInt(g.RemoteShareID, 10) + "-" + strconv.FormatUint(hash.Sum64(), 36)
	}
	return wopiFileID(g.FileID, g.Generation, g.VersionID)
}

func wopiFileID(fileID, generation, versionID int64) string {
	switch {
	case versionID != 0:
		return versionFileIDPrefix + strconv.FormatInt(versionID, 10)
	case generation != 0:
		return strconv.FormatInt(fileID, 10) + "-" + strconv.FormatInt(generation, 10)
	default:
		return strconv.FormatInt(fileID, 10)
	}
}

func (s *Service) authorize(w http.ResponseWriter, r *http.Request) (access, bool) {
	granted, err := s.tokens.parse(r.URL.Query().Get("access_token"))
	if err != nil || granted.wopiID() != chi.URLParam(r, "fileID") {
		http.Error(w, "access token is invalid or expired", http.StatusUnauthorized)
		return access{}, false
	}
	actor, err := s.auth.ActiveUser(r.Context(), cmp.Or(granted.ActorID, granted.UserID))
	if err != nil {
		http.Error(w, "account is not active", http.StatusUnauthorized)
		return access{}, false
	}
	if granted.RemoteShareID != 0 {
		return s.authorizeRemote(w, r, granted, actor)
	}
	user := actor
	if granted.ActorID != 0 {
		if user, err = s.auth.ActiveUser(r.Context(), granted.UserID); err != nil {
			http.Error(w, "the shared file is no longer available", http.StatusUnauthorized)
			return access{}, false
		}
	}
	fileID := granted.FileID
	entries, err := s.files.EntriesByID(r.Context(), user.ID, []int64{fileID})
	if err != nil {
		s.fail(w, r, err)
		return access{}, false
	}
	entry, ok := entries[fileID]
	if !ok || entry.IsDir {
		http.Error(w, "unknown file", http.StatusNotFound)
		return access{}, false
	}
	if granted.ShareID != 0 {
		editable, err := s.shares.CanEditSharedFile(r.Context(), actor, granted.ShareID, user.ID, entry.Path)
		if err != nil {
			http.Error(w, "the shared file is no longer available", http.StatusUnauthorized)
			return access{}, false
		}
		granted.ReadOnly = granted.ReadOnly || !editable
	}
	if granted.VersionID == 0 {
		return access{grant: granted, user: user, actor: actor, entry: entry}, true
	}
	version, versionEntry, err := s.files.FindVersion(r.Context(), user, granted.VersionID)
	if err != nil || versionEntry.ID != entry.ID {
		http.Error(w, "unknown file", http.StatusNotFound)
		return access{}, false
	}
	return access{grant: granted, user: user, actor: actor, entry: entry, version: &version}, true
}

func (s *Service) authorizeRemote(w http.ResponseWriter, r *http.Request, granted grant, user users.User) (access, bool) {
	remote, err := s.remote.RemoteStat(r.Context(), user, granted.RemoteShareID, granted.RemotePath)
	if err != nil {
		s.fail(w, r, err)
		return access{}, false
	}
	if remote.IsDir {
		http.Error(w, "unknown file", http.StatusNotFound)
		return access{}, false
	}
	granted.ReadOnly = granted.ReadOnly || !remote.Permissions.Edit
	return access{grant: granted, user: user, actor: user, entry: remoteEntry(remote)}, true
}

func versionFileName(name string, version files.Version) string {
	extension := path.Ext(name)
	if extension == name {
		extension = ""
	}
	return strings.TrimSuffix(name, extension) + " (" + version.ModifiedAt.Local().Format("2006-01-02 15.04") + ")" + extension
}

type fileInfo struct {
	BaseFileName            string `json:"BaseFileName"`
	OwnerID                 string `json:"OwnerId"`
	UserID                  string `json:"UserId"`
	UserFriendlyName        string `json:"UserFriendlyName"`
	Size                    int64  `json:"Size"`
	Version                 string `json:"Version"`
	LastModifiedTime        string `json:"LastModifiedTime"`
	UserCanWrite            bool   `json:"UserCanWrite"`
	UserCanNotWriteRelative bool   `json:"UserCanNotWriteRelative"`
	SupportsLocks           bool   `json:"SupportsLocks"`
	SupportsUpdate          bool   `json:"SupportsUpdate"`
	SupportsRename          bool   `json:"SupportsRename"`
	PostMessageOrigin       string `json:"PostMessageOrigin,omitempty"`
	// FileVersionPostMessage has Euro-Office show a version history entry that asks the app,
	// with UI_FileVersions, to show the file's history.
	FileVersionPostMessage bool `json:"FileVersionPostMessage,omitempty"`
}

func (s *Service) checkFileInfo(w http.ResponseWriter, r *http.Request) {
	granted, ok := s.authorize(w, r)
	if !ok {
		return
	}
	info := fileInfo{
		BaseFileName:            granted.entry.Name,
		OwnerID:                 strconv.FormatInt(granted.user.ID, 10),
		UserID:                  strconv.FormatInt(granted.actor.ID, 10),
		UserFriendlyName:        granted.actor.Username,
		Size:                    granted.entry.Size,
		Version:                 strconv.FormatInt(granted.entry.Rev, 10),
		LastModifiedTime:        granted.entry.Mtime.UTC().Format(wopiTime),
		UserCanWrite:            !granted.grant.ReadOnly,
		UserCanNotWriteRelative: true,
		SupportsLocks:           true,
		SupportsUpdate:          true,
		PostMessageOrigin:       granted.grant.Origin,
		FileVersionPostMessage:  s.kind == EuroOffice,
	}
	if version := granted.version; version != nil {
		info.BaseFileName = versionFileName(granted.entry.Name, *version)
		info.Size = version.Size
		info.Version = wopiFileID(0, 0, version.ID)
		info.LastModifiedTime = version.ModifiedAt.UTC().Format(wopiTime)
		info.UserCanWrite = false
		info.SupportsLocks = false
		info.SupportsUpdate = false
	}
	writeJSON(w, http.StatusOK, info)
}

func (s *Service) getFile(w http.ResponseWriter, r *http.Request) {
	granted, ok := s.authorize(w, r)
	if !ok {
		return
	}
	if granted.version != nil {
		s.getVersion(w, r, granted)
		return
	}
	if granted.isRemote() {
		s.getRemote(w, r, granted)
		return
	}
	file, entry, err := s.files.Open(r.Context(), granted.user, granted.entry.Path)
	if err != nil {
		s.fail(w, r, err)
		return
	}
	defer file.Close()
	w.Header().Set("Content-Type", "application/octet-stream")
	w.Header().Set("Content-Length", strconv.FormatInt(entry.Size, 10))
	w.Header().Set("X-WOPI-ItemVersion", strconv.FormatInt(entry.Rev, 10))
	_, _ = io.Copy(w, file)
}

func (s *Service) getRemote(w http.ResponseWriter, r *http.Request, granted access) {
	content, err := s.remote.RemoteOpen(r.Context(), granted.user, granted.grant.RemoteShareID, granted.grant.RemotePath, "", "")
	if err != nil {
		s.fail(w, r, err)
		return
	}
	defer content.Body.Close()
	w.Header().Set("Content-Type", "application/octet-stream")
	if content.ContentLength != "" {
		w.Header().Set("Content-Length", content.ContentLength)
	}
	w.Header().Set("X-WOPI-ItemVersion", strconv.FormatInt(granted.entry.Rev, 10))
	_, _ = io.Copy(w, content.Body)
}

func (s *Service) getVersion(w http.ResponseWriter, r *http.Request, granted access) {
	content, version, _, err := s.files.OpenVersion(r.Context(), granted.user, granted.version.ID)
	if err != nil {
		s.fail(w, r, err)
		return
	}
	defer content.Close()
	w.Header().Set("Content-Type", "application/octet-stream")
	w.Header().Set("Content-Length", strconv.FormatInt(version.Size, 10))
	w.Header().Set("X-WOPI-ItemVersion", wopiFileID(0, 0, version.ID))
	_, _ = io.Copy(w, content)
}

func (s *Service) putFile(w http.ResponseWriter, r *http.Request) {
	granted, ok := s.authorize(w, r)
	if !ok {
		return
	}
	if granted.grant.ReadOnly {
		http.Error(w, "this session cannot change the file", http.StatusUnauthorized)
		return
	}
	// A lock that expired while the editor sat idle is not held against it.
	if held := s.locks.current(granted.grant.wopiID()); held != "" && held != r.Header.Get("X-WOPI-Lock") {
		w.Header().Set("X-WOPI-Lock", held)
		w.WriteHeader(http.StatusConflict)
		return
	}
	if !savedOverCurrent(r, granted.entry.Mtime) {
		writeRaw(w, http.StatusConflict, documentChanged)
		return
	}
	if granted.isRemote() {
		s.putRemote(w, r, granted)
		return
	}
	// An editor that opened the file before an older version was restored would save over it,
	// as Euro-Office does when it saves after the last editor closed.
	if restores, err := s.files.RestoreCount(r.Context(), granted.entry.ID); err != nil {
		s.fail(w, r, err)
		return
	} else if restores != granted.grant.Generation {
		writeRaw(w, http.StatusConflict, documentChanged)
		return
	}
	ctx := activity.WithActor(r.Context(), granted.activityActor())
	saved, err := s.files.Write(ctx, granted.user, files.WriteRequest{
		Path:    granted.entry.Path,
		BaseRev: granted.entry.Rev,
		Content: r.Body,
	})
	switch {
	case apperr.Is(err, apperr.KindConflict):
		writeRaw(w, http.StatusConflict, documentChanged)
		return
	case apperr.Is(err, apperr.KindQuotaExceeded):
		http.Error(w, "storage quota exceeded", http.StatusRequestEntityTooLarge)
		return
	case err != nil:
		s.fail(w, r, err)
		return
	}
	w.Header().Set("X-WOPI-ItemVersion", strconv.FormatInt(saved.Rev, 10))
	writeJSON(w, http.StatusOK, map[string]string{"LastModifiedTime": saved.Mtime.UTC().Format(wopiTime)})
}

func (s *Service) putRemote(w http.ResponseWriter, r *http.Request, granted access) {
	var body io.Reader = r.Body
	size := r.ContentLength
	if size < 0 {
		content, err := io.ReadAll(io.LimitReader(r.Body, maxRemoteDocument+1))
		if err != nil || len(content) > maxRemoteDocument {
			http.Error(w, "the document is too large", http.StatusRequestEntityTooLarge)
			return
		}
		body, size = bytes.NewReader(content), int64(len(content))
	}
	ctx := activity.WithActor(r.Context(), granted.activityActor())
	err := s.remote.RemoteWrite(ctx, granted.user, granted.grant.RemoteShareID, granted.grant.RemotePath, body, size, granted.entry.Rev)
	switch {
	case apperr.Is(err, apperr.KindConflict):
		writeRaw(w, http.StatusConflict, documentChanged)
		return
	case apperr.Is(err, apperr.KindQuotaExceeded):
		http.Error(w, "storage quota exceeded", http.StatusRequestEntityTooLarge)
		return
	case err != nil:
		s.fail(w, r, err)
		return
	}
	saved, err := s.remote.RemoteStat(ctx, granted.user, granted.grant.RemoteShareID, granted.grant.RemotePath)
	if err != nil {
		s.fail(w, r, err)
		return
	}
	w.Header().Set("X-WOPI-ItemVersion", strconv.FormatInt(saved.Rev, 10))
	writeJSON(w, http.StatusOK, map[string]string{"LastModifiedTime": saved.Mtime.UTC().Format(wopiTime)})
}

const maxRemoteDocument = 512 << 20

// savedOverCurrent tells whether the editor started from the file as it is now. Without the
// timestamp header the editor asks to overwrite whatever is there.
func savedOverCurrent(r *http.Request, mtime time.Time) bool {
	timestamp := r.Header.Get("X-COOL-WOPI-Timestamp")
	if timestamp == "" {
		timestamp = r.Header.Get("X-LOOL-WOPI-Timestamp")
	}
	if timestamp == "" {
		return true
	}
	parsed, err := time.Parse(time.RFC3339Nano, timestamp)
	return err == nil && parsed.Truncate(time.Microsecond).Equal(mtime.Truncate(time.Microsecond))
}

func (s *Service) fileOperation(w http.ResponseWriter, r *http.Request) {
	granted, ok := s.authorize(w, r)
	if !ok {
		return
	}
	fileID := granted.grant.wopiID()
	lockID := r.Header.Get("X-WOPI-Lock")
	var held string
	var done bool
	switch r.Header.Get("X-WOPI-Override") {
	case "LOCK":
		if granted.grant.ReadOnly || granted.version != nil {
			http.Error(w, "this session cannot change the file", http.StatusUnauthorized)
			return
		}
		held, done = s.locks.lock(fileID, lockID, r.Header.Get("X-WOPI-OldLock"))
	case "REFRESH_LOCK":
		held, done = s.locks.refresh(fileID, lockID)
	case "UNLOCK":
		held, done = s.locks.unlock(fileID, lockID)
	case "GET_LOCK":
		held, done = s.locks.current(fileID), true
	default:
		http.Error(w, "not supported", http.StatusNotImplemented)
		return
	}
	w.Header().Set("X-WOPI-Lock", held)
	w.Header().Set("X-WOPI-ItemVersion", strconv.FormatInt(granted.entry.Rev, 10))
	if !done {
		w.WriteHeader(http.StatusConflict)
		return
	}
	w.WriteHeader(http.StatusOK)
}

func (s *Service) fail(w http.ResponseWriter, r *http.Request, err error) {
	if apperr.Is(err, apperr.KindNotFound) {
		http.Error(w, "unknown file", http.StatusNotFound)
		return
	}
	logger.Error("WOPI request failed", "method", r.Method, "path", r.URL.Path, "error", err)
	http.Error(w, "internal server error", http.StatusInternalServerError)
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}

func writeRaw(w http.ResponseWriter, status int, body string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_, _ = io.WriteString(w, body)
}
