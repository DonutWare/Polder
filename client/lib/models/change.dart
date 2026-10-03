import "package:freezed_annotation/freezed_annotation.dart";

import "package:nomad/models/file_entry.dart";

part "change.freezed.dart";
part "change.g.dart";

enum ChangeType { upsert, delete, move }

@freezed
abstract class Change with _$Change {
  /// A move keeps the file's identity: [fromPath] is where it lived before. Its [entry] is null when a later
  /// change already superseded it.
  const factory Change({
    required int seq,
    required ChangeType type,
    required String path,
    String? fromPath,
    FileEntry? entry,
  }) = _Change;

  factory Change.fromJson(Map<String, dynamic> json) => _$ChangeFromJson(json);
}

@freezed
abstract class ChangeFeedPage with _$ChangeFeedPage {
  const factory ChangeFeedPage({
    @Default(<Change>[]) List<Change> changes,
    required int cursor,
    @Default(false) bool hasMore,
  }) = _ChangeFeedPage;

  factory ChangeFeedPage.fromJson(Map<String, dynamic> json) => _$ChangeFeedPageFromJson(json);
}
