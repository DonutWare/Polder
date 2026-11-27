import "package:polder_notes/notes_locations.dart";
import "package:polder_ui/routes/sign_in_routes.dart";

abstract final class NotesAppRoutes {
  static const home = "/";
  static const cook = "/cook";
  static const media = "/media";
  static const settings = "/settings";
  static const signIn = SignInRoutes(home: home);
  static const notes = NotesLocations(home, cook: cook);

  static String? upFrom(Uri location, {required bool single}) => switch (location.path) {
    settings || media => home,
    cook => switch (NotesLocations.pathOf(location)) {
      final path? => notes.noteAt(path),
      null => home,
    },
    _ => null,
  };

  static bool isTopLevel(String location) => Uri.parse(location).path == home;
}
