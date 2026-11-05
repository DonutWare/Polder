package calendar

import (
	"polder-server/internal/apperr"
	"polder-server/internal/logging"
)

var logger = logging.For("calendar")

type Condition string

const (
	ConditionValidData          Condition = "valid-calendar-data"
	ConditionValidObject        Condition = "valid-calendar-object-resource"
	ConditionSupportedComponent Condition = "supported-calendar-component"
	ConditionNoUIDConflict      Condition = "no-uid-conflict"
	ConditionMaxResourceSize    Condition = "max-resource-size"
	ConditionValidTimezone      Condition = "valid-calendar-timezone"
	ConditionValidOrganizer     Condition = "valid-organizer"
	ConditionSameOrganizer      Condition = "same-organizer-in-all-components"
)

type Violation struct {
	Condition Condition
	Err       *apperr.Error
}

func (v *Violation) Error() string { return v.Err.Error() }
func (v *Violation) Unwrap() error { return v.Err }

func violation(condition Condition, kind apperr.Kind, format string, args ...any) error {
	return &Violation{Condition: condition, Err: apperr.New(kind, format, args...)}
}

func invalidData(format string, args ...any) error {
	return violation(ConditionValidData, apperr.KindInvalid, format, args...)
}

func calendarNotFound() error {
	return apperr.NotFound("calendar not found")
}

func objectNotFound() error {
	return apperr.NotFound("event not found")
}
