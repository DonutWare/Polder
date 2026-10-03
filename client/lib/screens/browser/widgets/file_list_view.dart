import "package:flutter/material.dart";

import "package:nomad/models/file_entry.dart";
import "package:nomad/screens/browser/widgets/file_list_tile.dart";
import "package:nomad/widgets/shared/nav_group.dart";

class FileListView extends StatelessWidget {
  const FileListView({required this.parentPath, required this.entries, required this.padding, super.key});

  final String parentPath;
  final List<FileEntry> entries;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: padding,
    itemCount: entries.length,
    itemBuilder: (context, index) => GroupedTile(
      index: index,
      count: entries.length,
      child: FileListTile(parentPath: parentPath, entry: entries[index]),
    ),
  );
}
