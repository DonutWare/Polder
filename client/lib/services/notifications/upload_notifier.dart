import "dart:async";

import "package:path/path.dart" as p;
import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/models/notifications/notification_preferences.dart";
import "package:polder/models/sync/sync_status.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/services/notifications/local_notification.dart";
import "package:polder/services/notifications/notification_service.dart";
import "package:polder/services/sync/sync_activity.dart";

class UploadProgress {
  const UploadProgress({required this.done, required this.total, required this.fraction, this.current});

  final int done;
  final int total;
  final double fraction;
  final String? current;
}

class UploadTally {
  final _seen = <String>{};
  var _finished = 0;
  Map<String, LocalSyncItem> _active = const {};

  bool get isEmpty => _seen.isEmpty;

  UploadProgress update(Map<String, LocalSyncItem> items) {
    final active = {
      for (final MapEntry(:key, :value) in items.entries)
        if (!value.isDownload) key: value,
    };
    _finished += _active.keys.where((key) => !active.containsKey(key)).length;
    _seen.addAll(active.keys);
    _active = active;
    return progress;
  }

  UploadProgress get progress {
    final total = _seen.length;
    final running = _active.values.fold(0.0, (sum, item) => sum + (item.progress ?? 0));
    final current = _active.values.where((item) => item.phase == LocalSyncPhase.uploading).firstOrNull;
    return UploadProgress(
      done: _finished.clamp(0, total),
      total: total,
      fraction: total == 0 ? 0 : ((_finished + running) / total).clamp(0.0, 1.0),
      current: current == null ? null : p.basename(current.relativePath),
    );
  }
}

class UploadNotifier {
  UploadNotifier({
    required this._notifications,
    required this._preferences,
    required this._strings,
    this.interval = const Duration(seconds: 1),
    this._clock = DateTime.now,
  });

  final NotificationService _notifications;
  final NotificationPreferences _preferences;
  final AppLocalizations _strings;
  final DateTime Function() _clock;
  final Duration interval;
  final _tally = UploadTally();
  StreamSubscription<Map<String, LocalSyncItem>>? _subscription;
  DateTime? _shownAt;
  Timer? _trailing;
  var _checking = false;

  Future<void> checking() async {
    if (!_preferences.wantsUploadCheck) return;
    _checking = true;
    await _notifications.show(
      LocalNotification(
        id: NotificationIds.uploadCheck,
        channel: NotificationChannel.uploads,
        title: _strings.notificationUploadChecking,
        location: AppRoutes.autoUpload,
        progress: -1,
        ongoing: true,
        silent: true,
      ),
    );
  }

  void watch(Stream<Map<String, LocalSyncItem>> changes) {
    unawaited(_subscription?.cancel());
    _subscription = changes.listen(_changed);
  }

  void _changed(Map<String, LocalSyncItem> items) {
    final progress = _tally.update(items);
    if (!_preferences.wantsUploadProgress || progress.total == 0) return;
    final now = _clock();
    final since = _shownAt == null ? null : now.difference(_shownAt!);
    if (since == null || since >= interval) {
      _trailing?.cancel();
      unawaited(_showProgress(progress));
      return;
    }
    _trailing ??= Timer(interval - since, () {
      _trailing = null;
      unawaited(_showProgress(_tally.progress));
    });
  }

  Future<void> _showProgress(UploadProgress progress) async {
    _shownAt = _clock();
    if (_checking) {
      _checking = false;
      await _notifications.cancel(NotificationIds.uploadCheck);
    }
    await _notifications.show(
      LocalNotification(
        id: NotificationIds.upload,
        channel: NotificationChannel.uploads,
        title: _strings.notificationUploadingTitle((progress.done + 1).clamp(1, progress.total), progress.total),
        body: progress.current ?? "",
        location: AppRoutes.autoUpload,
        progress: progress.fraction,
        ongoing: true,
        silent: true,
      ),
    );
  }

  Future<void> finish(SyncRunReport report) async {
    await _subscription?.cancel();
    _subscription = null;
    _trailing?.cancel();
    _trailing = null;
    await _notifications.cancel(NotificationIds.uploadCheck);
    await _notifications.cancel(NotificationIds.upload);
    final summary = summaryFor(report);
    if (summary != null) await _notifications.show(summary);
  }

  LocalNotification? summaryFor(SyncRunReport report) {
    if (!_preferences.wantsUploadSummary || (report.uploaded == 0 && report.failed == 0)) return null;
    final failed = report.failed > 0;
    return LocalNotification(
      id: NotificationIds.upload,
      channel: NotificationChannel.uploads,
      title: failed
          ? _strings.notificationUploadFailed(report.failed)
          : _strings.notificationUploadDone(report.uploaded),
      body: failed
          ? [
              if (report.uploaded > 0) _strings.notificationUploadDone(report.uploaded),
              _strings.notificationUploadFailedBody,
            ].join("\n")
          : "",
      location: AppRoutes.autoUpload,
      silent: !failed,
    );
  }
}
