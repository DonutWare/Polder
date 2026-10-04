import "package:flutter/material.dart";

import "package:nomad/models/file_entry.dart";
import "package:nomad/providers/browser/pending_uploads_provider.dart";
import "package:nomad/screens/browser/widgets/file_actions_menu.dart";
import "package:nomad/screens/browser/widgets/file_open_action.dart";
import "package:nomad/screens/browser/widgets/file_thumbnail.dart";
import "package:nomad/screens/browser/widgets/pending_upload_widgets.dart";
import "package:nomad/theme/app_theme.dart";

class FileGridTile extends StatelessWidget {
  const FileGridTile({required this.parentPath, required this.entry, this.pending, this.busy = false, super.key});

  final String parentPath;
  final FileEntry entry;
  final PendingUpload? pending;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final upload = pending;
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      shape: squircle(
        AppRadius.inset + 4,
        side: upload == null ? BorderSide.none : BorderSide(color: primary, width: 1.5),
      ),
      child: InkWell(
        onTap: () => openEntry(context, entry),
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
                      if (busy) const PositionedDirectional(top: 8, start: 8, child: FolderUploadingTag()),
                      if (upload != null)
                        Positioned(
                          left: 8,
                          right: 8,
                          bottom: 8,
                          child: DecoratedBox(
                            decoration: ShapeDecoration(
                              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
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
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 14),
                    child: Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                FileActionsMenu(parentPath: parentPath, entry: entry),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
