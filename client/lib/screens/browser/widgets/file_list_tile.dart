import "package:flutter/material.dart";

import "package:nomad/models/file_entry.dart";
import "package:nomad/screens/browser/widgets/file_actions_menu.dart";
import "package:nomad/screens/browser/widgets/file_metadata_text.dart";
import "package:nomad/screens/browser/widgets/file_open_action.dart";
import "package:nomad/screens/browser/widgets/file_thumbnail.dart";

class FileListTile extends StatelessWidget {
  const FileListTile({required this.parentPath, required this.entry, super.key});

  final String parentPath;
  final FileEntry entry;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 4),
    leading: FileThumbnail(entry: entry, dimension: 40),
    title: Text(entry.name, overflow: TextOverflow.ellipsis),
    subtitle: FileMetadataText(entry: entry),
    trailing: FileActionsMenu(parentPath: parentPath, entry: entry),
    onTap: () => openEntry(context, entry),
  );
}
