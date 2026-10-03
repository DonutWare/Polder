import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/models/user.dart";
import "package:nomad/theme/app_theme.dart";
import "package:nomad/util/byte_format.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/shared/level_bar.dart";
import "package:nomad/widgets/shared/section_card.dart";

/// Who uses the most space. Users with a quota show how full it is; the rest are measured
/// against the biggest user.
class StorageByUserCard extends StatelessWidget {
  const StorageByUserCard({required this.users, super.key});

  static const shown = 8;

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    final sorted = [...users]..sort((a, b) => b.usedBytes.compareTo(a.usedBytes));
    final largest = sorted.isEmpty ? 0 : sorted.first.usedBytes;
    return SectionCard(
      icon: IconsaxPlusLinear.chart_2,
      iconColor: AppColors.of(context).sky,
      title: context.localized.storageByUser,
      subtitle: context.localized.usersCount(users.length),
      child: Column(
        children: [
          for (final user in sorted.take(shown))
            _UserUsage(
              user: user,
              fraction: user.hasQuota ? user.usedFraction : (largest == 0 ? 0 : user.usedBytes / largest),
            ),
        ],
      ),
    );
  }
}

class _UserUsage extends StatelessWidget {
  const _UserUsage({required this.user, required this.fraction});

  final User user;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.localeName;
    final used = ByteFormat.format(user.usedBytes, locale: locale);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(user.username, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
              ),
              Text(
                user.hasQuota
                    ? context.localized.quotaUsedOf(used, ByteFormat.format(user.quotaBytes, locale: locale))
                    : context.localized.quotaUsedUnlimited(used),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          LevelBar(fraction: fraction, color: user.hasQuota ? null : AppColors.of(context).info),
        ],
      ),
    );
  }
}
