import "package:flutter/material.dart";

import "package:go_router/go_router.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/breadcrumbs.dart";
import "package:polder/screens/browser/widgets/browser_add_button.dart";
import "package:polder/screens/browser/widgets/directory_view.dart";
import "package:polder/screens/browser/widgets/sort_button.dart";
import "package:polder/screens/browser/widgets/transfers_button.dart";
import "package:polder/screens/browser/widgets/view_mode_button.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/layout/app_page.dart";

class BrowserScreen extends StatelessWidget {
  const BrowserScreen({required this.path, this.select, super.key});

  final String path;
  final String? select;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: path == RemotePath.root,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) context.go(AppRoutes.filesAt(RemotePath.parent(path)));
    },
    child: AppPage(
      title: Text(path == RemotePath.root ? context.localized.navFiles : RemotePath.name(path)),
      actions: const [TransfersButton(), SortButton(), ViewModeButton()],
      bottom: path == RemotePath.root
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Breadcrumbs(path: path),
            ),
      body: DirectoryView(path: path, select: select),
      floatingActionButton: BrowserAddButton(path: path),
    ),
  );
}
