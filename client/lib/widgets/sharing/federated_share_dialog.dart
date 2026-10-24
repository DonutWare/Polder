import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/federation.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/federation/federation_providers.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/loading_button.dart";

Future<bool> showNewFederatedShare(BuildContext context, {required SharedFile file, required String recipient}) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => _FederatedShareDialog(file: file, recipient: recipient),
    ) ??
    false;

Future<void> showFederatedShareSettings(
  BuildContext context, {
  required SharedFile file,
  required FederatedShare share,
}) => showDialog<void>(
  context: context,
  builder: (_) => _FederatedShareDialog(file: file, recipient: share.recipient, existing: share),
);

class _FederatedShareDialog extends ConsumerStatefulWidget {
  const _FederatedShareDialog({required this.file, required this.recipient, this.existing});

  final SharedFile file;
  final String recipient;
  final FederatedShare? existing;

  @override
  ConsumerState<_FederatedShareDialog> createState() => _FederatedShareDialogState();
}

class _FederatedShareDialogState extends ConsumerState<_FederatedShareDialog> {
  late var _permissions = widget.existing?.permissions ?? SharePermissions.viewOnly;
  var _saving = false;
  String? _error;

  FederatedSharesNotifier get _notifier => ref.read(federatedSharesProvider(widget.file.id).notifier);

  @override
  Widget build(BuildContext context) {
    ref.watch(federatedSharesProvider(widget.file.id));
    final localized = context.localized;
    final existing = widget.existing;
    return AlertDialog(
      icon: const Icon(IconsaxPlusLinear.global),
      title: Text(widget.recipient, overflow: TextOverflow.ellipsis),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(existing == null ? localized.federatedShareHint : _stateText(context, existing)),
            const SizedBox(height: 8),
            if (widget.file.isDir)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(localized.sharePermCreate),
                value: _permissions.create,
                onChanged: (value) => setState(() => _permissions = _permissions.copyWith(create: value ?? false)),
              ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(localized.sharePermEdit),
              value: _permissions.edit,
              onChanged: (value) => setState(() => _permissions = _permissions.copyWith(edit: value ?? false)),
            ),
            if (widget.file.isDir)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(localized.sharePermDelete),
                value: _permissions.delete,
                onChanged: (value) => setState(() => _permissions = _permissions.copyWith(delete: value ?? false)),
              ),
            if (_error case final error?)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ),
      ),
      actions: [
        if (existing != null)
          TextButton(
            onPressed: _saving ? null : () => _run(() => _notifier.remove(existing)),
            child: Text(localized.shareStop),
          ),
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(localized.cancel)),
        LoadingButton(
          label: existing == null ? localized.share : localized.save,
          loading: _saving,
          onPressed: _saving
              ? null
              : () => _run(
                  () => existing == null
                      ? _notifier.add(
                          fileId: widget.file.id,
                          recipient: widget.recipient,
                          permissions: _permissions.forEntry(isDir: widget.file.isDir),
                        )
                      : _notifier.change(existing, _permissions.forEntry(isDir: widget.file.isDir)),
                ),
        ),
      ],
    );
  }

  String _stateText(BuildContext context, FederatedShare share) =>
      share.isPending ? context.localized.federatedSharePending : context.localized.federatedShareAccepted;

  Future<void> _run(Future<void> Function() action) async {
    final localizations = context.localized;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) Navigator.of(context).pop(true);
      return;
    } on ApiException catch (error) {
      _error = localizations.describeError(error);
    }
    if (mounted) setState(() => _saving = false);
  }
}
