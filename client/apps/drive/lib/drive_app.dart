import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";

import "package:app_links/app_links.dart";
import "package:polder_account_link/app_location_links.dart";
import "package:polder_account_link/companion_app.dart";
import "package:polder_core/util/flavor.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_core/services/notifications/local_notification.dart";
import "package:polder_drive/desktop/sync_tray.dart";
import "package:polder_drive/providers/file_browser/file_browser_location_provider.dart";
import "package:polder_drive/providers/notifications/drive_notification_providers.dart";
import "package:polder_drive/providers/realtime/directory_refresher_provider.dart";
import "package:polder_drive/providers/sharing/share_target_provider.dart";
import "package:polder_drive/providers/sync/sync_platform_provider.dart";
import "package:polder_drive/providers/sync/sync_scheduler_provider.dart";
import "package:polder_drive/routes/drive_routes.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/app/standalone_app.dart";

import "package:polder_drive_app/routes/drive_app_router.dart";

class DriveApp extends ConsumerWidget {
  const DriveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
      ..watch(syncSchedulerProvider)
      ..watch(directoryRefresherProvider)
      ..watch(_driveNotificationsProvider)
      ..watch(_incomingLinksProvider)
      ..watch(shareTargetHandlerProvider)
      ..watch(showInFileBrowserProvider);
    final router = ref.watch(driveRouterProvider);
    final platform = ref.watch(syncPlatformProvider);
    TrayEntry route(String route, String Function(BuildContext context) label) => TrayEntry(
      label: label,
      onSelected: () {
        router.go(route);
        return showDesktopWindow();
      },
    );

    return StandaloneApp(
      title: (localized) => localized.navFiles,
      router: router,
      wrap: (child) => SyncTray(
        appName: (localized) => localized.driveAppTitle,
        router: router,
        openEntries: [
          if (platform.supportsFolderSync) route(DriveRoutes.sync, (context) => context.localized.trayOpenSyncedFolders),
          route(DriveRoutes.files, (context) => context.localized.trayOpenFiles),
        ],
        child: child,
      ),
    );
  }
}

final _driveNotificationsProvider = Provider<void>((ref) {
  ref
    ..watch(notificationFeedListenerProvider)
    ..watch(foregroundUploadNotifierProvider);
  ref.listen(deliveredNotificationPreferencesProvider.select((preferences) => preferences.value?.wantsShares), (
    _,
    enabled,
  ) {
    if (enabled != null) unawaited(ref.read(syncPlatformProvider).scheduleNotificationChecks(enabled: enabled));
  }, fireImmediately: true);
  final service = ref.watch(notificationServiceProvider);
  Future<void> handle(NotificationTap tap) async {
    if (await respondToShareTap(ref, tap)) return;
    if (tap.location case final location?) ref.read(driveRouterProvider).go(location);
  }

  final subscription = service.taps.listen((tap) => unawaited(handle(tap).catchError((_) {})));
  unawaited(service.launchTap().then((tap) => tap == null ? null : handle(tap)).catchError((_) {}));
  ref.onDispose(subscription.cancel);
});

final _incomingLinksProvider = Provider<void>((ref) {
  if (kIsWeb) return;
  final subscription = AppLinks().uriLinkStream.listen((uri) {
    final location = AppLocationLinks.locationOf(uri, CompanionApp.drive, dev: isDevFlavor);
    if (location != null) ref.read(driveRouterProvider).go(location);
  });
  ref.onDispose(subscription.cancel);
});
