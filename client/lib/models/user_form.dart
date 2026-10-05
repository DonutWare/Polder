import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/admin_user_requests.dart";
import "package:polder/models/user.dart";
import "package:polder/util/quota_unit.dart";

part "user_form.freezed.dart";

@freezed
abstract class UserForm with _$UserForm {
  const UserForm._();

  const factory UserForm({
    User? original,
    @Default("") String username,
    @Default("") String password,
    @Default(UserRole.user) UserRole role,
    @Default("0") String quotaAmount,
    @Default(QuotaUnit.gb) QuotaUnit quotaUnit,
    @Default(false) bool disabled,
    int? trashRetentionOverrideDays,
    @Default(false) bool saving,
  }) = _UserForm;

  factory UserForm.forUser(User? user) {
    if (user == null) return const UserForm();
    final unit = QuotaUnit.bestFor(user.quotaBytes);
    return UserForm(
      original: user,
      username: user.username,
      role: user.role,
      quotaAmount: _formatAmount(user.quotaBytes / unit.bytes),
      quotaUnit: unit,
      disabled: user.disabled,
      trashRetentionOverrideDays: user.trashRetentionOverrideDays,
    );
  }

  bool get isNew => original == null;

  double? get _amount => double.tryParse(quotaAmount.trim().replaceAll(",", "."));

  bool get isQuotaValid => (_amount ?? -1) >= 0;

  int get quotaBytes => quotaUnit.toBytes(_amount ?? 0);

  bool get isValid => isQuotaValid && (!isNew || username.trim().isNotEmpty && password.isNotEmpty);

  CreateUserRequest toCreateRequest() =>
      CreateUserRequest(username: username.trim(), password: password, role: role, quotaBytes: quotaBytes);

  UpdateUserRequest toUpdateRequest() {
    final user = original!;
    return UpdateUserRequest(
      password: password.isEmpty ? null : password,
      role: role == user.role ? null : role,
      quotaBytes: quotaBytes == user.quotaBytes ? null : quotaBytes,
      disabled: disabled == user.disabled ? null : disabled,
      trashRetentionOverrideDays: trashRetentionOverrideDays == user.trashRetentionOverrideDays
          ? null
          : trashRetentionOverrideDays ?? UpdateUserRequest.clearTrashRetentionOverride,
    );
  }

  static String _formatAmount(double amount) =>
      amount == amount.roundToDouble() ? amount.toInt().toString() : amount.toStringAsFixed(2);
}
