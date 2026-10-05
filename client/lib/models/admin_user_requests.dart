import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/user.dart";

part "admin_user_requests.freezed.dart";
part "admin_user_requests.g.dart";

@freezed
abstract class CreateUserRequest with _$CreateUserRequest {
  const factory CreateUserRequest({
    required String username,
    required String password,
    required UserRole role,
    required int quotaBytes,
  }) = _CreateUserRequest;

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) => _$CreateUserRequestFromJson(json);
}

@freezed
abstract class UpdateUserRequest with _$UpdateUserRequest {
  const UpdateUserRequest._();

  static const clearTrashRetentionOverride = -1;

  const factory UpdateUserRequest({
    String? password,
    UserRole? role,
    int? quotaBytes,
    bool? disabled,
    int? trashRetentionOverrideDays,
  }) = _UpdateUserRequest;

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) => _$UpdateUserRequestFromJson(json);

  bool get isEmpty =>
      password == null && role == null && quotaBytes == null && disabled == null && trashRetentionOverrideDays == null;
}
