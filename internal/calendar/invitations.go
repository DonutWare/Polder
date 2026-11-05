package calendar

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"strings"
	"time"

	"github.com/emersion/go-ical"

	"polder-server/internal/apperr"
	"polder-server/internal/mail"
	"polder-server/internal/users"
)

const (
	RSVPKeyPurpose = "polder-calendar-rsvp"
	rsvpPath       = "/calendar/rsvp/"
	rsvpMACLength  = 18
)

type rsvpClaims struct {
	ObjectID int64  `json:"o"`
	Attendee string `json:"a"`
	UID      string `json:"u"`
}

type Invitation struct {
	Summary   string    `json:"summary"`
	Location  string    `json:"location,omitempty" required:"false"`
	Organizer string    `json:"organizer"`
	Attendee  string    `json:"attendee"`
	Status    string    `json:"status"`
	Start     time.Time `json:"start"`
	End       time.Time `json:"end"`
	AllDay    bool      `json:"allDay"`
	Cancelled bool      `json:"cancelled"`
}

func (s *Service) rsvpToken(claims rsvpClaims) string {
	payload, _ := json.Marshal(claims)
	encoded := base64.RawURLEncoding.EncodeToString(payload)
	return encoded + "." + base64.RawURLEncoding.EncodeToString(s.rsvpMAC(encoded))
}

func (s *Service) rsvpMAC(encoded string) []byte {
	mac := hmac.New(sha256.New, s.options.RSVPKey)
	mac.Write([]byte(encoded))
	return mac.Sum(nil)[:rsvpMACLength]
}

func (s *Service) parseRSVPToken(token string) (rsvpClaims, error) {
	invalid := apperr.NotFound("this invitation link is not valid")
	if len(s.options.RSVPKey) == 0 || len(token) > 2048 {
		return rsvpClaims{}, invalid
	}
	encoded, signature, found := strings.Cut(token, ".")
	if !found {
		return rsvpClaims{}, invalid
	}
	given, err := base64.RawURLEncoding.DecodeString(signature)
	if err != nil || !hmac.Equal(given, s.rsvpMAC(encoded)) {
		return rsvpClaims{}, invalid
	}
	payload, err := base64.RawURLEncoding.DecodeString(encoded)
	var claims rsvpClaims
	if err != nil || json.Unmarshal(payload, &claims) != nil {
		return rsvpClaims{}, invalid
	}
	return claims, nil
}

func (s *Service) invitationTarget(ctx context.Context, token string) (rsvpClaims, Calendar, Object, *Resource, error) {
	claims, err := s.parseRSVPToken(token)
	if err != nil {
		return rsvpClaims{}, Calendar{}, Object{}, nil, err
	}
	object, err := s.store.ObjectByID(ctx, claims.ObjectID)
	if err != nil || object.UID != claims.UID {
		return rsvpClaims{}, Calendar{}, Object{}, nil, apperr.NotFound("the event of this invitation no longer exists")
	}
	c, err := s.store.CalendarByID(ctx, object.CalendarID)
	if err != nil {
		return rsvpClaims{}, Calendar{}, Object{}, nil, err
	}
	resource, err := Parse(object.Data, c.Location())
	if err != nil {
		return rsvpClaims{}, Calendar{}, Object{}, nil, err
	}
	return claims, c, object, resource, nil
}

func (s *Service) Invitation(ctx context.Context, token string) (Invitation, error) {
	claims, _, _, resource, err := s.invitationTarget(ctx, token)
	if err != nil {
		return Invitation{}, err
	}
	return describeInvitation(resource, claims.Attendee)
}

func (s *Service) RespondToInvitation(ctx context.Context, token, partstat string) (Invitation, error) {
	partstat = strings.ToUpper(strings.TrimSpace(partstat))
	if partstat != PartstatAccepted && partstat != PartstatDeclined && partstat != PartstatTentative {
		return Invitation{}, apperr.Invalid("answer with ACCEPTED, DECLINED or TENTATIVE")
	}
	claims, c, object, resource, err := s.invitationTarget(ctx, token)
	if err != nil {
		return Invitation{}, err
	}
	found := false
	forEachAttendee(resource, claims.Attendee, func(attendee *ical.Prop) {
		attendee.Params.Set(ical.ParamParticipationStatus, partstat)
		attendee.Params.Set(paramScheduleStatus, statusReplied)
		found = true
	})
	if !found {
		return Invitation{}, apperr.NotFound("you are no longer invited to this event")
	}
	resource.MarkChanged()
	if _, err := s.save(ctx, c, object.URI, resource, object.ScheduleTag); err != nil {
		return Invitation{}, err
	}
	return describeInvitation(resource, claims.Attendee)
}

