package apperr

import (
	"errors"
	"fmt"
)

type Kind string

const (
	KindInvalid       Kind = "invalid_request"
	KindUnauthorized  Kind = "unauthorized"
	KindForbidden     Kind = "forbidden"
	KindNotFound      Kind = "not_found"
	KindConflict      Kind = "conflict"
	KindAlreadyExists Kind = "already_exists"
	KindQuotaExceeded Kind = "quota_exceeded"
	KindPrecondition  Kind = "precondition_failed"
	KindRateLimited   Kind = "rate_limited"
)

type Error struct {
	Kind    Kind
	Message string
	Current any
}

func (e *Error) Error() string {
	return fmt.Sprintf("%s: %s", e.Kind, e.Message)
}

func New(kind Kind, format string, args ...any) *Error {
	return &Error{Kind: kind, Message: fmt.Sprintf(format, args...)}
}

func Invalid(format string, args ...any) *Error      { return New(KindInvalid, format, args...) }
func NotFound(format string, args ...any) *Error     { return New(KindNotFound, format, args...) }
func Forbidden(format string, args ...any) *Error    { return New(KindForbidden, format, args...) }
func Unauthorized(format string, args ...any) *Error { return New(KindUnauthorized, format, args...) }
func AlreadyExists(format string, args ...any) *Error {
	return New(KindAlreadyExists, format, args...)
}
func QuotaExceeded(format string, args ...any) *Error {
	return New(KindQuotaExceeded, format, args...)
}

func Conflict(current any, format string, args ...any) *Error {
	err := New(KindConflict, format, args...)
	err.Current = current
	return err
}

func KindOf(err error) (Kind, bool) {
	var appErr *Error
	if errors.As(err, &appErr) {
		return appErr.Kind, true
	}
	return "", false
}

func Is(err error, kind Kind) bool {
	found, ok := KindOf(err)
	return ok && found == kind
}
