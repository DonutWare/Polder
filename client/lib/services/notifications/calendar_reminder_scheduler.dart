import "package:flutter/material.dart";

import "package:intl/intl.dart";
import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/notifications/calendar_reminder_planner.dart";
import "package:polder/services/notifications/local_notification.dart";
import "package:polder/services/notifications/notification_service.dart";

class CalendarReminderScheduler {
  CalendarReminderScheduler({
    required this._api,
    required this._notifications,
    required this._strings,
    required this._sourceId,
    this._clock = DateTime.now,
  });

  final PolderApi _api;
  final NotificationService _notifications;
  final AppLocalizations _strings;
  final String _sourceId;
  final DateTime Function() _clock;

  bool get supported => _notifications.capabilities.scheduling;

  Future<void> reschedule({required bool enabled}) async {
    if (!supported) return;
    final scheduled = (await _notifications.scheduledIds()).where(NotificationIds.isCalendar).toSet();
    final wanted = enabled ? await _plan() : const <int, PlannedReminder>{};
    for (final id in scheduled.difference(wanted.keys.toSet())) {
      await _notifications.cancel(id);
    }
    for (final MapEntry(key: id, value: reminder) in wanted.entries) {
      await _notifications.schedule(notificationFor(id, reminder), reminder.at);
    }
  }

  Future<Map<int, PlannedReminder>> _plan() async {
    final calendars = [
      for (final calendar in await _api.calendarInfos(_sourceId))
        if (calendar.notify) int.parse(calendar.ref.calendarId),
    ];
    if (calendars.isEmpty) return const {};
    final now = _clock();
    final range = DateTimeRange(
      start: now.subtract(const Duration(days: 1)),
      end: now.add(CalendarReminderPlanner.window),
    );
    final events = await _api.calendarEvents(_sourceId, range, calendarIds: calendars);
    return {
      for (final reminder in CalendarReminderPlanner.plan(events, now: now))
        NotificationIds.calendar(reminder.key): reminder,
    };
  }

  LocalNotification notificationFor(int id, PlannedReminder reminder) {
    final event = reminder.event;
    final time = DateFormat.Hm(_strings.localeName);
    final when = event.allDay
        ? _strings.notificationReminderAllDay
        : "${time.format(event.start)} – ${time.format(event.end)}";
    return LocalNotification(
      id: id,
      channel: NotificationChannel.calendar,
      title: event.summary,
      body: [when, if (event.location case final location? when location.isNotEmpty) location].join(" · "),
      location: AppRoutes.calendarEventAt(event.ref, event.start),
    );
  }
}
