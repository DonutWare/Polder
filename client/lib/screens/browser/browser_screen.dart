import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/providers/browser/browser_selection_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/breadcrumbs.dart";
import "package:polder/screens/browser/widgets/browser_add_button.dart";
import "package:polder/screens/browser/widgets/directory_view.dart";
import "package:polder/screens/browser/widgets/file_actions_menu.dart";
import "package:polder/screens/browser/widgets/sort_button.dart";
import "package:polder/screens/browser/widgets/transfers_button.dart";
import "package:polder/screens/browser/widgets/view_mode_button.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/layout/app_page.dart";

class BrowserScreen extends ConsumerWidget {
  const BrowserScreen({required this.path, this.select, super.key});

  final String path;
  final String? select;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(browserSelectionProvider(path));
    final notifier = ref.read(browserSelectionProvider(path).notifier);
    final selecting = !usesPointerSelection && selection.isNotEmpty;
    final material = MaterialLocalizations.of(context);
    return PopScope(
      canPop: path == RemotePath.root && !selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (selecting) return notifier.clear();
        context.go(AppRoutes.filesAt(RemotePath.parent(path)));
      },
      child: AppPage(
        leading: selecting
            ? IconButton(
                tooltip: material.closeButtonTooltip,
                icon: const Icon(IconsaxPlusLinear.close_circle),
                onPressed: notifier.clear,
              )
            : null,
        title: selecting
            ? Text(material.selectedRowCountTitle(selection.length))
            : Text(path == RemotePath.root ? context.localized.navFiles : RemotePath.name(path)),
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
        bottom: path == RemotePath.root
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: Breadcrumbs(path: path),
              ),
        body: DirectoryView(path: path, select: select),
        floatingActionButton: selecting ? null : BrowserAddButton(path: path),
      ),
    );
  }
}
