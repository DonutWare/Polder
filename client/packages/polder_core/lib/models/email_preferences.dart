import "package:freezed_annotation/freezed_annotation.dart";

part "email_preferences.freezed.dart";

@freezed
abstract class EmailPreferences with _$EmailPreferences {
  const factory EmailPreferences({
    @Default(true) bool security,
    @Default(true) bool quota,
    @Default(true) bool shares,
    @Default(false) bool hasEmail,
    @Default(false) bool enabled,
  }) = _EmailPreferences;
}
