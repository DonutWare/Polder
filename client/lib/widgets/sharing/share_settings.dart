import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/sharing.dart";
import "package:polder/providers/sharing/share_actions.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/sharing/expiry_tile.dart";
import "package:polder/widgets/sharing/share_target_avatar.dart";

typedef ShareSettings = ({SharePermissions permissions, DateTime? expiresAt, String note});

typedef ShareSettingsAction = Future<void> Function(WidgetRef ref, ShareSettings settings);

Future<void> showShareSettings(BuildContext context, OutgoingShare share) => _showShareSettingsDialog<void>(
  context,
  recipient: share.recipient,
  fileName: share.file.name,
  subtitle: context.localized.sharedWithName(share.recipient.name),
  form: (done) => ShareSettingsForm.forShare(share, onDone: done),
);

Future<bool> showNewShareSettings(
  BuildContext context, {
  required SharedFile file,
  required ShareTarget recipient,
}) async =>
    await _showShareSettingsDialog<bool>(
      context,
      recipient: recipient,
      fileName: file.name,
      subtitle: context.localized.shareWithName(recipient.name),
      form: (done) => ShareSettingsForm(
        isDir: file.isDir,
        submitLabel: context.localized.share,
        onSubmit: (ref, settings) => ref
            .read(outgoingSharesProvider(file.id).notifier)
            .add(
              fileId: file.id,
              recipient: recipient,
              permissions: settings.permissions.forEntry(isDir: file.isDir),
              expiresAt: settings.expiresAt,
              note: settings.note,
            ),
        onDone: () => done(true),
      ),
    ) ??
    false;

Future<T?> _showShareSettingsDialog<T>(
  BuildContext context, {
  required ShareTarget recipient,
  required String fileName,
  required String subtitle,
  required Widget Function(void Function([T? result]) done) form,
}) => showDialog<T>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Row(
      spacing: 12,
      children: [
        ShareTargetAvatar(target: recipient),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fileName, overflow: TextOverflow.ellipsis),
              Text(subtitle, style: Theme.of(dialogContext).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    ),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(child: form(([result]) => Navigator.pop(dialogContext, result))),
    ),
  ),
);

class ShareSettingsForm extends ConsumerStatefulWidget {
  const ShareSettingsForm({
    required this.isDir,
    required this.onSubmit,
    this.initial = (permissions: SharePermissions.viewOnly, expiresAt: null, note: ""),
    this.enabled = true,
    this.submitLabel,
    this.onRemove,
    this.onDone,
    super.key,
  });

  ShareSettingsForm.forShare(OutgoingShare share, {this.onDone, super.key})
    : isDir = share.file.isDir,
      initial = (permissions: share.permissions, expiresAt: share.expiresAt, note: share.note),
      enabled = share.canChange,
      submitLabel = null,
      onSubmit = ((ref, settings) => ShareActions.update(
        ref,
        share,
        permissions: settings.permissions,
        expiresAt: settings.expiresAt,
        note: settings.note,
      )),
      onRemove = share.canRemove ? ((ref) => ShareActions.remove(ref, share)) : null;

  final bool isDir;
  final ShareSettings initial;
  final bool enabled;
  final String? submitLabel;
  final ShareSettingsAction onSubmit;
  final Future<void> Function(WidgetRef ref)? onRemove;
  final VoidCallback? onDone;

  @override
  ConsumerState<ShareSettingsForm> createState() => _ShareSettingsFormState();
}

class _ShareSettingsFormState extends ConsumerState<ShareSettingsForm> {
  late SharePermissions _permissions = widget.initial.permissions;
  late DateTime? _expiresAt = widget.initial.expiresAt;
  late final _note = TextEditingController(text: widget.initial.note);
  var _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final isDir = widget.isDir;
    final enabled = widget.enabled;
    final onRemove = widget.onRemove;
    Widget permission(String label, bool value, [SharePermissions Function(bool)? change]) => CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(label),
      value: value,
      onChanged: change != null && enabled
          ? (checked) => setState(() => _permissions = change(checked ?? false))
          : null,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        permission(localized.sharePermView, true),
        if (isDir)
          permission(localized.sharePermCreate, _permissions.create, (value) => _permissions.copyWith(create: value)),
        permission(localized.sharePermEdit, _permissions.edit, (value) => _permissions.copyWith(edit: value)),
        if (isDir)
          permission(localized.sharePermDelete, _permissions.delete, (value) => _permissions.copyWith(delete: value)),
        ExpiryTile(
          dense: true,
          enabled: enabled,
          value: _expiresAt,
          onChanged: (value) => setState(() => _expiresAt = value),
        ),
        TextField(
          controller: _note,
          enabled: enabled,
          minLines: 1,
          maxLines: 4,
          maxLength: 1000,
          decoration: InputDecoration(labelText: localized.shareNote, helperText: localized.shareNoteHint),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (onRemove != null)
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                icon: const Icon(IconsaxPlusLinear.minus_cirlce),
                label: Text(localized.shareStop),
                onPressed: _busy ? null : () => _run(onRemove(ref)),
              ),
            const Spacer(),
            if (enabled)
              FilledButton(onPressed: _busy ? null : _submit, child: Text(widget.submitLabel ?? localized.save)),
          ],
        ),
      ],
    );
  }

  Future<void> _submit() =>
      _run(widget.onSubmit(ref, (permissions: _permissions, expiresAt: _expiresAt, note: _note.text.trim())));

  Future<void> _run(Future<void> action) async {
    setState(() => _busy = true);
    final done = await context.runWithFeedback(action);
    if (!mounted) return;
    setState(() => _busy = false);
    if (done) widget.onDone?.call();
  }
}
