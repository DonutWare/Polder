import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_core/models/security.dart";
import "package:polder/providers/admin/auth_providers_provider.dart";
import "package:polder/screens/admin/widgets/provider_terms.dart";
import "package:polder_core/services/api/api_exceptions.dart";
import "package:polder_ui/util/api_error_localization.dart";
import "package:polder_ui/util/clipboard.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/auth/provider_badge.dart";
import "package:polder_ui/widgets/shared/confirm_dialog.dart";
import "package:polder_ui/widgets/shared/loading_button.dart";
import "package:polder_ui/widgets/shared/password_field.dart";

Future<void> showAddAuthProvider(BuildContext context) async {
  final preset = await showDialog<AuthProviderPreset>(context: context, builder: (_) => const _PresetPicker());
  if (preset == null || !context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => _AuthProviderForm(preset: preset),
  );
}

Future<void> showEditAuthProvider(BuildContext context, AuthProvider provider) => showDialog<void>(
  context: context,
  builder: (_) => _AuthProviderForm(existing: provider),
);

class _PresetPicker extends ConsumerWidget {
  const _PresetPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(authProviderPresetsProvider);
    return AlertDialog(
      title: Text(context.localized.addProvider),
      content: SizedBox(
        width: 420,
        child: switch (presets) {
          AsyncData(:final value) => GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2.6,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (final preset in value)
                OutlinedButton.icon(
                  icon: ProviderBadge(preset: preset.id, label: preset.label),
                  label: Text(preset.label, overflow: TextOverflow.ellipsis),
                  onPressed: () => Navigator.of(context).pop(preset),
                ),
            ],
          ),
          AsyncError(:final error) => Text(context.localized.describeError(error)),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.localized.cancel))],
    );
  }
}

class _AuthProviderForm extends ConsumerStatefulWidget {
  const _AuthProviderForm({this.preset, this.existing});

  final AuthProviderPreset? preset;
  final AuthProvider? existing;

  @override
  ConsumerState<_AuthProviderForm> createState() => _AuthProviderFormState();
}

class _AuthProviderFormState extends ConsumerState<_AuthProviderForm> {
  late final _label = TextEditingController(text: widget.existing?.label ?? widget.preset?.label ?? "");
  late final _issuer = TextEditingController(text: widget.existing?.issuer ?? "");
  late final _clientId = TextEditingController(text: widget.existing?.clientId ?? "");
  final _clientSecret = TextEditingController();
  late final _fields = {
    for (final field in widget.preset?.fields ?? const <AuthProviderField>[]) field: TextEditingController(),
  };
  late bool _allowSignup = widget.existing?.allowSignup ?? widget.preset?.allowSignup ?? false;
  late bool _linkByEmail = widget.existing?.linkByEmail ?? widget.preset?.linkByEmail ?? true;
  AuthProvider? _saved;
  bool _busy = false;
  String? _error;
  String? _testResult;

  AuthProvider? get _current => _saved ?? widget.existing;

  bool get _locked => widget.existing?.managedByConfig ?? false;

