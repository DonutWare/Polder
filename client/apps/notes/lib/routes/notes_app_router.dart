import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/media_gallery.dart";
import "package:polder_media/media_viewer_screen.dart";
import "package:polder_notes/notes_locations.dart";
import "package:polder_notes/screens/notes/cooking/cooking_screen.dart";
import "package:polder_notes/screens/notes/notes_screen.dart";
import "package:polder_notes/screens/notes/widgets/notes_navigation.dart";
import "package:polder_notes_app/routes/notes_app_routes.dart";
import "package:polder_ui/l10n/generated/app_localizations.dart";
import "package:polder_ui/routes/standalone_router.dart";
import "package:polder_ui/routes/up_scope.dart";
import "package:polder_ui/screens/settings/standalone_settings_screen.dart";

final notesRouterProvider = Provider<GoRouter>(
  (ref) => createStandaloneRouter(
    ref,
    signIn: NotesAppRoutes.signIn,
    settings: NotesAppRoutes.settings,
    title: (context) => AppLocalizations.of(context).navNotes,
    home: (location) => NotesScreen(notePath: NotesLocations.pathOf(location), showSidebar: false),
    sidebar: (location) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: NotesNavigationSidebar(location: location)),
        SettingsSidebarItem(location: location),
      ],
    ),
    rail: (location) => NotesNavigationRail(location: location),
    railFooter: (location) => SettingsRailTile(location: location),
    sidebarWidth: 320,
    fullScreenRoutes: [
      GoRoute(
        path: NotesAppRoutes.media,
        redirect: (_, state) => state.extra is FileEntry || state.extra is MediaGallery ? null : NotesAppRoutes.home,
        pageBuilder: (_, state) => MaterialPage<void>(
          key: state.pageKey,
          child: switch (state.extra) {
            final MediaGallery gallery => MediaViewerScreen(entry: gallery.entry, gallery: gallery.items),
            final extra => MediaViewerScreen(entry: extra! as FileEntry),
          },
        ),
      ),
      GoRoute(
        path: NotesAppRoutes.cook,
        redirect: (_, state) => NotesLocations.pathOf(state.uri) == null ? NotesAppRoutes.home : null,
        pageBuilder: (_, state) => MaterialPage<void>(
          key: state.pageKey,
          child: UpScope(child: CookingScreen(path: NotesLocations.pathOf(state.uri)!)),
        ),
      ),
    ],
  ),
);
