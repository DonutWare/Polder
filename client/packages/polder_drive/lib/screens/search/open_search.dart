import "dart:async";

import "package:flutter/foundation.dart";
import "package:material_ui/material_ui.dart";
import "package:flutter/services.dart";

import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_core/models/file_entry.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_drive/routes/drive_routes.dart";
import "package:polder_drive/screens/browser/widgets/file_open_action.dart";
import "package:polder_drive/screens/search/search_view.dart";
import "package:polder_drive/search_host.dart";
import "package:polder_ui/polder_ui_config.dart";
import "package:polder_ui/routes/up_scope.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/adaptive_layout/adaptive_layout.dart";
import "package:polder_ui/util/localization_helper.dart";

bool _paletteOpen = false;

Future<void> openSearch(BuildContext context, {String initialQuery = ""}) async {
  if (AdaptiveLayout.isPhone(context)) {
    if (GoRouter.of(context).routerDelegate.currentConfiguration.uri.path == DriveRoutes.search) return;
    await context.push(DriveRoutes.searchFor(initialQuery));
    return;
  }
  if (_paletteOpen) return;
  _paletteOpen = true;
  try {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _SearchPalette(host: context, initialQuery: initialQuery),
    );
  } finally {
    _paletteOpen = false;
  }
}

void openSearchInScope(BuildContext context, Uri location) =>
    unawaited(openSearch(context, initialQuery: searchHostOf(context).scopeFor(context, location)));

void showInFolder(BuildContext context, FileEntry entry) =>
    context.go(DriveRoutes.filesAt(RemotePath.parent(entry.path), select: entry.name));

void _goFromSearch(BuildContext context, String route) =>
    readPolderUiConfig(context).isTopLevel(route) ? context.go(route) : unawaited(context.push(route));

class _SearchPalette extends StatelessWidget {
  const _SearchPalette({required this.host, required this.initialQuery});

  final BuildContext host;
  final String initialQuery;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    void closeThen(void Function(BuildContext host) action) {
      Navigator.of(context).pop();
      if (host.mounted) action(host);
    }

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.only(top: size.height * 0.1, left: 24, right: 24, bottom: 24),
      shape: squircle(AppRadius.panel),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720, maxHeight: size.height * 0.75),
        child: SearchView(
          initialQuery: initialQuery,
          onOpenEntry: (entry) => closeThen((host) => openEntry(host, entry)),
          onShowInFolder: (entry) => closeThen((host) => showInFolder(host, entry)),
          onGo: (route) => closeThen((host) => _goFromSearch(host, route)),
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({this.initialQuery = "", super.key});

  final String initialQuery;

  @override
  Widget build(BuildContext context) {
    void close() => context.canPop() ? context.pop() : unawaited(UpScope.navigateUp(context));
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SearchView(
          initialQuery: initialQuery,
          leading: BackButton(onPressed: close),
          onOpenEntry: (entry) => openEntry(context, entry),
          onShowInFolder: (entry) => showInFolder(context, entry),
          onGo: (route) =>
              readPolderUiConfig(context).isTopLevel(route) ? context.go(route) : context.pushReplacement(route),
          onClose: close,
        ),
      ),
    );
  }
}

class SearchShortcut extends StatefulWidget {
  const SearchShortcut({required this.child, super.key});

  final Widget child;

  @override
  State<SearchShortcut> createState() => _SearchShortcutState();
}

class _SearchShortcutState extends State<SearchShortcut> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.keyK) return false;
    final keyboard = HardwareKeyboard.instance;
    if (!(_usesCommandKey ? keyboard.isMetaPressed : keyboard.isControlPressed) ||
        keyboard.isShiftPressed ||
        keyboard.isAltPressed) {
      return false;
    }
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return false;
    openSearchInScope(context, GoRouter.of(context).routerDelegate.currentConfiguration.uri);
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.localized.searchTooltip(_usesCommandKey ? "⌘K" : "Ctrl+K"),
    icon: const Icon(IconsaxPlusLinear.search_normal_1),
    onPressed: () => openSearchInScope(context, GoRouterState.of(context).uri),
  );
}

bool get _usesCommandKey => const {TargetPlatform.macOS, TargetPlatform.iOS}.contains(defaultTargetPlatform);
