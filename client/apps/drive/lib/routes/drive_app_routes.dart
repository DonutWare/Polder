import "package:polder_drive/routes/drive_routes.dart";
import "package:polder_ui/routes/sign_in_routes.dart";

abstract final class DriveAppRoutes {
  static const home = DriveRoutes.files;
  static const settings = "/settings";
  static const signIn = SignInRoutes(home: home, isPublic: DriveRoutes.isPublic);

  static String? upFrom(Uri location, {required bool single}) =>
      location.path == settings ? home : DriveRoutes.upFrom(location, single: single);

  static bool isTopLevel(String location) => DriveRoutes.isTab(location);
}
