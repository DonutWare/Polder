import "package:freezed_annotation/freezed_annotation.dart";

part "sync_entry.freezed.dart";
part "sync_entry.g.dart";

enum EntryState { placeholder, hydrating, hydrated, pinned, dirty }

@freezed
abstract class SyncEntry with _$SyncEntry {
  const SyncEntry._();

  const factory SyncEntry({
    required String syncRootId,
    required String relativePath,
    @Default(false) bool isDir,
    String? localHash,
    int? localSize,
    DateTime? localMtime,
    @Default(0) int syncedRev,
    @Default("") String syncedHash,
    String? manifestJson,
    @Default(EntryState.hydrated) EntryState state,
  }) = _SyncEntry;

  factory SyncEntry.fromJson(Map<String, dynamic> json) => _$SyncEntryFromJson(json);

  bool get isPlaceholder => state == EntryState.placeholder;
}
