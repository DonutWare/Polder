import "package:flutter/material.dart";

import "package:nomad/providers/browser/pending_uploads_provider.dart";
import "package:nomad/screens/browser/widgets/file_list_tile.dart";
import "package:nomad/screens/browser/widgets/pending_upload_widgets.dart";
import "package:nomad/widgets/shared/nav_group.dart";

class FileListView extends StatelessWidget {
  const FileListView({required this.parentPath, required this.items, required this.padding, super.key});

  final String parentPath;
  final List<BrowserItem> items;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: padding,
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      final entry = item.entry;
      return GroupedTile(
        key: ValueKey(item.name),
        index: index,
        count: items.length,
        child: switch (item) {
          BrowserItem(:final pendingFolder?) => PendingFolderListTile(name: pendingFolder),
          _ when entry == null => PendingFileListTile(upload: item.pending!),
          _ => FileListTile(parentPath: parentPath, entry: entry, pending: item.pending, busy: item.busy),
        },
      );
    },
  );
}
