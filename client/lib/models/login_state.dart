import "package:freezed_annotation/freezed_annotation.dart";

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
    @Default(false) bool loading,
    @Default(false) bool completed,

    /// The server is the one this web client was served from, so it can't be changed.
    @Default(false) bool serverLocked,

    /// Checking whether the page's own origin is a Polder server, before showing any form.
    @Default(false) bool probingHostedServer,
    LoginFailure? failure,
  }) = _LoginState;

  bool get canConnect => serverUrl.trim().isNotEmpty && !loading;

  bool get canSubmitCredentials => username.trim().isNotEmpty && password.isNotEmpty && !loading;
}
