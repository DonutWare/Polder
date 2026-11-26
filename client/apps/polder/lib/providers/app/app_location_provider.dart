import "dart:async";

import "package:flutter/foundation.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "package:polder_core/models/document_editor.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/media_gallery.dart";
import "package:polder/routes/app_router.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder_core/util/remote_path.dart";

enum AppSection { notes, calendar, other }

@immutable
class AppLocation {
  const AppLocation(this.section, [this.detail]);

  factory AppLocation.of(Uri uri, Object? extra) {
    final path = uri.queryParameters[AppRoutes.pathParameter];
    return switch (uri.path) {
      AppRoutes.notes || AppRoutes.cook => AppLocation(AppSection.notes, _noteName(path)),
      AppRoutes.calendar => const AppLocation(AppSection.calendar),
      AppRoutes.pdf || AppRoutes.media || AppRoutes.editor => AppLocation(AppSection.other, _fileName(extra)),
      _ => AppLocation(AppSection.other, _folderName(path)),
    };
  }

  final AppSection section;
  final String? detail;

  static String? _noteName(String? path) => path == null ? null : RemotePath.withoutExtension(RemotePath.name(path));

  static String? _folderName(String? path) => path == null || path == RemotePath.root ? null : RemotePath.name(path);

  static String? _fileName(Object? extra) => switch (extra) {
    final FileEntry entry => entry.name,
    final MediaGallery gallery => gallery.entry.name,
    final EditorTarget target => target.entry.name,
    _ => null,
  };

  @override
  bool operator ==(Object other) => other is AppLocation && other.section == section && other.detail == detail;

  @override
  int get hashCode => Object.hash(section, detail);
}

final appLocationProvider = NotifierProvider<AppLocationNotifier, AppLocation>(AppLocationNotifier.new);

class AppLocationNotifier extends Notifier<AppLocation> {
  @override
  AppLocation build() {
    final delegate = ref.watch(routerProvider).routerDelegate;
    AppLocation current() => _locationOf(delegate.currentConfiguration);
    void update() => scheduleMicrotask(() {
      if (ref.mounted) state = current();
    });
    delegate.addListener(update);
    ref.onDispose(() => delegate.removeListener(update));
    return current();
  }

  static AppLocation _locationOf(RouteMatchList configuration) {
    if (configuration.isEmpty) return const AppLocation(AppSection.other);
    final top = switch (configuration.last) {
      final ImperativeRouteMatch pushed => pushed.matches,
      _ => configuration,
    };
    return AppLocation.of(top.uri, top.extra);
  }
}
