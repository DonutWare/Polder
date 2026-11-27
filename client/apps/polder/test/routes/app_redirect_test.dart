import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder_core/models/account.dart";
import "package:polder_core/models/user.dart";
import "package:polder/routes/app_router.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/services/features/feature_modes.dart";

import "../support/provider_harness.dart";

void main() {
  AsyncValue<Account?> signedIn(UserRole role) => AsyncData(testAccount(role: role));

  String? resolve(
    AsyncValue<Account?> account,
    String location, {
    bool isAdmin = false,
    bool offline = false,
    bool twoFactorSetup = false,
  }) => AppRedirect.resolve(
    account,
    Uri.parse(location),
    isAdmin: isAdmin,
    continueOffline: offline,
    twoFactorSetupRequired: twoFactorSetup,
  );

  AsyncValue<Account?> ended() => AsyncData(testAccount().endSession());

  test("signed-out users go to login and come back afterwards", () {
    expect(resolve(const AsyncData(null), AppRoutes.files), AppRoutes.login);
    final redirect = resolve(const AsyncData(null), AppRoutes.sharedAt(4, path: "/Photos"))!;
    expect(Uri.parse(redirect).path, AppRoutes.login);
    final from = Uri.parse(redirect).queryParameters[AppRoutes.fromParameter];
    expect(from, AppRoutes.sharedAt(4, path: "/Photos"));
    expect(resolve(signedIn(UserRole.user), redirect), AppRoutes.sharedAt(4, path: "/Photos"));
  });

  test("public share pages need no account", () {
    expect(resolve(const AsyncData(null), AppRoutes.publicShareAt("Ab3dE9xQ2k")), isNull);
    expect(
      resolve(signedIn(UserRole.user), AppRoutes.publicShareAt("Ab3dE9xQ2k", server: "files.example.com")),
      isNull,
    );
  });

  test("only local paths are returned to after login", () {
    expect(AppRoutes.safeReturn("//evil.example.com"), isNull);
    expect(AppRoutes.safeReturn("https://evil.example.com"), isNull);
    expect(AppRoutes.safeReturn(AppRoutes.login), isNull);
    expect(AppRoutes.safeReturn(AppRoutes.trash), AppRoutes.trash);
  });

  test("an ended session goes to login and returns afterwards", () {
    final redirect = resolve(ended(), AppRoutes.trash)!;
    expect(Uri.parse(redirect).path, AppRoutes.login);
    expect(resolve(ended(), redirect), isNull);
    expect(resolve(signedIn(UserRole.user), redirect), AppRoutes.trash);
  });

  test("an ended session can keep using the app offline", () {
    expect(resolve(ended(), AppRoutes.trash, offline: true), isNull);
    expect(resolve(ended(), AppRoutes.login, offline: true), AppRoutes.files);
  });

  test("signed-in users skip login", () {
    expect(resolve(signedIn(UserRole.user), AppRoutes.login), AppRoutes.files);
  });

  test("administration is only reachable for administrators", () {
    expect(resolve(signedIn(UserRole.user), AppRoutes.admin), AppRoutes.files);
    expect(resolve(signedIn(UserRole.user), AppRoutes.adminUsers), AppRoutes.files);
    expect(resolve(signedIn(UserRole.admin), AppRoutes.admin, isAdmin: true), isNull);
    expect(resolve(signedIn(UserRole.admin), AppRoutes.adminUsers, isAdmin: true), isNull);
  });

  test("paths that only start like /admin are not administration", () {
    expect(AppRoutes.isAdmin("/administrator-notes"), isFalse);
    expect(AppRoutes.isAdmin(AppRoutes.files), isFalse);
  });

  test("an overdue second factor keeps the user on its setup page", () {
    expect(resolve(signedIn(UserRole.user), AppRoutes.files, twoFactorSetup: true), AppRoutes.twoFactorSetup);
    expect(resolve(signedIn(UserRole.user), AppRoutes.twoFactorSetup, twoFactorSetup: true), isNull);
    expect(resolve(signedIn(UserRole.user), AppRoutes.twoFactorSetup), AppRoutes.files);
    expect(resolve(const AsyncData(null), AppRoutes.twoFactorSetup), startsWith(AppRoutes.login));
  });

  group("feature modes", () {
    const calendarOnly = FeatureModes({
      PolderFeature.drive: FeatureMode.hidden,
      PolderFeature.notes: FeatureMode.openApp,
      PolderFeature.calendar: FeatureMode.builtIn,
    });
    const nothing = FeatureModes({
      PolderFeature.drive: FeatureMode.hidden,
      PolderFeature.notes: FeatureMode.hidden,
      PolderFeature.calendar: FeatureMode.hidden,
    });
    String? resolveWith(FeatureModes features, String location) =>
        AppRedirect.resolve(signedIn(UserRole.user), Uri.parse(location), features: features);

    test("routes of a feature that is not built in go to the first built-in one", () {
      expect(resolveWith(calendarOnly, AppRoutes.files), AppRoutes.calendar);
      expect(resolveWith(calendarOnly, AppRoutes.trash), AppRoutes.calendar);
      expect(resolveWith(calendarOnly, AppRoutes.notes), AppRoutes.calendar);
      expect(resolveWith(calendarOnly, AppRoutes.cook), AppRoutes.calendar);
      expect(resolveWith(calendarOnly, AppRoutes.calendar), isNull);
    });

    test("settings and shared routes stay reachable", () {
      expect(resolveWith(calendarOnly, AppRoutes.settings), isNull);
      expect(resolveWith(calendarOnly, AppRoutes.groups), isNull);
      expect(resolveWith(calendarOnly, AppRoutes.media), isNull);
    });

    test("with every feature hidden the user lands on the apps settings to bring them back", () {
      expect(resolveWith(nothing, AppRoutes.files), AppRoutes.settingsPage(SettingsPage.apps));
      expect(resolveWith(nothing, AppRoutes.settingsPage(SettingsPage.apps)), isNull);
    });
  });
}
