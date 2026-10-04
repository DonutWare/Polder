import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/l10n/generated/app_localizations.dart";
import "package:nomad/providers/appearance/appearance_provider.dart";
import "package:nomad/routes/app_router.dart";
import "package:nomad/theme/app_theme.dart";
import "package:nomad/widgets/layout/window_titlebar.dart";

class NomadApp extends ConsumerStatefulWidget {
  const NomadApp({super.key});

  @override
  ConsumerState<NomadApp> createState() => _NomadAppState();
}

class _NomadAppState extends ConsumerState<NomadApp> {
  late final AppLifecycleListener _lifecycle;

  Color? _seed;
  late ThemeData _light;
  late ThemeData _dark;

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

  void _updateThemes(Color seed) {
    if (seed == _seed) return;
    _seed = seed;
    _light = AppTheme.build(seed, Brightness.light);
    _dark = AppTheme.build(seed, Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final appearance = ref.watch(appearanceProvider);
    _updateThemes(appearance.seed);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: _light,
      darkTheme: _dark,
      themeMode: appearance.mode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (_, child) => WindowTitlebar(child: child!),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
