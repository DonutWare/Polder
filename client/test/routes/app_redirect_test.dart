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

  test("signed-out users go to login", () {
    expect(resolve(const AsyncData(null), AppRoutes.admin), AppRoutes.login);
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
