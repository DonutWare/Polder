import "dart:async";
import "dart:convert";
import "dart:io";

import "package:background_downloader/background_downloader.dart";
import "package:crypto/crypto.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "package:polder/models/offline_models.dart";
import "package:polder/services/offline/content_downloader.dart";
import "package:polder/services/offline/content_store.dart";
import "package:polder/services/offline/file_content_store.dart";

class BackgroundContentDownloader implements ContentDownloader {
  BackgroundContentDownloader({
    required String accountKey,
    required this._content,
    required this._requestFor,
    required DownloadNotificationTexts texts,
  }) : _group = "offline_$accountKey" {
    _downloader.configureNotificationForGroup(
      _group,
      running: TaskNotification(texts.runningTitle, texts.runningBody),
      complete: TaskNotification(texts.doneTitle, texts.doneBody),
      error: TaskNotification(texts.failedTitle, texts.failedBody),
      progressBar: true,
      groupNotificationId: _group,
    );
    _subscription = _updates.where((update) => update.task.group == _group).listen(_onUpdate);
  }

  static const directory = "offline_downloads";
  static const reserveMegabytes = 1024;

  static final _downloader = FileDownloader();
  static final Stream<TaskUpdate> _updates = _downloader.updates.asBroadcastStream();
  static final Future<void> _ready = _start();
  static var _askedForNotifications = false;

  final String _group;
  final FileContentStore _content;
  final Future<DownloadRequest> Function(String path) _requestFor;
  final _events = StreamController<ContentDownloadEvent>.broadcast();
  late final StreamSubscription<TaskUpdate> _subscription;

  @override
  Stream<ContentDownloadEvent> get events => _events.stream;

  @override
  Future<Set<String>> queued() async {
    await _ready;
    return {for (final task in await _downloader.allTasks(group: _group)) task.metaData};
  }

  @override
  Future<void> enqueue(OfflineFile file) async {
    await _ready;
    _askForNotificationsOnce();
    final request = await _requestFor(file.path);
    await _downloader.enqueue(
      DownloadTask(
        taskId: _taskIdFor(file.path),
        url: request.url.toString(),
        headers: request.headers,
        filename: _taskIdFor(file.path),
        directory: directory,
        baseDirectory: BaseDirectory.applicationSupport,
        group: _group,
        updates: Updates.statusAndProgress,
        retries: 3,
        allowPause: true,
        displayName: file.entry.name,
        metaData: file.path,
      ),
    );
  }

  @override
  Future<void> cancel(String path) async {
    await _ready;
    await _downloader.cancelTaskWithId(_taskIdFor(path));
  }

  @override
  Future<void> clearLeftovers() async {
    if ((await queued()).isNotEmpty) return;
    final folder = Directory(p.join((await getApplicationSupportDirectory()).path, directory));
    if (!await folder.exists()) return;
    await for (final entity in folder.list()) {
      if (entity is File) await entity.delete();
    }
  }

  @override
  Future<void> dispose() async {
    await _subscription.cancel();
    await _events.close();
  }

  static Future<void> _start() async {
    await _downloader.configure(globalConfig: (Config.checkAvailableSpace, reserveMegabytes));
    await _downloader.start(autoCleanDatabase: true);
  }

  static void _askForNotificationsOnce() {
    if (_askedForNotifications) return;
    _askedForNotifications = true;
    final permissions = _downloader.permissions;
    unawaited(
      permissions.status(PermissionType.notifications).then((status) async {
        if (status != PermissionStatus.granted) await permissions.request(PermissionType.notifications);
      }, onError: (Object _) {}),
    );
  }

  String _taskIdFor(String path) => sha1.convert(utf8.encode("$_group:$path")).toString();

  Future<void> _onUpdate(TaskUpdate update) async {
    final path = update.task.metaData;
    switch (update) {
      case TaskProgressUpdate(:final progress, :final expectedFileSize) when progress >= 0:
        _emit(
          ContentDownloadProgress(
            path,
            received: expectedFileSize > 0 ? (progress * expectedFileSize).round() : 0,
            total: expectedFileSize,
            fraction: progress,
          ),
        );
      case TaskStatusUpdate(status: TaskStatus.complete):
        try {
          _emit(ContentDownloadDone(path, hash: await _content.adopt(await update.task.filePath())));
        } on Object catch (error) {
          _emit(ContentDownloadFailed(path, error));
        }
      case TaskStatusUpdate(:final status, :final exception) when status.isFinalState:
        _emit(ContentDownloadFailed(path, _failureOf(exception) ?? status));
      case _:
        break;
    }
  }

  static Object? _failureOf(TaskException? exception) => switch (exception) {
    TaskFileSystemException(:final description) when description.toLowerCase().contains("space") =>
      DeviceStorageFullException(description),
    _ => exception,
  };

  void _emit(ContentDownloadEvent event) {
    if (!_events.isClosed) _events.add(event);
  }
}
