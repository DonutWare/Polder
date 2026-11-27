import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_drive/services/notifications/notification_feed.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder_core/providers/service_providers.dart";

final notificationFeedProvider = Provider<NotificationFeed?>((ref) {
  final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
  if (accountId == null) return null;
  return NotificationFeed(
    api: ref.watch(polderApiProvider),
    store: ref.watch(preferencesStoreProvider),
    notifications: ref.watch(notificationServiceProvider),
    strings: ref.watch(notificationStringsProvider),
    accountId: accountId,
    readPreferences: () => ref.read(deliveredNotificationPreferencesProvider.future),
  );
});
