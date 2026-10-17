import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/sharing.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/file_type_icon.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/detail_row.dart";
import "package:polder/widgets/sharing/share_labels.dart";

Future<void> showIncomingShareDetails(BuildContext context, IncomingShare share) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _IncomingShareDetailsSheet(share: share),
);

class _IncomingShareDetailsSheet extends ConsumerWidget {
  const _IncomingShareDetailsSheet({required this.share});

  final IncomingShare share;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final theme = Theme.of(context);
    final groups = share.groups;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: FileTypeIcon.of(isDir: share.entry.isDir, mime: share.entry.mime, size: 64),
            ),
            const SizedBox(height: 16),
            Text(share.entry.name, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            DetailRow(label: localized.shareDetailsOwner, value: share.owner.name),
            if (groups.isNotEmpty)
              DetailRow(
                label: localized.shareDetailsGroups(groups.length),
                value: groups.map((group) => group.name).join(", "),
              ),
            DetailRow(label: localized.shareDetailsAccess, value: share.permissions.summary(localized)),
            DetailRow(
              label: localized.linkExpiry,
              value: switch (share.expiresAt) {
                final expiresAt? => expiresAt.formattedDate(context),
                null => localized.linkNoExpiry,
              },
            ),
            if (share.note.isNotEmpty) DetailRow(label: localized.shareDetailsNote, value: share.note),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(IconsaxPlusLinear.folder_open),
              label: Text(localized.open),
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.context.go(AppRoutes.sharedAt(share.id));
              },
            ),
            if (share.direct) ...[
              const SizedBox(height: 8),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                onPressed: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.context.runWithFeedback(ref.read(incomingSharesProvider.notifier).leave(share));
                },
                child: Text(localized.shareLeave),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
