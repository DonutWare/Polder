import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:quick_actions/quick_actions.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/providers/shortcuts/app_shortcut_runner.dart";
import "package:polder/services/shortcuts/app_shortcut.dart";

class LauncherShortcuts extends ConsumerStatefulWidget {
  const LauncherShortcuts({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<LauncherShortcuts> createState() => _LauncherShortcutsState();
}

class _LauncherShortcutsState extends ConsumerState<LauncherShortcuts> {
  static final _supported =
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  final _quickActions = const QuickActions();
  List<(String, String)>? _published;

  @override
  void initState() {
    super.initState();
    if (!_supported) return;
    unawaited(_quickActions.initialize(_launched));
    ref.listenManual(currentAccountProvider.select((account) => account == null), (_, _) => _publish());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_supported) _publish();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _launched(String type) {
    if (AppShortcut.fromSlug(type) case final shortcut?) unawaited(ref.read(appShortcutRunnerProvider).run(shortcut));
  }

  void _publish() {
    final signedIn = ref.read(currentAccountProvider) != null;
    final canScan = ref.read(documentScannerServiceProvider).isSupported;
    final shortcuts = signedIn ? AppShortcut.forLauncher(canScan: canScan) : const <AppShortcut>[];
    final items = [
      for (final shortcut in shortcuts)
        ShortcutItem(type: shortcut.slug, localizedTitle: shortcut.label(context), icon: shortcut.iconName),
    ];
    final published = [for (final item in items) (item.type, item.localizedTitle)];
    if (listEquals(published, _published)) return;
    _published = published;
    unawaited(_quickActions.setShortcutItems(items));
  }
}
