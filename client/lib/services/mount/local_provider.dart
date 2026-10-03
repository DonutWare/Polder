import "dart:typed_data";

import "package:nomad/models/file_entry.dart";
import "package:nomad/models/sync/sync_entry.dart";

abstract interface class LocalProvider {
  Future<List<FileEntry>> list(String remotePath);

  Future<Uint8List> readRange(String remotePath, {required int offset, required int length});

  Future<FileEntry> write(String remotePath, Stream<List<int>> content, {required int length, required int baseRev});

  Future<EntryState> materialize(String remotePath);

  Future<EntryState> evict(String remotePath);

  Future<void> notifyChanged(Iterable<String> remotePaths);
}

class UnsupportedLocalProvider implements LocalProvider {
  const UnsupportedLocalProvider();

  @override
  Future<List<FileEntry>> list(String remotePath) => _unsupported();

  @override
  Future<Uint8List> readRange(String remotePath, {required int offset, required int length}) => _unsupported();

  @override
  Future<FileEntry> write(String remotePath, Stream<List<int>> content, {required int length, required int baseRev}) =>
      _unsupported();

  @override
  Future<EntryState> materialize(String remotePath) => _unsupported();

  @override
  Future<EntryState> evict(String remotePath) => _unsupported();

  @override
  Future<void> notifyChanged(Iterable<String> remotePaths) => _unsupported();

  Future<T> _unsupported<T>() => Future.error(UnsupportedError("Mounting is not implemented yet"));
}
