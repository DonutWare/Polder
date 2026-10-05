import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/sync/sync_root.dart";
import "package:polder/providers/sync/sync_roots_provider.dart";
import "package:polder/screens/sync/widgets/sync_root_tile.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/nav_group.dart";

class SyncRootsList extends ConsumerWidget {
  const SyncRootsList({required this.mode, super.key});

  final SyncMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roots = ref.watch(syncRootsByModeProvider(mode));
    return NavGroup(
      title: context.localized.folders,
      children: [
        if (roots.isEmpty)
          ListTile(
            title: Text(
              context.localized.noFolders,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          )
        else
          for (final root in roots) SyncRootTile(root: root),
      ],
    );
  }
}
