import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/models/sync/sync_status.dart";
import "package:nomad/providers/sync/sync_status_provider.dart";
import "package:nomad/theme/app_theme.dart";
import "package:nomad/util/date_format_extension.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/shared/notice_tile.dart";
import "package:nomad/widgets/shared/section_card.dart";
import "package:nomad/widgets/shared/tag.dart";

class SyncStatusCard extends ConsumerWidget {
  const SyncStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    final report = status.lastReport;
    final lastRunAt = status.lastRunAt;
    final localized = context.localized;
    final colors = AppColors.of(context);
    final cs = Theme.of(context).colorScheme;
    final (icon, label, color) = switch (status.phase) {
      SyncPhase.idle => (IconsaxPlusLinear.cloud_change, localized.syncIdle, colors.success),
      SyncPhase.syncing => (IconsaxPlusLinear.refresh_2, localized.syncRunning, cs.primary),
      SyncPhase.error => (IconsaxPlusLinear.cloud_cross, localized.syncError, cs.error),
    };
    return SectionCard(
      icon: icon,
      iconColor: color,
      title: label,
      subtitle: lastRunAt == null ? null : localized.lastSynced(lastRunAt.formatted(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Tag(
                icon: IconsaxPlusLinear.document_upload,
                text: localized.uploadedCount(report.uploaded),
                color: cs.primary,
              ),
              Tag(
                icon: IconsaxPlusLinear.document_download,
                text: localized.downloadedCount(report.downloaded),
                color: colors.sky,
              ),
              Tag(icon: IconsaxPlusLinear.trash, text: localized.deletedCount(report.deleted), color: cs.outline),
              if (report.failed > 0)
                Tag(icon: IconsaxPlusLinear.danger, text: localized.failedCount(report.failed), color: cs.error),
            ],
          ),
          if (status.errorMessage != null)
            NoticeTile(icon: IconsaxPlusLinear.information, text: status.errorMessage!, color: cs.error),
        ],
      ),
    );
  }
}
