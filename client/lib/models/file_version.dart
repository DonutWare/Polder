import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/trash.dart";

part "file_version.freezed.dart";

@freezed
abstract class FileVersion with _$FileVersion {
  const factory FileVersion({
    required int id,
    @Default(0) int size,
    @Default("") String hash,
    required DateTime modifiedAt,
    required DateTime replacedAt,
    @Default(false) bool hasPreview,
  }) = _FileVersion;
}

@freezed
abstract class VersionRetention with _$VersionRetention {
  const VersionRetention._();

  const factory VersionRetention({
    @Default(false) bool enabled,
    @Default(0) int keepAllHours,
    @Default(0) int maxAgeDays,
    @Default(0) int maxPerFile,
    @Default(RetentionSource.serverDefault) RetentionSource source,
    @Default(false) bool serverEnabled,
    @Default(0) int serverKeepAllHours,
    @Default(0) int serverMaxAgeDays,
    @Default(0) int serverMaxPerFile,
    @Default(VersionPreferences()) VersionPreferences user,
  }) = _VersionRetention;

  bool get changeable => serverEnabled;
}

@freezed
abstract class VersionPreferences with _$VersionPreferences {
  const factory VersionPreferences({bool? enabled, int? keepAllHours, int? maxAgeDays, int? maxPerFile}) =
      _VersionPreferences;
}

@freezed
abstract class VersionListing with _$VersionListing {
  const factory VersionListing({
    required FileEntry current,
    @Default(<FileVersion>[]) List<FileVersion> versions,
    required VersionRetention retention,
  }) = _VersionListing;
}
