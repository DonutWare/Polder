package calendar

import (
	"context"
	"regexp"
	"strings"
	"testing"
	"time"

	"polder-server/internal/mail"
)

type capturingMailer struct {
	sent []mail.Message
}

func (m *capturingMailer) Configured() bool { return true }

func (m *capturingMailer) Send(_ context.Context, message mail.Message) error {
	m.sent = append(m.sent, message)
	return nil
}

var rsvpLink = regexp.MustCompile(`/calendar/rsvp/(\S+)`)

func TestExternalAttendeesAnswerThroughTheEmailedLink(t *testing.T) {
	mailer := &capturingMailer{}
	service, _, owner := newTestService(t, Options{Mailer: mailer, PublicURL: "https://polder.example.com", RSVPKey: []byte("key")})
	ctx := context.Background()
	personal, err := service.DefaultCalendar(ctx, owner)
	if err != nil {
		t.Fatal(err)
	}
	start := time.Date(2030, 5, 6, 14, 0, 0, 0, time.UTC)
	created, err := service.CreateEvent(ctx, owner, personal.ID, EventInput{
		Summary: "Interview", Start: start, End: start.Add(time.Hour), Attendees: []AttendeeInput{{Email: "carol@elsewhere.example"}},
	})
	if err != nil {
		t.Fatal(err)
	}
	if len(mailer.sent) != 1 {
		t.Fatalf("sent %d messages", len(mailer.sent))
	}
	message := mailer.sent[0]
	if message.To != "carol@elsewhere.example" || message.Method != "REQUEST" || message.ReplyTo != "alice@example.com" ||
		!strings.Contains(string(message.Calendar), "METHOD:REQUEST") || strings.Contains(string(message.Calendar), "SCHEDULE-STATUS") {
		t.Fatalf("invitation %+v\n%s", message, message.Calendar)
	}
	for _, attendee := range created.Attendees {
		if attendee.Email == "carol@elsewhere.example" && attendee.ScheduleStatus != statusSent {
			t.Fatalf("schedule status %q", attendee.ScheduleStatus)
		}
	}
	match := rsvpLink.FindStringSubmatch(message.Text)
	if match == nil {
		t.Fatalf("no answer link in:\n%s", message.Text)
	}
	invitation, err := service.Invitation(ctx, match[1])
	if err != nil || invitation.Summary != "Interview" || invitation.Status != PartstatNeedsAction {
		t.Fatalf("invitation %+v %v", invitation, err)
	}
	if _, err := service.RespondToInvitation(ctx, match[1], "tentative"); err != nil {
		t.Fatal(err)
	}
	details, err := service.Event(ctx, owner, personal.ID, created.ID)
	if err != nil {
		t.Fatal(err)
	}
	for _, attendee := range details.Attendees {
		if attendee.Email == "carol@elsewhere.example" && attendee.Status != PartstatTentative {
			t.Fatalf("answer not recorded: %+v", details.Attendees)
		}
	}
	if len(mailer.sent) != 1 {
		t.Fatalf("recording the answer re-sent the invitation: %d messages", len(mailer.sent))
	}
	if err := service.DeleteEvent(ctx, owner, personal.ID, created.ID, ScopeAll, "", ""); err != nil {
		t.Fatal(err)
	}
	if len(mailer.sent) != 2 || mailer.sent[1].Method != "CANCEL" {
		t.Fatalf("cancellation %+v", mailer.sent)
	}
}
