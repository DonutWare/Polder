import "dart:async";

import "package:polder/models/offline_models.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/offline/content_downloader.dart";
import "package:polder/services/offline/content_store.dart";

class StreamingContentDownloader implements ContentDownloader {
  StreamingContentDownloader({required this._api, required this._content});

  static const reportEvery = 256 * 1024;

  final PolderApi _api;
  final OfflineContentStore _content;
  final _events = StreamController<ContentDownloadEvent>.broadcast();
  final _waiting = <String, OfflineFile>{};
  final _cancelled = <String>{};
  String? _running;
  Future<void>? _loop;

  @override
  Stream<ContentDownloadEvent> get events => _events.stream;

  @override
  Future<Set<String>> queued() async => {..._waiting.keys, ?_running};

  @override
  Future<void> enqueue(OfflineFile file) async {
    if (_running == file.path || _waiting.containsKey(file.path)) return;
    _cancelled.remove(file.path);
    _waiting[file.path] = file;
    _loop ??= _drain().whenComplete(() => _loop = null);
  }

  @override
  Future<void> cancel(String path) async {
    _waiting.remove(path);
    if (_running == path) _cancelled.add(path);
  }

  @override
  Future<void> clearLeftovers() async {}

  @override
  Future<void> dispose() async {
    _waiting.clear();
    await _events.close();
  }

  Future<void> _drain() async {
    while (_waiting.isNotEmpty && !_events.isClosed) {
      final file = _waiting.remove(_waiting.keys.first)!;
      _running = file.path;
      try {
        final hash = await _download(file);
        if (!_cancelled.remove(file.path)) _emit(ContentDownloadDone(file.path, hash: hash));
      } on Object catch (error) {
        _emit(ContentDownloadFailed(file.path, error));
      } finally {
        _running = null;
      }
    }
  }

  Future<String> _download(OfflineFile file) async {
    final total = file.entry.size;
    var received = 0;
    var reported = 0;
    _emit(ContentDownloadProgress(file.path, received: 0, total: total));
    final body = (await _api.downloadStream(file.path)).map((chunk) {
      if (_cancelled.contains(file.path)) throw StateError("cancelled");
      received += chunk.length;
      if (received - reported >= reportEvery || received >= total) {
        reported = received;
        _emit(ContentDownloadProgress(file.path, received: received, total: total));
      }
      return chunk;
    });
    return _content.writeStream(body);
  }

  void _emit(ContentDownloadEvent event) {
    if (!_events.isClosed) _events.add(event);
  }
}
