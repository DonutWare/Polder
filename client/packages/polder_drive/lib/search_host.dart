import "package:flutter/widgets.dart";

import "package:calendar_views/calendar_views.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_core/models/search.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_drive/routes/drive_routes.dart";
import "package:polder_ui/util/search_syntax.dart";

class SearchHost {
  const SearchHost({this.scopeFor = _folderScope, this.eventAt});

  final String Function(BuildContext context, Uri location) scopeFor;

  final String Function(EventRef ref, DateTime start)? eventAt;

  bool get searchesEvents => eventAt != null;
}

final searchHostProvider = Provider<SearchHost>((_) => const SearchHost());

SearchHost searchHostOf(BuildContext context) =>
    ProviderScope.containerOf(context, listen: false).read(searchHostProvider);

String folderSearchScope(Uri location) {
  final folder = location.path == DriveRoutes.files ? location.queryParameters[DriveRoutes.pathParameter] : null;
  if (folder == null || folder == RemotePath.root) return "";
  return appendSearchFilter(
    "",
    formatSearchFilter(SearchFilter(key: SearchKey.folder, op: SearchOp.equals, values: [folder])),
  );
}

String _folderScope(BuildContext _, Uri location) => folderSearchScope(location);
