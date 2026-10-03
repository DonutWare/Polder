import "package:freezed_annotation/freezed_annotation.dart";

import "package:nomad/models/sync/conflict.dart";

part "sync_status.freezed.dart";

enum SyncPhase { idle, syncing, error }

@freezed
abstract class SyncRunReport with _$SyncRunReport {
  const SyncRunReport._();

  const factory SyncRunReport({
    @Default(0) int uploaded,
    @Default(0) int downloaded,
    @Default(0) int deleted,
    @Default(0) int moved,
    @Default(0) int failed,
    @Default(<Conflict>[]) List<Conflict> conflicts,
    @Default(<String>[]) List<String> errors,
  }) = _SyncRunReport;

  factory SyncRunReport.failure(String error) => SyncRunReport(failed: 1, errors: [error]);

  factory SyncRunReport.conflict(Conflict conflict) => SyncRunReport(conflicts: [conflict]);

  bool get hasFailures => failed > 0;

  SyncRunReport operator +(SyncRunReport other) => SyncRunReport(
    uploaded: uploaded + other.uploaded,
    downloaded: downloaded + other.downloaded,
    deleted: deleted + other.deleted,
    moved: moved + other.moved,
    failed: failed + other.failed,
    conflicts: [...conflicts, ...other.conflicts],
    errors: [...errors, ...other.errors],
  );
}

@freezed
abstract class SyncStatus with _$SyncStatus {
  const SyncStatus._();

  const factory SyncStatus({
    @Default(SyncPhase.idle) SyncPhase phase,
    @Default(SyncRunReport()) SyncRunReport lastReport,
    DateTime? lastRunAt,
    String? errorMessage,
  }) = _SyncStatus;

  bool get isSyncing => phase == SyncPhase.syncing;
}
