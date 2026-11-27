import "dart:async";

import "package:flutter/widgets.dart";

import "package:calendar_views/calendar_views.dart" as cal;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:polder_calendar/calendar_locations.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_calendar/services/notifications/calendar_reminder_scheduler.dart";
import "package:polder_core/services/notifications/local_notification.dart";
import "package:polder_core/models/calendar_reminder.dart";
import "package:polder_core/models/server_event.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder_core/providers/realtime/events_provider.dart";
import "package:polder_core/services/calendar/polder_calendar_source.dart";

final calendarReminderSchedulerProvider = Provider<CalendarReminderScheduler?>((ref) {
  final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
  if (accountId == null) return null;
  return CalendarReminderScheduler(
    api: ref.watch(polderApiProvider),
    notifications: ref.watch(notificationServiceProvider),
    strings: ref.watch(notificationStringsProvider),
    sourceId: PolderCalendarSource.idFor(accountId),
    locations: ref.watch(calendarLocationsProvider),
  );
});

final calendarReminderRefreshProvider = Provider<void>((ref) {
  final scheduler = ref.watch(calendarReminderSchedulerProvider);
  if (scheduler == null || !scheduler.supported) return;
  Timer? pending;
  void refresh({Duration delay = const Duration(seconds: 2)}) {
    pending?.cancel();
    pending = Timer(delay, () async {
      final preferences = await ref.read(deliveredNotificationPreferencesProvider.future);
      await scheduler.reschedule(enabled: preferences.wantsCalendarReminders).catchError((_) {});
    });
  }

  ref.listen(
    deliveredNotificationPreferencesProvider.select((preferences) => preferences.value?.wantsCalendarReminders),
    (_, _) => refresh(delay: Duration.zero),
  );
  ref.listen(cal.calendarChangesProvider, (_, _) => refresh());
  ref.listen(cal.calendarListProvider, (_, _) => refresh());
  final lifecycle = AppLifecycleListener(onResume: refresh);
  refresh(delay: Duration.zero);
  ref.onDispose(() {
    pending?.cancel();
    lifecycle.dispose();
  });
});

final liveCalendarReminderProvider = Provider<void>((ref) {
  final service = ref.watch(notificationServiceProvider);
  if (service.capabilities.scheduling) return;
  final userId = ref.watch(currentAccountProvider.select((account) => account?.user.id));
  final client = ref.watch(eventsClientProvider);
  if (userId == null || client == null) return;
  final strings = ref.watch(notificationStringsProvider);
  final subscription = client.events.listen((event) async {
    if (event case CalendarReminderEvent(userId: final owner, :final reminder) when owner == userId) {
      final preferences = await ref.read(deliveredNotificationPreferencesProvider.future);
      if (!preferences.wantsCalendarReminders) return;
      await service.show(
        _reminderNotification(
          reminder,
          strings.localeName,
          strings.notificationReminderAllDay,
          ref.read(calendarLocationsProvider),
        ),
      );
    }
  });
  ref.onDispose(subscription.cancel);
});

LocalNotification _reminderNotification(
  CalendarReminder reminder,
  String locale,
  String allDay,
  CalendarLocations locations,
) {
  final start = reminder.allDay
      ? DateTime(reminder.start.year, reminder.start.month, reminder.start.day)
      : reminder.start.toLocal();
  final time = DateFormat.Hm(locale);
  final when = reminder.allDay ? allDay : "${time.format(start)} – ${time.format(reminder.end.toLocal())}";
  final calendarRef = cal.CalendarRef(sourceId: "", calendarId: "${reminder.calendarId}");
  return LocalNotification(
    id: NotificationIds.calendar(
      "${reminder.calendarId}|${reminder.eventId}|${reminder.recurrenceId ?? ""}|${reminder.triggerAt.millisecondsSinceEpoch}",
    ),
    channel: NotificationChannel.calendar,
    title: reminder.summary,
    body: [when, if (reminder.location case final location? when location.isNotEmpty) location].join(" · "),
    location: locations.eventAt(
      cal.EventRef(calendar: calendarRef, eventId: "${reminder.eventId}", recurrenceId: reminder.recurrenceId),
      start,
    ),
  );
}
