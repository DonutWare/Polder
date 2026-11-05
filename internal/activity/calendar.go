package activity

import "time"

type CalendarUpdate struct {
	CalendarID int64 `json:"calendarId"`
}

type CalendarReminder struct {
	CalendarID   int64     `json:"calendarId"`
	EventID      int64     `json:"eventId"`
	UID          string    `json:"uid"`
	RecurrenceID string    `json:"recurrenceId,omitempty" required:"false" doc:"Which occurrence of a repeating event the reminder is for"`
	Summary      string    `json:"summary"`
	Location     string    `json:"location,omitempty" required:"false"`
	Start        time.Time `json:"start"`
	End          time.Time `json:"end"`
	AllDay       bool      `json:"allDay"`
	TriggerAt    time.Time `json:"triggerAt"`
}
