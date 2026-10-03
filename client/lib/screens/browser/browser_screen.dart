import "package:flutter/material.dart";

import "package:nomad/screens/browser/widgets/breadcrumbs.dart";
import "package:nomad/screens/browser/widgets/browser_add_button.dart";
import "package:nomad/screens/browser/widgets/directory_view.dart";
import "package:nomad/screens/browser/widgets/transfers_button.dart";
import "package:nomad/screens/browser/widgets/view_mode_button.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/util/remote_path.dart";
import "package:nomad/widgets/layout/app_page.dart";

class BrowserScreen extends StatelessWidget {
  const BrowserScreen({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context) => AppPage(
    title: Text(path == RemotePath.root ? context.localized.navFiles : RemotePath.name(path)),
    actions: const [TransfersButton(), ViewModeButton()],
    bottom: path == RemotePath.root
        ? null
        : PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: Breadcrumbs(path: path),
          ),
    body: DirectoryView(path: path),
    floatingActionButton: BrowserAddButton(path: path),
  );
}
