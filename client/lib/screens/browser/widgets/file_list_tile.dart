import "package:flutter/material.dart";

import "package:nomad/models/file_entry.dart";
import "package:nomad/providers/browser/pending_uploads_provider.dart";
import "package:nomad/screens/browser/widgets/file_actions_menu.dart";
import "package:nomad/screens/browser/widgets/file_metadata_text.dart";
import "package:nomad/screens/browser/widgets/file_open_action.dart";
import "package:nomad/screens/browser/widgets/file_thumbnail.dart";
import "package:nomad/screens/browser/widgets/pending_upload_widgets.dart";

class FileListTile extends StatelessWidget {
  const FileListTile({required this.parentPath, required this.entry, this.pending, this.busy = false, super.key});

  final String parentPath;
  final FileEntry entry;

  final PendingUpload? pending;

  final bool busy;

  @override
  Widget build(BuildContext context) {
    final upload = pending;
    final tile = ListTile(
      contentPadding: EdgeInsetsDirectional.only(start: upload == null ? 12 : 8, end: 4),
      leading: upload == null
          ? FileThumbnail(entry: entry, dimension: 40)
          : UploadRing(
              progress: upload.progress,
              child: FileThumbnail(entry: entry, dimension: 36),
            ),
      title: Text(entry.name, overflow: TextOverflow.ellipsis),
      subtitle: switch ((upload, busy)) {
        (final PendingUpload upload, _) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: PendingUploadStatus(upload: upload),
        ),
        (_, true) => Row(
          spacing: 8,
          children: [
            Flexible(child: FileMetadataText(entry: entry)),
            const FolderUploadingTag(),
          ],
        ),
        _ => FileMetadataText(entry: entry),
      },
      trailing: FileActionsMenu(parentPath: parentPath, entry: entry),
      onTap: () => openEntry(context, entry),
    );
    return upload == null ? tile : PendingHighlight(child: tile);
  }
}
