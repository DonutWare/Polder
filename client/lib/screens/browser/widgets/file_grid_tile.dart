import "package:flutter/material.dart";

import "package:nomad/models/file_entry.dart";
import "package:nomad/screens/browser/widgets/file_actions_menu.dart";
import "package:nomad/screens/browser/widgets/file_open_action.dart";
import "package:nomad/screens/browser/widgets/file_thumbnail.dart";
import "package:nomad/theme/app_theme.dart";

class FileGridTile extends StatelessWidget {
  const FileGridTile({required this.parentPath, required this.entry, super.key});

  final String parentPath;
  final FileEntry entry;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    shape: squircle(AppRadius.inset + 4),
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
                child: LayoutBuilder(
                  builder: (context, constraints) =>
                      FileThumbnail(entry: entry, dimension: constraints.biggest.shortestSide, fill: true),
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
