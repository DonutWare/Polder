import "package:material_ui/material_ui.dart";

import "package:polder_core/models/activity.dart";

import "package:polder_core/models/file_entry.dart";
import "package:polder_core/providers/browser/file_operations_provider.dart";
import "package:polder_drive/providers/browser/pending_uploads_provider.dart";
import "package:polder_drive/screens/browser/widgets/browser_selection.dart";
import "package:polder_drive/screens/browser/widgets/file_actions_menu.dart";
import "package:polder_drive/screens/browser/widgets/file_operation_widgets.dart";
import "package:polder_drive/screens/browser/widgets/file_thumbnail.dart";
import "package:polder_drive/screens/browser/widgets/offline_mark.dart";
import "package:polder_drive/screens/browser/widgets/share_marks.dart";
import "package:polder_drive/screens/browser/widgets/pending_upload_widgets.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/widgets/tags/tag_chip.dart";

class FileGridTile extends StatelessWidget {
  const FileGridTile({
    required this.entry,
    required this.interaction,
    this.pending,
    this.syncing,
    this.operation,
    super.key,
  });

  final FileEntry entry;
  final EntryInteraction interaction;
  final PendingUpload? pending;
  final TransferDirectionKind? syncing;
  final EntryOperation? operation;

  @override
  Widget build(BuildContext context) {
    final upload = pending;
    final colors = Theme.of(context).colorScheme;
    final selected = interaction.selected;
    final onIconTap = interaction.onIconTap;
    final onMenu = interaction.onMenu;
    final card = Card(
      margin: EdgeInsets.zero,
      color: selected ? colors.secondaryContainer : null,
      shape: squircle(
        AppRadius.inset + 4,
        side: upload == null && operation == null ? BorderSide.none : BorderSide(color: colors.primary, width: 1.5),
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
                      if (operation case final operation?)
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
                              child: EntryOperationStatus(operation: operation),
                            ),
                          ),
                        )
                      else if (upload != null)
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
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6),
                    child: EntryTagDots(entry: entry),
                  ),
                  OfflineMark(path: entry.path),
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
    if (operation case final operation?) return BusyEntry(operation: operation, child: card);
    return card;
  }
}
