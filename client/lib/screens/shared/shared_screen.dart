import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/federation.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/federation/federation_providers.dart";
import "package:polder/providers/sharing/shares_in_files_provider.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/file_type_icon.dart";
import "package:polder/screens/shared/mounted_share_screen.dart";
import "package:polder/screens/shared/widgets/federation_invite_dialogs.dart";
import "package:polder/screens/shared/widgets/incoming_share_details_sheet.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/layout/dual_pane.dart";
import "package:polder/widgets/navigation/navigation_shell.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/message_view.dart";
import "package:polder/widgets/shared/refreshable_empty_view.dart";
import "package:polder/widgets/sharing/share_labels.dart";
import "package:polder/widgets/sharing/share_link_tile.dart";
import "package:polder/widgets/sharing/share_panel.dart";

class SharedScreen extends ConsumerWidget {
  const SharedScreen({this.section, this.shareId, this.path = "/", super.key});

  final SharedSection? section;
  final int? shareId;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    return DualPane(
      title: Text(localized.navShared),
      listLocation: AppRoutes.shared,
      list: _SectionList(selected: DualPane.highlights(context) ? section ?? SharedSection.withMe : null),
      placeholder: MessageView(icon: IconsaxPlusLinear.share, message: localized.nothingSelected),
      defaultDetail: const _IncomingPage(key: ValueKey(SharedSection.withMe)),
      detail: switch ((section, shareId)) {
        (SharedSection.federated, final int shareId) => MountedShareScreen(
          key: ValueKey("federated-$shareId"),
          origin: ShareOrigin.federated,
          shareId: shareId,
          path: path,
          exitRoute: AppRoutes.sharedSection(SharedSection.federated.segment),
        ),
        (_, final int shareId) => MountedShareScreen(
          key: ValueKey("share-$shareId"),
          origin: ShareOrigin.local,
          shareId: shareId,
          path: path,
          exitRoute: AppRoutes.sharedSection(SharedSection.withMe.segment),
        ),
        (SharedSection.withMe, _) => const _IncomingPage(key: ValueKey(SharedSection.withMe)),
        (SharedSection.byMe, _) => const _OutgoingPage(key: ValueKey(SharedSection.byMe)),
        (SharedSection.links, _) => const _LinksPage(key: ValueKey(SharedSection.links)),
        (SharedSection.federated, _) => const _FederatedPage(key: ValueKey(SharedSection.federated)),
        (null, _) => null,
      },
    );
  }
}

class _SectionList extends ConsumerWidget {
  const _SectionList({required this.selected});

  final SharedSection? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final incoming = ref.watch(incomingSharesProvider).value?.length;
    final outgoing = ref.watch(outgoingSharesProvider(null)).value?.map((share) => share.file.id).toSet().length;
    final links = ref.watch(shareLinksProvider(null)).value?.length;
    final federation = ref.watch(federationStatusProvider).value?.enabled ?? false;
    final federated = federation ? ref.watch(incomingFederatedSharesProvider).value : null;
    Widget item(SharedSection section, IconData icon, String label, int? count) => SidebarItem(
      icon: icon,
      label: label,
      selected: selected == section,
      detail: count == null || count == 0 ? null : "$count",
      onTap: () => context.go(AppRoutes.sharedSection(section.segment)),
    );
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        item(SharedSection.withMe, IconsaxPlusLinear.import_1, localized.sharedWithMe, incoming),
        item(SharedSection.byMe, IconsaxPlusLinear.export_1, localized.sharedByMe, outgoing),
        item(SharedSection.links, IconsaxPlusLinear.link_21, localized.shareLinks, links),
        if (federation)
          item(
            SharedSection.federated,
            IconsaxPlusLinear.global,
            localized.sharedFromOtherServers,
            federated?.where((share) => share.isPending).length,
          ),
        const Divider(height: 24),
        const _SharesInFilesSwitch(),
      ],
    );
  }
}

class _SharesInFilesSwitch extends ConsumerWidget {
  const _SharesInFilesSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shown = ref.watch(sharesInFilesProvider).value;
    return SwitchListTile(
      secondary: const Icon(IconsaxPlusLinear.folder_2),
      title: Text(context.localized.showSharesInFiles),
      subtitle: Text(context.localized.showSharesInFilesHint),
      value: shown ?? true,
      onChanged: shown == null
          ? null
          : (value) => context.runWithFeedback(ref.read(sharesInFilesProvider.notifier).setShown(value)),
    );
  }
}

