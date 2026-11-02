package calendar

import (
	"context"
	"time"

	"github.com/emersion/go-ical"

	"polder-server/internal/activity"
)

const (
	reminderTick      = 30 * time.Second
	reminderCatchUp   = 10 * time.Minute
	alarmLogRetention = 60 * 24 * time.Hour
)

func (s *Service) RunReminders(ctx context.Context) {
	ticker := time.NewTicker(reminderTick)
	defer ticker.Stop()
	since := s.now().Add(-reminderCatchUp)
	for {
		now := s.now()
		if err := s.FireReminders(ctx, since, now); err != nil && ctx.Err() == nil {
			logger.Warn("send calendar reminders", "error", err)
		} else {
			since = now
		}
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
		}
	}
}

func (s *Service) FireReminders(ctx context.Context, from, to time.Time) error {
	candidates, err := s.store.AlarmCandidates(ctx, from.Add(-alarmLookaround), to.Add(alarmLookaround))
	if err != nil {
		return err
	}
	calendars := map[int64]Calendar{}
	for _, object := range candidates {
		c, ok := calendars[object.CalendarID]
		if !ok {
			if c, err = s.store.CalendarByID(ctx, object.CalendarID); err != nil {
				continue
			}
			calendars[object.CalendarID] = c
		}
		if err := s.fireObjectReminders(ctx, c, object, from, to); err != nil {
			logger.Warn("compute reminders of an event", "calendar", c.ID, "uri", object.URI, "error", err)
		}
	}
	return nil
}

func (s *Service) fireObjectReminders(ctx context.Context, c Calendar, object Object, from, to time.Time) error {
	resource, err := Parse(object.Data, c.Location())
	if err != nil {
		return err
	}
	triggers, err := resource.TriggersBetween(from, to)
	if err != nil || len(triggers) == 0 {
		return err
	}
	recipients, err := s.reminderRecipients(ctx, c)
	if err != nil {
		return err
	}
	for _, trigger := range triggers {
		for _, userID := range recipients {
			fresh, err := s.store.NoteAlarm(ctx, object.ID, userID, trigger.Occurrence.Start, trigger.Key)
			if err != nil {
				return err
			}
			if fresh && s.hub != nil {
				s.hub.Publish(activity.Event{Type: activity.EventCalendarReminder, UserID: userID, Reminder: reminderOf(c, object, trigger)})
			}
		}
	}
	return nil
}

func (s *Service) reminderRecipients(ctx context.Context, c Calendar) ([]int64, error) {
	choices, err := s.store.NotifyChoices(ctx, c.ID)
	if err != nil {
		return nil, err
	}
	var recipients []int64
	if notify, chosen := choices[c.OwnerID]; !chosen || notify {
		recipients = append(recipients, c.OwnerID)
	}
	audience, err := s.store.ShareAudience(ctx, c.ID)
	if err != nil {
		return nil, err
	}
	for _, userID := range audience {
		if userID != c.OwnerID && choices[userID] {
			recipients = append(recipients, userID)
		}
	}
	return recipients, nil
}

func reminderOf(c Calendar, object Object, trigger Trigger) *activity.CalendarReminder {
	component := trigger.Occurrence.Component
	return &activity.CalendarReminder{
		CalendarID:   c.ID,
		EventID:      object.ID,
		UID:          object.UID,
		RecurrenceID: trigger.Occurrence.RecurrenceID,
		Summary:      propText(component, ical.PropSummary),
		Location:     propText(component, ical.PropLocation),
		Start:        trigger.Occurrence.Start,
		End:          trigger.Occurrence.End,
		AllDay:       trigger.Occurrence.AllDay,
		TriggerAt:    trigger.At,
	}
}
