import "package:polder/services/features/feature_modes.dart";
import "package:polder_drive/services/background/background_session.dart";
import "package:polder_calendar/services/notifications/calendar_reminder_scheduler.dart";
import "package:polder_ui/services/notifications/device_localizations.dart";
import "package:polder_drive/services/notifications/notification_feed.dart";
import "package:polder_core/services/notifications/notification_preferences_store.dart";
import "package:polder_core/services/notifications/notification_service.dart";
import "package:polder_core/services/storage/credentials_store.dart";
import "package:polder_core/services/storage/preferences_store.dart";
import "package:polder/routes/app_routes.dart";

class NotificationCheckTask {
  const NotificationCheckTask({required this.credentials, required this.notifications, required this.store});

  final CredentialsStore credentials;
  final NotificationService notifications;
  final PreferencesStore store;

  Future<void> run() async {
    final modes = await FeatureModes.readResolved(store);
    final preferences = modes.restrict(await NotificationPreferencesStore.read(store));
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
      readPreferences: () async => preferences,
    ).poll();
    await CalendarReminderScheduler(
      api: session.api,
      notifications: notifications,
      strings: strings,
      sourceId: session.calendarSourceId,
      locations: AppRoutes.calendarLocations,
    ).reschedule(enabled: preferences.wantsCalendarReminders);
  }
}
