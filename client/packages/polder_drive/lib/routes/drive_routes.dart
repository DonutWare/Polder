import "package:polder_core/util/remote_path.dart";
import "package:polder_notes/notes_locations.dart";

abstract final class DriveRoutes {
  static const files = "/files";
  static const scan = "/scan";
  static const pdf = "/pdf";
  static const media = "/media";
  static const editor = "/editor";
  static const note = "/note";
  static const cook = "/note/cook";
  static const notes = NotesLocations(note, cook: cook);
  static const activity = "/activity";
  static const sync = "/sync";
  static const conflicts = "/sync/conflicts";
  static const autoUpload = "/auto-upload";
  static const trash = "/trash";
  static const shared = "/shared";
  static const tags = "/tags";
  static const publicShare = "/share";
  static const search = "/search";

  static const pathParameter = "path";
  static const selectParameter = "select";
  static const serverParameter = "server";
  static const queryParameter = "q";

  static String filesAt(String path, {String? select}) =>
      Uri(path: files, queryParameters: {pathParameter: path, selectParameter: ?select}).toString();

  static String noteAt(String path) => notes.noteAt(path);

  static String searchFor(String query) =>
      Uri(path: search, queryParameters: query.isEmpty ? null : {queryParameter: query}).toString();

  static String sharedSection(String section) => "$shared/$section";

  static String sharedAt(int shareId, {String path = "/"}) => Uri(
    path: "$shared/${SharedSection.withMe.segment}/$shareId",
    queryParameters: path == "/" ? null : {pathParameter: path},
  ).toString();

  static String federatedAt(int shareId, {String path = "/"}) => Uri(
    path: "$shared/${SharedSection.federated.segment}/$shareId",
    queryParameters: path == "/" ? null : {pathParameter: path},
  ).toString();

  static String publicShareAt(String code, {String? server, String path = "/"}) {
    final parameters = {serverParameter: ?server, if (path != "/") pathParameter: path};
    return Uri(path: "$publicShare/$code", queryParameters: parameters.isEmpty ? null : parameters).toString();
  }

  static bool isPublic(String location) => location.startsWith("$publicShare/");

  static bool isTab(String location) =>
      [files, shared].any((root) => location == root || location.startsWith(RegExp("$root[/?]")));

  static String? upFrom(Uri location, {required bool single, String home = files}) {
    final segments = location.pathSegments;
    final path = location.queryParameters[pathParameter] ?? RemotePath.root;
    return switch ("/${segments.firstOrNull ?? ""}") {
      files => path == RemotePath.root ? null : filesAt(RemotePath.parent(path)),
      shared => _sharedUp(segments, path, single: single, home: home),
      sync when segments.length > 1 => sync,
      note => _noteUp(location, path),
      _ => home,
    };
  }

  static String _noteUp(Uri location, String path) =>
      location.path == cook ? noteAt(path) : filesAt(RemotePath.parent(path), select: RemotePath.name(path));

  static String _sharedUp(List<String> segments, String path, {required bool single, required String home}) {
    final section = SharedSection.fromSegment(segments.elementAtOrNull(1));
    final shareId = int.tryParse(segments.elementAtOrNull(2) ?? "");
    if (section == null) return home;
    if (shareId == null) return single ? shared : home;
    final federated = section == SharedSection.federated;
    final rootSection = federated ? SharedSection.federated : SharedSection.withMe;
    if (path == RemotePath.root) return sharedSection(rootSection.segment);
    final parent = RemotePath.parent(path);
    return federated ? federatedAt(shareId, path: parent) : sharedAt(shareId, path: parent);
  }
}

enum SharedSection {
  withMe("with-me"),
  byMe("by-me"),
  links("links"),
  federated("other-servers");

  const SharedSection(this.segment);

  final String segment;

  static SharedSection? fromSegment(String? segment) =>
      SharedSection.values.where((section) => section.segment == segment).firstOrNull;
}
