import "dart:ui";

import "package:flutter_test/flutter_test.dart";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/models/notifications/feed_notification.dart";
import "package:polder/models/notifications/notification_preferences.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/notifications/local_notification.dart";
import "package:polder/services/notifications/notification_feed.dart";
import "package:polder/services/notifications/notification_preferences_store.dart";
import "package:polder/services/storage/preferences_store.dart";

import "../../support/fake_notification_service.dart";
import "../../support/scripted_client.dart";

Map<String, dynamic> shareJson(int id, {bool read = false, String kind = "share.received", String? group}) => {
  "id": id,
  "kind": kind,
  "createdAt": "2026-11-06T09:00:00Z",
  "read": read,
  "share": {
    "shareId": 40 + id,
    "ownerName": "Bob",
    "owner": "bob",
    "name": "Photos",
    "isDir": true,
    "group": ?group,
    if (kind == "federated_share.received") "server": "cloud.example.com",
  },
};

void main() {
  final strings = lookupAppLocalizations(const Locale("en"));
  late InMemoryPreferencesStore store;
  late FakeNotificationService notifications;
  late List<Map<String, dynamic>> pending;
  late ScriptedClient client;
  late NotificationFeed feed;

  setUp(() async {
    store = InMemoryPreferencesStore();
    await NotificationPreferencesStore.write(store, const NotificationPreferences(enabled: true));
    notifications = FakeNotificationService();
    pending = [];
    client = ScriptedClient((request) async {
      final after = int.parse(request.query["after"]!);
      if (after < 0) return jsonResponse(200, {"notifications": <Object>[], "cursor": 10, "hasMore": false});
      final page = [
        for (final item in pending)
          if (item["id"] as int > after) item,
      ];
      return jsonResponse(200, {
        "notifications": page,
        "cursor": page.isEmpty ? after : page.last["id"],
        "hasMore": false,
      });
    });
    feed = NotificationFeed(
      api: PolderApi(ApiClientFactory.create("https://cloud.test", httpClient: client)),
      store: store,
      notifications: notifications,
      strings: strings,
      accountId: "alice",
    );
  });

  test("the first check only remembers where the feed is", () async {
    pending = [shareJson(3)];
    await feed.poll();

    expect(client.requests.single.query["after"], "-1");
    expect(notifications.shown, isEmpty);
  });

  test("later checks show what is new and move the cursor past it", () async {
    await feed.poll();
    pending = [shareJson(11), shareJson(12, read: true), shareJson(13, group: "Family")];
    await feed.poll();
    await feed.poll();

    expect(client.requests.map((request) => request.query["after"]), ["-1", "10", "13"]);
    expect(notifications.shown.map((shown) => shown.title), [
      "Bob shared Photos with you",
      "Bob shared Photos with Family",
    ]);
    final first = notifications.shown.first;
    expect(first.id, NotificationIds.feed(11));
    expect(first.location, AppRoutes.sharedAt(51));
    expect(first.actions.map((action) => action.id), [NotificationActionId.accept, NotificationActionId.decline]);
    expect(first.data, {"shareId": 51, "federated": false});
  });

  test("federated shares name the server and open the other-servers list", () async {
    await feed.poll();
    pending = [shareJson(11, kind: "federated_share.received")];
    await feed.poll();

    final shown = notifications.shown.single;
    expect(shown.body, "From cloud.example.com");
    expect(shown.location, AppRoutes.sharedSection(SharedSection.federated.segment));
    expect(shown.data["federated"], isTrue);
  });

  test("live notifications show once, and only when newer than the cursor", () async {
    await feed.poll();
    const share = ShareNotice(shareId: 51, ownerName: "Bob", owner: "bob", name: "Photos");
    FeedNotification live(int id) => FeedNotification(
      id: id,
      kind: FeedNotificationKind.shareReceived,
      createdAt: DateTime(2026, 11, 6),
      share: share,
    );

    await feed.deliver(live(9));
    await feed.deliver(live(11));
    await feed.deliver(live(11));
    pending = [shareJson(11)];
    await feed.poll();

    expect(notifications.shown.map((shown) => shown.id), [NotificationIds.feed(11)]);
  });

  test("turning share notifications off still moves the cursor", () async {
    await feed.poll();
    await NotificationPreferencesStore.write(store, const NotificationPreferences(enabled: true, shares: false));
    pending = [shareJson(11)];
    await feed.poll();
    await NotificationPreferencesStore.write(store, const NotificationPreferences(enabled: true));
    await feed.poll();

    expect(notifications.shown, isEmpty);
    expect(client.requests.last.query["after"], "11");
  });
}
