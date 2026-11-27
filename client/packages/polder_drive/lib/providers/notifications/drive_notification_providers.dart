import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_core/models/server_event.dart";
import "package:polder_core/models/sync/sync_status.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder_core/providers/realtime/events_provider.dart";
import "package:polder_core/services/notifications/local_notification.dart";
import "package:polder_core/services/realtime/events_client.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";

import "package:polder_drive/providers/notifications/notification_feed_provider.dart";
import "package:polder_drive/providers/sharing/shares_provider.dart";
import "package:polder_drive/providers/sync/sync_activity_provider.dart";
import "package:polder_drive/providers/sync/sync_platform_provider.dart";
import "package:polder_drive/providers/sync/sync_status_provider.dart";
import "package:polder_drive/services/notifications/share_notifications.dart";
import "package:polder_drive/services/notifications/upload_notifier.dart";

Future<bool> respondToShareTap(Ref ref, NotificationTap tap) async {
  if (!ShareNotifications.handles(tap)) return false;
  await ShareNotifications.respond(ref.read(polderApiProvider), tap);
  invalidateShares(ref.invalidate);
  return true;
}

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
      final preferences = await ref.read(deliveredNotificationPreferencesProvider.future);
      notifier = UploadNotifier(notifications: service, preferences: preferences, strings: strings)
        ..watch(activity.changes);
    } else if (stopped) {
      await notifier?.finish(next.lastReport);
      notifier = null;
    }
  });
});
