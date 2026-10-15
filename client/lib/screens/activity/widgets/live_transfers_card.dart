import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/activity.dart";
import "package:polder/models/sync/sync_status.dart";
import "package:polder/providers/activity/activity_scope_provider.dart";
import "package:polder/providers/activity/now_groups_provider.dart";
import "package:polder/providers/browser/pending_uploads_provider.dart";
import "package:polder/providers/realtime/events_provider.dart";
import "package:polder/providers/sync/sync_status_provider.dart";
import "package:polder/screens/browser/widgets/pending_upload_widgets.dart";
import "package:polder/screens/sync/widgets/pause_sync_button.dart";
import "package:polder/services/realtime/events_client.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/byte_format.dart";
import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/level_bar.dart";
import "package:polder/widgets/shared/notice_tile.dart";
import "package:polder/widgets/shared/section_card.dart";
import "package:polder/widgets/shared/tag.dart";

class LiveTransfersSliver extends ConsumerWidget {
  const LiveTransfersSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(nowGroupsProvider);
    final open = ref.watch(openNowGroupsProvider);
    final status = ref.watch(syncStatusProvider);
    final lastRunAt = status.lastRunAt;
    final showUser = ref.watch(activityScopeProvider) is! ActivityScopeMe;
    final offline = ref.watch(realtimeStatusProvider).value == RealtimeStatus.offline;
    final cs = Theme.of(context).colorScheme;
    final card = Theme.of(context).cardTheme;
    final localized = context.localized;
    final colors = AppColors.of(context);

    final (icon, label, color) = switch (status.phase) {
      SyncPhase.idle => (IconsaxPlusLinear.cloud_change, localized.syncIdle, colors.success),
      SyncPhase.syncing => (IconsaxPlusLinear.refresh_2, localized.syncRunning, cs.primary),
      SyncPhase.error => (IconsaxPlusLinear.cloud_cross, localized.syncError, cs.error),
      SyncPhase.paused => (IconsaxPlusLinear.pause_circle, localized.syncPaused, cs.outline),
    };

    final subtitle = offline
        ? localized.realtimeOffline
        : lastRunAt == null
        ? null
        : localized.lastSynced(lastRunAt.formatted(context));
    final error = status.errorMessage;
    final rows = _nowRows(groups, open);

