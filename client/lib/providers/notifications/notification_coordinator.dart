import "dart:async";

import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:polder/models/calendar_reminder.dart";
import "package:polder/models/server_event.dart";
import "package:polder/models/sync/sync_status.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/notifications/notification_providers.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/realtime/events_provider.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/providers/sync/sync_activity_provider.dart";
import "package:polder/providers/sync/sync_platform_provider.dart";
import "package:polder/providers/sync/sync_status_provider.dart";
import "package:polder/routes/app_router.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/services/notifications/local_notification.dart";
import "package:polder/services/notifications/share_notifications.dart";
import "package:polder/services/notifications/upload_notifier.dart";
import "package:polder/services/realtime/events_client.dart";
import "package:polder_calendar/polder_calendar.dart" as cal;

final notificationCoordinatorProvider = Provider<void>((ref) {
  ref.watch(notificationTapHandlerProvider);
  ref.watch(notificationFeedListenerProvider);
  ref.watch(calendarReminderRefreshProvider);
  ref.watch(liveCalendarReminderProvider);
  ref.watch(foregroundUploadNotifierProvider);
  ref.listen(notificationPreferencesProvider.select((preferences) => preferences.value?.enabled), (_, enabled) {
    if (enabled != null) unawaited(ref.read(syncPlatformProvider).scheduleNotificationChecks(enabled: enabled));
  }, fireImmediately: true);
});

final notificationTapHandlerProvider = Provider<void>((ref) {
  final service = ref.watch(notificationServiceProvider);
  Future<void> handle(NotificationTap tap) async {
    if (ShareNotifications.handles(tap)) {
      await ShareNotifications.respond(ref.read(polderApiProvider), tap);
      invalidateShares(ref.invalidate);
      return;
    }
    if (tap.location case final location?) ref.read(routerProvider).go(location);
  }

  final subscription = service.taps.listen((tap) => unawaited(handle(tap).catchError((_) {})));
  unawaited(service.launchTap().then((tap) => tap == null ? null : handle(tap)).catchError((_) {}));
  ref.onDispose(subscription.cancel);
});

final notificationFeedListenerProvider = Provider<void>((ref) {
  final feed = ref.watch(notificationFeedProvider);
  final userId = ref.watch(currentAccountProvider.select((account) => account?.user.id));
  final client = ref.watch(eventsClientProvider);
  if (feed == null || userId == null || client == null) return;
  final events = client.events.listen((event) {
    if (event case NotificationEvent(userId: final owner, :final notification) when owner == userId) {
      unawaited(feed.deliver(notification));
    }
  });
  final statuses = client.statusChanges.listen((status) {
    if (status == RealtimeStatus.connected) unawaited(feed.poll());
  });
  unawaited(feed.poll());
  ref.onDispose(() {
    unawaited(events.cancel());
    unawaited(statuses.cancel());
  });
});

final calendarReminderRefreshProvider = Provider<void>((ref) {
  final scheduler = ref.watch(calendarReminderSchedulerProvider);
  if (scheduler == null || !scheduler.supported) return;
  Timer? pending;
  void refresh({Duration delay = const Duration(seconds: 2)}) {
    pending?.cancel();
    pending = Timer(delay, () async {
      final preferences = await ref.read(notificationPreferencesProvider.future);
      await scheduler.reschedule(enabled: preferences.wantsCalendarReminders).catchError((_) {});
    });
  }

  ref.listen(
    notificationPreferencesProvider.select((preferences) => preferences.value?.wantsCalendarReminders),
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
      final preferences = await ref.read(notificationPreferencesProvider.future);
      if (!preferences.wantsCalendarReminders) return;
      await service.show(_reminderNotification(reminder, strings.localeName, strings.notificationReminderAllDay));
    }
  });
  ref.onDispose(subscription.cancel);
});

LocalNotification _reminderNotification(CalendarReminder reminder, String locale, String allDay) {
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
    location: AppRoutes.calendarEventAt(
      cal.EventRef(calendar: calendarRef, eventId: "${reminder.eventId}", recurrenceId: reminder.recurrenceId),
      start,
    ),
  );
}

final foregroundUploadNotifierProvider = Provider<void>((ref) {
  if (!ref.watch(syncPlatformProvider).supportsAutoUpload) return;
  final service = ref.watch(notificationServiceProvider);
  final strings = ref.watch(notificationStringsProvider);
  final activity = ref.watch(syncActivityProvider);
  UploadNotifier? notifier;
  ref.listen<SyncStatus>(syncStatusProvider, (previous, next) async {
    final started = next.isSyncing && !(previous?.isSyncing ?? false);
    final stopped = !next.isSyncing && (previous?.isSyncing ?? false);
    if (started) {
      final preferences = await ref.read(notificationPreferencesProvider.future);
      notifier = UploadNotifier(notifications: service, preferences: preferences, strings: strings)
        ..watch(activity.changes);
    } else if (stopped) {
      await notifier?.finish(next.lastReport);
      notifier = null;
    }
  });
});
