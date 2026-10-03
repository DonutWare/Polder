import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/providers/sync/sync_roots_provider.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/shared/confirm_dialog.dart";
import "package:nomad/widgets/shared/icon_badge.dart";

class SyncRootTile extends ConsumerWidget {
  const SyncRootTile({required this.root, super.key});

  final SyncRoot root;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(syncRootsProvider.notifier);
    return ListTile(
      leading: IconBadge(
        icon: root.mode == SyncMode.sync ? IconsaxPlusLinear.refresh_2 : IconsaxPlusLinear.gallery_import,
        color: root.enabled ? null : Theme.of(context).colorScheme.outline,
      ),
      title: Text(root.localPath, overflow: TextOverflow.ellipsis),
      subtitle: Text(context.localized.syncedWith(root.remotePath)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(value: root.enabled, onChanged: (enabled) => notifier.setEnabled(root, enabled)),
          IconButton(
            tooltip: context.localized.remove,
            icon: const Icon(IconsaxPlusLinear.trash),
            onPressed: () => _confirmRemove(context, notifier),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, SyncRootsNotifier notifier) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.localized.removeSyncFolderTitle,
      message: context.localized.removeSyncFolderMessage,
      confirmLabel: context.localized.remove,
    );
    if (confirmed) await notifier.remove(root);
  }
}
