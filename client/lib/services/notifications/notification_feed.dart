import "dart:async";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/models/notifications/feed_notification.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/notifications/notification_preferences_store.dart";
import "package:polder/services/notifications/notification_service.dart";
import "package:polder/services/notifications/share_notifications.dart";
import "package:polder/services/storage/preferences_store.dart";

class NotificationFeed {
  NotificationFeed({
    required this._api,
    required this._store,
    required this._notifications,
    required this._strings,
    required String accountId,
  }) : _cursorKey = "polder.notifications.cursor.$accountId";

  static const _cursorField = "cursor";

  final PolderApi _api;
  final PreferencesStore _store;
  final NotificationService _notifications;
  final AppLocalizations _strings;
  final String _cursorKey;
  Future<void> _queue = Future.value();

  Future<void> poll() => _serially(_poll);

  Future<void> deliver(FeedNotification notification) => _serially(() async {
    final cursor = await _cursor();
    if (cursor == null || notification.id <= cursor) return;
    await _show(notification);
    await _saveCursor(notification.id);
  });

  Future<void> _serially(Future<void> Function() work) => _queue = _queue.then((_) => work()).catchError((_) {});

  Future<void> _poll() async {
    final cursor = await _cursor();
    if (cursor == null) return _saveCursor((await _api.notifications(after: -1)).cursor);
    var after = cursor;
    FeedPage page;
    do {
      page = await _api.notifications(after: after);
      for (final notification in page.notifications) {
        await _show(notification);
      }
      after = page.cursor;
      await _saveCursor(after);
    } while (page.hasMore && page.notifications.isNotEmpty);
  }

  Future<void> _show(FeedNotification notification) async {
    if (notification.read) return;
    final preferences = await NotificationPreferencesStore.read(_store);
    if (!preferences.wantsShares) return;
    if (ShareNotifications.build(notification, _strings) case final local?) await _notifications.show(local);
  }

  Future<int?> _cursor() async => (await _store.readJson(_cursorKey))?[_cursorField] as int?;

  Future<void> _saveCursor(int cursor) => _store.writeJson(_cursorKey, {_cursorField: cursor});
}
