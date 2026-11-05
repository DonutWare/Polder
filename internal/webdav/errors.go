package webdav

import (
	"net/http"

	"polder-server/internal/dav"
)

var (
	errLocked            = dav.WithStatus(http.StatusLocked, "the resource is locked")
	errLockTokenMismatch = dav.WithStatus(http.StatusPreconditionFailed, "no matching lock token was submitted")
	errLockForbidden     = dav.WithStatus(http.StatusForbidden, "the lock belongs to someone else")
	errTooManyLocks      = dav.WithStatus(http.StatusServiceUnavailable, "too many locks")
	errParentMissing     = dav.WithStatus(http.StatusConflict, "the parent collection does not exist")
)
