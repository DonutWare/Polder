import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_mount.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/federation/federation_providers.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/detail_row.dart";
import "package:polder/widgets/sharing/share_labels.dart";

Future<void> showMountDetails(BuildContext context, FileEntry entry) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _MountDetailsSheet(entry: entry),
);

class _MountDetailsSheet extends ConsumerWidget {
  const _MountDetailsSheet({required this.entry});

  final FileEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mount = entry.mount!;
    final localized = context.localized;
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: FileThumbnail(entry: entry, dimension: 96, fill: true)),
            const SizedBox(height: 16),
            Text(RemotePath.name(mount.path), style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            MountDetailRows(mount: mount),
            if (mount.canLeave) ...[
              const SizedBox(height: 16),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                onPressed: () => _leave(context, ref, mount),
                child: Text(localized.shareLeave),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _leave(BuildContext context, WidgetRef ref, FileMount mount) async {
    final localized = context.localized;
    final navigator = Navigator.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: localized.removeFederatedTitle(RemotePath.name(mount.path)),
      message: localized.leaveShareMessage(mount.ownerName.isEmpty ? mount.owner : mount.ownerName),
      confirmLabel: localized.remove,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    navigator.pop();
    final outer = navigator.context;
    final left = await outer.runWithFeedback(_leaveMount(ref, mount));
    if (!left || !outer.mounted) return;
    final browsing = GoRouter.of(outer).state.uri.queryParameters[AppRoutes.pathParameter];
    if (browsing != null && mount.contains(browsing)) outer.go(AppRoutes.filesAt(RemotePath.root));
  }

  Future<void> _leaveMount(WidgetRef ref, FileMount mount) async {
    final api = ref.read(polderApiProvider);
    if (mount.isFederated) {
      await api.removeIncomingFederatedShare(mount.shareId);
      ref.invalidate(incomingFederatedSharesProvider);
      ref.invalidate(directoryProvider);
    } else {
      await api.removeShare(mount.shareId);
      invalidateShares(ref.invalidate);
    }
  }
}

class MountDetailRows extends StatelessWidget {
  const MountDetailRows({required this.mount, super.key});

  final FileMount mount;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailRow(label: localized.shareDetailsOwner, value: mount.shownOwner),
        if (mount.server.isNotEmpty) DetailRow(label: localized.server, value: mount.server),
        if (mount.provider.isNotEmpty) DetailRow(label: localized.shareDetailsSoftware, value: mount.provider),
        if (mount.groups.isNotEmpty)
          DetailRow(label: localized.shareDetailsGroups(mount.groups.length), value: mount.groups.join(", ")),
        DetailRow(label: localized.shareDetailsAccess, value: mount.permissions.summary(localized)),
        DetailRow(label: localized.shareDetailsSharedOn, value: mount.sharedAt.formattedDate(context)),
        if (mount.expiresAt case final expiresAt?)
          DetailRow(label: localized.linkExpiry, value: expiresAt.formattedDate(context)),
        if (mount.note.isNotEmpty) DetailRow(label: localized.shareDetailsNote, value: mount.note),
      ],
    );
  }
}