class _SectionPage extends StatelessWidget {
  const _SectionPage({
    required this.title,
    required this.onRefresh,
    required this.empty,
    required this.children,
    this.actions = const [],
  });

  final String title;
  final Future<void> Function() onRefresh;
  final Widget empty;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => AppPage(
    title: Text(title),
    actions: actions,
    body: ReadableWidth(
      maxWidth: 840,
      builder: (context, inset) => RefreshIndicator(
        edgeOffset: inset.top,
        onRefresh: onRefresh,
        child: children.isEmpty
            ? RefreshableEmptyView(child: empty)
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: inset + const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: children,
              ),
      ),
    ),
  );
}

class _IncomingPage extends ConsumerWidget {
  const _IncomingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView<List<IncomingShare>>(
    value: ref.watch(incomingSharesProvider),
    onRetry: () => ref.invalidate(incomingSharesProvider),
    data: (shares) => _SectionPage(
      title: context.localized.sharedWithMe,
      onRefresh: ref.read(incomingSharesProvider.notifier).refresh,
      empty: MessageView(icon: IconsaxPlusLinear.share, message: context.localized.noIncomingShares),
      children: [for (final share in shares) _IncomingShareTile(share: share)],
    ),
  );
}

class _IncomingShareTile extends ConsumerWidget {
  const _IncomingShareTile({required this.share});

  final IncomingShare share;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 4),
      leading: FileTypeIcon.of(isDir: share.entry.isDir, mime: share.entry.mime, size: 40),
      title: Text(share.entry.name, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        share.direct || share.groups.isEmpty ? share.owner.name : share.groups.map((group) => group.name).join(", "),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => openMountedShare(
        context,
        ref,
        origin: ShareOrigin.local,
        shareId: share.id,
        isDir: share.entry.isDir,
        mountPath: share.mountPath,
      ),
      onLongPress: () => showIncomingShareDetails(context, share),
      trailing: IconButton(
        tooltip: localized.details,
        icon: const Icon(IconsaxPlusLinear.more),
        onPressed: () => showIncomingShareDetails(context, share),
      ),
    );
  }
}

class _OutgoingPage extends ConsumerWidget {
  const _OutgoingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView<List<OutgoingShare>>(
    value: ref.watch(outgoingSharesProvider(null)),
    onRetry: () => ref.invalidate(outgoingSharesProvider(null)),
    data: (shares) {
      final byFile = <int, List<OutgoingShare>>{};
      for (final share in shares) {
        byFile.putIfAbsent(share.file.id, () => []).add(share);
      }
      return _SectionPage(
        title: context.localized.sharedByMe,
        onRefresh: ref.read(outgoingSharesProvider(null).notifier).refresh,
        empty: MessageView(icon: IconsaxPlusLinear.share, message: context.localized.noOutgoingShares),
        children: [for (final group in byFile.values) _OutgoingTile(shares: group)],
      );
    },
  );
}

class _OutgoingTile extends StatelessWidget {
  const _OutgoingTile({required this.shares});

  final List<OutgoingShare> shares;

  @override
  Widget build(BuildContext context) {
    final first = shares.first;
    final file = first.file;
    final localized = context.localized;
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 16),
      leading: FileTypeIcon.of(isDir: file.isDir, mime: "", size: 40),
      title: Text(file.displayName(localized), overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [if (!first.available) localized.shareUnavailable, ...shares.map((share) => share.recipient.name)].join(", "),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: first.available ? () => showSharePanel(context, file) : null,
    );
  }
}

class _LinksPage extends ConsumerWidget {
  const _LinksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView<List<ShareLink>>(
    value: ref.watch(shareLinksProvider(null)),
    onRetry: () => ref.invalidate(shareLinksProvider(null)),
    data: (links) => _SectionPage(
      title: context.localized.shareLinks,
      onRefresh: ref.read(shareLinksProvider(null).notifier).refresh,
      empty: MessageView(icon: IconsaxPlusLinear.link_21, message: context.localized.noShareLinks),
      children: [for (final link in links) ShareLinkTile(link: link, showFileName: true)],
    ),
  );
}

