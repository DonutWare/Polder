import "package:freezed_annotation/freezed_annotation.dart";
import "package:polder/util/credential_rules.dart";

part "login_state.freezed.dart";

enum LoginStep { server, credentials, setup }

enum LoginFailure { unreachable, invalidCredentials, accountDisabled, setupUnavailable, unknown }

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
    LoginFailure? failure,
    Object? failureCause,
  }) = _LoginState;

  bool get canConnect => serverUrl.trim().isNotEmpty && !loading;

  bool get _creatingAdmin => step == LoginStep.setup;

  bool get passwordsMatch => !_creatingAdmin || password == passwordConfirmation;

  bool get meetsRequirements =>
      !_creatingAdmin || CredentialRules.isValidUsername(username) && CredentialRules.isValidPassword(password);

  bool get canSubmitCredentials =>
      username.trim().isNotEmpty && password.isNotEmpty && passwordsMatch && meetsRequirements && !loading;
}
