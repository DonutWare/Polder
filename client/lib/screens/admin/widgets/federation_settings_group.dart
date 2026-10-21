import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/federation.dart";
import "package:polder/providers/admin/server_settings_provider.dart";
import "package:polder/providers/federation/federation_providers.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/loading_button.dart";
import "package:polder/widgets/shared/nav_group.dart";

class ServerFederationSettingsGroup extends ConsumerWidget {
  const ServerFederationSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(serverSettingsProvider).value;
    final status = ref.watch(federationStatusProvider).value;
    final localized = context.localized;
    if (settings == null || status == null) return const SizedBox.shrink();
    return NavGroup(
      title: localized.federation,
      trailing: settings.federationEnabled
          ? TextButton.icon(
              icon: const Icon(IconsaxPlusLinear.add),
              label: Text(localized.trustServer),
              onPressed: () => showDialog<void>(context: context, builder: (_) => const _AddServerDialog()),
            )
          : null,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(localized.federationEnabled),
          subtitle: Text(status.configured ? localized.federationEnabledHint : localized.federationNeedsPublicUrl),
          value: settings.federationEnabled,
          onChanged: status.configured || settings.federationEnabled
              ? (enabled) => _setEnabled(context, ref, enabled)
              : null,
        ),
        if (settings.federationEnabled) const _TrustedServers(),
      ],
    );
  }

  Future<void> _setEnabled(BuildContext context, WidgetRef ref, bool enabled) async {
    if (await context.runWithFeedback(ref.read(serverSettingsProvider.notifier).setFederationEnabled(enabled))) {
      ref.invalidate(federationStatusProvider);
    }
  }
}

class _TrustedServers extends ConsumerWidget {
  const _TrustedServers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    return switch (ref.watch(trustedServersProvider)) {
      AsyncData(:final value) when value.isEmpty => ListTile(
        leading: const Icon(IconsaxPlusLinear.shield_security),
        title: Text(localized.noTrustedServers),
        subtitle: Text(localized.noTrustedServersHint),
      ),
      AsyncData(:final value) => Column(children: [for (final server in value) _ServerTile(server: server)]),
      AsyncError(:final error) => ListTile(
        title: Text(error is ApiException ? localized.describeError(error) : "$error"),
        trailing: IconButton(
          tooltip: localized.refresh,
          icon: const Icon(IconsaxPlusLinear.refresh),
          onPressed: () => ref.invalidate(trustedServersProvider),
        ),
      ),
      _ => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

enum _ServerAction { rediscover, addressCheck, remove }

class _ServerTile extends ConsumerWidget {
  const _ServerTile({required this.server});

  final TrustedServer server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final details = [
      if (server.provider.isNotEmpty) server.provider,
      if (server.signsRequests)
        localized.serverKey(_shortFingerprint(server.keyFingerprint))
      else
        server.verifySenderAddress ? localized.serverUnsignedChecked : localized.serverUnsignedAnyAddress,
      if (server.allowPrivateNetwork) localized.allowPrivateNetwork,
    ];
    return ListTile(
      leading: Icon(
        server.signsRequests || server.verifySenderAddress
            ? IconsaxPlusLinear.shield_tick
            : IconsaxPlusLinear.shield_cross,
      ),
      title: Text(server.remote, overflow: TextOverflow.ellipsis),
      subtitle: Text(details.join(" · ")),
      trailing: PopupMenuButton<_ServerAction>(
        icon: const Icon(IconsaxPlusLinear.more),
        onSelected: (action) => switch (action) {
          _ServerAction.rediscover => _rediscover(context, ref),
          _ServerAction.addressCheck => context.runWithFeedback(
            ref.read(trustedServersProvider.notifier).setAddressCheck(server, verify: !server.verifySenderAddress),
          ),
          _ServerAction.remove => _remove(context, ref),
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: _ServerAction.rediscover, child: Text(localized.rediscoverServer)),
          if (!server.signsRequests)
            CheckedPopupMenuItem(
              value: _ServerAction.addressCheck,
              checked: server.verifySenderAddress,
              child: Text(localized.checkSenderAddress),
            ),
          PopupMenuItem(value: _ServerAction.remove, child: Text(localized.remove)),
        ],
      ),
    );
  }

  Future<void> _rediscover(BuildContext context, WidgetRef ref) async {
    final localized = context.localized;
    final confirmed = await showConfirmDialog(
      context,
      title: localized.rediscoverServerTitle(server.remote),
      message: localized.rediscoverServerMessage,
      confirmLabel: localized.rediscoverServer,
    );
    if (!confirmed || !context.mounted) return;
    await context.runWithFeedback(ref.read(trustedServersProvider.notifier).rediscover(server));
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final localized = context.localized;
    final confirmed = await showConfirmDialog(
      context,
      title: localized.removeTrustedServerTitle(server.remote),
      message: localized.removeTrustedServerMessage,
      confirmLabel: localized.remove,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await context.runWithFeedback(ref.read(trustedServersProvider.notifier).remove(server));
  }
}

String _shortFingerprint(String fingerprint) {
  final short = fingerprint.length > 16 ? fingerprint.substring(0, 16) : fingerprint;
  return [for (var i = 0; i < short.length; i += 4) short.substring(i, (i + 4).clamp(0, short.length))].join(" ");
}

class _AddServerDialog extends ConsumerStatefulWidget {
  const _AddServerDialog();

  @override
  ConsumerState<_AddServerDialog> createState() => _AddServerDialogState();
}

class _AddServerDialogState extends ConsumerState<_AddServerDialog> {
  final _remote = TextEditingController();
  var _allowPrivate = false;
  var _checkAddress = true;
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _remote.dispose();
    super.dispose();
  }

  bool get _canSave => _remote.text.trim().isNotEmpty && !_saving;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return AlertDialog(
      title: Text(localized.trustServer),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(localized.trustServerHint),
            TextField(
              controller: _remote,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: localized.serverAddress,
                hintText: "cloud.example.com",
                errorText: _error,
                errorMaxLines: 4,
              ),
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => _canSave ? _save() : null,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(localized.allowPrivateNetwork),
              subtitle: Text(localized.allowPrivateNetworkHint),
              value: _allowPrivate,
              onChanged: (value) => setState(() => _allowPrivate = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(localized.checkSenderAddress),
              subtitle: Text(localized.checkSenderAddressHint),
              value: _checkAddress,
              onChanged: (value) => setState(() => _checkAddress = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(localized.cancel)),
        LoadingButton(label: localized.add, loading: _saving, onPressed: _canSave ? _save : null),
      ],
    );
  }

  Future<void> _save() async {
    final localizations = context.localized;
    setState(() => _saving = true);
    try {
      await ref
          .read(trustedServersProvider.notifier)
          .add(_remote.text.trim(), allowPrivateNetwork: _allowPrivate, skipAddressCheck: !_checkAddress);
      if (mounted) Navigator.of(context).pop();
      return;
    } on ApiException catch (error) {
      _error = localizations.describeError(error);
    }
    if (mounted) setState(() => _saving = false);
  }
}
