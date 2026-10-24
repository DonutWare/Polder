import "package:flutter/material.dart";

import "package:polder/models/activity.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/pending_uploads_provider.dart";
import "package:polder/screens/browser/widgets/browser_selection.dart";
import "package:polder/screens/browser/widgets/file_actions_menu.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/screens/browser/widgets/share_marks.dart";
import "package:polder/screens/browser/widgets/pending_upload_widgets.dart";
import "package:polder/theme/app_theme.dart";

class FileGridTile extends StatelessWidget {
  const FileGridTile({required this.entry, required this.interaction, this.pending, this.syncing, super.key});

  final FileEntry entry;
  final EntryInteraction interaction;
  final PendingUpload? pending;
  final TransferDirectionKind? syncing;

  @override
  Widget build(BuildContext context) {
    final upload = pending;
    final colors = Theme.of(context).colorScheme;
    final selected = interaction.selected;
    final onIconTap = interaction.onIconTap;
    final onMenu = interaction.onMenu;
    return Card(
      margin: EdgeInsets.zero,
      color: selected ? colors.secondaryContainer : null,
      shape: squircle(
        AppRadius.inset + 4,
        side: upload == null ? BorderSide.none : BorderSide(color: colors.primary, width: 1.5),
      ),
      child: InkWell(
        onTap: interaction.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: DecoratedBox(
                  decoration: ShapeDecoration(color: AppColors.of(context).inset, shape: squircle(AppRadius.inset)),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, constraints) =>
                              FileThumbnail(entry: entry, dimension: constraints.biggest.shortestSide, fill: true),
                        ),
                      ),
                      if (syncing case final direction?)
                        PositionedDirectional(top: 8, start: 8, child: FolderSyncTag(direction: direction)),
                      if (onIconTap != null)
                        PositionedDirectional(
                          top: 0,
                          end: 0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onIconTap,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: SelectionMark(selected: selected, showUnselected: true),
                            ),
                          ),
                        ),
                      if (upload != null)
                        Positioned(
                          left: 8,
                          right: 8,
                          bottom: 8,
                          child: DecoratedBox(
                            decoration: ShapeDecoration(
                              color: colors.surface.withValues(alpha: 0.9),
                              shape: squircle(AppRadius.tag),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: PendingGridStatus(upload: upload),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(start: 14, end: onMenu == null ? 14 : 0),
                      child: Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: selected ? colors.onSecondaryContainer : null,
                        ),
                      ),
                    ),
                  ),
                  if (entry.sharedByYou)
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: onMenu == null ? 10 : 0),
                      child: const SharedByYouMark(),
                    ),
                  if (onMenu != null) FileActionsButton(onPressed: onMenu),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
