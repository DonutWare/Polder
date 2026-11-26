import "package:freezed_annotation/freezed_annotation.dart";

part "auto_upload_settings.freezed.dart";
part "auto_upload_settings.g.dart";

@freezed
abstract class AutoUploadSettings with _$AutoUploadSettings {
  const factory AutoUploadSettings({
    @Default(false) bool enabled,
    @Default(true) bool wifiOnly,
    @Default(false) bool chargingOnly,
  }) = _AutoUploadSettings;

  factory AutoUploadSettings.fromJson(Map<String, dynamic> json) => _$AutoUploadSettingsFromJson(json);
}
