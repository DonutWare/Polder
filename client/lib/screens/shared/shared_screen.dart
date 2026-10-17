import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/sharing.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/file_type_icon.dart";
import "package:polder/screens/shared/shared_browser_screen.dart";
import "package:polder/screens/shared/widgets/incoming_share_details_sheet.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/layout/split_view.dart";
import "package:polder/widgets/navigation/navigation_shell.dart";
import "package:polder/widgets/shared/async_value_view.dart";
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
    final shown = section ?? (WindowSize.isCompact(context) ? null : SharedSection.withMe);
    final parent = _parentRoute(context);
    return PopScope(
      canPop: parent == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && parent != null) context.go(parent);
      },
      child: SplitView(
        title: Text(localized.navShared),
        pane: _SectionList(selected: shown),
        placeholder: MessageView(icon: IconsaxPlusLinear.share, message: localized.nothingSelected),
        content: switch ((shown, shareId)) {
          (_, final int shareId) => SharedBrowserScreen(
            key: ValueKey("share-$shareId"),
            shareId: shareId,
            path: path,
            parentRoute: parent!,
          ),
          (SharedSection.withMe, _) => const _IncomingPage(key: ValueKey(SharedSection.withMe)),
          (SharedSection.byMe, _) => const _OutgoingPage(key: ValueKey(SharedSection.byMe)),
          (SharedSection.links, _) => const _LinksPage(key: ValueKey(SharedSection.links)),
          (null, _) => null,
        },
      ),
    );
  }

  String? _parentRoute(BuildContext context) {
    if (shareId case final shareId?) {
      return path == RemotePath.root
          ? AppRoutes.sharedSection(SharedSection.withMe.segment)
          : AppRoutes.sharedAt(shareId, path: RemotePath.parent(path));
    }
    if (section != null && WindowSize.isCompact(context)) return AppRoutes.shared;
    return null;
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
      ],
    );
  }
}

class _SectionPage extends StatelessWidget {
  const _SectionPage({required this.title, required this.onRefresh, required this.empty, required this.children});

  final String title;
  final Future<void> Function() onRefresh;
  final Widget empty;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AppPage(
    leading: SplitView.backTo(context, AppRoutes.shared),
    title: Text(title),
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
      onTap: () => context.go(AppRoutes.sharedAt(share.id)),
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
