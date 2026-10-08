import "package:freezed_annotation/freezed_annotation.dart";

part "user.freezed.dart";
part "user.g.dart";

enum UserRole { admin, user }

@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required int id,
    required String username,
    @JsonKey(unknownEnumValue: UserRole.user) @Default(UserRole.user) UserRole role,
    @Default(0) int quotaBytes,
    @Default(0) int usedBytes,
    @Default(0) int historyBytes,
    @Default(false) bool disabled,
    DateTime? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  bool get isAdmin => role == UserRole.admin;

  bool get hasQuota => quotaBytes > 0;

  double get usedFraction => hasQuota ? (usedBytes / quotaBytes).clamp(0, 1).toDouble() : 0;
}
