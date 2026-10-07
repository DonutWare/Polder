package httpapi

import (
	"errors"
	"net/http"
	"strings"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/logging"
)

var logger = logging.For("http")

const (
	smallBodyLimit  = 1 << 20
	uploadPlanLimit = 32 << 20
)

type errorDetail struct {
	Code    string `json:"code" doc:"Machine-readable error code, such as not_found, conflict or invalid_request"`
	Message string `json:"message" doc:"Human-readable explanation"`
}

// errorResponse is the body of every error the API sends. Huma builds it through newError, so
// errors from handlers, request validation and middleware all look the same.
type errorResponse struct {
	status  int
	Detail  errorDetail `json:"error"`
	Current any         `json:"current,omitempty" doc:"The server's current entry, sent with conflict and already_exists errors"`
}

func (e *errorResponse) Error() string  { return e.Detail.Message }
func (e *errorResponse) GetStatus() int { return e.status }

var statusByKind = map[apperr.Kind]int{
	apperr.KindInvalid:       http.StatusBadRequest,
	apperr.KindUnauthorized:  http.StatusUnauthorized,
	apperr.KindForbidden:     http.StatusForbidden,
	apperr.KindNotFound:      http.StatusNotFound,
	apperr.KindConflict:      http.StatusConflict,
	apperr.KindAlreadyExists: http.StatusConflict,
	apperr.KindQuotaExceeded: http.StatusInsufficientStorage,
	apperr.KindPrecondition:  http.StatusPreconditionFailed,
	apperr.KindRateLimited:   http.StatusTooManyRequests,
	apperr.KindUnavailable:   http.StatusServiceUnavailable,
}

// kindByStatus names errors that Huma raises itself, such as failed request validation.
var kindByStatus = map[int]apperr.Kind{
	http.StatusBadRequest:   apperr.KindInvalid,
	http.StatusUnauthorized: apperr.KindUnauthorized,
	http.StatusForbidden:    apperr.KindForbidden,
	http.StatusNotFound:     apperr.KindNotFound,
}

func init() {
	huma.NewError = func(status int, message string, errs ...error) huma.StatusError {
		return newError(nil, status, message, errs...)
	}
	huma.NewErrorWithContext = newError
}

// newError turns whatever a handler or Huma reports into an errorResponse. Handlers return
// apperr errors, which Huma passes here as the cause of a 500; their kind decides the status.
func newError(ctx huma.Context, status int, message string, errs ...error) huma.StatusError {
	for _, err := range errs {
		var appErr *apperr.Error
		if errors.As(err, &appErr) {
			return fromAppError(appErr)
		}
	}
	if status >= http.StatusInternalServerError {
		logFailure(ctx, errors.Join(errs...))
		return &errorResponse{status: http.StatusInternalServerError, Detail: errorDetail{Code: "internal", Message: "internal server error"}}
	}
	if status == http.StatusUnprocessableEntity {
		status = http.StatusBadRequest
	}
	var details []string
	for _, err := range errs {
		details = appendDetail(details, err)
	}
	if len(details) > 0 {
		message = strings.TrimPrefix(message+": "+strings.Join(details, "; "), ": ")
	}
	return &errorResponse{status: status, Detail: errorDetail{Code: codeFor(status), Message: message}}
}

// appendDetail describes a validation problem by message and location only, never by the
// offending value, which may be a password.
func appendDetail(details []string, err error) []string {
	var detailer huma.ErrorDetailer
	switch {
	case err == nil:
		return details
	case errors.As(err, &detailer):
		detail := detailer.ErrorDetail()
		if detail.Location == "" {
			return append(details, detail.Message)
		}
		return append(details, detail.Message+" ("+detail.Location+")")
	default:
		return append(details, err.Error())
	}
}

func fromAppError(appErr *apperr.Error) *errorResponse {
	response := &errorResponse{status: statusByKind[appErr.Kind], Detail: errorDetail{Code: string(appErr.Kind), Message: appErr.Message}}
	if appErr.Kind == apperr.KindConflict || appErr.Kind == apperr.KindAlreadyExists {
		response.Current = appErr.Current
	}
	return response
}

func codeFor(status int) string {
	if kind, ok := kindByStatus[status]; ok {
		return string(kind)
	}
	return strings.ReplaceAll(strings.ToLower(http.StatusText(status)), " ", "_")
}

func logFailure(ctx huma.Context, err error) {
	if ctx == nil {
		logger.Error("request failed", "error", err)
		return
	}
	url := ctx.URL()
	logger.Error("request failed", "method", ctx.Method(), "path", url.Path, "error", err)
}

// writeError sends err from a middleware, where there is no handler to return it from.
func writeError(api huma.API, ctx huma.Context, err error) {
	_ = huma.WriteErr(api, ctx, http.StatusInternalServerError, "", err)
}

// jsonBody is the input or output of an operation whose request or response body is a JSON T.
type jsonBody[T any] struct {
	Body T
}

func respond[T any](body T) *jsonBody[T] {
	return &jsonBody[T]{Body: body}
}

var binarySchema = &huma.Schema{Type: huma.TypeString, Format: "binary"}

func binaryContent(contentType string) map[string]*huma.MediaType {
	return map[string]*huma.MediaType{contentType: {Schema: binarySchema}}
}
