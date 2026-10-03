import "dart:io";

import "package:nomad/services/sync/sync_ignore_rules.dart";

abstract final class FolderWatcher {
  static Stream<void> watch(String localPath) {
    if (!FileSystemEntity.isWatchSupported) return const Stream.empty();
    return Directory(localPath)
        .watch(recursive: true)
        .where((event) => !_isTemporary(event.path))
        .map((_) {})
        .handleError((Object _) {});
  }

  static bool _isTemporary(String path) =>
      path.split(Platform.pathSeparator).any((segment) => segment.startsWith(SyncIgnoreRules.tempPrefix));
}
