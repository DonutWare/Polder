import "package:flutter/material.dart";

import "package:nomad/models/file_entry.dart";
import "package:nomad/screens/browser/widgets/file_grid_tile.dart";

class FileGridView extends StatelessWidget {
  const FileGridView({required this.parentPath, required this.entries, required this.padding, super.key});

  final String parentPath;
  final List<FileEntry> entries;
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
    itemCount: entries.length,
    itemBuilder: (context, index) => FileGridTile(parentPath: parentPath, entry: entries[index]),
  );
}
