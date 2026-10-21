import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/federation.dart";
import "package:polder/providers/federation/federation_providers.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/loading_button.dart";

Future<void> createAndShowInvite(BuildContext context, WidgetRef ref) async {
  FederationInvite? invite;
  final created = await context.runWithFeedback(() async {
    invite = await ref.read(federationInvitesProvider.notifier).create();
  }());
  if (!created || invite == null || !context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => _InviteCreatedDialog(invite: invite!),
  );
}

Future<void> showAcceptInvite(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _AcceptInviteDialog());

class _InviteCreatedDialog extends StatelessWidget {
  const _InviteCreatedDialog({required this.invite});

  final FederationInvite invite;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final theme = Theme.of(context);
    Widget field(String label, String value) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: theme.textTheme.labelMedium),
      subtitle: SelectableText(value, style: theme.textTheme.bodyMedium?.copyWith(fontFamily: "monospace")),
      trailing: IconButton(
        tooltip: localized.copy,
        icon: const Icon(IconsaxPlusLinear.copy),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(localized.copied)));
        },
      ),
    );
    return AlertDialog(
      icon: const Icon(IconsaxPlusLinear.user_add),
      title: Text(localized.inviteCreatedTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(localized.inviteCreatedMessage(invite.expiresAt.formattedDate(context))),
            const SizedBox(height: 8),
            field(localized.inviteToken, invite.token),
            field(localized.serverAddress, invite.provider),
          ],
        ),
      ),
      actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(localized.done))],
    );
  }
}

class _AcceptInviteDialog extends ConsumerStatefulWidget {
  const _AcceptInviteDialog();

  @override
  ConsumerState<_AcceptInviteDialog> createState() => _AcceptInviteDialogState();
}

class _AcceptInviteDialogState extends ConsumerState<_AcceptInviteDialog> {
  final _token = TextEditingController();
  final _provider = TextEditingController();
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _token.dispose();
    _provider.dispose();
    super.dispose();
  }

  bool get _canSave => _token.text.trim().isNotEmpty && _provider.text.trim().isNotEmpty && !_saving;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return AlertDialog(
      title: Text(localized.acceptInvite),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(localized.acceptInviteHint),
            TextField(
              controller: _token,
              autofocus: true,
              decoration: InputDecoration(labelText: localized.inviteToken),
              onChanged: (_) => setState(() => _error = null),
            ),
            TextField(
              controller: _provider,
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
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(localized.cancel)),
        LoadingButton(label: localized.accept, loading: _saving, onPressed: _canSave ? _save : null),
      ],
    );
  }

  Future<void> _save() async {
    final localizations = context.localized;
    final messenger = ScaffoldMessenger.maybeOf(context);
    setState(() => _saving = true);
    try {
      final contact = await ref
          .read(federationContactsProvider.notifier)
          .acceptInvite(token: _token.text, provider: _provider.text);
      messenger?.showSnackBar(SnackBar(content: Text(localizations.inviteAccepted(contact.shownName))));
      if (mounted) Navigator.of(context).pop();
      return;
    } on ApiException catch (error) {
      _error = localizations.describeError(error);
    }
    if (mounted) setState(() => _saving = false);
  }
}
