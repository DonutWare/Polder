package dav

import (
	"errors"
	"net/http"
	"strconv"

	"polder-server/internal/apperr"
	"polder-server/internal/logging"
)

const BasicChallenge = `Basic realm="Polder", charset="UTF-8"`

var logger = logging.For("dav")

type statusError struct {
	status    int
	message   string
	condition *Name
}

func (e *statusError) Error() string { return e.message }

func WithStatus(status int, message string) error {
	return &statusError{status: status, message: message}
}

func WithCondition(status int, condition Name, message string) error {
	return &statusError{status: status, message: message, condition: &condition}
}

var (
	ErrBodyTooLarge = WithStatus(http.StatusRequestEntityTooLarge, "request body is too large")
	ErrMalformedXML = WithStatus(http.StatusBadRequest, "malformed XML request body")
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

func StatusAndMessage(err error) (int, string) {
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
	status, message := StatusAndMessage(err)
	if status == http.StatusInternalServerError {
		logger.Error("dav request failed", "method", r.Method, "path", r.URL.Path, "error", err)
	}
	if status == http.StatusUnauthorized {
		w.Header().Set("WWW-Authenticate", BasicChallenge)
	}
	var conditional *statusError
	if errors.As(err, &conditional) && conditional.condition != nil {
		writeConditionError(w, status, *conditional.condition, message)
		return
	}
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.WriteHeader(status)
	_, _ = w.Write([]byte(message + "\n"))
}

func writeConditionError(w http.ResponseWriter, status int, condition Name, message string) {
	body := NewWriter()
	body.Start("d:error", NamespaceAttributes(NamespaceDAV, NamespaceCalDAV)...)
	name, attributes := (&ForeignNames{}).Qualified(condition)
	body.Empty(name, attributes...)
	body.Element("d:responsedescription", message)
	body.End("d:error")
	body.WriteTo(w, status)
}

func WritePropstat(w *Writer, props *Writer, status int) {
	if props.Len() == 0 {
		return
	}
	w.Start("d:propstat")
	w.Start("d:prop")
	w.Append(props)
	w.End("d:prop")
	w.Element("d:status", StatusLine(status))
	w.End("d:propstat")
}

func StatusLine(status int) string {
	return "HTTP/1.1 " + strconv.Itoa(status) + " " + http.StatusText(status)
}
