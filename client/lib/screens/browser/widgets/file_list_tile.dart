import "package:flutter/material.dart";

import "package:polder/models/activity.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/pending_uploads_provider.dart";
import "package:polder/screens/browser/widgets/browser_selection.dart";
import "package:polder/screens/browser/widgets/file_actions_menu.dart";
import "package:polder/screens/browser/widgets/file_metadata_text.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/screens/browser/widgets/share_marks.dart";
import "package:polder/screens/browser/widgets/pending_upload_widgets.dart";
import "package:polder/widgets/tags/tag_chip.dart";

class FileListTile extends StatelessWidget {
  const FileListTile({required this.entry, required this.interaction, this.pending, this.syncing, super.key});

  final FileEntry entry;
  final EntryInteraction interaction;

  final PendingUpload? pending;

  final TransferDirectionKind? syncing;

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
      title: Row(
        spacing: 8,
        children: [
          Flexible(child: Text(entry.name, overflow: TextOverflow.ellipsis)),
          EntryTagChips(entry: entry),
        ],
      ),
      subtitle: switch ((upload, syncing)) {
        (final PendingUpload upload, _) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: PendingUploadStatus(upload: upload),
        ),
        (_, final TransferDirectionKind direction) => Row(
          spacing: 8,
          children: [
            Flexible(child: FileMetadataText(entry: entry)),
            FolderSyncTag(direction: direction),
          ],
        ),
        _ => FileMetadataText(entry: entry),
      },
      trailing: !entry.sharedByYou && onMenu == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (entry.sharedByYou) const SharedByYouMark(),
                if (onMenu != null) FileActionsButton(onPressed: onMenu),
              ],
            ),
      onTap: interaction.onTap,
    );
    return upload == null ? tile : PendingHighlight(child: tile);
  }
}
