import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:intl/intl.dart";

import "package:polder/providers/current_user_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/notice_tile.dart";

class TwoFactorDeadlineBanner extends ConsumerWidget {
  const TwoFactorDeadlineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadline = ref.watch(twoFactorDeadlineProvider);
    if (deadline == null) return const SizedBox.shrink();
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(deadline.toLocal());
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: NoticeTile(
          icon: IconsaxPlusLinear.shield_tick,
          color: AppColors.of(context).warning,
          text: context.localized.twoFactorDeadlineBanner(date),
          action: FilledButton.tonal(
            onPressed: () => context.go(AppRoutes.settingsPage(SettingsPage.account)),
            child: Text(context.localized.setUp),
          ),
        ),
      ),
    );
  }
}
