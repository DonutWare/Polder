import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/providers/browser/browser_selection_provider.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/widgets/navigation/intercept_back.dart";
import "package:polder/screens/browser/widgets/breadcrumbs.dart";
import "package:polder/screens/browser/widgets/browser_add_button.dart";
import "package:polder/screens/browser/widgets/browser_scope.dart";
import "package:polder/screens/browser/widgets/directory_view.dart";
import "package:polder/screens/browser/widgets/file_actions_menu.dart";
import "package:polder/screens/browser/widgets/sort_button.dart";
import "package:polder/screens/browser/widgets/transfers_button.dart";
import "package:polder/screens/browser/widgets/view_mode_button.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";

class BrowserScreen extends ConsumerWidget {
  const BrowserScreen({required this.path, this.select, super.key});

  final String path;
  final String? select;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = BrowserRoutes.of(context);
    final parentRoute = routes.parentRoute(path);
    final mount = ref.watch(directoryProvider(path)).value?.mount;
    final canAdd = mount == null || mount.permissions.create;
    final selection = ref.watch(browserSelectionProvider(path));
    final notifier = ref.read(browserSelectionProvider(path).notifier);
    final selecting = !AdaptiveLayout.usesPointer(context) && selection.isNotEmpty;
    final material = MaterialLocalizations.of(context);
    return InterceptBack(
      active: selecting,
      child: BackButtonListener(
        onBackButtonPressed: () async {
          if (!selecting || !isFrontmost(context)) return false;
          notifier.clear();
          return true;
        },
        child: AppPage(
          leading: selecting
              ? IconButton(
                  tooltip: material.closeButtonTooltip,
                  icon: const Icon(IconsaxPlusLinear.close_circle),
                  onPressed: notifier.clear,
                )
              : routes.exitRoute == null
              ? null
              : BackButton(onPressed: () => context.go(parentRoute!)),
          title: selecting
              ? Text(material.selectedRowCountTitle(selection.length))
              : routes.isRoot(path)
              ? Text(routes.rootLabel ?? context.localized.navFiles)
              : Breadcrumbs(path: path, acceptsMoves: true, padding: EdgeInsets.zero),
          actions: selecting
              ? [
                  IconButton(
                    tooltip: material.selectAllButtonLabel,
                    icon: const Icon(IconsaxPlusLinear.tick_square),
                    onPressed: notifier.selectAll,
                  ),
                  FileActionsButton(
                    onPressed: (position) => FileActions.showMenuFor(
                      context,
                      ref,
                      parentPath: path,
                      entries: notifier.selectedEntries,
                      position: position,
                    ),
                  ),
                ]
              : const [TransfersButton(), SortButton(), ViewModeButton()],
          body: DirectoryView(path: path, select: select),
          floatingActionButton: selecting || !canAdd ? null : BrowserAddButton(path: path),
        ),
      ),
    );
  }
}
