import "package:flutter/foundation.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_core/models/account.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/current_user_provider.dart";

class SignInRoutes {
  const SignInRoutes({
    required this.home,
    this.login = defaultLogin,
    this.twoFactorSetup = "/two-factor-setup",
    this.isPublic = _nothingIsPublic,
  });

  static const defaultLogin = "/login";
  static const fromParameter = "from";

  final String home;
  final String login;
  final String twoFactorSetup;
  final bool Function(String path) isPublic;

  String loginFrom(Uri location) => location.path == home && location.query.isEmpty
      ? login
      : Uri(path: login, queryParameters: {fromParameter: location.toString()}).toString();

  String? safeReturn(String? location) =>
      location != null && location.startsWith("/") && !location.startsWith("//") && !location.startsWith(login)
      ? location
      : null;

  String afterSignIn(Uri loginLocation) => safeReturn(loginLocation.queryParameters[fromParameter]) ?? home;

  String? redirect(SignInSnapshot state, Uri location) {
    if (state.account.isLoading && !state.account.hasValue) return null;
    if (isPublic(location.path)) return null;
    final signedIn = switch (state.account.value) {
      null => false,
      final current => !current.sessionEnded || state.continueOffline,
    };
    final atLogin = location.path == login;
    if (!signedIn && !atLogin) return loginFrom(location);
    if (signedIn && atLogin) return afterSignIn(location);
    final atTwoFactorSetup = location.path == twoFactorSetup;
    if (signedIn && state.twoFactorSetupRequired && !atTwoFactorSetup) return twoFactorSetup;
    if (atTwoFactorSetup && !state.twoFactorSetupRequired) return home;
    return null;
  }

  static bool _nothingIsPublic(String path) => false;
}

@immutable
class SignInSnapshot {
  const SignInSnapshot({required this.account, this.continueOffline = false, this.twoFactorSetupRequired = false});

  final AsyncValue<Account?> account;
  final bool continueOffline;
  final bool twoFactorSetupRequired;
}

class SignInState extends ChangeNotifier {
  SignInState(Ref ref)
    : _snapshot = SignInSnapshot(
        account: ref.read(accountProvider),
        continueOffline: ref.read(continueOfflineProvider),
        twoFactorSetupRequired: ref.read(twoFactorSetupRequiredProvider),
      ) {
    ref
      ..listen(accountProvider, (_, next) => _update(account: next))
      ..listen(continueOfflineProvider, (_, next) => _update(continueOffline: next))
      ..listen(twoFactorSetupRequiredProvider, (_, next) => _update(twoFactorSetupRequired: next));
  }

  SignInSnapshot _snapshot;

  SignInSnapshot get snapshot => _snapshot;

  void _update({AsyncValue<Account?>? account, bool? continueOffline, bool? twoFactorSetupRequired}) {
    _snapshot = SignInSnapshot(
      account: account ?? _snapshot.account,
      continueOffline: continueOffline ?? _snapshot.continueOffline,
      twoFactorSetupRequired: twoFactorSetupRequired ?? _snapshot.twoFactorSetupRequired,
    );
    notifyListeners();
  }
}
