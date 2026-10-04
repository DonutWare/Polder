import "package:freezed_annotation/freezed_annotation.dart";

import "package:nomad/util/remote_path.dart";

part "activity.freezed.dart";

enum ActivityKind {
  upload,
  download,
  mkdir,
  move,
  delete,
  restore,
  trashDelete,
  trashEmpty,
  trashExpire,
  rescan,
  login,
  logout,
  unknown,
}

enum ActivityStatus { ok, failed, cancelled }

@freezed
abstract class ActivityEntry with _$ActivityEntry {
  const ActivityEntry._();

  const factory ActivityEntry({
    required int id,
    required int userId,
    required String username,
    required String device,
    required ActivityKind kind,
    required String path,
    String? fromPath,
    @Default(false) bool isDir,
    int? size,
    int? bytes,
    int? durationMs,
    int? count,
    @Default(ActivityStatus.ok) ActivityStatus status,
    @Default("") String detail,
    required DateTime createdAt,
  }) = _ActivityEntry;

  String get name => RemotePath.name(path);

  bool get isSession => kind == ActivityKind.login || kind == ActivityKind.logout;
}

@freezed
abstract class ActivityPage with _$ActivityPage {
  const factory ActivityPage({@Default(<ActivityEntry>[]) List<ActivityEntry> entries, @Default(0) int nextCursor}) =
      _ActivityPage;
}

enum TransferDirectionKind { upload, download }

@freezed
abstract class LiveTransfer with _$LiveTransfer {
  const LiveTransfer._();

  const factory LiveTransfer({
    required String id,
    required int userId,
    required String username,
    required TransferDirectionKind direction,
    required String path,
    required String device,
    String? clientId,
    @Default(0) int bytes,
    int? total,
    @Default(0) int rate,
    required DateTime startedAt,
  }) = _LiveTransfer;

  String get name => RemotePath.name(path);

  String get parentPath => RemotePath.parent(path);

  bool get isUpload => direction == TransferDirectionKind.upload;

  double? get progress {
    final expected = total;
    return expected == null || expected <= 0 ? null : (bytes / expected).clamp(0.0, 1.0);
  }
}

@freezed
sealed class ActivityScope with _$ActivityScope {
  const ActivityScope._();

  const factory ActivityScope.me() = ActivityScopeMe;

  const factory ActivityScope.all() = ActivityScopeAll;

  const factory ActivityScope.user({required int id, required String username}) = ActivityScopeUser;

  String get query => switch (this) {
    ActivityScopeMe() => "me",
    ActivityScopeAll() => "all",
    ActivityScopeUser(:final id) => "$id",
  };

  bool includes(int userId, {required int selfId}) => switch (this) {
    ActivityScopeMe() => userId == selfId,
    ActivityScopeAll() => true,
    ActivityScopeUser(:final id) => userId == id,
  };
}
