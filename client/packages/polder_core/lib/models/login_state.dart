import "package:freezed_annotation/freezed_annotation.dart";
import "package:polder_core/models/security.dart";
import "package:polder_core/util/credential_rules.dart";

part "login_state.freezed.dart";

enum LoginStep { server, credentials, setup, twoFactor, deviceApproval }

enum LoginFailure {
  unreachable,
  invalidCredentials,
  accountDisabled,
  setupUnavailable,
  invalidCode,
  tooManyAttempts,
  approvalDenied,
  approvalExpired,
  ssoSignupDisabled,
  ssoLinkRequired,
  ssoFailed,
  unknown,
}

@freezed
abstract class LoginState with _$LoginState {
  const LoginState._();

  const factory LoginState({
    @Default(LoginStep.server) LoginStep step,
    @Default("") String serverUrl,
    @Default("") String username,
    @Default("") String password,

    @Default("") String passwordConfirmation,
    @Default(false) bool loading,
    @Default(false) bool completed,

    /// The server is the one this web client was served from, so it can't be changed.
    @Default(false) bool serverLocked,

    /// Checking whether the page's own origin is a Polder server, before showing any form.
    @Default(false) bool probingHostedServer,
    @Default(false) bool reauthenticating,
    LoginFailure? failure,
    Object? failureCause,
    String? challenge,
    @Default(false) bool deviceApprovalAvailable,
    @Default(false) bool useRecoveryCode,
    @Default("") String code,
    DeviceLoginStart? deviceLogin,
    String? signingInWith,
  }) = _LoginState;

  bool get canConnect => serverUrl.trim().isNotEmpty && !loading;

  bool get _creatingAdmin => step == LoginStep.setup;

  bool get passwordsMatch => !_creatingAdmin || password == passwordConfirmation;

  bool get meetsRequirements =>
      !_creatingAdmin || CredentialRules.isValidUsername(username) && CredentialRules.isValidPassword(password);

  bool get canSubmitCode {
    final trimmed = code.replaceAll(RegExp(r"\s"), "");
    return !loading && (useRecoveryCode ? trimmed.length >= 10 : RegExp(r"^\d{6}$").hasMatch(trimmed));
  }

  bool get canAskAnotherDevice => username.trim().isNotEmpty && !loading;

  bool get canSubmitCredentials =>
      username.trim().isNotEmpty && password.isNotEmpty && passwordsMatch && meetsRequirements && !loading;
}
