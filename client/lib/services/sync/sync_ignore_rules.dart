import "package:polder/models/sync/sync_root.dart";

abstract final class SyncIgnoreRules {
  static const tempPrefix = ".polder";
  static const _ignoredNames = {".DS_Store", "Thumbs.db", "desktop.ini"};

  static bool isIgnored(String relativePath, {SyncMode mode = SyncMode.sync}) =>
      relativePath.split("/").any((segment) => _isIgnoredSegment(segment, mode));

  static bool _isIgnoredSegment(String segment, SyncMode mode) =>
      segment.startsWith(tempPrefix) ||
      segment.startsWith("._") ||
      _ignoredNames.contains(segment) ||
      (mode == SyncMode.autoUpload && segment.startsWith("."));
}
