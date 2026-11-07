import "package:polder/models/branding.dart";
import "package:polder/models/calendar.dart";
import "package:polder/models/sharing.dart";
import "package:polder/services/api/generated/polder.swagger.dart" as wire;
import "package:polder/services/api/sharing_mappers.dart";
import "package:polder_calendar/polder_calendar.dart" as cal;

extension CalendarToModel on wire.Calendar {
  CalendarSummary toModel() => CalendarSummary(
    id: id,
    uri: uri,
    name: name,
    color: parseHexColor(color),
    access: switch (access) {
      wire.CalendarAccess.owner => CalendarAccess.owner,
      wire.CalendarAccess.readwrite => CalendarAccess.readWrite,
      wire.CalendarAccess.freebusy => CalendarAccess.freeBusy,
      _ => CalendarAccess.read,
    },
    subscription: kind == wire.CalendarKind.subscription,
    ownerName: owner?.displayName,
  );
}

extension FeedToModel on wire.Feed {
  CalendarFeed toModel() => CalendarFeed(
    id: id,
    calendarId: calendarId,
    name: name,
    mode: mode == wire.FeedMode.busy ? CalendarFeedMode.busy : CalendarFeedMode.full,
    createdAt: createdAt.toLocal(),
    lastUsedAt: lastUsedAt?.toLocal(),
  );

  CreatedCalendarFeed toCreated() => CreatedCalendarFeed(feed: toModel(), url: url ?? "");
}

extension CalendarFeedModeToWire on CalendarFeedMode {
  wire.NewFeedMode toWire() => switch (this) {
    CalendarFeedMode.full => wire.NewFeedMode.full,
    CalendarFeedMode.busy => wire.NewFeedMode.busy,
  };
}

extension CalendarToInfo on wire.Calendar {
  cal.CalendarInfo toInfo(String sourceId) => cal.CalendarInfo(
    ref: cal.CalendarRef(sourceId: sourceId, calendarId: "$id"),
    name: name,
    color: parseHexColor(color),
    access: switch (access) {
      wire.CalendarAccess.owner => cal.CalendarAccess.owner,
      wire.CalendarAccess.readwrite => cal.CalendarAccess.readWrite,
      wire.CalendarAccess.freebusy => cal.CalendarAccess.freeBusy,
      _ => cal.CalendarAccess.read,
    },
    hidden: hidden,
    notify: notify,
    isDefault: isDefault,
    subscription: kind == wire.CalendarKind.subscription,
    ownerName: owner?.displayName,
    sourceUrl: sourceUrl,
    fetchedAt: fetchedAt?.toLocal(),
    fetchError: fetchError == null || fetchError!.isEmpty ? null : fetchError,
  );
}

extension CalendarShareToModel on wire.CalendarShare {
  CalendarShare toModel() => CalendarShare(
    id: id,
    calendarId: calendarId,
    recipient: group != null
        ? ShareTarget(kind: ShareTargetKind.group, id: group!.id, name: group!.name)
        : user!.toModel(),
    access: switch (access) {
      wire.CalendarShareAccess.readwrite => CalendarShareAccess.readWrite,
      wire.CalendarShareAccess.freebusy => CalendarShareAccess.freeBusy,
      _ => CalendarShareAccess.read,
    },
  );
}

extension ImportResultToModel on wire.ImportResult {
  CalendarImportResult toModel() =>
      CalendarImportResult(created: created, updated: updated, skipped: skipped, errors: errors ?? const []);
}

extension CalendarShareAccessToWire on CalendarShareAccess {
  wire.NewCalendarShareAccess toWire() => switch (this) {
    CalendarShareAccess.freeBusy => wire.NewCalendarShareAccess.freebusy,
    CalendarShareAccess.readWrite => wire.NewCalendarShareAccess.readwrite,
    CalendarShareAccess.read => wire.NewCalendarShareAccess.read,
  };

  wire.UpdateCalendarShareInputBodyAccess toUpdateWire() => switch (this) {
    CalendarShareAccess.freeBusy => wire.UpdateCalendarShareInputBodyAccess.freebusy,
    CalendarShareAccess.readWrite => wire.UpdateCalendarShareInputBodyAccess.readwrite,
    CalendarShareAccess.read => wire.UpdateCalendarShareInputBodyAccess.read,
  };
}

