import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/search.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/file_open_action.dart";
import "package:polder/screens/search/search_view.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/util/search_syntax.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";

bool _paletteOpen = false;

// Compact windows get a full page, so the keyboard and the results have the whole screen; larger
// windows get a palette over whatever is open.
Future<void> openSearch(BuildContext context, {String initialQuery = ""}) async {
  if (AdaptiveLayout.isPhone(context)) {
    if (GoRouter.of(context).routerDelegate.currentConfiguration.uri.path == AppRoutes.search) return;
    await context.push(AppRoutes.searchFor(initialQuery));
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

void showInFolder(BuildContext context, FileEntry entry) =>
    context.go(AppRoutes.filesAt(RemotePath.parent(entry.path), select: entry.name));

class _SearchPalette extends StatelessWidget {
  const _SearchPalette({required this.host, required this.initialQuery});

  // Results open from the page behind the palette, which outlives the palette itself.
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
          onGo: (route) => closeThen((host) => AppRoutes.isTab(route) ? host.go(route) : unawaited(host.push(route))),
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
    void close() => context.canPop() ? context.pop() : context.go(AppRoutes.files);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SearchView(
          initialQuery: initialQuery,
          leading: BackButton(onPressed: close),
          onOpenEntry: (entry) => openEntry(context, entry),
          onShowInFolder: (entry) => showInFolder(context, entry),
          onGo: (route) => AppRoutes.isTab(route) ? context.go(route) : context.pushReplacement(route),
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
    final apple = const {TargetPlatform.macOS, TargetPlatform.iOS}.contains(defaultTargetPlatform);
    if (!(apple ? keyboard.isMetaPressed : keyboard.isControlPressed) ||
        keyboard.isShiftPressed ||
        keyboard.isAltPressed) {
      return false;
    }
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return false;
    openSearch(context);
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// Searching from inside a folder starts out limited to that folder.
class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final apple = const {TargetPlatform.macOS, TargetPlatform.iOS}.contains(defaultTargetPlatform);
    return IconButton(
      tooltip: context.localized.searchTooltip(apple ? "⌘K" : "Ctrl+K"),
      icon: const Icon(IconsaxPlusLinear.search_normal_1),
      onPressed: () {
        final uri = GoRouterState.of(context).uri;
        final folder = uri.path == AppRoutes.files ? uri.queryParameters[AppRoutes.pathParameter] : null;
        final scope = folder == null || folder == RemotePath.root
            ? ""
            : appendSearchTag(
                "",
                formatSearchFilter(SearchFilter(key: SearchKey.folder, op: SearchOp.equals, values: [folder])),
              );
        openSearch(context, initialQuery: scope);
      },
    );
  }
}
