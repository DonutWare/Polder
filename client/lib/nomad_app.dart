import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/l10n/generated/app_localizations.dart";
import "package:nomad/providers/appearance/appearance_provider.dart";
import "package:nomad/routes/app_router.dart";
import "package:nomad/theme/app_theme.dart";
import "package:nomad/widgets/desktop/desktop_tray.dart";
import "package:nomad/widgets/layout/window_titlebar.dart";

class NomadApp extends ConsumerStatefulWidget {
  const NomadApp({super.key});

  @override
  ConsumerState<NomadApp> createState() => _NomadAppState();
}

class _NomadAppState extends ConsumerState<NomadApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => ref.read(appearanceProvider.notifier).refreshSystemAccent());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appearance = ref.watch(appearanceProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.build(appearance.seed, Brightness.light),
      darkTheme: AppTheme.build(appearance.seed, Brightness.dark),
      themeMode: appearance.mode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (_, child) => DesktopTray(child: WindowTitlebar(child: child!)),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
