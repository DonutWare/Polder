import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/account.dart";
import "package:polder/models/user.dart";
import "package:polder/routes/app_router.dart";
import "package:polder/routes/app_routes.dart";

import "../support/provider_harness.dart";

void main() {
  AsyncValue<Account?> signedIn(UserRole role) => AsyncData(testAccount(role: role));

  String? resolve(AsyncValue<Account?> account, String location, {bool isAdmin = false}) =>
      AppRedirect.resolve(account, Uri.parse(location), isAdmin: isAdmin);

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
}