func describeInvitation(resource *Resource, attendee string) (Invitation, error) {
	primary := resource.Primary()
	timing, err := resource.timing(primary)
	if err != nil {
		return Invitation{}, err
	}
	invitation := Invitation{
		Summary: resource.Summary(), Location: propText(primary, ical.PropLocation), Attendee: strings.TrimPrefix(attendee, mailtoPrefix),
		Start: timing.start.Time, End: timing.start.Time.Add(timing.duration), AllDay: timing.start.AllDay,
		Status: PartstatNeedsAction, Cancelled: strings.EqualFold(propText(primary, ical.PropStatus), statusCancelled),
	}
	if organizer := organizerOf(resource); organizer != nil {
		invitation.Organizer = displayAddress(organizer)
	}
	forEachAttendee(resource, attendee, func(prop *ical.Prop) {
		if partstat := prop.Params.Get(ical.ParamParticipationStatus); partstat != "" {
			invitation.Status = strings.ToUpper(partstat)
		}
	})
	return invitation, nil
}

func displayAddress(prop *ical.Prop) string {
	address := strings.TrimPrefix(normalizeAddress(prop.Value), mailtoPrefix)
	if name := prop.Params.Get(ical.ParamCommonName); name != "" {
		return name + " <" + address + ">"
	}
	return address
}

func (s *Service) sendInvitationMail(ctx context.Context, owner users.User, message itipMessage, data []byte, objectID int64) error {
	address, isMail := strings.CutPrefix(normalizeAddress(message.recipient), mailtoPrefix)
	if !isMail || s.options.Mailer == nil || !s.options.Mailer.Configured() {
		return nil
	}
	return s.options.Mailer.Send(ctx, mail.Message{
		To:          address,
		ReplyTo:     owner.Profile.Email,
		Subject:     invitationSubject(owner, message),
		Text:        s.invitationText(owner, message, objectID),
		Calendar:    data,
		Method:      message.method,
		Attachments: []mail.Attachment{{ContentType: "application/ics", Filename: "invite.ics", Content: data}},
	})
}

func invitationSubject(owner users.User, message itipMessage) string {
	switch message.method {
	case methodCancel:
		return "Cancelled: " + message.summary
	case methodReply:
		return owner.ShownName() + " replied: " + message.summary
	}
	return "Invitation: " + message.summary
}

func (s *Service) invitationText(owner users.User, message itipMessage, objectID int64) string {
	var b strings.Builder
	b.WriteString(invitationSubject(owner, message) + "\n\n")
	if resource, err := FromCalendar(copyWithoutMethod(message.calendar), time.UTC); err == nil {
		if timing, err := resource.timing(resource.Primary()); err == nil {
			b.WriteString("When: " + describeTime(timing) + "\n")
		}
		if location := propText(resource.Primary(), ical.PropLocation); location != "" {
			b.WriteString("Where: " + location + "\n")
		}
	}
	b.WriteString("From: " + owner.ShownName() + "\n")
	if message.method == methodRequest && objectID > 0 && s.options.PublicURL != "" && len(s.options.RSVPKey) > 0 {
		token := s.rsvpToken(rsvpClaims{ObjectID: objectID, Attendee: message.recipient, UID: message.uid})
		b.WriteString("\nAnswer the invitation: " + strings.TrimSuffix(s.options.PublicURL, "/") + rsvpPath + token + "\n")
	}
	return b.String()
}

func describeTime(timing eventTiming) string {
	if timing.start.AllDay {
		return timing.start.Time.Format("Monday 2 January 2006") + " (all day)"
	}
	end := timing.start.Time.Add(timing.duration)
	return timing.start.Time.Format("Monday 2 January 2006 15:04 MST") + " – " + end.Format("15:04 MST")
}
