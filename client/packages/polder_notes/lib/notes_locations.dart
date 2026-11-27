import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

class NotesLocations {
  const NotesLocations(this.root, {required this.cook});

  static const pathParameter = "path";

  final String root;
  final String cook;

  String noteAt(String path) => Uri(path: root, queryParameters: {pathParameter: path}).toString();

  String cookAt(String path) => Uri(path: cook, queryParameters: {pathParameter: path}).toString();

  bool isNoteLocation(String? location) {
    final uri = location == null ? null : Uri.tryParse(location);
    return uri != null && uri.path == root && uri.queryParameters.containsKey(pathParameter);
  }

  static String? pathOf(Uri location) => location.queryParameters[pathParameter];
}

final notesLocationsProvider = Provider<NotesLocations>(
  (ref) => throw UnimplementedError("Each app overrides notesLocationsProvider"),
);

NotesLocations notesLocationsOf(BuildContext context) =>
    ProviderScope.containerOf(context, listen: false).read(notesLocationsProvider);
