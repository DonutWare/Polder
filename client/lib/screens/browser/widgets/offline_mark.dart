import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/offline/offline_availability_provider.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/widgets/shared/tag.dart";

class OfflineMark extends ConsumerWidget {
  const OfflineMark({required this.path, super.key});

  static const size = 18.0;

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(offlineStatusProvider(path));
    if (status.availability == OfflineAvailability.none) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    final localized = context.localized;
    final percent = ((status.progress ?? 0) * 100).round();
    final (Widget child, String message) = switch (status.availability) {
      OfflineAvailability.available => (_icon(colors.primary), localized.availableOffline),
      OfflineAvailability.downloading => (
        SizedBox.square(
          dimension: size - 2,
          child: CircularProgressIndicator(value: status.progress, strokeWidth: 2, color: colors.primary),
        ),
        localized.downloadingForOffline(percent),
      ),
      OfflineAvailability.failed => (
        _icon(colors.error),
        localized.offlineDownloadFailed(context.syncProblem(status.error)),
      ),
      _ => (
        _icon(colors.outline),
        status.total > 0
            ? localized.downloadingFilesForOffline(status.done, status.total)
            : localized.waitingForOffline,
      ),
    };
    return Tooltip(
      message: message,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox.square(
          dimension: size,
          child: Center(child: child),
        ),
      ),
    );
  }

  static Widget _icon(Color color) => Icon(IconsaxPlusLinear.arrow_circle_down, size: size, color: color);
}

class OfflineDownloadTag extends ConsumerWidget {
  const OfflineDownloadTag({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(offlineStatusProvider(path));
    if (status.availability != OfflineAvailability.downloading) return const SizedBox.shrink();
    return Tag(
      icon: IconsaxPlusLinear.document_download,
      text: context.localized.offlineDownloadingTag(((status.progress ?? 0) * 100).round()),
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
