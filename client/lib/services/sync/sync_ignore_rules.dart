abstract final class SyncIgnoreRules {
  static const tempPrefix = ".nomad";
  static const _ignoredNames = {".DS_Store", "Thumbs.db", "desktop.ini"};

  static bool isIgnored(String relativePath) => relativePath.split("/").any(_isIgnoredSegment);

  static bool _isIgnoredSegment(String segment) =>
      segment.startsWith(tempPrefix) || segment.startsWith("._") || _ignoredNames.contains(segment);
}
