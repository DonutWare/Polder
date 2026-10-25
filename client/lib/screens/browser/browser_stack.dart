import "package:flutter/widgets.dart";

import "package:polder/routes/up_scope.dart";
import "package:polder/screens/browser/browser_screen.dart";
import "package:polder/screens/browser/widgets/browser_scope.dart";
import "package:polder/util/remote_path.dart";

class BrowserStack extends StatelessWidget {
  const BrowserStack({required this.path, this.select, super.key});

  final String path;
  final String? select;

  @override
  Widget build(BuildContext context) {
    final routes = BrowserRoutes.of(context);
    return PageStack(
      pages: [
        for (final folder in _foldersDownTo(routes.root))
          StackPage(
            location: routes.routeFor(folder),
            key: ValueKey(folder),
            child: BrowserScreen(key: ValueKey(folder), path: folder, select: folder == path ? select : null),
          ),
      ],
    );
  }

  List<String> _foldersDownTo(String root) {
    final folders = [path];
    while (folders.last != root && folders.last != RemotePath.root) {
      folders.add(RemotePath.parent(folders.last));
    }
    return folders.reversed.toList();
  }
}
