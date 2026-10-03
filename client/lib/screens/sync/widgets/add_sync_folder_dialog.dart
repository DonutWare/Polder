import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/providers/sync/sync_folder_form_provider.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/shared/icon_badge.dart";
import "package:nomad/widgets/shared/remote_folder_picker_dialog.dart";

Future<void> showAddSyncFolderDialog(BuildContext context, SyncMode mode) => showDialog<void>(
  context: context,
  builder: (_) => AddSyncFolderDialog(mode: mode),
);

class AddSyncFolderDialog extends ConsumerWidget {
  const AddSyncFolderDialog({required this.mode, super.key});

  final SyncMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(syncFolderFormProvider(mode));
    final notifier = ref.read(syncFolderFormProvider(mode).notifier);
    final localized = context.localized;
    return AlertDialog(
      icon: Icon(mode == SyncMode.sync ? IconsaxPlusLinear.folder_add : IconsaxPlusLinear.gallery_add),
      title: Text(mode == SyncMode.sync ? localized.addSyncFolder : localized.addAutoUploadFolder),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const IconBadge(icon: IconsaxPlusLinear.monitor),
              title: Text(localized.localFolder),
              subtitle: Text(form.localPath ?? localized.notChosen),
              trailing: TextButton(onPressed: notifier.pickLocalFolder, child: Text(localized.choose)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const IconBadge(icon: IconsaxPlusLinear.cloud),
              title: Text(localized.serverFolder),
              subtitle: Text(form.remotePath),
              trailing: TextButton(
                onPressed: () => _pickRemote(context, notifier, form.remotePath),
                child: Text(localized.choose),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(localized.cancel)),
        FilledButton(onPressed: form.isComplete ? () => _submit(context, notifier) : null, child: Text(localized.add)),
      ],
    );
  }

  Future<void> _pickRemote(BuildContext context, SyncFolderFormNotifier notifier, String current) async {
    final picked = await showRemoteFolderPicker(context, initialPath: current);
    if (picked != null) notifier.setRemotePath(picked);
  }

  Future<void> _submit(BuildContext context, SyncFolderFormNotifier notifier) async {
    final added = await notifier.submit();
    if (added && context.mounted) Navigator.pop(context);
  }
}
