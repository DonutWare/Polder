import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:intl/intl.dart";
import "package:polder/models/federation.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/federation/federation_providers.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/loading_button.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/password_field.dart";

class AppPasswordsGroup extends ConsumerWidget {
  const AppPasswordsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final account = ref.watch(currentAccountProvider);
    final passwords = ref.watch(appPasswordsProvider);
    final address = account == null ? null : webdavAddress(account.serverUrl, account.user.username);
    return NavGroup(
      title: localized.appPasswords,
      trailing: TextButton.icon(
        icon: const Icon(IconsaxPlusLinear.add),
        label: Text(localized.createAppPassword),
        onPressed: () => _create(context),
      ),
      children: [
        ListTile(
          leading: const Icon(IconsaxPlusLinear.global),
          title: Text(localized.webdavAddress),
          subtitle: Text(address ?? "", overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            tooltip: localized.copy,
            icon: const Icon(IconsaxPlusLinear.copy),
            onPressed: address == null ? null : () => _copy(context, address, localized.webdavAddressCopied),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(localized.appPasswordsHint, style: Theme.of(context).textTheme.bodySmall),
        ),
        ...switch (passwords) {
          AsyncData(:final value) when value.isEmpty => [ListTile(title: Text(localized.noAppPasswords))],
          AsyncData(:final value) => [for (final password in value) _AppPasswordTile(password: password)],
          AsyncError(:final error) => [
            ListTile(
              title: Text(error is ApiException ? localized.describeError(error) : "$error"),
              trailing: IconButton(
                tooltip: localized.refresh,
                icon: const Icon(IconsaxPlusLinear.refresh),
                onPressed: () => ref.invalidate(appPasswordsProvider),
              ),
            ),
          ],
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

  Future<void> _create(BuildContext context) async {
    final created = await showDialog<CreatedAppPassword>(context: context, builder: (_) => const _CreateDialog());
    if (created == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _CreatedDialog(created: created),
    );
  }
}

String webdavAddress(String serverUrl, String username) {
  final base = serverUrl.endsWith("/") ? serverUrl.substring(0, serverUrl.length - 1) : serverUrl;
  return "$base/dav/files/${Uri.encodeComponent(username)}/";
}

void _copy(BuildContext context, String value, String message) {
  Clipboard.setData(ClipboardData(text: value));
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));
}

class _AppPasswordTile extends ConsumerWidget {
  const _AppPasswordTile({required this.password});

  final AppPassword password;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final lastUsed = password.lastUsedAt;
    final details = [
      if (password.readOnly) localized.appPasswordReadOnly,
      lastUsed == null
          ? localized.appPasswordNeverUsed
          : localized.appPasswordLastUsed(DateFormat.yMMMd().add_Hm().format(lastUsed), password.lastUsedAddress),
    ];
    return ListTile(
      leading: Icon(password.readOnly ? IconsaxPlusLinear.eye : IconsaxPlusLinear.key),
      title: Text(password.name, overflow: TextOverflow.ellipsis),
      subtitle: Text(details.join(" · ")),
      trailing: IconButton(
        tooltip: localized.revokeAppPassword,
        icon: const Icon(IconsaxPlusLinear.trash),
        onPressed: () => _revoke(context, ref),
      ),
    );
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    final localized = context.localized;
    final confirmed = await showConfirmDialog(
      context,
      title: localized.revokeAppPasswordTitle(password.name),
      message: localized.revokeAppPasswordMessage,
      confirmLabel: localized.revokeAppPassword,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await context.runWithFeedback(ref.read(appPasswordsProvider.notifier).revoke(password));
  }
}

class _CreateDialog extends ConsumerStatefulWidget {
  const _CreateDialog();

  @override
  ConsumerState<_CreateDialog> createState() => _CreateDialogState();
}

class _CreateDialogState extends ConsumerState<_CreateDialog> {
  final _name = TextEditingController();
  final _password = TextEditingController();
  var _readOnly = false;
  var _saving = false;
  var _passwordIncorrect = false;

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _canSave => _name.text.trim().isNotEmpty && _password.text.isNotEmpty && !_saving;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return AlertDialog(
      title: Text(localized.createAppPassword),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              maxLength: 100,
              decoration: InputDecoration(labelText: localized.name, hintText: localized.appPasswordNameHint),
              onChanged: (_) => setState(() {}),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(localized.appPasswordReadOnly),
              subtitle: Text(localized.appPasswordReadOnlyHint),
              value: _readOnly,
              onChanged: (value) => setState(() => _readOnly = value),
            ),
            PasswordField(
              controller: _password,
              label: localized.currentPassword,
              autofillHints: const [AutofillHints.password],
              errorText: _passwordIncorrect ? localized.currentPasswordIncorrect : null,
              helperText: localized.appPasswordConfirmHint,
              onChanged: (_) => setState(() => _passwordIncorrect = false),
              onSubmitted: (_) => _canSave ? _save() : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(localized.cancel)),
        LoadingButton(label: localized.create, loading: _saving, onPressed: _canSave ? _save : null),
      ],
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final localizations = context.localized;
    setState(() => _saving = true);
    try {
      final created = await ref
          .read(appPasswordsProvider.notifier)
          .create(name: _name.text.trim(), currentPassword: _password.text, readOnly: _readOnly);
      if (mounted) Navigator.of(context).pop(created);
      return;
    } on ForbiddenException {
      _passwordIncorrect = true;
    } on ApiException catch (error) {
      messenger?.showSnackBar(SnackBar(content: Text(localizations.describeError(error))));
    }
    if (mounted) setState(() => _saving = false);
  }
}

class _CreatedDialog extends StatelessWidget {
  const _CreatedDialog({required this.created});

  final CreatedAppPassword created;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(localized.appPasswordCreatedTitle),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(localized.appPasswordCreatedMessage),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  created.token,
                  style: theme.textTheme.bodyMedium?.copyWith(fontFamily: "monospace"),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(IconsaxPlusLinear.copy),
          label: Text(localized.copy),
          onPressed: () => _copy(context, created.token, localized.appPasswordCopied),
        ),
        FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(localized.done)),
      ],
    );
  }
}
