import "dart:math";
import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/file_version.dart";
import "package:polder/models/server_log.dart";
import "package:polder/models/transfer.dart";
import "package:polder/models/trash.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/providers/sync/sync_scheduler_provider.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/transfer/file_picker_service.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/util/throughput_meter.dart";

final transfersProvider = NotifierProvider<TransfersNotifier, List<Transfer>>(TransfersNotifier.new);

class TransfersNotifier extends Notifier<List<Transfer>> {
  /// Progress arrives for every few KB sent; rebuilding the transfer list that often makes the UI sluggish.
  static const progressInterval = Duration(milliseconds: 100);

  var _nextId = 0;
  final _random = Random.secure();
  final Map<int, Stopwatch> _sinceProgress = {};
  final Map<int, ThroughputMeter> _meters = {};

  @override
  List<Transfer> build() => const [];

  Future<void> pickAndUpload(String directory) async {
    final files = await ref.read(filePickerServiceProvider).pickFiles();
    await Future.wait(files.map((file) => upload(directory, file)));
  }

  Future<void> upload(String directory, PickedFile file) async {
    final length = await file.length() ?? 0;
    final remotePath = RemotePath.join(directory, file.name);
    final transfer = _start(file.name, TransferDirection.upload, length, remotePath: remotePath);
    await _track(transfer, () async {
      await ref
          .read(polderApiProvider)
          .putContent(
            remotePath,
            file.openRead(),
            length: length,
            transferId: transfer.clientId,
            onProgress: (sent, total) => _progress(transfer.id, sent, total),
          );
      ref.invalidate(directoryProvider(directory));
      ref.invalidate(currentUserProvider);
      ref.read(syncSchedulerProvider)?.requestRun();
    });
  }

  Future<void> download(FileEntry entry) => _downloadAndSave(
    name: entry.name,
    size: entry.size,
    mime: entry.mime,
    fetch: (onProgress) => ref.read(polderApiProvider).downloadBytes(entry.path, onProgress: onProgress),
  );

  Future<void> downloadVersion(FileEntry entry, FileVersion version) => _downloadAndSave(
    name: entry.name,
    size: version.size,
    mime: entry.mime,
    fetch: (onProgress) => ref.read(polderApiProvider).downloadVersion(version.id, onProgress: onProgress),
  );

  Future<void> downloadFromTrash(TrashItem item) => _downloadAndSave(
    name: item.isDir ? "${item.name}.zip" : item.name,
    size: item.isDir ? 0 : item.size,
    mime: item.isDir ? "application/zip" : item.mime,
    fetch: (onProgress) => ref.read(polderApiProvider).downloadFromTrash(item.id, onProgress: onProgress),
  );

  Future<void> downloadLogFile(ServerLogFile file) => _downloadAndSave(
    name: file.name,
    size: file.size,
    mime: "application/x-ndjson",
    fetch: (onProgress) => ref.read(polderApiProvider).downloadLogFile(file.name, onProgress: onProgress),
  );

  Future<void> _downloadAndSave({
    required String name,
    required int size,
    required String mime,
    required Future<Uint8List> Function(void Function(int received, int total) onProgress) fetch,
  }) async {
    final transfer = _start(name, TransferDirection.download, size);
    await _track(transfer, () async {
      final bytes = await fetch((received, total) => _progress(transfer.id, received, total));
      await ref.read(filePickerServiceProvider).saveFile(name: name, bytes: bytes, mime: mime);
    });
  }

  void clearFinished() => state = state.where((transfer) => transfer.isRunning).toList();

  Transfer _start(String name, TransferDirection direction, int total, {String? remotePath}) {
    final transfer = Transfer(
      id: _nextId++,
      clientId: _newClientId(),
      name: name,
      direction: direction,
      remotePath: remotePath,
      total: total,
    );
    state = [...state, transfer];
    return transfer;
  }

  Future<void> _track(Transfer transfer, Future<void> Function() work) async {
    try {
      await work();
      _replace(
        transfer.id,
        (current) => current.copyWith(status: TransferStatus.done, transferred: current.total, rate: 0),
      );
    } on ApiException catch (error) {
      _replace(transfer.id, (current) => current.copyWith(status: TransferStatus.failed, error: error, rate: 0));
    } finally {
      _sinceProgress.remove(transfer.id);
      _meters.remove(transfer.id);
    }
  }

  void _progress(int id, int transferred, int total) {
    final since = _sinceProgress[id];
    if (since != null && since.elapsed < progressInterval && transferred < total) return;
    _sinceProgress[id] = Stopwatch()..start();
    _replace(id, (current) {
      final meter = _meters.putIfAbsent(id, ThroughputMeter.new)..add(transferred - current.transferred);
      return current.copyWith(transferred: transferred, total: total > 0 ? total : current.total, rate: meter.rate);
    });
  }

  String _newClientId() => [for (var i = 0; i < 16; i++) _random.nextInt(256).toRadixString(16).padLeft(2, "0")].join();

  void _replace(int id, Transfer Function(Transfer current) update) =>
      state = [for (final transfer in state) transfer.id == id ? update(transfer) : transfer];
}
