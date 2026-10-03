import "package:freezed_annotation/freezed_annotation.dart";

part "transfer.freezed.dart";

enum TransferDirection { upload, download }

enum TransferStatus { running, done, failed }

@freezed
abstract class Transfer with _$Transfer {
  const Transfer._();

  const factory Transfer({
    required int id,
    required String name,
    required TransferDirection direction,
    @Default(0) int transferred,
    @Default(0) int total,
    @Default(TransferStatus.running) TransferStatus status,
    Object? error,
  }) = _Transfer;

  double? get progress => total > 0 ? transferred / total : null;

  bool get isRunning => status == TransferStatus.running;
}
