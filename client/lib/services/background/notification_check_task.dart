import "package:polder/services/background/background_session.dart";
import "package:polder/services/notifications/calendar_reminder_scheduler.dart";
import "package:polder/services/notifications/device_localizations.dart";
import "package:polder/services/notifications/notification_feed.dart";
import "package:polder/services/notifications/notification_preferences_store.dart";
import "package:polder/services/notifications/notification_service.dart";
import "package:polder/services/storage/credentials_store.dart";
import "package:polder/services/storage/preferences_store.dart";

class NotificationCheckTask {
  const NotificationCheckTask({required this.credentials, required this.notifications, required this.store});

  final CredentialsStore credentials;
  final NotificationService notifications;
  final PreferencesStore store;

  Future<void> run() async {
    final preferences = await NotificationPreferencesStore.read(store);
    if (!preferences.enabled) return;
    final session = await BackgroundSession.open(credentials);
    if (session == null) return;
    final strings = deviceLocalizations();
    await NotificationFeed(
      api: session.api,
      store: store,
      notifications: notifications,
      strings: strings,
      accountId: session.account.id,
    ).poll();
    await CalendarReminderScheduler(
      api: session.api,
      notifications: notifications,
      strings: strings,
      sourceId: session.calendarSourceId,
    ).reschedule(enabled: preferences.wantsCalendarReminders);
  }
}
