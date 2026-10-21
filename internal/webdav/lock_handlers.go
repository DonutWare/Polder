package webdav

import (
	"errors"
	"net/http"
	"strconv"
	"strings"
	"time"

	"polder-server/internal/files"
)

func (h *Handler) lock(req *request) error {
	if !req.space.canWrite() {
		return withStatus(http.StatusForbidden, "this space is read-only")
	}
	timeout := lockTimeout(req.r.Header.Get("Timeout"))
	root, err := readXMLBody(req.r)
	if err != nil {
		return err
	}
	if root == nil {
		return h.refreshLock(req, timeout)
	}
	if root.name != dav("lockinfo") {
		return errMalformedXML
	}
	scope := lockScopeExclusive
	if lockScope := root.child(nsDAV, "lockscope"); lockScope != nil && lockScope.child(nsDAV, "shared") != nil {
		scope = lockScopeShared
	}
	if lockType := root.child(nsDAV, "locktype"); lockType == nil || lockType.child(nsDAV, "write") == nil {
		return withStatus(http.StatusUnprocessableEntity, "only write locks are supported")
	}
	depth := lockDepthInfinite
	switch req.r.Header.Get("Depth") {
	case "0":
		depth = lockDepthResourceOnly
	case "", "infinity":
	default:
		return withStatus(http.StatusBadRequest, "LOCK takes Depth 0 or infinity")
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
		owner:     lockOwner(root.child(nsDAV, "owner")),
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
		return withStatus(http.StatusBadRequest, "missing Lock-Token header")
	}
	if err := h.locks.Unlock(req.space.Principal, req.space.key(req.absolute), token); err != nil {
		if errors.Is(err, errLockTokenMismatch) {
			return withStatus(http.StatusConflict, "the lock token does not cover this resource")
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

func lockOwner(owner *xmlElement) string {
	if owner == nil {
		return ""
	}
	text := owner.text
	if href := owner.child(nsDAV, "href"); href != nil {
		text = href.text
	}
	text = strings.TrimSpace(text)
	if len(text) > maxLockOwnerLength {
		text = text[:maxLockOwnerLength]
	}
	return text
}

func writeLockResponse(w http.ResponseWriter, lock Lock, status int) {
	body := newXMLWriter()
	body.start("d:prop", namespaceAttributes(nsDAV)...)
	writeLockDiscovery(body, []Lock{lock})
	body.end("d:prop")
	body.writeTo(w, status)
}

func writeLockDiscovery(w *xmlWriter, locks []Lock) {
	if len(locks) == 0 {
		w.empty("d:lockdiscovery")
		return
	}
	w.start("d:lockdiscovery")
	for _, lock := range locks {
		w.start("d:activelock")
		w.start("d:locktype")
		w.empty("d:write")
		w.end("d:locktype")
		w.start("d:lockscope")
		w.empty("d:" + lock.Scope)
		w.end("d:lockscope")
		depth := "infinity"
		if lock.Depth == lockDepthResourceOnly {
			depth = "0"
		}
		w.element("d:depth", depth)
		if lock.Owner != "" {
			w.start("d:owner")
			w.element("d:href", lock.Owner)
			w.end("d:owner")
		}
		w.element("d:timeout", "Second-"+strconv.FormatInt(int64(lock.Timeout/time.Second), 10))
		w.start("d:locktoken")
		w.element("d:href", lock.Token)
		w.end("d:locktoken")
		w.end("d:activelock")
	}
	w.end("d:lockdiscovery")
}
