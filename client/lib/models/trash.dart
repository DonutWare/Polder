import "package:freezed_annotation/freezed_annotation.dart";

import "package:nomad/models/file_entry.dart";

part "trash.freezed.dart";

enum RetentionSource { serverDefault, user, server, admin }

enum RestoreMode { fail, overwrite, keepBoth }

@freezed
abstract class TrashItem with _$TrashItem {
  const TrashItem._();

  const factory TrashItem({
    required int id,
    required String name,
    required String originalPath,
    @Default(false) bool isDir,
    @Default(0) int size,
    @Default("") String mime,
    @Default("") String hash,
    @Default(PreviewState.none) PreviewState previewState,
    required DateTime deletedAt,
    DateTime? expiresAt,
  }) = _TrashItem;

  bool get hasPreview => previewState == PreviewState.ready;
}

@freezed
abstract class TrashRetention with _$TrashRetention {
  const TrashRetention._();

  const factory TrashRetention({
    required int days,
    required RetentionSource source,
    @Default(false) bool locked,
    int? userDays,
    required int defaultDays,
  }) = _TrashRetention;

  bool get keepsForever => days == 0;
}

@freezed
abstract class TrashListing with _$TrashListing {
  const factory TrashListing({
    @Default(<TrashItem>[]) List<TrashItem> items,
    @Default(0) int totalBytes,
    required TrashRetention retention,
  }) = _TrashListing;
}
