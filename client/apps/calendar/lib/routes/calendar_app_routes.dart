import "package:polder_calendar/calendar_locations.dart";
import "package:polder_ui/routes/sign_in_routes.dart";

abstract final class CalendarAppRoutes {
  static const home = "/";
  static const settings = "/settings";
  static const signIn = SignInRoutes(home: home);
  static const calendar = CalendarLocations(home);

  static String? upFrom(Uri location, {required bool single}) => location.path == settings ? home : null;

  static bool isTopLevel(String location) => Uri.parse(location).path == home;
}
