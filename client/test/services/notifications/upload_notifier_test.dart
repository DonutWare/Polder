import "dart:async";
import "dart:ui";

import "package:fake_async/fake_async.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/models/notifications/notification_preferences.dart";
import "package:polder/models/sync/sync_status.dart";
import "package:polder/services/notifications/local_notification.dart";
import "package:polder/services/notifications/upload_notifier.dart";
import "package:polder/services/sync/sync_activity.dart";

import "../../support/fake_notification_service.dart";

LocalSyncItem uploading(String name, {int bytes = 0, int total = 100}) => LocalSyncItem(
  rootId: "camera",
  relativePath: "DCIM/$name",
  remotePath: "/Camera/$name",
  phase: LocalSyncPhase.uploading,
  bytes: bytes,
  total: total,
);

LocalSyncItem waiting(String name) => LocalSyncItem(
  rootId: "camera",
  relativePath: "DCIM/$name",
  remotePath: "/Camera/$name",
  phase: LocalSyncPhase.waiting,
);

void main() {
  final strings = lookupAppLocalizations(const Locale("en"));
  const everything = NotificationPreferences(enabled: true, autoUploadCheck: true);

  test("progress counts finished files and the one uploading now", () {
    final tally = UploadTally();
    tally.update({
      "a": uploading("a.jpg", bytes: 50),
      "b": waiting("b.jpg"),
      "c": waiting("c.jpg"),
      "d": waiting("d.jpg"),
    });
    final progress = tally.update({"b": uploading("b.jpg", bytes: 50), "c": waiting("c.jpg"), "d": waiting("d.jpg")});

    expect(progress.done, 1);
    expect(progress.total, 4);
    expect(progress.fraction, closeTo(1.5 / 4, 0.001));
    expect(progress.current, "b.jpg");
  });

  test("downloads are not counted as uploads", () {
    final tally = UploadTally();
    final progress = tally.update({
      "a": const LocalSyncItem(
        rootId: "camera",
        relativePath: "a.jpg",
        remotePath: "/a.jpg",
        phase: LocalSyncPhase.downloading,
        isDownload: true,
      ),
    });
    expect(progress.total, 0);
  });

  test("one live notification updates at most once per interval", () {
    fakeAsync((async) {
      final notifications = FakeNotificationService();
      final changes = StreamController<Map<String, LocalSyncItem>>();
      final notifier = UploadNotifier(
        notifications: notifications,
        preferences: everything,
        strings: strings,
        clock: () => DateTime(2026).add(async.elapsed),
      )..watch(changes.stream);

      changes.add({"a": uploading("a.jpg"), "b": waiting("b.jpg")});
      async.flushMicrotasks();
      changes.add({"a": uploading("a.jpg", bytes: 30), "b": waiting("b.jpg")});
      changes.add({"a": uploading("a.jpg", bytes: 60), "b": waiting("b.jpg")});
      async.flushMicrotasks();
      expect(notifications.shown, hasLength(1));

      async.elapse(const Duration(seconds: 1));
      expect(notifications.shown, hasLength(2));
      expect(notifications.shown.map((shown) => shown.id).toSet(), {NotificationIds.upload});
      final latest = notifications.shown.last;
      expect(latest.title, "Uploading 1 of 2");
      expect(latest.body, "a.jpg");
      expect(latest.ongoing, isTrue);
      expect(latest.progress, closeTo(0.3, 0.001));
      unawaited(changes.close());
      unawaited(notifier.finish(const SyncRunReport()));
      async.flushMicrotasks();
    });
  });

  test("the check notification makes way for progress, then a summary replaces both", () async {
    final notifications = FakeNotificationService();
    final changes = StreamController<Map<String, LocalSyncItem>>();
    final notifier = UploadNotifier(notifications: notifications, preferences: everything, strings: strings);

    await notifier.checking();
    notifier.watch(changes.stream);
    changes.add({"a": uploading("a.jpg")});
    await pumpEventQueue();
    await notifier.finish(const SyncRunReport(uploaded: 3, failed: 1));

    expect(notifications.shown.map((shown) => shown.id), [
      NotificationIds.uploadCheck,
      NotificationIds.upload,
      NotificationIds.upload,
    ]);
    expect(notifications.cancelled, containsAll([NotificationIds.uploadCheck, NotificationIds.upload]));
    final summary = notifications.shown.last;
    expect(summary.title, "1 file could not be uploaded");
    expect(summary.body, contains("3 files uploaded"));
    expect(summary.ongoing, isFalse);
    await changes.close();
  });

  test("nothing to report and turned-off topics stay quiet", () async {
    final notifications = FakeNotificationService();
    final quiet = UploadNotifier(notifications: notifications, preferences: everything, strings: strings);
    await quiet.finish(const SyncRunReport());

    final off = UploadNotifier(
      notifications: notifications,
      preferences: const NotificationPreferences(enabled: true, autoUploadProgress: false, autoUploadSummary: false),
      strings: strings,
    );
    await off.checking();
    final changes = StreamController<Map<String, LocalSyncItem>>();
    off.watch(changes.stream);
    changes.add({"a": uploading("a.jpg")});
    await pumpEventQueue();
    await off.finish(const SyncRunReport(uploaded: 2));

    expect(notifications.shown, isEmpty);
    await changes.close();
  });
}
