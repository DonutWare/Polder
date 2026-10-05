import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:nomad/models/activity.dart";
import "package:nomad/models/sync/sync_status.dart";
import "package:nomad/providers/activity/activity_scope_provider.dart";
import "package:nomad/providers/activity/now_groups_provider.dart";
import "package:nomad/providers/browser/pending_uploads_provider.dart";
import "package:nomad/providers/realtime/events_provider.dart";
import "package:nomad/providers/sync/sync_status_provider.dart";
import "package:nomad/screens/browser/widgets/pending_upload_widgets.dart";
import "package:nomad/screens/sync/widgets/pause_sync_button.dart";
import "package:nomad/services/realtime/events_client.dart";
import "package:nomad/theme/app_theme.dart";
import "package:nomad/util/byte_format.dart";
import "package:nomad/util/date_format_extension.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/util/remote_path.dart";
import "package:nomad/widgets/shared/level_bar.dart";
import "package:nomad/widgets/shared/notice_tile.dart";
import "package:nomad/widgets/shared/section_card.dart";
import "package:nomad/widgets/shared/tag.dart";

class LiveTransfersCard extends ConsumerWidget {
  const LiveTransfersCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(nowGroupsProvider);
    final status = ref.watch(syncStatusProvider);
    final lastRunAt = status.lastRunAt;
    final showUser = ref.watch(activityScopeProvider) is! ActivityScopeMe;
    final offline = ref.watch(realtimeStatusProvider).value == RealtimeStatus.offline;
    final cs = Theme.of(context).colorScheme;
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

    return SectionCard(
      icon: icon,
      iconColor: color,
      title: label,
      subtitle: subtitle,
      trailing: const PauseSyncButton(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          if (error != null) NoticeTile(icon: IconsaxPlusLinear.information, text: error, color: cs.error),
          if (groups.isEmpty)
            Text(
              localized.nothingTransferring,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          for (final group in groups)
            if (group.isBatch)
              NowGroupTile(key: ValueKey(group.key), group: group, showUser: showUser)
            else
              ..._tiles(group, showUser: showUser),
        ],
      ),
    );
  }
}

List<Widget> _tiles(NowGroup group, {required bool showUser, bool relativeTitles = false, int? limit}) {
  String? title(String path) => relativeTitles ? RemotePath.relativeTo(path, group.folder) : null;
  final local = [...group.local]
    ..sort((a, b) {
      final byPhase = b.phase.index.compareTo(a.phase.index);
      return byPhase != 0 ? byPhase : a.path.compareTo(b.path);
    });
  final transfers = [...group.transfers]..sort((a, b) => a.path.compareTo(b.path));
  final tiles = [
    for (final upload in local) LocalSyncTile(key: ValueKey(upload.path), upload: upload, title: title(upload.path)),
    for (final transfer in transfers)
      LiveTransferTile(key: ValueKey(transfer.id), transfer: transfer, showUser: showUser, title: title(transfer.path)),
  ];
  return limit == null || tiles.length <= limit ? tiles : tiles.take(limit).toList();
}

class NowGroupTile extends ConsumerWidget {
  const NowGroupTile({required this.group, this.showUser = false, super.key});

  static const shownWhenOpen = 50;

  final NowGroup group;
  final bool showUser;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
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
        ),
        if (open)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                ..._tiles(group, showUser: showUser, relativeTitles: true, limit: NowGroupTile.shownWhenOpen),
                if (group.active > NowGroupTile.shownWhenOpen)
                  Text(
                    localized.andMore(group.active - NowGroupTile.shownWhenOpen),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
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
