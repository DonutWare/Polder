import "dart:io";

import "package:polder/services/sync/sync_ignore_rules.dart";

abstract final class FolderWatcher {
  static Stream<String> watch(String localPath) {
    if (!FileSystemEntity.isWatchSupported) return const Stream.empty();
    return Directory(localPath)
        .watch(recursive: true)
        .expand((event) => [event.path, if (event case FileSystemMoveEvent(:final destination?)) destination])
        .where((path) => !_isTemporary(path))
        .handleError((Object _) {});
  }

  static bool _isTemporary(String path) =>
      path.split(Platform.pathSeparator).any((segment) => segment.startsWith(SyncIgnoreRules.tempPrefix));
}