class _FederatedPage extends ConsumerWidget {
  const _FederatedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final contacts = ref.watch(federationContactsProvider).value ?? const <FederationContact>[];
    final invites = ref.watch(federationInvitesProvider).value ?? const <FederationInvite>[];
    return AsyncValueView<List<IncomingFederatedShare>>(
      value: ref.watch(incomingFederatedSharesProvider),
      onRetry: () => ref.invalidate(incomingFederatedSharesProvider),
      data: (shares) => _SectionPage(
        title: localized.sharedFromOtherServers,
        onRefresh: () async {
          ref.invalidate(federationContactsProvider);
          ref.invalidate(federationInvitesProvider);
          await ref.read(incomingFederatedSharesProvider.notifier).refresh();
        },
        actions: [
          IconButton(
            tooltip: localized.acceptInvite,
            icon: const Icon(IconsaxPlusLinear.ticket),
            onPressed: () => showAcceptInvite(context),
          ),
          IconButton(
            tooltip: localized.inviteSomeone,
            icon: const Icon(IconsaxPlusLinear.user_add),
            onPressed: () => createAndShowInvite(context, ref),
          ),
        ],
        empty: MessageView(icon: IconsaxPlusLinear.global, message: localized.noFederatedShares),
        children: [
          for (final share in shares) _FederatedShareTile(share: share),
          if (contacts.isNotEmpty) ...[
            _ListHeader(title: localized.federationContacts),
            for (final contact in contacts) _ContactTile(contact: contact),
          ],
          if (invites.isNotEmpty) ...[
            _ListHeader(title: localized.openInvites),
            for (final invite in invites) _InviteTile(invite: invite),
          ],
        ],
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 24, 12, 4),
    child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
  );
}

class _ContactTile extends ConsumerWidget {
  const _ContactTile({required this.contact});

  final FederationContact contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 4),
      leading: const CircleAvatar(child: Icon(IconsaxPlusLinear.global)),
      title: Text(contact.shownName, overflow: TextOverflow.ellipsis),
      subtitle: Text(contact.cloudId, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        tooltip: localized.remove,
        icon: const Icon(IconsaxPlusLinear.trash),
        onPressed: () async {
          final confirmed = await showConfirmDialog(
            context,
            title: localized.removeContactTitle(contact.shownName),
            message: localized.removeContactMessage,
            confirmLabel: localized.remove,
            destructive: true,
          );
          if (confirmed && context.mounted) {
            await context.runWithFeedback(ref.read(federationContactsProvider.notifier).remove(contact));
          }
        },
      ),
    );
  }
}

class _InviteTile extends ConsumerWidget {
  const _InviteTile({required this.invite});

  final FederationInvite invite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 4),
      leading: const CircleAvatar(child: Icon(IconsaxPlusLinear.ticket)),
      title: Text(localized.openInvite),
      subtitle: Text(localized.linkExpiresOn(invite.expiresAt.formattedDate(context))),
      trailing: IconButton(
        tooltip: localized.revokeAppPassword,
        icon: const Icon(IconsaxPlusLinear.trash),
        onPressed: () => context.runWithFeedback(ref.read(federationInvitesProvider.notifier).revoke(invite)),
      ),
    );
  }
}

class _FederatedShareTile extends ConsumerWidget {
  const _FederatedShareTile({required this.share});

  final IncomingFederatedShare share;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final notifier = ref.read(incomingFederatedSharesProvider.notifier);
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 4),
      leading: FileTypeIcon.of(isDir: share.isDir, mime: "", size: 40),
      title: Text(share.name, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [share.shownOwner, if (share.provider.isNotEmpty) share.provider].join(" · "),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: share.isPending
          ? null
          : () => openMountedShare(
              context,
              ref,
              origin: ShareOrigin.federated,
              shareId: share.id,
              isDir: share.isDir,
              mountPath: share.mountPath,
            ),
      trailing: share.isPending
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _remove(context, notifier, declining: true),
                  child: Text(localized.decline),
                ),
                FilledButton.tonal(
                  onPressed: () => context.runWithFeedback(notifier.accept(share)),
                  child: Text(localized.accept),
                ),
              ],
            )
          : IconButton(
              tooltip: localized.remove,
              icon: const Icon(IconsaxPlusLinear.logout),
              onPressed: () => _remove(context, notifier, declining: false),
            ),
    );
  }

  Future<void> _remove(
    BuildContext context,
    IncomingFederatedSharesNotifier notifier, {
    required bool declining,
  }) async {
    final localized = context.localized;
    final confirmed = await showConfirmDialog(
      context,
      title: declining ? localized.declineFederatedTitle(share.name) : localized.removeFederatedTitle(share.name),
      message: localized.removeFederatedMessage(share.owner),
      confirmLabel: declining ? localized.decline : localized.remove,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await context.runWithFeedback(notifier.remove(share));
  }
}
