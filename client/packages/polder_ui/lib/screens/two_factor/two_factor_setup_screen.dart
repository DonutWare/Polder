import "package:material_ui/material_ui.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_ui/screens/settings/widgets/sign_out.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/auth/two_factor_enrollment.dart";
import "package:polder_ui/widgets/shared/icon_badge.dart";

class TwoFactorSetupScreen extends ConsumerWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      Center(
                        child: IconBadge(icon: IconsaxPlusLinear.shield_tick, color: theme.colorScheme.primary),
                      ),
                      Text(
                        context.localized.twoFactorRequiredTitle,
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      Text(context.localized.twoFactorRequiredBody, textAlign: TextAlign.center),
                      TwoFactorEnrollment(onDone: () {}),
                      TextButton(onPressed: () => confirmSignOut(context, ref), child: Text(context.localized.signOut)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
