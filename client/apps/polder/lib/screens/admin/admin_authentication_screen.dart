import "package:material_ui/material_ui.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_core/models/security.dart";
import "package:polder_core/models/server_settings.dart";
import "package:polder/providers/admin/auth_providers_provider.dart";
import "package:polder/providers/admin/server_settings_provider.dart";
import "package:polder/screens/admin/widgets/auth_provider_editor.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/action_feedback.dart";
import "package:polder_ui/util/api_error_localization.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/auth/provider_badge.dart";
import "package:polder_ui/widgets/layout/adaptive.dart";
import "package:polder_ui/widgets/layout/app_page.dart";
import "package:polder_ui/widgets/shared/async_value_view.dart";
import "package:polder_ui/widgets/shared/confirm_dialog.dart";
import "package:polder_ui/widgets/shared/count_input_dialog.dart";
import "package:polder_ui/widgets/shared/nav_group.dart";
import "package:polder_ui/widgets/shared/notice_tile.dart";

class AdminAuthenticationScreen extends ConsumerWidget {
  const AdminAuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppPage(
    title: Text(context.localized.adminAuthentication),
    body: AsyncValueView<ServerSettings>(
      value: ref.watch(serverSettingsProvider),
      onRetry: () => ref.invalidate(serverSettingsProvider),
      data: (settings) => ReadableWidth(
        maxWidth: 720,
        builder: (context, inset) => ListView(
          padding: inset + const EdgeInsets.only(top: 8, bottom: 24),
          children: [
            _TwoFactorPolicyGroup(settings: settings),
            const _AuthProvidersGroup(),
          ],
        ),
      ),
    ),
  );
}

class _TwoFactorPolicyGroup extends ConsumerWidget {
  const _TwoFactorPolicyGroup({required this.settings});

  final ServerSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final notifier = ref.read(serverSettingsProvider.notifier);
    final mailConfigured = settings.smtpHost.isNotEmpty && settings.smtpFrom.isNotEmpty;
    return NavGroup(
      title: localized.twoFactorTitle,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(localized.requireTwoFactor),
          subtitle: Text(localized.requireTwoFactorHint),
          value: settings.requireTwoFactor,
          onChanged: (required) => _setRequired(context, notifier, required),
        ),
        NavEntry(
          icon: IconsaxPlusLinear.timer_1,
          title: localized.twoFactorGracePeriod,
          subtitle: localized.twoFactorGracePeriodHint(settings.twoFactorGraceDays),
          onTap: () => _chooseDays(context, notifier),
        ),
        if (settings.requireTwoFactor && !mailConfigured)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: NoticeTile(
              icon: IconsaxPlusLinear.sms_notification,
              color: AppColors.of(context).warning,
              text: localized.twoFactorNoMailWarning,
            ),
          ),
      ],
    );
  }

  Future<void> _setRequired(BuildContext context, ServerSettingsNotifier notifier, bool required) async {
    if (required) {
      final confirmed = await showConfirmDialog(
        context,
        title: context.localized.requireTwoFactor,
        message: context.localized.requireTwoFactorConfirm(settings.twoFactorGraceDays),
        confirmLabel: context.localized.require,
      );
      if (!confirmed || !context.mounted) return;
    }
    await context.runWithFeedback(notifier.setRequireTwoFactor(required));
  }

  Future<void> _chooseDays(BuildContext context, ServerSettingsNotifier notifier) async {
    final days = await showCountInputDialog(
      context,
      title: context.localized.twoFactorGracePeriod,
      label: context.localized.days,
      initialValue: settings.twoFactorGraceDays,
      maximum: 365,
    );
    if (days != null && context.mounted) await context.runWithFeedback(notifier.setTwoFactorGraceDays(days));
  }
}

class _AuthProvidersGroup extends ConsumerWidget {
  const _AuthProvidersGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final providers = ref.watch(authProvidersProvider);
    return NavGroup(
      title: localized.singleSignOn,
      trailing: TextButton.icon(
        icon: const Icon(IconsaxPlusLinear.add),
        label: Text(localized.addProvider),
        onPressed: () => showAddAuthProvider(context),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(localized.singleSignOnHint, style: Theme.of(context).textTheme.bodySmall),
        ),
        ...switch (providers) {
          AsyncData(:final value) when value.isEmpty => [ListTile(title: Text(localized.noProviders))],
          AsyncData(:final value) => [_ProviderList(providers: value)],
          AsyncError(:final error) => [ListTile(title: Text(localized.describeError(error)))],
          _ => [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        },
      ],
    );
  }
}

class _ProviderList extends ConsumerWidget {
  const _ProviderList({required this.providers});

  final List<AuthProvider> providers;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ReorderableListView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    buildDefaultDragHandles: false,
    onReorderItem: (from, to) {
      final ordered = [...providers];
      final moved = ordered.removeAt(from);
      ordered.insert(to, moved);
      context.runWithFeedback(ref.read(authProvidersProvider.notifier).reorder(ordered));
    },
    children: [
      for (final (index, provider) in providers.indexed)
        ListTile(
          key: ValueKey(provider.id),
          leading: ReorderableDragStartListener(
            index: index,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                const Icon(IconsaxPlusLinear.menu, size: 18),
                ProviderBadge(preset: provider.preset, label: provider.label),
              ],
            ),
          ),
          title: Text(provider.label),
          subtitle: Text(
            [
              if (provider.managedByConfig) context.localized.managedByConfig,
              context.localized.linkedAccounts(provider.linkedUsers),
            ].join(" · "),
          ),
          trailing: Switch(
            value: provider.enabled,
            onChanged: (enabled) => context.runWithFeedback(
              ref.read(authProvidersProvider.notifier).change(provider.id, AuthProviderChanges(enabled: enabled)),
            ),
          ),
          onTap: () => showEditAuthProvider(context, provider),
        ),
    ],
  );
}
