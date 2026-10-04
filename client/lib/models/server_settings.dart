import "package:freezed_annotation/freezed_annotation.dart";

part "server_settings.freezed.dart";

@freezed
abstract class ServerSettings with _$ServerSettings {
  const factory ServerSettings({required int trashRetentionDays, @Default(false) bool trashRetentionEnforced}) =
      _ServerSettings;
}
