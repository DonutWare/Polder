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

  var _nextId = 0;
  final Map<int, Stopwatch> _sinceProgress = {};

  @override
  List<Transfer> build() => const [];

  Future<void> pickAndUpload(String directory) async {
    final files = await ref.read(filePickerServiceProvider).pickFiles();
    await Future.wait(files.map((file) => upload(directory, file)));
  }

  Future<void> upload(String directory, PickedFile file) async {
    final length = await file.length() ?? 0;
    final transfer = _start(file.name, TransferDirection.upload, length);
    await _track(transfer, () async {
      await ref
          .read(nomadApiProvider)
          .putContent(
            RemotePath.join(directory, file.name),
            file.openRead(),
            length: length,
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

  Transfer _start(String name, TransferDirection direction, int total) {
    final transfer = Transfer(id: _nextId++, name: name, direction: direction, total: total);
    state = [...state, transfer];
    return transfer;
  }

  Future<void> _track(Transfer transfer, Future<void> Function() work) async {
    try {
      await work();
      _replace(transfer.id, (current) => current.copyWith(status: TransferStatus.done, transferred: current.total));
    } on ApiException catch (error) {
      _replace(transfer.id, (current) => current.copyWith(status: TransferStatus.failed, error: error));
    } finally {
      _sinceProgress.remove(transfer.id);
    }
  }

  void _progress(int id, int transferred, int total) {
    final since = _sinceProgress[id];
    if (since != null && since.elapsed < progressInterval && transferred < total) return;
    _sinceProgress[id] = Stopwatch()..start();
    _replace(id, (current) => current.copyWith(transferred: transferred, total: total > 0 ? total : current.total));
  }

  void _replace(int id, Transfer Function(Transfer current) update) =>
      state = [for (final transfer in state) transfer.id == id ? update(transfer) : transfer];
}
