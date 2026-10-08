import "dart:ui";

import "package:freezed_annotation/freezed_annotation.dart";

part "server_settings.freezed.dart";

@freezed
abstract class ServerSettings with _$ServerSettings {
  const factory ServerSettings({
    required int trashRetentionDays,
    @Default(false) bool trashRetentionEnforced,
    @Default(true) bool searchContentEnabled,
    @Default(true) bool ocrEnabled,
    @Default(<String>[]) List<String> ocrLanguages,
    @Default(1) int ocrMaxPages,
    @Default("") String instanceName,
    @Default("") String welcomeMessage,
    Color? accentColor,
  }) = _ServerSettings;
}
