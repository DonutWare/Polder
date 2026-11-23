import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder/models/account.dart";
import "package:polder/models/login_state.dart";
import "package:polder/models/security.dart";
import "package:polder/models/setup_status.dart";
import "package:polder/models/token_pair.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/branding/branding_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/auth/single_sign_on.dart";

final loginProvider = NotifierProvider.autoDispose<LoginNotifier, LoginState>(LoginNotifier.new);

class LoginNotifier extends Notifier<LoginState> {
  static const _pollInterval = Duration(seconds: 2);

  Timer? _poll;

  @override
  LoginState build() {
    ref.onDispose(() {
      _poll?.cancel();
      SingleSignOn.cancel();
    });
    final ended = ref.read(currentAccountProvider);
    if (ended != null && ended.sessionEnded) return _reauthenticate(ended);
    final hosted = ref.read(hostedServerUrlProvider);
    if (hosted == null) return const LoginState();
    Future.microtask(_connectToHostedServer);
    return LoginState(serverUrl: ApiClientFactory.normalizeServerUrl(hosted), probingHostedServer: true);
  }

  LoginState _reauthenticate(Account account) {
    ref.listen(currentAccountProvider.select((account) => account == null), (_, signedOut) {
      if (signedOut) ref.invalidateSelf();
    });
    Future.microtask(() => ref.read(brandingProvider.notifier).load(account.serverUrl));
    return LoginState(
      step: LoginStep.credentials,
      serverUrl: account.serverUrl,
      username: account.user.username,
      serverLocked: true,
      reauthenticating: true,
    );
  }

  /// Falls back to asking for a server when the page's own origin isn't a Polder server
  /// (for example when the web client runs from `flutter run`).
  Future<void> _connectToHostedServer() async {
    if (!ref.mounted) return;
    try {
      final status = await _api.setupStatus();
      if (!ref.mounted) return;
      unawaited(ref.read(brandingProvider.notifier).load(state.serverUrl));
      state = state.copyWith(
        probingHostedServer: false,
        serverLocked: true,
        step: status.needsSetup ? LoginStep.setup : LoginStep.credentials,
      );
    } catch (_) {
      // Not a Polder API (a dev server answers with index.html, for example): ask for the server instead.
      if (ref.mounted) state = state.copyWith(probingHostedServer: false);
    }
  }

  PolderApi get _api => ref.read(serverPolderApiProvider(state.serverUrl));

  void setServerUrl(String value) => state = state.copyWith(serverUrl: value, failure: null);

  void setUsername(String value) => state = state.copyWith(username: value, failure: null);

  void setPassword(String value) => state = state.copyWith(password: value, failure: null);

  void setPasswordConfirmation(String value) => state = state.copyWith(passwordConfirmation: value, failure: null);

  void backToServer() {
    if (state.serverLocked) return;
    ref.read(brandingProvider.notifier).clear();
    state = state.copyWith(step: LoginStep.server, password: "", passwordConfirmation: "", failure: null);
  }

  Future<void> connect() => _run(() async {
    final input = state.serverUrl.trim();
    state = state.copyWith(serverUrl: ApiClientFactory.normalizeServerUrl(input));
    SetupStatus status;
    try {
      status = await _api.setupStatus();
    } catch (error) {
      final serverAnswered = error is ApiException && error is! NetworkException;
      if (input.contains("://") || serverAnswered) rethrow;
      state = state.copyWith(serverUrl: state.serverUrl.replaceFirst("https://", "http://"));
      status = await _api.setupStatus();
    }
    unawaited(ref.read(brandingProvider.notifier).load(state.serverUrl));
    state = state.copyWith(step: status.needsSetup ? LoginStep.setup : LoginStep.credentials);
  });

  Future<void> signIn() => _run(() async {
    try {
      final tokens = await _api.login(
        username: state.username.trim(),
        password: state.password,
        deviceName: ref.read(deviceNameProvider),
      );
      await _complete(tokens);
    } on TwoFactorRequiredException catch (required) {
      state = state.copyWith(
        step: LoginStep.twoFactor,
        challenge: required.challenge,
        deviceApprovalAvailable: required.deviceApproval,
        code: "",
        useRecoveryCode: false,
      );
    }
  });

  void setCode(String value) => state = state.copyWith(code: value, failure: null);

  void toggleRecoveryCode() => state = state.copyWith(useRecoveryCode: !state.useRecoveryCode, code: "", failure: null);

  void backToCredentials() {
    _stopWaiting();
    state = state.copyWith(
      step: LoginStep.credentials,
      challenge: null,
      deviceApprovalAvailable: false,
      useRecoveryCode: false,
      code: "",
      password: "",
      failure: null,
      deviceLogin: null,
    );
  }

  Future<void> verifyTwoFactor() => _run(() async {
    final code = state.code.trim();
    final tokens = await _api.verifyTwoFactor(
      challenge: state.challenge!,
      code: state.useRecoveryCode ? null : code.replaceAll(RegExp(r"\s"), ""),
      recoveryCode: state.useRecoveryCode ? code : null,
      deviceName: ref.read(deviceNameProvider),
    );
    await _complete(tokens);
  });

