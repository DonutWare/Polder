import "dart:ui";

import "package:freezed_annotation/freezed_annotation.dart";

part "server_settings.freezed.dart";

@freezed
abstract class ServerSettings with _$ServerSettings {
  const factory ServerSettings({
    required int trashRetentionDays,
    @Default(true) bool trashEnabled,
    @Default(true) bool searchContentEnabled,
    @Default(true) bool ocrEnabled,
    @Default(<String>[]) List<String> ocrLanguages,
    @Default(1) int ocrMaxPages,
    @Default("") String instanceName,
    @Default("") String welcomeMessage,
    Color? accentColor,
    @Default(true) bool versionsEnabled,
    @Default(0) int versionsKeepAllHours,
    @Default(0) int versionsMaxAgeDays,
    @Default(0) int versionsMaxPerFile,
  }) = _ServerSettings;
}
