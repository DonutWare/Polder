import "dart:async";

import "package:material_ui/material_ui.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/branding/branding_provider.dart";
import "package:polder_core/providers/connection/server_connection_provider.dart";
import "package:polder_core/providers/offline/offline_sync_provider.dart";
import "package:polder_window/window_titlebar.dart";

import "package:polder_ui/l10n/generated/app_localizations.dart";
import "package:polder_ui/providers/appearance/appearance_provider.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/adaptive_layout/adaptive_layout.dart";

class StandaloneApp extends ConsumerStatefulWidget {
  const StandaloneApp({
    required this.title,
    required this.router,
    this.localizationsDelegates = const [],
    this.wrap,
    this.onResume,
    super.key,
  });

  final String Function(AppLocalizations localized) title;
  final GoRouter router;
  final List<LocalizationsDelegate<Object?>> localizationsDelegates;
  final Widget Function(Widget child)? wrap;
  final VoidCallback? onResume;

  @override
  ConsumerState<StandaloneApp> createState() => _StandaloneAppState();
}

class _StandaloneAppState extends ConsumerState<StandaloneApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  void _onResume() {
    ref.read(appearanceProvider.notifier).refreshSystemAccent();
    widget.onResume?.call();
    if (ref.read(currentAccountProvider) == null || ref.read(sessionEndedProvider)) return;
    unawaited(ref.read(serverConnectionProvider.notifier).check());
    ref.read(offlineSyncProvider.notifier).kickAll();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appearance = ref.watch(appearanceProvider);
    final seed = appearance.seedWith(ref.watch(brandingProvider).accent);
    ref.watch(offlineSyncProvider);
    final restoringAccount = ref.watch(accountProvider.select((account) => account.isLoading && !account.hasValue));
    return MaterialApp.router(
      onGenerateTitle: (context) => widget.title(AppLocalizations.of(context)),
      theme: AppTheme.build(seed, Brightness.light),
      darkTheme: AppTheme.build(seed, Brightness.dark),
      themeMode: appearance.mode,
      localizationsDelegates: [...AppLocalizations.localizationsDelegates, ...widget.localizationsDelegates],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => restoringAccount
          ? ColoredBox(color: Theme.of(context).colorScheme.surface)
          : AdaptiveLayoutBuilder(child: (_) => WindowTitlebar(child: widget.wrap?.call(child!) ?? child!)),
      routerConfig: widget.router,
    );
  }
}