  @override
  void dispose() {
    for (final controller in [_label, _issuer, _clientId, _clientSecret, ..._fields.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final theme = Theme.of(context);
    final current = _current;
    final preset = widget.preset;
    final terms = ProviderTerms.of(context, current?.preset ?? preset?.id ?? "");
    return AlertDialog(
      title: Text(current == null ? localized.addProviderNamed(preset!.label) : current.label),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: 14,
            children: [
              if (current != null) _callbackTile(context, current, terms),
              if (current == null && preset != null) Text(preset.setupHint, style: theme.textTheme.bodySmall),
              if (_locked) Text(localized.providerManagedByConfigHint, style: theme.textTheme.bodySmall),
              TextField(
                controller: _label,
                enabled: !_locked,
                decoration: InputDecoration(labelText: localized.buttonLabel),
              ),
              if (current == null)
                for (final MapEntry(key: field, value: controller) in _fields.entries)
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: terms.fieldLabel(context, field),
                      helperText: terms.fieldHint(field),
                      helperMaxLines: 2,
                    ),
                  ),
              if (current != null && !current.isGitHub)
                TextField(
                  controller: _issuer,
                  enabled: !_locked,
                  decoration: InputDecoration(labelText: localized.issuerUrl),
                ),
              TextField(
                controller: _clientId,
                enabled: !_locked,
                decoration: InputDecoration(labelText: terms.clientId),
              ),
              PasswordField(
                controller: _clientSecret,
                enabled: !_locked,
                label: terms.clientSecret,
                helperText: current?.clientSecretSet ?? false ? localized.clientSecretKept : null,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(localized.providerAllowSignup),
                subtitle: Text(localized.providerAllowSignupHint),
                value: _allowSignup,
                onChanged: _locked ? null : (value) => setState(() => _allowSignup = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(localized.providerLinkByEmail),
                subtitle: Text(localized.providerLinkByEmailHint),
                value: _linkByEmail,
                onChanged: _locked ? null : (value) => setState(() => _linkByEmail = value),
              ),
              if (_testResult case final result?)
                Text(
                  result.isEmpty ? localized.providerTestOk : localized.providerTestFailed(result),
                  style: TextStyle(color: result.isEmpty ? theme.colorScheme.primary : theme.colorScheme.error),
                ),
              if (_error case final error?) Text(error, style: TextStyle(color: theme.colorScheme.error)),
            ],
          ),
        ),
      ),
      actions: [
        if (current != null && !current.managedByConfig)
          TextButton(
            onPressed: _busy ? null : () => _delete(current),
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: Text(localized.delete),
          ),
        if (current != null)
          TextButton(onPressed: _busy ? null : () => _test(current), child: Text(localized.testConnection)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_saved == null ? localized.cancel : localized.done),
        ),
        if (!_locked) LoadingButton(label: localized.save, loading: _busy, onPressed: _save),
      ],
    );
  }

  Widget _callbackTile(BuildContext context, AuthProvider provider, ProviderTerms terms) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(IconsaxPlusLinear.link),
    title: Text(context.localized.callbackUrl),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(provider.callbackUrl),
        Text(
          context.localized.callbackUrlHint(terms.providerName, terms.redirectField),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
    trailing: IconButton(
      icon: const Icon(IconsaxPlusLinear.copy),
      tooltip: context.localized.copy,
      onPressed: () => copyWithNotice(context, provider.callbackUrl, context.localized.copied),
    ),
  );

  Future<void> _save() => _run(() async {
    final notifier = ref.read(authProvidersProvider.notifier);
    final current = _current;
    if (current == null) {
      final created = await notifier.create(
        NewAuthProvider(
          preset: widget.preset!.id,
          label: _label.text,
          fields: {for (final MapEntry(:key, :value) in _fields.entries) key: value.text.trim()},
          clientId: _clientId.text,
          clientSecret: _clientSecret.text,
          allowSignup: _allowSignup,
          linkByEmail: _linkByEmail,
        ),
      );
      if (mounted) {
        setState(() {
          _saved = created;
          _issuer.text = created.issuer;
        });
      }
      return;
    }
    await notifier.change(
      current.id,
      AuthProviderChanges(
        label: _label.text.trim(),
        issuer: current.isGitHub ? null : _issuer.text.trim(),
        clientId: _clientId.text.trim(),
        clientSecret: _clientSecret.text.isEmpty ? null : _clientSecret.text,
        allowSignup: _allowSignup,
        linkByEmail: _linkByEmail,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  });

  Future<void> _test(AuthProvider provider) => _run(() async {
    final failure = await ref.read(authProvidersProvider.notifier).test(provider.id);
    if (mounted) setState(() => _testResult = failure ?? "");
  });

  Future<void> _delete(AuthProvider provider) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.localized.deleteProviderTitle(provider.label),
      message: context.localized.deleteProviderMessage(provider.linkedUsers),
      confirmLabel: context.localized.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _run(() async {
      await ref.read(authProvidersProvider.notifier).delete(provider.id);
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on ApiException catch (error) {
      if (mounted) {
        setState(
          () => _error = error.serverMessage.isEmpty ? context.localized.describeError(error) : error.serverMessage,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
