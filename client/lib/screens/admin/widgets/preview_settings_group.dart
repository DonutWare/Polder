import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/polder_api_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/nav_group.dart";

class PreviewSettingsGroup extends ConsumerWidget {
  const PreviewSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    return NavGroup(
      title: localized.serverPreviewsGroup,
      children: [
        NavEntry(
          icon: IconsaxPlusLinear.gallery,
          title: localized.regeneratePreviews,
          subtitle: localized.regeneratePreviewsHint,
          onTap: () => _regenerate(context, ref),
        ),
      ],
    );
  }

  Future<void> _regenerate(BuildContext context, WidgetRef ref) async {
    final localized = context.localized;
    final confirmed = await showConfirmDialog(
      context,
      title: localized.regeneratePreviews,
      message: localized.regeneratePreviewsMessage,
      confirmLabel: localized.regenerate,
    );
    if (!confirmed || !context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    await context.runWithFeedback(() async {
      final queued = await ref.read(polderApiProvider).regeneratePreviews();
      messenger?.showSnackBar(SnackBar(content: Text(localized.previewsQueued(queued))));
    }());
  }
}