  Future<void> askAnotherDevice() => _run(() async {
    final started = await _api.startDeviceLogin(
      username: state.challenge == null ? state.username.trim() : null,
      challenge: state.challenge,
      deviceName: ref.read(deviceNameProvider),
    );
    state = state.copyWith(step: LoginStep.deviceApproval, deviceLogin: started);
    _scheduleApprovalCheck(started);
  });

  void _scheduleApprovalCheck(DeviceLoginStart started) {
    _poll?.cancel();
    _poll = Timer(_pollInterval, () => unawaited(_checkApproval(started)));
  }

  Future<void> _checkApproval(DeviceLoginStart started) async {
    if (!ref.mounted || state.deviceLogin != started) return;
    final result = await _approvalStatus(started);
    if (!ref.mounted || state.deviceLogin != started) return;
    switch (result?.status) {
      case null || DeviceLoginStatus.pending:
        _scheduleApprovalCheck(started);
      case DeviceLoginStatus.approved:
        _stopWaiting();
        await _run(() => _complete(result!.tokens!));
      case DeviceLoginStatus.denied:
        _approvalEnded(LoginFailure.approvalDenied);
      case DeviceLoginStatus.expired || DeviceLoginStatus.cancelled:
        _approvalEnded(LoginFailure.approvalExpired);
    }
  }

  Future<DeviceLoginResult?> _approvalStatus(DeviceLoginStart started) async {
    try {
      return await _api.deviceLoginStatus(started);
    } on NotFoundException {
      return const DeviceLoginResult(status: DeviceLoginStatus.expired);
    } on Object {
      return null;
    }
  }

  void _approvalEnded(LoginFailure failure) {
    _stopWaiting();
    state = state.copyWith(
      step: state.challenge == null ? LoginStep.credentials : LoginStep.twoFactor,
      deviceLogin: null,
      failure: failure,
    );
  }

  void cancelDeviceApproval() {
    final started = state.deviceLogin;
    if (started != null) unawaited(_api.cancelDeviceLogin(started).catchError((Object _) {}));
    _stopWaiting();
    state = state.copyWith(
      step: state.challenge == null ? LoginStep.credentials : LoginStep.twoFactor,
      deviceLogin: null,
      failure: null,
    );
  }

  void _stopWaiting() {
    _poll?.cancel();
    _poll = null;
  }

  Future<void> signInWithProvider(String providerId) async {
    state = state.copyWith(signingInWith: providerId);
    await _run(() async {
      final deviceName = ref.read(deviceNameProvider);
      final result = await SingleSignOn.signIn(
        serverUrl: state.serverUrl,
        providerId: providerId,
        deviceName: deviceName,
      );
      final tokens = await _api.exchangeSingleSignOnCode(
        code: result.code,
        codeVerifier: result.verifier,
        deviceName: deviceName,
      );
      await _complete(tokens);
    });
    if (ref.mounted) state = state.copyWith(signingInWith: null);
  }

  void cancelSignInWithProvider() => SingleSignOn.cancel();

  Future<void> createAdmin() => _run(() async {
    final tokens = await _api.setup(
      username: state.username.trim(),
      password: state.password,
      deviceName: ref.read(deviceNameProvider),
    );
    await _complete(tokens);
  });

  Future<void> _complete(TokenPair tokens) async {
    final account = Account.fromTokens(serverUrl: state.serverUrl, tokens: tokens);
    await ref.read(accountProvider.notifier).signIn(account);
    if (ref.mounted) state = state.copyWith(completed: true);
  }

  Future<void> _run(Future<void> Function() action) async {
    state = state.copyWith(loading: true, failure: null, failureCause: null);
    try {
      await action();
      if (ref.mounted) state = state.copyWith(loading: false);
    } on SingleSignOnException catch (error) {
      if (!ref.mounted) return;
      final failure = switch (error.failure) {
        SingleSignOnFailure.cancelled => null,
        SingleSignOnFailure.signupDisabled => LoginFailure.ssoSignupDisabled,
        SingleSignOnFailure.linkRequired => LoginFailure.ssoLinkRequired,
        SingleSignOnFailure.accountDisabled => LoginFailure.accountDisabled,
        SingleSignOnFailure.alreadyLinked || SingleSignOnFailure.failed => LoginFailure.ssoFailed,
      };
      state = state.copyWith(loading: false, failure: failure, failureCause: null);
    } on Object catch (error) {
      if (ref.mounted) state = state.copyWith(loading: false, failure: _failureFor(error), failureCause: error);
    }
  }

  LoginFailure _failureFor(Object error) => switch (error) {
    NetworkException() || NotFoundException() => LoginFailure.unreachable,
    RateLimitedException() => LoginFailure.tooManyAttempts,
    UnauthorizedException() when state.step == LoginStep.twoFactor => LoginFailure.invalidCode,
    UnauthorizedException() => LoginFailure.invalidCredentials,
    ForbiddenException() when state.step == LoginStep.setup => LoginFailure.setupUnavailable,
    ForbiddenException() => LoginFailure.accountDisabled,
    ConflictException() || AlreadyExistsException() => LoginFailure.setupUnavailable,
    _ => LoginFailure.unknown,
  };
}