    return SliverPadding(
      padding: card.margin ?? EdgeInsets.zero,
      sliver: DecoratedSliver(
        decoration: ShapeDecoration(color: card.color, shape: card.shape ?? const RoundedRectangleBorder()),
        sliver: SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionCardHeader(
                    icon: icon,
                    iconColor: color,
                    title: label,
                    subtitle: subtitle,
                    trailing: const PauseSyncButton(),
                  ),
                  if (error != null || rows.isEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, rows.isEmpty ? 20 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 16,
                        children: [
                          if (error != null)
                            NoticeTile(icon: IconsaxPlusLinear.information, text: error, color: cs.error),
                          if (rows.isEmpty)
                            Text(
                              localized.nothingTransferring,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, rows.isEmpty ? 0 : 20),
              sliver: SliverList.builder(
                itemCount: rows.length,
                itemBuilder: (context, index) => _NowRowView(row: rows[index], first: index == 0, showUser: showUser),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

sealed class _NowRow {
  const _NowRow();
}

class _GroupRow extends _NowRow {
  const _GroupRow(this.group);

  final NowGroup group;
}

class _LocalRow extends _NowRow {
  const _LocalRow(this.upload, {required this.title, required this.nested});

  final PendingUpload upload;
  final String? title;
  final bool nested;
}

class _TransferRow extends _NowRow {
  const _TransferRow(this.transfer, {required this.title, required this.nested});

  final LiveTransfer transfer;
  final String? title;
  final bool nested;
}

List<_NowRow> _nowRows(List<NowGroup> groups, Set<String> open) => [
  for (final group in groups)
    if (group.isBatch) ...[
      _GroupRow(group),
      if (open.contains(group.key)) ..._fileRows(group, nested: true),
    ] else
      ..._fileRows(group, nested: false),
];

List<_NowRow> _fileRows(NowGroup group, {required bool nested}) {
  String? title(String path) => nested ? RemotePath.relativeTo(path, group.folder) : null;
  final local = [...group.local]
    ..sort((a, b) {
      final byPhase = b.phase.index.compareTo(a.phase.index);
      return byPhase != 0 ? byPhase : a.path.compareTo(b.path);
    });
  final transfers = [...group.transfers]..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final upload in local) _LocalRow(upload, title: title(upload.path), nested: nested),
    for (final transfer in transfers) _TransferRow(transfer, title: title(transfer.path), nested: nested),
  ];
}

class _NowRowView extends StatelessWidget {
  const _NowRowView({required this.row, required this.first, required this.showUser});

  final _NowRow row;
  final bool first;
  final bool showUser;

  @override
  Widget build(BuildContext context) {
    final nested = switch (row) {
      _LocalRow(:final nested) || _TransferRow(:final nested) => nested,
      _GroupRow() => false,
    };
    return Padding(
      padding: EdgeInsetsDirectional.only(top: first ? 0 : (nested ? 12 : 16), start: nested ? 24 : 0),
      child: switch (row) {
        _GroupRow(:final group) => NowGroupTile(key: ValueKey(group.key), group: group),
        _LocalRow(:final upload, :final title) => LocalSyncTile(
          key: ValueKey(upload.path),
          upload: upload,
          title: title,
        ),
        _TransferRow(:final transfer, :final title) => LiveTransferTile(
          key: ValueKey(transfer.id),
          transfer: transfer,
          showUser: showUser,
          title: title,
        ),
      },
    );
  }
}

class NowGroupTile extends ConsumerWidget {
  const NowGroupTile({required this.group, super.key});

  final NowGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(openNowGroupsProvider.select((keys) => keys.contains(group.key)));
    final localized = context.localized;
    final cs = Theme.of(context).colorScheme;
    final name = RemotePath.name(group.folder);
    final sky = AppColors.of(context).sky;
    final phases = [
      if (group.uploading > 0) (localized.nowGroupUploading(group.uploading), cs.primary),
      if (group.downloading > 0) (localized.nowGroupDownloading(group.downloading), sky),
      if (group.preparing > 0) (localized.nowGroupPreparing(group.preparing), cs.primary),
      if (group.waiting > 0) (localized.nowGroupWaiting(group.waiting), cs.primary),
    ];
    final color = group.uploading == 0 && group.downloading > 0 ? sky : cs.primary;
    final progress = [
      localized.nowGroupProgress(group.completed, group.totalFiles),
      if (group.rate > 0) ByteFormat.rate(group.rate, locale: context.localeName),
    ];
    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UploadRing(
          progress: group.progress,
          dimension: 44,
          child: Icon(IconsaxPlusBold.folder_2, color: color, size: 20),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                "${name.isEmpty ? localized.activityAllFiles : name} · ${localized.nowGroupFiles(group.totalFiles)}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [for (final (text, color) in phases) Tag(text: text, color: color)],
              ),
              Text(
                progress.join(" · "),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              LevelBar(fraction: group.progress, height: 4, color: color),
            ],
          ),
        ),
        IconButton(
          tooltip: open ? localized.hideFiles : localized.showFiles,
          icon: AnimatedRotation(
            turns: open ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(IconsaxPlusLinear.arrow_down_2),
          ),
          onPressed: () => ref.read(openNowGroupsProvider.notifier).toggle(group.key),
        ),
      ],
    );
  }
}

class LiveTransferTile extends StatelessWidget {
  const LiveTransferTile({required this.transfer, this.showUser = false, this.title, super.key});

  final LiveTransfer transfer;
  final bool showUser;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final color = transfer.isUpload ? Theme.of(context).colorScheme.primary : AppColors.of(context).sky;
    final localized = context.localized;
    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UploadRing(
          progress: transfer.progress,
          dimension: 44,
          child: Icon(
            transfer.isUpload ? IconsaxPlusLinear.document_upload : IconsaxPlusLinear.document_download,
            color: color,
            size: 20,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(title ?? transfer.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  Tag(
                    text: transfer.isUpload ? localized.transferUploading : localized.transferDownloading,
                    color: color,
                  ),
                  if (showUser) Tag(text: transfer.username, color: AppColors.of(context).sky),
                ],
              ),
              Text(
                "${transferSummary(context, bytes: transfer.bytes, total: transfer.total, rate: transfer.rate)} · ${transfer.parentPath}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              LevelBar(fraction: transfer.progress, height: 4, color: color),
            ],
          ),
        ),
      ],
    );
  }
}

class LocalSyncTile extends StatelessWidget {
  const LocalSyncTile({required this.upload, this.title, super.key});

  final PendingUpload upload;
  final String? title;

  @override
  Widget build(BuildContext context) => Row(
    spacing: 12,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      UploadRing(
        progress: upload.progress,
        dimension: 44,
        child: Icon(upload.icon, color: upload.color(context), size: 20),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(title ?? upload.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            PendingUploadStatus(upload: upload),
            Text(
              RemotePath.parent(upload.path),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ],
  );
}
