import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_core/models/security.dart";
import "package:polder_ui/providers/auth/linked_identities_provider.dart";
import "package:polder_core/providers/branding/branding_provider.dart";
import "package:polder_core/services/api/api_exceptions.dart";
import "package:polder_core/services/auth/single_sign_on.dart";
import "package:polder_ui/util/api_error_localization.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/auth/provider_badge.dart";
import "package:polder_ui/widgets/shared/confirm_dialog.dart";
import "package:polder_ui/widgets/shared/nav_group.dart";

class ConnectedAccountsGroup extends ConsumerWidget {
  const ConnectedAccountsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(brandingProvider.select((branding) => branding.authProviders));
    final identities = ref.watch(linkedIdentitiesProvider);
    if (providers.isEmpty && (identities.value?.isEmpty ?? true)) return const SizedBox.shrink();
    final localized = context.localized;
    final linked = identities.value ?? const [];
    return NavGroup(
      title: localized.connectedAccounts,
      children: [
        for (final identity in linked)
          ListTile(
            leading: ProviderBadge(preset: identity.preset, label: identity.providerLabel),
            title: Text(identity.providerLabel),
            subtitle: identity.email.isEmpty ? null : Text(identity.email),
            trailing: TextButton(onPressed: () => _unlink(context, ref, identity), child: Text(localized.unlink)),
          ),
        for (final provider in providers)
          if (!linked.any((identity) => identity.providerId == provider.id))
            ListTile(
              leading: ProviderBadge(preset: provider.icon, label: provider.label),
              title: Text(provider.label),
              subtitle: Text(localized.notConnected),
              trailing: TextButton.icon(
                icon: const Icon(IconsaxPlusLinear.link, size: 18),
                label: Text(localized.connect),
                onPressed: () => _link(context, ref, provider.id),
              ),
            ),
      ],
    );
  }

  Future<void> _link(BuildContext context, WidgetRef ref, String providerId) async {
    try {
      await ref.read(linkedIdentitiesProvider.notifier).link(providerId);
    } on SingleSignOnException catch (error) {
      if (!context.mounted || error.failure == SingleSignOnFailure.cancelled) return;
      _show(
        context,
        error.failure == SingleSignOnFailure.alreadyLinked
            ? context.localized.ssoAlreadyLinked
            : context.localized.loginErrorSsoFailed,
      );
    } on AlreadyExistsException {
      if (context.mounted) _show(context, context.localized.ssoAlreadyLinked);
    } on Object catch (error) {
      if (context.mounted) _show(context, context.localized.describeError(error));
    }
  }

  Future<void> _unlink(BuildContext context, WidgetRef ref, LinkedIdentity identity) async {
    final notifier = ref.read(linkedIdentitiesProvider.notifier);
    final confirmed = await showConfirmDialog(
      context,
      title: context.localized.unlinkTitle(identity.providerLabel),
      message: context.localized.unlinkMessage(identity.providerLabel),
      confirmLabel: context.localized.unlink,
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await notifier.unlink(identity);
    } on Object catch (error) {
      if (context.mounted) _show(context, context.localized.describeError(error));
    }
  }

  void _show(BuildContext context, String message) =>
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));
}
