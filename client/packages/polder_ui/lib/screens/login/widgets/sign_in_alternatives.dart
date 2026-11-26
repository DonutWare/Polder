import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_core/providers/branding/branding_provider.dart";
import "package:polder_core/providers/login_provider.dart";
import "package:polder_core/services/auth/single_sign_on.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/auth/provider_badge.dart";

class SignInAlternatives extends ConsumerWidget {
  const SignInAlternatives({super.key});

  static const anotherDeviceKey = Key("login.anotherDevice");
  static const cancelBrowserKey = Key("login.sso.cancel");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(brandingProvider.select((branding) => branding.authProviders));
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Row(
          spacing: 12,
          children: [
            const Expanded(child: Divider()),
            Text(context.localized.signInOr, style: Theme.of(context).textTheme.labelMedium),
            const Expanded(child: Divider()),
          ],
        ),
        for (final provider in providers)
          OutlinedButton.icon(
            key: Key("login.sso.${provider.id}"),
            icon: state.signingInWith == provider.id
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : ProviderBadge(preset: provider.icon, label: provider.label, size: 20),
            label: Text(context.localized.signInWithProvider(provider.label)),
            onPressed: state.loading ? null : () => notifier.signInWithProvider(provider.id),
          ),
        if (state.signingInWith != null && SingleSignOn.finishesInBrowser)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Flexible(child: Text(context.localized.waitingForBrowser, style: Theme.of(context).textTheme.bodySmall)),
              TextButton(
                key: cancelBrowserKey,
                onPressed: notifier.cancelSignInWithProvider,
                child: Text(context.localized.cancel),
              ),
            ],
          ),
        if (!state.reauthenticating || state.username.isNotEmpty)
          TextButton.icon(
            key: anotherDeviceKey,
            icon: const Icon(IconsaxPlusLinear.devices, size: 18),
            label: Text(context.localized.signInWithAnotherDevice),
            onPressed: state.canAskAnotherDevice ? notifier.askAnotherDevice : null,
          ),
      ],
    );
  }
}
