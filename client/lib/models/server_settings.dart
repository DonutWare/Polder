import "dart:ui";

import "package:freezed_annotation/freezed_annotation.dart";

part "server_settings.freezed.dart";

enum MailSecurity { starttls, tls, none }

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
    @Default(false) bool federationEnabled,
    @Default("") String smtpHost,
    @Default(0) int smtpPort,
    @Default("") String smtpUsername,
    @Default(false) bool smtpPasswordSet,
    @Default("") String smtpFrom,
    @Default(MailSecurity.starttls) MailSecurity smtpSecurity,
    @Default(false) bool smtpManagedByConfig,
    @Default(false) bool requireTwoFactor,
    @Default(14) int twoFactorGraceDays,
  }) = _ServerSettings;
}
