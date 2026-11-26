import "package:freezed_annotation/freezed_annotation.dart";

part "setup_status.freezed.dart";
part "setup_status.g.dart";

@freezed
abstract class SetupStatus with _$SetupStatus {
  const factory SetupStatus({required bool needsSetup}) = _SetupStatus;

  factory SetupStatus.fromJson(Map<String, dynamic> json) => _$SetupStatusFromJson(json);
}
