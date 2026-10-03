import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/user.dart";
import "package:nomad/providers/current_user_provider.dart";
import "package:nomad/util/byte_format.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/shared/level_bar.dart";

class QuotaBar extends ConsumerWidget {
  const QuotaBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(
          quotaLabel(context, user),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        if (user.hasQuota) LevelBar(fraction: user.usedFraction, height: 6),
      ],
    );
  }

  static String quotaLabel(BuildContext context, User user) {
    final used = ByteFormat.format(user.usedBytes, locale: context.localeName);
    if (!user.hasQuota) return context.localized.quotaUsedUnlimited(used);
    return context.localized.quotaUsedOf(used, ByteFormat.format(user.quotaBytes, locale: context.localeName));
  }
}
