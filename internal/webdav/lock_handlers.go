package webdav

import (
	"errors"
	"net/http"
	"strconv"
	"strings"
	"time"

	"polder-server/internal/dav"
	"polder-server/internal/files"
)

func (h *Handler) lock(req *request) error {
	if !req.space.canWrite() {
		return dav.WithStatus(http.StatusForbidden, "this space is read-only")
	}
	timeout := lockTimeout(req.r.Header.Get("Timeout"))
	root, err := dav.ReadBody(req.r)
	if err != nil {
		return err
	}
	if root == nil {
		return h.refreshLock(req, timeout)
	}
	if root.Name != dav.DAV("lockinfo") {
		return dav.ErrMalformedXML
	}
	scope := lockScopeExclusive
	if lockScope := root.Child(dav.NamespaceDAV, "lockscope"); lockScope != nil && lockScope.Child(dav.NamespaceDAV, "shared") != nil {
		scope = lockScopeShared
	}
	if lockType := root.Child(dav.NamespaceDAV, "locktype"); lockType == nil || lockType.Child(dav.NamespaceDAV, "write") == nil {
		return dav.WithStatus(http.StatusUnprocessableEntity, "only write locks are supported")
	}
	depth := lockDepthInfinite
	switch req.r.Header.Get("Depth") {
	case "0":
		depth = lockDepthResourceOnly
	case "", "infinity":
	default:
		return dav.WithStatus(http.StatusBadRequest, "LOCK takes Depth 0 or infinity")
	}
	created, err := h.createIfMissing(req)
	if err != nil {
		return err
	}
	lock, err := h.locks.Create(lockRequest{
		principal: req.space.Principal,
		key:       req.space.key(req.absolute),
		scope:     scope,
		depth:     depth,
		owner:     lockOwner(root.Child(dav.NamespaceDAV, "owner")),
		timeout:   timeout,
	})
	if err != nil {
		return err
	}
	req.w.Header().Set("Lock-Token", "<"+lock.Token+">")
	status := http.StatusOK
	if created {
		status = http.StatusCreated
	}
	writeLockResponse(req.w, *lock, status)
	return nil
}

func (h *Handler) createIfMissing(req *request) (bool, error) {
	_, exists, err := h.stat(req, req.absolute)
	if err != nil || exists {
		return false, err
	}
	if err := req.space.Access.RequireCreate(); err != nil {
		return false, err
	}
	if err := h.requireParent(req, req.absolute); err != nil {
		return false, err
	}
	if err := h.checkLocks(req, req.absolute, false, true); err != nil {
		return false, err
	}
	_, err = h.files.Write(req.r.Context(), req.space.Access.Owner, files.WriteRequest{
		Path:    req.absolute,
		BaseRev: files.BaseRevMustNotExist,
		Content: strings.NewReader(""),
	})
	return err == nil, err
}

func (h *Handler) refreshLock(req *request, timeout time.Duration) error {
	tokens := submittedLockTokens(req.r.Header.Get("If"))
	lock, err := h.locks.Refresh(req.space.Principal, req.space.key(req.absolute), tokens, timeout)
	if err != nil {
		return err
	}
	writeLockResponse(req.w, *lock, http.StatusOK)
	return nil
}

func (h *Handler) unlock(req *request) error {
	token := strings.TrimSuffix(strings.TrimPrefix(strings.TrimSpace(req.r.Header.Get("Lock-Token")), "<"), ">")
	if token == "" {
		return dav.WithStatus(http.StatusBadRequest, "missing Lock-Token header")
	}
	if err := h.locks.Unlock(req.space.Principal, req.space.key(req.absolute), token); err != nil {
		if errors.Is(err, errLockTokenMismatch) {
			return dav.WithStatus(http.StatusConflict, "the lock token does not cover this resource")
		}
		return err
	}
	req.w.WriteHeader(http.StatusNoContent)
	return nil
}

func lockTimeout(header string) time.Duration {
	for _, option := range strings.Split(header, ",") {
		option = strings.TrimSpace(option)
		if strings.EqualFold(option, "Infinite") {
			return maxLockTimeout
		}
		if seconds, found := strings.CutPrefix(option, "Second-"); found {
			if value, err := strconv.ParseInt(seconds, 10, 64); err == nil && value > 0 {
				return min(time.Duration(value)*time.Second, maxLockTimeout)
			}
		}
	}
	return defaultLockTimeout
}

func lockOwner(owner *dav.Element) string {
	if owner == nil {
		return ""
	}
	text := owner.Text
	if href := owner.Child(dav.NamespaceDAV, "href"); href != nil {
		text = href.Text
	}
	text = strings.TrimSpace(text)
	if len(text) > maxLockOwnerLength {
		text = text[:maxLockOwnerLength]
	}
	return text
}

func writeLockResponse(w http.ResponseWriter, lock Lock, status int) {
	body := dav.NewWriter()
	body.Start("d:prop", dav.NamespaceAttributes(dav.NamespaceDAV)...)
	writeLockDiscovery(body, []Lock{lock})
	body.End("d:prop")
	body.WriteTo(w, status)
}

func writeLockDiscovery(w *dav.Writer, locks []Lock) {
	if len(locks) == 0 {
		w.Empty("d:lockdiscovery")
		return
	}
	w.Start("d:lockdiscovery")
	for _, lock := range locks {
		w.Start("d:activelock")
		w.Start("d:locktype")
		w.Empty("d:write")
		w.End("d:locktype")
		w.Start("d:lockscope")
		w.Empty("d:" + lock.Scope)
		w.End("d:lockscope")
		depth := "infinity"
		if lock.Depth == lockDepthResourceOnly {
			depth = "0"
		}
		w.Element("d:depth", depth)
		if lock.Owner != "" {
			w.Start("d:owner")
			w.Element("d:href", lock.Owner)
			w.End("d:owner")
		}
		w.Element("d:timeout", "Second-"+strconv.FormatInt(int64(lock.Timeout/time.Second), 10))
		w.Start("d:locktoken")
		w.Element("d:href", lock.Token)
		w.End("d:locktoken")
		w.End("d:activelock")
	}
	w.End("d:lockdiscovery")
}
