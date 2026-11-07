import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:permission_handler/permission_handler.dart";
import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/models/notifications/notification_preferences.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/providers/sync/sync_platform_provider.dart";
import "package:polder/services/calendar/polder_calendar_source.dart";
import "package:polder/services/notifications/calendar_reminder_scheduler.dart";
import "package:polder/services/notifications/device_localizations.dart";
import "package:polder/services/notifications/noop_notification_service.dart";
import "package:polder/services/notifications/notification_feed.dart";
import "package:polder/services/notifications/notification_preferences_store.dart";
import "package:polder/services/notifications/notification_service.dart";

final notificationServiceProvider = Provider<NotificationService>((ref) => const NoopNotificationService());

final notificationStringsProvider = Provider<AppLocalizations>((ref) => deviceLocalizations());

final notificationPreferencesProvider = AsyncNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
  NotificationPreferencesNotifier.new,
);

class NotificationPreferencesNotifier extends AsyncNotifier<NotificationPreferences> {
  @override
  Future<NotificationPreferences> build() => NotificationPreferencesStore.read(ref.watch(preferencesStoreProvider));

  Future<bool> setEnabled(bool enabled) async {
    if (enabled && !await ref.read(notificationServiceProvider).requestPermission()) {
      ref.invalidate(notificationPermissionProvider);
      return false;
    }
    await _update((preferences) => preferences.copyWith(enabled: enabled));
    ref.invalidate(notificationPermissionProvider);
    return true;
  }

  Future<void> setShares(bool shares) => _update((preferences) => preferences.copyWith(shares: shares));

  Future<void> setCalendarReminders(bool reminders) =>
      _update((preferences) => preferences.copyWith(calendarReminders: reminders));

  Future<void> setUploadProgress(bool progress) =>
      _update((preferences) => preferences.copyWith(autoUploadProgress: progress));

  Future<void> setUploadSummary(bool summary) =>
      _update((preferences) => preferences.copyWith(autoUploadSummary: summary));

  Future<void> setUploadCheck(bool check) => _update((preferences) => preferences.copyWith(autoUploadCheck: check));

  Future<void> _update(NotificationPreferences Function(NotificationPreferences current) change) async {
    final next = change(state.value ?? await future);
    state = AsyncData(next);
    await NotificationPreferencesStore.write(ref.read(preferencesStoreProvider), next);
    await ref.read(syncPlatformProvider).scheduleNotificationChecks(enabled: next.enabled);
  }
}

final notificationPermissionProvider = FutureProvider.autoDispose<NotificationPermission>(
  (ref) => ref.watch(notificationServiceProvider).permission(),
);

final unrestrictedBackgroundProvider = FutureProvider.autoDispose<bool>((ref) async {
  if (!ref.watch(notificationServiceProvider).capabilities.batteryOptimization) return true;
  return Permission.ignoreBatteryOptimizations.isGranted;
});

final notificationFeedProvider = Provider<NotificationFeed?>((ref) {
  final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
  if (accountId == null) return null;
  return NotificationFeed(
    api: ref.watch(polderApiProvider),
    store: ref.watch(preferencesStoreProvider),
    notifications: ref.watch(notificationServiceProvider),
    strings: ref.watch(notificationStringsProvider),
    accountId: accountId,
  );
});

final calendarReminderSchedulerProvider = Provider<CalendarReminderScheduler?>((ref) {
  final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
  if (accountId == null) return null;
  return CalendarReminderScheduler(
    api: ref.watch(polderApiProvider),
    notifications: ref.watch(notificationServiceProvider),
    strings: ref.watch(notificationStringsProvider),
    sourceId: PolderCalendarSource.idFor(accountId),
  );
});
