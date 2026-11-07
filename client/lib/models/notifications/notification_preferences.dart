import "package:freezed_annotation/freezed_annotation.dart";

part "notification_preferences.freezed.dart";
part "notification_preferences.g.dart";

@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const NotificationPreferences._();

  const factory NotificationPreferences({
    @Default(false) bool enabled,
    @Default(true) bool shares,
    @Default(true) bool calendarReminders,
    @Default(true) bool autoUploadProgress,
    @Default(true) bool autoUploadSummary,
    @Default(false) bool autoUploadCheck,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);

  bool get wantsShares => enabled && shares;

  bool get wantsCalendarReminders => enabled && calendarReminders;

  bool get wantsUploadProgress => enabled && autoUploadProgress;

  bool get wantsUploadSummary => enabled && autoUploadSummary;

  bool get wantsUploadCheck => enabled && autoUploadCheck;
}
