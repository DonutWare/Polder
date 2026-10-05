import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder/models/account.dart";
import "package:polder/models/login_state.dart";
import "package:polder/models/setup_status.dart";
import "package:polder/models/token_pair.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";

final loginProvider = NotifierProvider.autoDispose<LoginNotifier, LoginState>(LoginNotifier.new);

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() {
    final hosted = ref.read(hostedServerUrlProvider);
    if (hosted == null) return const LoginState();
    Future.microtask(_connectToHostedServer);
    return LoginState(serverUrl: ApiClientFactory.normalizeServerUrl(hosted), probingHostedServer: true);
  }

  /// Falls back to asking for a server when the page's own origin isn't a Polder server
  /// (for example when the web client runs from `flutter run`).
  Future<void> _connectToHostedServer() async {
    if (!ref.mounted) return;
    try {
      final status = await _api.setupStatus();
      if (!ref.mounted) return;
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

  void backToServer() {
    if (state.serverLocked) return;
    state = state.copyWith(step: LoginStep.server, password: "", failure: null);
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
    state = state.copyWith(step: status.needsSetup ? LoginStep.setup : LoginStep.credentials);
  });

  Future<void> signIn() => _run(() async {
    final tokens = await _api.login(
      username: state.username.trim(),
      password: state.password,
      deviceName: ref.read(deviceNameProvider),
    );
    await _complete(tokens);
  });

  Future<void> createAdmin() => _run(() async {
    await _complete(await _api.setup(username: state.username.trim(), password: state.password));
  });

  Future<void> _complete(TokenPair tokens) async {
    final account = Account.fromTokens(
      serverUrl: state.serverUrl,
      deviceName: ref.read(deviceNameProvider),
      tokens: tokens,
    );
    await ref.read(accountProvider.notifier).signIn(account);
    if (ref.mounted) state = state.copyWith(completed: true);
  }

  Future<void> _run(Future<void> Function() action) async {
    state = state.copyWith(loading: true, failure: null);
    try {
      await action();
      if (ref.mounted) state = state.copyWith(loading: false);
    } on ApiException catch (error) {
      if (ref.mounted) state = state.copyWith(loading: false, failure: _failureFor(error));
    }
  }

  LoginFailure _failureFor(ApiException error) => switch (error) {
    NetworkException() || NotFoundException() => LoginFailure.unreachable,
    UnauthorizedException() => LoginFailure.invalidCredentials,
    ForbiddenException() when state.step == LoginStep.setup => LoginFailure.setupUnavailable,
    ForbiddenException() => LoginFailure.accountDisabled,
    ConflictException() || AlreadyExistsException() => LoginFailure.setupUnavailable,
    _ => LoginFailure.unknown,
  };
}
