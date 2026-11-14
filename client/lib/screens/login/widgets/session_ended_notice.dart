import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/screens/settings/widgets/sign_out.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/icon_badge.dart";

class SessionEndedNotice extends StatelessWidget {
  const SessionEndedNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(color: colors.errorContainer, shape: squircle(AppRadius.inset)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          IconBadge(icon: IconsaxPlusLinear.lock, color: colors.error),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  context.localized.sessionEndedTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  context.localized.sessionEndedMessage,
                  style: theme.textTheme.bodySmall?.copyWith(color: colors.onErrorContainer.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SessionEndedActions extends ConsumerWidget {
  const SessionEndedActions({super.key});

  static const continueOfflineKey = Key("login.continueOffline");
  static const signOutKey = Key("login.signOut");

  @override
  Widget build(BuildContext context, WidgetRef ref) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      TextButton.icon(
        key: signOutKey,
        icon: const Icon(IconsaxPlusLinear.logout, size: 18),
        label: Text(context.localized.signOut),
        onPressed: () => unawaited(confirmSignOut(context, ref)),
      ),
      TextButton.icon(
        key: continueOfflineKey,
        icon: const Icon(IconsaxPlusLinear.cloud_cross, size: 18),
        label: Text(context.localized.continueOffline),
        onPressed: ref.read(continueOfflineProvider.notifier).continueOffline,
      ),
    ],
  );
}
