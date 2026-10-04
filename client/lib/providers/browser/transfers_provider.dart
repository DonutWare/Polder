import "dart:math";
import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/file_entry.dart";
import "package:nomad/models/transfer.dart";
import "package:nomad/models/trash.dart";
import "package:nomad/providers/nomad_api_provider.dart";
import "package:nomad/providers/browser/directory_provider.dart";
import "package:nomad/providers/current_user_provider.dart";
import "package:nomad/providers/service_providers.dart";
import "package:nomad/providers/sync/sync_scheduler_provider.dart";
import "package:nomad/services/api/api_exceptions.dart";
import "package:nomad/services/transfer/file_picker_service.dart";
import "package:nomad/util/remote_path.dart";

final transfersProvider = NotifierProvider<TransfersNotifier, List<Transfer>>(TransfersNotifier.new);

class TransfersNotifier extends Notifier<List<Transfer>> {
  /// Progress arrives for every few KB sent; rebuilding the transfer list that often makes the UI sluggish.
  static const progressInterval = Duration(milliseconds: 100);
  static const _rateSmoothing = 0.3;

  var _nextId = 0;
  final _random = Random.secure();
  final Map<int, Stopwatch> _sinceProgress = {};

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
          .read(nomadApiProvider)
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
    fetch: (onProgress) => ref.read(nomadApiProvider).downloadBytes(entry.path, onProgress: onProgress),
  );

  Future<void> downloadFromTrash(TrashItem item) => _downloadAndSave(
    name: item.isDir ? "${item.name}.zip" : item.name,
    size: item.isDir ? 0 : item.size,
    mime: item.isDir ? "application/zip" : item.mime,
    fetch: (onProgress) => ref.read(nomadApiProvider).downloadFromTrash(item.id, onProgress: onProgress),
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
    }
  }

  void _progress(int id, int transferred, int total) {
    final since = _sinceProgress[id];
    if (since != null && since.elapsed < progressInterval && transferred < total) return;
    _sinceProgress[id] = Stopwatch()..start();
    final seconds = (since?.elapsedMicroseconds ?? 0) / Duration.microsecondsPerSecond;
    _replace(id, (current) {
      final instant = seconds > 0 ? (transferred - current.transferred) / seconds : 0.0;
      final rate = current.rate == 0 ? instant : _rateSmoothing * instant + (1 - _rateSmoothing) * current.rate;
      return current.copyWith(
        transferred: transferred,
        total: total > 0 ? total : current.total,
        rate: max(rate, 0).round(),
      );
    });
  }

  String _newClientId() => [for (var i = 0; i < 16; i++) _random.nextInt(256).toRadixString(16).padLeft(2, "0")].join();

  void _replace(int id, Transfer Function(Transfer current) update) =>
      state = [for (final transfer in state) transfer.id == id ? update(transfer) : transfer];
}
