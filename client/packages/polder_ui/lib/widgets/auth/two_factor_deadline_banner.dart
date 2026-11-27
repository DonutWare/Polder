import "package:material_ui/material_ui.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:intl/intl.dart";

import "package:polder_core/providers/current_user_provider.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/shared/notice_tile.dart";
import "package:polder_ui/polder_ui_config.dart";

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
            onPressed: () => context.go(readPolderUiConfig(context).accountSettings),
            child: Text(context.localized.setUp),
          ),
        ),
      ),
    );
  }
}
