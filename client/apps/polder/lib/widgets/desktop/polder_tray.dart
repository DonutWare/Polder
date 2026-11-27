import "dart:async";

import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_drive/desktop/sync_tray.dart";
import "package:polder_ui/l10n/generated/app_localizations.dart";
import "package:polder_ui/util/localization_helper.dart";

import "package:polder/providers/features/feature_modes_provider.dart";
import "package:polder/providers/platform_service_providers.dart";
import "package:polder/providers/shortcuts/app_shortcut_runner.dart";
import "package:polder/providers/update/update_provider.dart";
import "package:polder/routes/app_router.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/services/features/feature_modes.dart";
import "package:polder/services/shortcuts/app_shortcut.dart";

/// The sync tray of the main app, shown only while it runs Drive itself.
class PolderTray extends ConsumerWidget {
  const PolderTray({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final modes = ref.watch(resolvedFeatureModesProvider);
    final canScan = ref.watch(documentScannerServiceProvider).isSupported;
    final updatable = ref.watch(updateProvider.select((state) => state.phase != UpdatePhase.disabled));

    TrayEntry route(String route, String Function(AppLocalizations l10n) label) => TrayEntry(
      label: (context) => label(context.localized),
      onSelected: () {
        router.go(route);
        return showDesktopWindow();
      },
    );

    TrayEntry shortcut(AppShortcut shortcut) => TrayEntry(
      label: shortcut.groupedLabel,
      onSelected: () => ref.read(appShortcutRunnerProvider).run(shortcut),
    );

    return SyncTray(
      appName: (l10n) => l10n.appTitle,
      router: router,
      enabled: modes.isBuiltIn(PolderFeature.drive),
      openEntries: [
        route(AppRoutes.sync, (l10n) => l10n.trayOpenSyncedFolders),
        route(AppRoutes.files, (l10n) => l10n.trayOpenFiles),
        if (modes.isBuiltIn(PolderFeature.calendar)) route(AppRoutes.calendar, (l10n) => l10n.trayOpenCalendar),
        if (modes.isBuiltIn(PolderFeature.notes)) route(AppRoutes.notes, (l10n) => l10n.trayOpenNotes),
      ],
      newEntries: [for (final item in AppShortcut.inGroup(AppShortcutGroup.create, canScan: canScan)) shortcut(item)],
      findEntries: [for (final item in AppShortcut.inGroup(AppShortcutGroup.find, canScan: canScan)) shortcut(item)],
      appEntries: [
        if (updatable)
          TrayEntry(
            label: (context) => switch (ref.read(updateProvider)) {
              UpdateState(phase: UpdatePhase.ready) => context.localized.updatesRestart,
              UpdateState(phase: UpdatePhase.available, inPlace: true) => context.localized.updatesInstall,
              _ => context.localized.updatesCheck,
            },
            needsAccount: false,
            isEnabled: () => !ref.read(updateProvider).busy,
            onSelected: () => _updateClicked(ref),
          ),
      ],
      refreshOn: [updateProvider],
      beforeQuit: ({required restart}) => ref.read(updateProvider.notifier).installBeforeQuit(relaunch: restart),
      restartRequested: updateProvider.select((state) => state.restartRequested),
      onRestartCancelled: () => ref.read(updateProvider.notifier).cancelRestart(),
      child: child,
    );
  }

  static void _updateClicked(WidgetRef ref) {
    final notifier = ref.read(updateProvider.notifier);
    unawaited(switch (ref.read(updateProvider)) {
      UpdateState(phase: UpdatePhase.ready) ||
      UpdateState(phase: UpdatePhase.available, inPlace: true) => notifier.restartToUpdate(),
      _ => notifier.check(),
    });
  }
}
