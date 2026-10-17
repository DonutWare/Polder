import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/sharing.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/sharing/link_form_dialog.dart";
import "package:polder/widgets/sharing/share_labels.dart";
import "package:polder/widgets/sharing/share_link_tile.dart";
import "package:polder/widgets/sharing/share_settings.dart";
import "package:polder/widgets/sharing/share_target_avatar.dart";

Future<void> showSharePanel(BuildContext context, SharedFile file) {
  if (WindowSize.isCompact(context)) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (context, controller) => SharePanel(file: file, scrollController: controller),
      ),
    );
  }
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) => Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: SizedBox(
          width: 420,
          height: double.infinity,
          child: SafeArea(child: SharePanel(file: file)),
        ),
      ),
    ),
    transitionBuilder: (context, animation, _, child) => SlideTransition(
      position: Tween(
        begin: Offset(Directionality.of(context) == TextDirection.rtl ? -1 : 1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

class SharePanel extends ConsumerStatefulWidget {
  const SharePanel({required this.file, this.scrollController, super.key});

  final SharedFile file;
  final ScrollController? scrollController;

  @override
  ConsumerState<SharePanel> createState() => _SharePanelState();
}

class _SharePanelState extends ConsumerState<SharePanel> {
  final _search = TextEditingController();
  var _query = "";

  SharedFile get file => widget.file;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final theme = Theme.of(context);
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                localized.shareTitle(file.name),
                style: theme.textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: const Icon(IconsaxPlusLinear.close_circle),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _search,
          decoration: InputDecoration(
            prefixIcon: const Icon(IconsaxPlusLinear.search_normal_1),
            hintText: localized.shareSearchHint,
          ),
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        if (_query.isNotEmpty)
          _Matches(query: _query, fileId: file.id, onPick: _add)
        else ...[
          _SectionTitle(
            title: localized.shareLinks,
            action: IconButton(
              tooltip: localized.createLink,
              icon: const Icon(IconsaxPlusLinear.add),
              onPressed: _createLink,
            ),
          ),
          _Links(fileId: file.id),
          _SectionTitle(title: localized.shareRecipients),
          _People(fileId: file.id),
        ],
      ],
    );
  }

  Future<void> _add(ShareTarget recipient) async {
    final added = await showNewShareSettings(context, file: file, recipient: recipient);
    if (added && mounted) {
      _search.clear();
      setState(() => _query = "");
    }
  }

  Future<void> _createLink() async {
    final options = await showLinkFormDialog(context, isDir: file.isDir);
    if (options == null || !mounted) return;
    ShareLink? created;
    final ok = await context.runWithFeedback(() async {
      created = await ref.read(shareLinksProvider(file.id).notifier).create(file.id, options);
    }());
    if (ok && created != null && mounted) await copyShareLink(context, ref, created!);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        ),
        ?action,
      ],
    ),
  );
}

class _Links extends ConsumerWidget {
  const _Links({required this.fileId});

  final int fileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView<List<ShareLink>>(
    value: ref.watch(shareLinksProvider(fileId)),
    onRetry: () => ref.invalidate(shareLinksProvider(fileId)),
    data: (links) => links.isEmpty
        ? _Quiet(text: context.localized.noShareLinks)
        : Column(
            children: [for (final link in links) ShareLinkTile(link: link, fileId: fileId)],
          ),
  );
}

class _Quiet extends StatelessWidget {
  const _Quiet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}

class _People extends ConsumerWidget {
  const _People({required this.fileId});

  final int fileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView<List<OutgoingShare>>(
    value: ref.watch(outgoingSharesProvider(fileId)),
    onRetry: () => ref.invalidate(outgoingSharesProvider(fileId)),
    data: (shares) => shares.isEmpty
        ? _Quiet(text: context.localized.shareNotSharedYet)
        : Column(children: [for (final share in shares) _ShareRow(share: share)]),
  );
}

class _Matches extends ConsumerWidget {
  const _Matches({required this.query, required this.fileId, required this.onPick});

  final String query;
  final int fileId;
  final ValueChanged<ShareTarget> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shared = {
      for (final share in ref.watch(outgoingSharesProvider(fileId)).value ?? <OutgoingShare>[])
        (share.recipient.kind, share.recipient.id),
    };
    return AsyncValueView<ShareTargets>(
      value: ref.watch(shareTargetSearchProvider(query)),
      data: (found) {
        final targets = [
          ...found.groups,
          ...found.users,
        ].where((target) => !shared.contains((target.kind, target.id))).toList();
        if (targets.isEmpty) return _Quiet(text: context.localized.shareNoMatches);
        return Column(
          children: [
            for (final target in targets)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ShareTargetAvatar(target: target),
                title: Text(target.name, overflow: TextOverflow.ellipsis),
                subtitle: target.isGroup ? Text(context.localized.shareGroupMembers(target.memberCount ?? 0)) : null,
                trailing: const Icon(IconsaxPlusLinear.add),
                onTap: () => onPick(target),
              ),
          ],
        );
      },
    );
  }
}

class _ShareRow extends ConsumerStatefulWidget {
  const _ShareRow({required this.share});

  final OutgoingShare share;

  @override
  ConsumerState<_ShareRow> createState() => _ShareRowState();
}

class _ShareRowState extends ConsumerState<_ShareRow> {
  var _expanded = false;

  OutgoingShare get share => widget.share;

  @override
  Widget build(BuildContext context) {
    final recipient = share.recipient;
    final editable = share.isManageable;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ShareTargetAvatar(target: recipient),
          title: Text(recipient.name, overflow: TextOverflow.ellipsis),
          subtitle: Text(shareDescription(context, share), maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: editable ? const Icon(IconsaxPlusLinear.setting_4) : null,
          onTap: editable ? () => setState(() => _expanded = !_expanded) : null,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.topCenter,
          child: _expanded
              ? Container(
                  margin: const EdgeInsets.only(left: 48, bottom: 12),
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  decoration: ShapeDecoration(color: AppColors.of(context).inset, shape: squircle(AppRadius.inset)),
                  child: ShareSettingsForm.forShare(
                    share,
                    key: ValueKey(share),
                    onDone: () => setState(() => _expanded = false),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
