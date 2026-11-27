import "package:flutter/material.dart";

import "package:go_router/go_router.dart";
import "package:polder_core/models/document_editor.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/media_gallery.dart";
import "package:polder_core/models/scan_session.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_ui/routes/up_scope.dart";

import "package:polder_drive/routes/drive_routes.dart";
import "package:polder_drive/screens/activity/activity_screen.dart";
import "package:polder_drive/screens/auto_upload/auto_upload_screen.dart";
import "package:polder_drive/screens/browser/browser_stack.dart";
import "package:polder_drive/screens/public_share/public_share_screen.dart";
import "package:polder_drive/screens/scan/scan_review_screen.dart";
import "package:polder_drive/screens/shared/shared_screen.dart";
import "package:polder_drive/screens/sync/conflict_resolver_screen.dart";
import "package:polder_drive/screens/sync/sync_folders_screen.dart";
import "package:polder_drive/screens/tags/tags_screen.dart";
import "package:polder_drive/screens/trash/trash_screen.dart";
import "package:polder_drive/screens/viewer/document_editor_screen.dart";
import "package:polder_drive/screens/viewer/media/polder_media_viewer.dart";
import "package:polder_drive/screens/viewer/pdf_viewer_screen.dart";

class BrowsedPathMemory {
  String path = RemotePath.root;
}

List<RouteBase> driveFullScreenRoutes() => [
  drivePage(
    path: "${DriveRoutes.publicShare}/:code",
    page: (state) => PublicShareScreen(
      code: state.pathParameters["code"]!,
      server: state.uri.queryParameters[DriveRoutes.serverParameter],
      path: state.uri.queryParameters[DriveRoutes.pathParameter] ?? RemotePath.root,
    ),
  ),
  drivePage(
    path: DriveRoutes.scan,
    redirect: (_, state) => state.extra is ScanRequest ? null : DriveRoutes.files,
    page: (state) => ScanReviewScreen(request: state.extra! as ScanRequest),
  ),
  drivePage(
    path: DriveRoutes.pdf,
    redirect: (_, state) => state.extra is FileEntry ? null : DriveRoutes.files,
    page: (state) => PdfViewerScreen(entry: state.extra! as FileEntry),
  ),
  drivePage(
    path: DriveRoutes.media,
    redirect: (_, state) => state.extra is FileEntry || state.extra is MediaGallery ? null : DriveRoutes.files,
    page: (state) => switch (state.extra) {
      final MediaGallery gallery => PolderMediaViewer(entry: gallery.entry, gallery: gallery.items),
      final extra => PolderMediaViewer(entry: extra! as FileEntry),
    },
  ),
  drivePage(
    path: DriveRoutes.editor,
    redirect: (_, state) => state.extra is FileEntry || state.extra is EditorTarget ? null : DriveRoutes.files,
    page: (state) => DocumentEditorScreen(
      target: switch (state.extra) {
        final EditorTarget target => target,
        final extra => EditorTarget(extra! as FileEntry),
      },
    ),
  ),
];

List<RouteBase> driveShellRoutes(BrowsedPathMemory memory) => [
  driveTab(
    path: DriveRoutes.files,
    redirect: (_, state) {
      final path = state.uri.queryParameters[DriveRoutes.pathParameter];
      if (path == null) return DriveRoutes.filesAt(memory.path);
      memory.path = path;
      return null;
    },
    page: (state) => UpScope(
      child: BrowserStack(
        path: state.uri.queryParameters[DriveRoutes.pathParameter] ?? RemotePath.root,
        select: state.uri.queryParameters[DriveRoutes.selectParameter],
      ),
    ),
  ),
  drivePage(
    path: DriveRoutes.sync,
    page: (_) => const UpScope(child: SyncFoldersScreen()),
    routes: [
      drivePage(
        path: "conflicts",
        page: (_) => const UpScope(child: ConflictResolverScreen()),
      ),
    ],
  ),
  driveTab(
    path: DriveRoutes.shared,
    page: (_) => const UpScope(child: SharedScreen()),
  ),
  driveTab(
    path: "${DriveRoutes.shared}/:section",
    redirect: (_, state) =>
        SharedSection.fromSegment(state.pathParameters["section"]) == null ? DriveRoutes.shared : null,
    page: (state) => UpScope(child: SharedScreen(section: SharedSection.fromSegment(state.pathParameters["section"]))),
  ),
  driveTab(
    path: "${DriveRoutes.shared}/:section/:shareId",
    redirect: (_, state) =>
        !_browsableSections.contains(SharedSection.fromSegment(state.pathParameters["section"])) ||
            int.tryParse(state.pathParameters["shareId"] ?? "") == null
        ? DriveRoutes.shared
        : null,
    page: (state) => UpScope(
      child: SharedScreen(
        section: SharedSection.fromSegment(state.pathParameters["section"]),
        shareId: int.parse(state.pathParameters["shareId"]!),
        path: state.uri.queryParameters[DriveRoutes.pathParameter] ?? RemotePath.root,
      ),
    ),
  ),
  drivePage(
    path: DriveRoutes.activity,
    page: (_) => const UpScope(child: ActivityScreen()),
  ),
  drivePage(
    path: DriveRoutes.autoUpload,
    page: (_) => const UpScope(child: AutoUploadScreen()),
  ),
  drivePage(
    path: DriveRoutes.trash,
    page: (_) => const UpScope(child: TrashScreen()),
  ),
  drivePage(
    path: DriveRoutes.tags,
    page: (_) => const UpScope(child: TagsScreen()),
  ),
];

GoRoute drivePage({
  required String path,
  required Widget Function(GoRouterState state) page,
  LocalKey Function(GoRouterState state)? key,
  GoRouterRedirect? redirect,
  List<RouteBase> routes = const [],
}) => GoRoute(
  path: path,
  redirect: redirect,
  routes: routes,
  pageBuilder: (_, state) =>
      MaterialPage<void>(key: key?.call(state) ?? state.pageKey, name: state.path, child: page(state)),
);

GoRoute driveTab({
  required String path,
  required Widget Function(GoRouterState state) page,
  GoRouterRedirect? redirect,
  List<RouteBase> routes = const [],
}) => GoRoute(
  path: path,
  redirect: redirect,
  routes: routes,
  pageBuilder: (_, state) =>
      NoTransitionPage<void>(key: ValueKey("tab:${state.uri.pathSegments.firstOrNull}"), child: page(state)),
);

const _browsableSections = {SharedSection.withMe, SharedSection.federated};
