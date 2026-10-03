import "package:freezed_annotation/freezed_annotation.dart";

part "sync_root.freezed.dart";
part "sync_root.g.dart";

enum SyncMode { sync, autoUpload }

@freezed
abstract class SyncRoot with _$SyncRoot {
  const factory SyncRoot({
    required String id,
    required String accountId,
    required String localPath,
    required String remotePath,
    @Default(SyncMode.sync) SyncMode mode,
    @Default(true) bool enabled,
  }) = _SyncRoot;

  factory SyncRoot.fromJson(Map<String, dynamic> json) => _$SyncRootFromJson(json);
}
