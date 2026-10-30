package webdav

import (
	"errors"
	"net/http"

	"polder-server/internal/apperr"
	"polder-server/internal/logging"
)

var logger = logging.For("webdav")

type statusError struct {
	status  int
	message string
}

func (e *statusError) Error() string { return e.message }

func withStatus(status int, message string) error {
	return &statusError{status: status, message: message}
}

var (
	errLocked            = withStatus(http.StatusLocked, "the resource is locked")
	errLockTokenMismatch = withStatus(http.StatusPreconditionFailed, "no matching lock token was submitted")
	errLockForbidden     = withStatus(http.StatusForbidden, "the lock belongs to someone else")
	errTooManyLocks      = withStatus(http.StatusServiceUnavailable, "too many locks")
	errBodyTooLarge      = withStatus(http.StatusRequestEntityTooLarge, "request body is too large")
	errMalformedXML      = withStatus(http.StatusBadRequest, "malformed XML request body")
	errParentMissing     = withStatus(http.StatusConflict, "the parent collection does not exist")
)

var statusByKind = map[apperr.Kind]int{
	apperr.KindInvalid:       http.StatusBadRequest,
	apperr.KindUnauthorized:  http.StatusUnauthorized,
	apperr.KindForbidden:     http.StatusForbidden,
	apperr.KindNotFound:      http.StatusNotFound,
	apperr.KindConflict:      http.StatusPreconditionFailed,
	apperr.KindAlreadyExists: http.StatusPreconditionFailed,
	apperr.KindQuotaExceeded: http.StatusInsufficientStorage,
	apperr.KindPrecondition:  http.StatusPreconditionFailed,
	apperr.KindRateLimited:   http.StatusTooManyRequests,
	apperr.KindUnavailable:   http.StatusServiceUnavailable,
}

func statusAndMessage(err error) (int, string) {
	var status *statusError
	if errors.As(err, &status) {
		return status.status, status.message
	}
	var appErr *apperr.Error
	if errors.As(err, &appErr) {
		if code, known := statusByKind[appErr.Kind]; known {
			return code, appErr.Message
		}
	}
	return http.StatusInternalServerError, err.Error()
}

func WriteError(w http.ResponseWriter, r *http.Request, err error) {
	status, message := statusAndMessage(err)
	if status == http.StatusInternalServerError {
		logger.Error("webdav request failed", "method", r.Method, "path", r.URL.Path, "error", err)
	}
	if status == http.StatusUnauthorized {
		w.Header().Set("WWW-Authenticate", basicChallenge)
	}
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.WriteHeader(status)
	_, _ = w.Write([]byte(message + "\n"))
}
