import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/activity.dart";
import "package:polder/providers/browser/pending_uploads_provider.dart";
import "package:polder/providers/sync/sync_paused_provider.dart";
import "package:polder/screens/browser/widgets/file_type_icon.dart";
import "package:polder/services/sync/sync_activity.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/byte_format.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/level_bar.dart";
import "package:polder/widgets/shared/tag.dart";

String transferSummary(BuildContext context, {required int bytes, int? total, int rate = 0}) {
  final locale = context.localeName;
  final done = ByteFormat.format(bytes, locale: locale);
  return [
    if (total != null && total > 0)
      context.localized.transferProgress(done, ByteFormat.format(total, locale: locale))
    else
      done,
    if (rate > 0) ByteFormat.rate(rate, locale: locale),
  ].join(" · ");
}

extension PendingUploadPresentation on PendingUpload {
  String label(BuildContext context) => switch (phase) {
    LocalSyncPhase.waiting when paused => context.localized.itemPaused,
    LocalSyncPhase.waiting => context.localized.syncWaiting,
    LocalSyncPhase.preparing => context.localized.syncPreparing,
    LocalSyncPhase.uploading => context.localized.transferUploading,
    LocalSyncPhase.downloading => context.localized.transferDownloading,
  };

  IconData get icon => switch (phase) {
    LocalSyncPhase.waiting when paused => IconsaxPlusLinear.pause,
    LocalSyncPhase.waiting => IconsaxPlusLinear.clock,
    LocalSyncPhase.preparing => IconsaxPlusLinear.document_code,
    LocalSyncPhase.uploading => IconsaxPlusLinear.document_upload,
    LocalSyncPhase.downloading => IconsaxPlusLinear.document_download,
  };

  Color color(BuildContext context) => switch (phase) {
    LocalSyncPhase.waiting => Theme.of(context).colorScheme.outline,
    LocalSyncPhase.preparing => Theme.of(context).colorScheme.tertiary,
    LocalSyncPhase.uploading || LocalSyncPhase.downloading => Theme.of(context).colorScheme.primary,
  };

  String summary(BuildContext context) => switch (phase) {
    LocalSyncPhase.waiting => total == null ? "" : ByteFormat.format(total!, locale: context.localeName),
    _ => transferSummary(context, bytes: bytes, total: total, rate: rate),
  };
}

class PendingHighlight extends StatelessWidget {
  const PendingHighlight({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.07),
        border: BorderDirectional(start: BorderSide(color: primary, width: 3)),
      ),
      child: child,
    );
  }
}

class UploadRing extends StatelessWidget {
  const UploadRing({required this.progress, required this.child, this.dimension = 48, super.key});

  final double? progress;
  final Widget child;
  final double dimension;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: dimension,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.5,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        child,
      ],
    ),
  );
}

class PendingUploadStatus extends StatelessWidget {
  const PendingUploadStatus({required this.upload, super.key});

  final PendingUpload upload;

  @override
  Widget build(BuildContext context) {
    final color = upload.color(context);
    final summary = upload.summary(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Row(
          spacing: 6,
          children: [
            Flexible(
              child: Tag(icon: upload.icon, text: upload.label(context), color: color),
            ),
            if (summary.isNotEmpty) Flexible(child: Text(summary, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
        LevelBar(fraction: upload.progress, height: 4, color: color),
      ],
    );
  }
}

class PendingFileListTile extends StatelessWidget {
  const PendingFileListTile({required this.upload, super.key});

  final PendingUpload upload;

  @override
  Widget build(BuildContext context) => PendingHighlight(
    child: ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 8, end: 16, top: 4, bottom: 4),
      leading: UploadRing(
        progress: upload.progress,
        child: const FileTypeIcon.of(isDir: false, mime: "", size: 32),
      ),
      title: Text(upload.name, overflow: TextOverflow.ellipsis),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: PendingUploadStatus(upload: upload),
      ),
    ),
  );
}

class PendingFileGridTile extends StatelessWidget {
  const PendingFileGridTile({required this.upload, super.key});

  final PendingUpload upload;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      color: Color.alphaBlend(primary.withValues(alpha: 0.07), Theme.of(context).cardTheme.color ?? Colors.transparent),
      shape: squircle(AppRadius.inset + 4, side: BorderSide(color: primary, width: 1.5)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Expanded(
              child: Center(
                child: UploadRing(
                  progress: upload.progress,
                  dimension: 64,
                  child: const FileTypeIcon.of(isDir: false, mime: "", size: 44),
                ),
              ),
            ),
            Text(
              upload.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            PendingGridStatus(upload: upload),
          ],
        ),
      ),
    );
  }
}

class PendingGridStatus extends StatelessWidget {
  const PendingGridStatus({required this.upload, super.key});

  final PendingUpload upload;

  @override
  Widget build(BuildContext context) {
    final color = upload.color(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Tag(icon: upload.icon, text: upload.label(context), color: color),
        Text(
          upload.summary(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        LevelBar(fraction: upload.progress, height: 4, color: color),
      ],
    );
  }
}

class FolderSyncTag extends ConsumerWidget {
  const FolderSyncTag({required this.direction, super.key});

  final TransferDirectionKind direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) => (ref.watch(syncPausedProvider).value ?? false)
      ? Tag(
          icon: IconsaxPlusLinear.pause,
          text: context.localized.itemPaused,
          color: Theme.of(context).colorScheme.outline,
        )
      : switch (direction) {
          TransferDirectionKind.upload => Tag(
            icon: IconsaxPlusLinear.document_upload,
            text: context.localized.folderUploading,
            color: Theme.of(context).colorScheme.primary,
          ),
          TransferDirectionKind.download => Tag(
            icon: IconsaxPlusLinear.document_download,
            text: context.localized.folderDownloading,
            color: Theme.of(context).colorScheme.primary,
          ),
        };
}

class PendingFolderListTile extends StatelessWidget {
  const PendingFolderListTile({required this.name, required this.direction, super.key});

  final String name;
  final TransferDirectionKind direction;

  @override
  Widget build(BuildContext context) => PendingHighlight(
    child: ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 9, end: 16),
      leading: const FileTypeIcon.of(isDir: true, mime: "", size: 40),
      title: Text(name, overflow: TextOverflow.ellipsis),
      subtitle: Align(
        alignment: AlignmentDirectional.centerStart,
        child: FolderSyncTag(direction: direction),
      ),
    ),
  );
}

class PendingFolderGridTile extends StatelessWidget {
  const PendingFolderGridTile({required this.name, required this.direction, super.key});

  final String name;
  final TransferDirectionKind direction;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      shape: squircle(AppRadius.inset + 4, side: BorderSide(color: primary, width: 1.5)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            const Expanded(
              child: Center(child: FileTypeIcon.of(isDir: true, mime: "", size: 64)),
            ),
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FolderSyncTag(direction: direction),
            ),
          ],
        ),
      ),
    );
  }
}
