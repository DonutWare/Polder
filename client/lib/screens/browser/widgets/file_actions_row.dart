import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/screens/browser/widgets/file_actions_menu.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/icon_badge.dart";

class FileActionsRow extends ConsumerWidget {
  const FileActionsRow({
    required this.entry,
    this.onRenamed,
    this.onRemoved,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  static const _tileWidth = 76.0;

  final FileEntry entry;
  final ValueChanged<String>? onRenamed;
  final VoidCallback? onRemoved;
  final EdgeInsets padding;

  String get _parentPath => RemotePath.parent(entry.path);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(directoryProvider(_parentPath).select((_) => null));
    final actions = FileActions.available(ref, [entry]).where((action) => action != FileAction.open);
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final action in actions)
            SizedBox(
              width: _tileWidth,
              child: InkWell(
                customBorder: squircle(AppRadius.inset),
                onTap: () => FileActions.perform(
                  context,
                  ref,
                  action,
                  parentPath: _parentPath,
                  entries: [entry],
                  onRenamed: onRenamed,
                  onRemoved: onRemoved,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    spacing: 6,
                    children: [
                      IconBadge(
                        icon: FileActions.iconOf(action),
                        color: action == FileAction.delete ? colors.error : colors.primary,
                        size: 44,
                      ),
                      Text(
                        FileActions.labelOf(context, action),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
