import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/providers/appearance/appearance_provider.dart";
import "package:polder/routes/app_router.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/widgets/desktop/desktop_tray.dart";
import "package:polder/widgets/layout/window_titlebar.dart";

class PolderApp extends ConsumerStatefulWidget {
  const PolderApp({super.key});

  @override
  ConsumerState<PolderApp> createState() => _PolderAppState();
}

class _PolderAppState extends ConsumerState<PolderApp> {
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
