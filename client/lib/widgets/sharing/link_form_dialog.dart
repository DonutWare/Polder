import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/sharing.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/password_field.dart";
import "package:polder/widgets/sharing/expiry_tile.dart";

Future<LinkOptions?> showLinkFormDialog(BuildContext context, {required bool isDir, ShareLink? link}) =>
    showDialog<LinkOptions>(
      context: context,
      builder: (_) => _LinkFormDialog(isDir: isDir, link: link),
    );

class _LinkFormDialog extends StatefulWidget {
  const _LinkFormDialog({required this.isDir, this.link});

  final bool isDir;
  final ShareLink? link;

  @override
  State<_LinkFormDialog> createState() => _LinkFormDialogState();
}

class _LinkFormDialogState extends State<_LinkFormDialog> {
  final _password = TextEditingController();
  late LinkPermissions _permissions = widget.link?.permissions ?? const LinkPermissions();
  late DateTime? _expiresAt = widget.link?.expiresAt;
  var _removePassword = false;

  bool get _editing => widget.link != null;

  bool get _hadPassword => widget.link?.hasPassword ?? false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return AlertDialog(
      title: Text(_editing ? localized.editLink : localized.createLink),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(localized.linkAccess, style: Theme.of(context).textTheme.labelLarge),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(IconsaxPlusLinear.eye),
                    title: Text(localized.linkCanView),
                    subtitle: Text(localized.linkCanViewHint),
                    value: _permissions.view,
                    onChanged: (view) => setState(
                      () => _permissions = _permissions.copyWith(view: view, download: view && _permissions.download),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(IconsaxPlusLinear.document_download),
                    title: Text(localized.linkCanDownload),
                    subtitle: Text(localized.linkCanDownloadHint),
                    value: _permissions.download,
                    onChanged: _permissions.view
                        ? (download) => setState(() => _permissions = _permissions.copyWith(download: download))
                        : null,
                  ),
                  if (widget.isDir)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(IconsaxPlusLinear.document_upload),
                      title: Text(localized.linkCanUpload),
                      subtitle: Text(localized.linkCanUploadHint),
                      value: _permissions.upload,
                      onChanged: (upload) => setState(() => _permissions = _permissions.copyWith(upload: upload)),
                    ),
                ],
              ),
              PasswordField(
                controller: _password,
                enabled: !_removePassword,
                autofillHints: const [AutofillHints.newPassword],
                label: localized.linkPassword,
                helperText: _hadPassword ? localized.linkPasswordKeep : localized.linkPasswordHint,
              ),
              if (_hadPassword)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _removePassword,
                  title: Text(localized.linkRemovePassword),
                  onChanged: (value) => setState(() => _removePassword = value ?? false),
                ),
              ExpiryTile(value: _expiresAt, onChanged: (value) => setState(() => _expiresAt = value)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(localized.cancel)),
        FilledButton(
          onPressed: _permissions.isValid ? _submit : null,
          child: Text(_editing ? localized.save : localized.create),
        ),
      ],
    );
  }

  void _submit() {
    final password = _password.text;
    Navigator.pop(
      context,
      LinkOptions(
        permissions: widget.isDir ? _permissions : _permissions.copyWith(upload: false),
        password: _removePassword || password.isEmpty ? null : password,
        removePassword: _removePassword,
        expiresAt: _expiresAt,
        removeExpiry: _editing && _expiresAt == null && widget.link?.expiresAt != null,
      ),
    );
  }
}
