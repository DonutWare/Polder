import "package:freezed_annotation/freezed_annotation.dart";
import "package:polder/models/admin_user_requests.dart";
import "package:polder/models/user.dart";
import "package:polder/util/credential_rules.dart";
import "package:polder/util/quota_unit.dart";

part "user_form.freezed.dart";

@freezed
abstract class UserForm with _$UserForm {
  const UserForm._();

  const factory UserForm({
    User? original,
    @Default("") String username,
    @Default("") String password,
    @Default("") String passwordConfirmation,
    @Default(UserRole.user) UserRole role,
    @Default("0") String quotaAmount,
    @Default(QuotaUnit.gb) QuotaUnit quotaUnit,
    @Default(false) bool disabled,
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
    );
  }

  bool get isNew => original == null;

  double? get _amount => double.tryParse(quotaAmount.trim().replaceAll(",", "."));

  bool get isQuotaValid => (_amount ?? -1) >= 0;

  int get quotaBytes => quotaUnit.toBytes(_amount ?? 0);

  bool get passwordsMatch => password == passwordConfirmation;

  bool get isUsernameValid => !isNew || CredentialRules.isValidUsername(username);

  bool get isPasswordValid => password.isEmpty ? !isNew : CredentialRules.isValidPassword(password);

  bool get isValid => isQuotaValid && passwordsMatch && isUsernameValid && isPasswordValid;

  CreateUserRequest toCreateRequest() =>
      CreateUserRequest(username: username.trim(), password: password, role: role, quotaBytes: quotaBytes);

  UpdateUserRequest toUpdateRequest() {
    final user = original!;
    return UpdateUserRequest(
      password: password.isEmpty ? null : password,
      role: role == user.role ? null : role,
      quotaBytes: quotaBytes == user.quotaBytes ? null : quotaBytes,
      disabled: disabled == user.disabled ? null : disabled,
    );
  }

  static String _formatAmount(double amount) =>
      amount == amount.roundToDouble() ? amount.toInt().toString() : amount.toStringAsFixed(2);
}
