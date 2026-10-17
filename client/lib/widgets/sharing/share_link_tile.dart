import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/sharing.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/icon_badge.dart";
import "package:polder/widgets/sharing/link_form_dialog.dart";
import "package:polder/widgets/sharing/share_labels.dart";

enum _LinkAction { copy, edit, delete }

Future<void> copyShareLink(BuildContext context, WidgetRef ref, ShareLink link) async {
  final serverUrl = ref.read(currentAccountProvider)?.serverUrl ?? "";
  final messenger = ScaffoldMessenger.maybeOf(context);
  final copied = context.localized.linkCopied;
  await Clipboard.setData(ClipboardData(text: link.url(serverUrl)));
  messenger?.showSnackBar(SnackBar(content: Text(copied)));
}

class ShareLinkTile extends ConsumerWidget {
  const ShareLinkTile({required this.link, this.fileId, this.showFileName = false, super.key});

  final ShareLink link;
  final int? fileId;
  final bool showFileName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final theme = Theme.of(context);
    final expired = link.isExpired(DateTime.now());
    final serverUrl = ref.watch(currentAccountProvider.select((account) => account?.serverUrl)) ?? "";
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 4),
      leading: IconBadge(
        icon: IconsaxPlusLinear.link_21,
        color: expired || !link.available ? theme.colorScheme.outline : null,
      ),
      title: Text(
        showFileName && link.file.name.isNotEmpty ? link.file.name : link.url(serverUrl),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _status(context, expired: expired),
        overflow: TextOverflow.ellipsis,
        style: expired ? TextStyle(color: theme.colorScheme.error) : null,
      ),
      onTap: () => copyShareLink(context, ref, link),
      trailing: PopupMenuButton<_LinkAction>(
        icon: const Icon(IconsaxPlusLinear.more),
        onSelected: (action) => switch (action) {
          _LinkAction.copy => copyShareLink(context, ref, link),
          _LinkAction.edit => _edit(context, ref),
          _LinkAction.delete => _delete(context, ref),
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _LinkAction.copy,
            child: ListTile(leading: const Icon(IconsaxPlusLinear.copy), title: Text(localized.linkCopy)),
          ),
          PopupMenuItem(
            value: _LinkAction.edit,
            child: ListTile(leading: const Icon(IconsaxPlusLinear.edit_2), title: Text(localized.edit)),
          ),
          PopupMenuItem(
            value: _LinkAction.delete,
            child: ListTile(
              leading: Icon(IconsaxPlusLinear.trash, color: theme.colorScheme.error),
              title: Text(localized.delete, style: TextStyle(color: theme.colorScheme.error)),
            ),
          ),
        ],
      ),
    );
  }

  String _status(BuildContext context, {required bool expired}) {
    final localized = context.localized;
    final notices = [
      if (!link.available) localized.shareUnavailable,
      if (expired)
        localized.linkExpired
      else if (link.expiresAt case final expiresAt?)
        localized.linkExpiresOn(expiresAt.formattedDate(context)),
      if (link.hasPassword) localized.linkPasswordSet,
    ];
    final shown = notices.isEmpty ? [for (final (label, _) in link.permissions.labels(localized)) label] : notices;
    return shown.join(" · ");
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final options = await showLinkFormDialog(context, isDir: link.file.isDir, link: link);
    if (options == null || !context.mounted) return;
    await context.runWithFeedback(ref.read(shareLinksProvider(fileId).notifier).edit(link, options));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.localized.deleteLinkTitle,
      message: context.localized.deleteLinkMessage,
      confirmLabel: context.localized.delete,
      destructive: true,
    );
    if (confirmed && context.mounted) {
      await context.runWithFeedback(ref.read(shareLinksProvider(fileId).notifier).remove(link));
    }
  }
}
