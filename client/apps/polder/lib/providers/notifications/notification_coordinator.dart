import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_core/models/notifications/notification_preferences.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_drive/providers/sync/sync_platform_provider.dart";
import "package:polder/routes/app_router.dart";
import "package:polder_core/services/notifications/local_notification.dart";
import "package:polder_calendar/providers/calendar/calendar_reminder_providers.dart";
import "package:polder_drive/providers/notifications/drive_notification_providers.dart";

final notificationCoordinatorProvider = Provider<void>((ref) {
  ref.watch(notificationTapHandlerProvider);
  ref.watch(notificationFeedListenerProvider);
  ref.watch(calendarReminderRefreshProvider);
  ref.watch(liveCalendarReminderProvider);
  ref.watch(foregroundUploadNotifierProvider);
  ref.listen(deliveredNotificationPreferencesProvider.select((preferences) => preferences.value?.needsChecks), (
    _,
    enabled,
  ) {
    if (enabled != null) unawaited(ref.read(syncPlatformProvider).scheduleNotificationChecks(enabled: enabled));
  }, fireImmediately: true);
});

final notificationTapHandlerProvider = Provider<void>((ref) {
  final service = ref.watch(notificationServiceProvider);
  Future<void> handle(NotificationTap tap) async {
    if (await respondToShareTap(ref, tap)) return;
    if (tap.location case final location?) ref.read(routerProvider).go(location);
  }

  final subscription = service.taps.listen((tap) => unawaited(handle(tap).catchError((_) {})));
  unawaited(service.launchTap().then((tap) => tap == null ? null : handle(tap)).catchError((_) {}));
  ref.onDispose(subscription.cancel);
});

extension on NotificationPreferences {
  bool get needsChecks => wantsShares || wantsCalendarReminders;
}
