import "package:flutter/material.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/pending_uploads_provider.dart";
import "package:polder/screens/browser/widgets/browser_selection.dart";
import "package:polder/screens/browser/widgets/file_actions_menu.dart";
import "package:polder/screens/browser/widgets/file_metadata_text.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/screens/browser/widgets/pending_upload_widgets.dart";

class FileListTile extends StatelessWidget {
  const FileListTile({required this.entry, required this.interaction, this.pending, this.busy = false, super.key});

  final FileEntry entry;
  final EntryInteraction interaction;

  final PendingUpload? pending;

  final bool busy;

  @override
  Widget build(BuildContext context) {
    final upload = pending;
    final colors = Theme.of(context).colorScheme;
    final onIconTap = interaction.onIconTap;
    final onMenu = interaction.onMenu;
    final thumbnail = upload == null
        ? FileThumbnail(entry: entry, dimension: 40)
        : UploadRing(
            progress: upload.progress,
            child: FileThumbnail(entry: entry, dimension: 36),
          );
    final tile = ListTile(
      selected: interaction.selected,
      selectedTileColor: colors.secondaryContainer,
      selectedColor: colors.onSecondaryContainer,
      contentPadding: EdgeInsetsDirectional.only(start: upload == null ? 12 : 8, end: onMenu == null ? 16 : 4),
      leading: onIconTap == null
          ? thumbnail
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onIconTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  thumbnail,
                  PositionedDirectional(end: -6, bottom: -6, child: SelectionMark(selected: interaction.selected)),
                ],
              ),
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
      trailing: onMenu == null ? null : FileActionsButton(onPressed: onMenu),
      onTap: interaction.onTap,
    );
    return upload == null ? tile : PendingHighlight(child: tile);
  }
}
