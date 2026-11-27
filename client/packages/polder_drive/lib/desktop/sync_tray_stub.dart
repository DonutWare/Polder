import "package:flutter/widgets.dart";

import "package:flutter_riverpod/misc.dart";
import "package:go_router/go_router.dart";
import "package:polder_ui/l10n/generated/app_localizations.dart";

import "package:polder_drive/desktop/tray_entry.dart";

Future<void> initializeDesktopWindow({bool startHidden = false}) async {}

Future<void> setDesktopWindowTitle(String title) async {}

Future<void> showDesktopWindow() async {}

class SyncTray extends StatelessWidget {
  const SyncTray({
    required this.child,
    required this.appName,
    required this.router,
    this.enabled = true,
    this.openEntries = const [],
    this.newEntries = const [],
    this.findEntries = const [],
    this.appEntries = const [],
    this.refreshOn = const [],
    this.beforeQuit,
    this.restartRequested,
    this.onRestartCancelled,
    super.key,
  });

  final Widget child;
  final String Function(AppLocalizations l10n) appName;
  final GoRouter router;
  final bool enabled;
  final List<TrayEntry> openEntries;
  final List<TrayEntry> newEntries;
  final List<TrayEntry> findEntries;
  final List<TrayEntry> appEntries;
  final List<ProviderListenable<Object?>> refreshOn;
  final Future<void> Function({required bool restart})? beforeQuit;
  final ProviderListenable<bool>? restartRequested;
  final VoidCallback? onRestartCancelled;

  @override
  Widget build(BuildContext context) => child;
}
