import "package:flutter/material.dart";

import "package:nomad/providers/browser/pending_uploads_provider.dart";
import "package:nomad/screens/browser/widgets/file_grid_tile.dart";
import "package:nomad/screens/browser/widgets/pending_upload_widgets.dart";

class FileGridView extends StatelessWidget {
  const FileGridView({required this.parentPath, required this.items, required this.padding, super.key});

  final String parentPath;
  final List<BrowserItem> items;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: padding,
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 180,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
    ),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      final entry = item.entry;
      if (item.pendingFolder case final folder?) return PendingFolderGridTile(key: ValueKey(folder), name: folder);
      return entry == null
          ? PendingFileGridTile(key: ValueKey(item.name), upload: item.pending!)
          : FileGridTile(
              key: ValueKey(item.name),
              parentPath: parentPath,
              entry: entry,
              pending: item.pending,
              busy: item.busy,
            );
    },
  );
}