extension EventToModel on wire.Event {
  cal.CalendarEvent toModel(String sourceId) => cal.CalendarEvent(
    ref: cal.EventRef(
      calendar: cal.CalendarRef(sourceId: sourceId, calendarId: "$calendarId"),
      eventId: "$id",
      recurrenceId: recurrenceId,
    ),
    etag: etag,
    summary: summary,
    start: allDay ? DateTime(start.year, start.month, start.day) : start.toLocal(),
    end: allDay ? DateTime(end.year, end.month, end.day) : end.toLocal(),
    allDay: allDay,
    description: description,
    location: location,
    url: url,
    timezone: timezone,
    rrule: rrule,
    recurring: recurring,
    modifiedOccurrence: $override,
    status: _status(status),
    showAs: showAs == wire.EventShowAs.free ? cal.EventShowAs.free : cal.EventShowAs.busy,
    busyOnly: busyOnly,
    organizer: organizer?.toModel(),
    attendees: [for (final attendee in attendees ?? const <wire.Attendee>[]) attendee.toModel()],
    reminders: [for (final alarm in alarms ?? const <wire.Alarm>[]) alarm.toModel()],
  );
}

extension EventDetailsToModel on wire.EventDetails {
  cal.CalendarEventDetails toModel(String sourceId) => cal.CalendarEventDetails(
    series: wire.Event.fromJson(toJson()).toModel(sourceId),
    overrides: [for (final event in overrides ?? const <wire.Event>[]) event.toModel(sourceId)],
  );
}

extension on wire.Person {
  cal.EventPerson toModel() => cal.EventPerson(email: email, name: name, self: self);
}

extension on wire.Attendee {
  cal.EventAttendee toModel() => cal.EventAttendee(
    person: cal.EventPerson(email: email, name: name, self: self),
    status: switch (status) {
      "ACCEPTED" => cal.AttendeeStatus.accepted,
      "DECLINED" => cal.AttendeeStatus.declined,
      "TENTATIVE" => cal.AttendeeStatus.tentative,
      "DELEGATED" => cal.AttendeeStatus.delegated,
      _ => cal.AttendeeStatus.needsAction,
    },
    role: switch (role) {
      "CHAIR" => cal.AttendeeRole.chair,
      "OPT-PARTICIPANT" => cal.AttendeeRole.optional,
      "NON-PARTICIPANT" => cal.AttendeeRole.nonParticipant,
      _ => cal.AttendeeRole.required,
    },
  );
}

extension on wire.Alarm {
  cal.EventReminder toModel() => cal.EventReminder(
    action: switch (action) {
      "EMAIL" => cal.ReminderAction.email,
      "AUDIO" => cal.ReminderAction.audio,
      _ => cal.ReminderAction.display,
    },
    offsetMinutes: offsetMinutes,
    relativeToEnd: relativeToEnd ?? false,
    at: at?.toLocal(),
  );
}

cal.EventStatus _status(String status) => switch (status) {
  "TENTATIVE" => cal.EventStatus.tentative,
  "CANCELLED" => cal.EventStatus.cancelled,
  _ => cal.EventStatus.confirmed,
};

extension EventDraftToWire on cal.EventDraft {
  wire.EventInput toWire() => wire.EventInput(
    summary: summary,
    start: allDay ? DateTime.utc(start.year, start.month, start.day) : start.toUtc(),
    end: allDay ? DateTime.utc(end.year, end.month, end.day) : end.toUtc(),
    allDay: allDay,
    description: description,
    location: location,
    url: url,
    timezone: timezone,
    rrule: rrule,
    status: status.name.toUpperCase(),
    showAs: showAs == cal.EventShowAs.free ? wire.EventInputShowAs.free : wire.EventInputShowAs.busy,
    attendees: [for (final person in attendees) wire.AttendeeInput(email: person.email, name: person.name)],
    alarms: [
      for (final reminder in reminders)
        wire.Alarm(
          action: reminder.action.name.toUpperCase(),
          offsetMinutes: reminder.offsetMinutes,
          relativeToEnd: reminder.relativeToEnd,
          at: reminder.at?.toUtc(),
        ),
    ],
  );
}

extension AttendeeStatusToWire on cal.AttendeeStatus {
  String toWire() => switch (this) {
    cal.AttendeeStatus.needsAction => "NEEDS-ACTION",
    cal.AttendeeStatus.accepted => "ACCEPTED",
    cal.AttendeeStatus.declined => "DECLINED",
    cal.AttendeeStatus.tentative => "TENTATIVE",
    cal.AttendeeStatus.delegated => "DELEGATED",
  };
}
