import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/models/user.dart";
import "package:nomad/providers/admin/user_form_provider.dart";
import "package:nomad/screens/admin/widgets/quota_input.dart";
import "package:nomad/screens/admin/widgets/role_selector.dart";
import "package:nomad/util/action_feedback.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/shared/loading_button.dart";
import "package:nomad/widgets/shared/retention_picker_dialog.dart";

Future<void> showUserFormDialog(BuildContext context, {User? user}) => showDialog<void>(
  context: context,
  builder: (_) => UserFormDialog(user: user),
);

class UserFormDialog extends ConsumerWidget {
  const UserFormDialog({this.user, super.key});

  final User? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(userFormProvider(user));
    final notifier = ref.read(userFormProvider(user).notifier);
    final localized = context.localized;
    return AlertDialog(
      icon: Icon(form.isNew ? IconsaxPlusLinear.user_add : IconsaxPlusLinear.user_edit),
      title: Text(form.isNew ? localized.addUser : localized.editUser(form.username)),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              if (form.isNew)
                TextFormField(
                  initialValue: form.username,
                  decoration: InputDecoration(labelText: localized.username),
                  onChanged: notifier.setUsername,
                ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: form.isNew ? localized.password : localized.newPasswordOptional),
                onChanged: notifier.setPassword,
              ),
              RoleSelector(role: form.role, onChanged: notifier.setRole),
              QuotaInput(
                amount: form.quotaAmount,
                unit: form.quotaUnit,
                isValid: form.isQuotaValid,
                onAmountChanged: notifier.setQuotaAmount,
                onUnitChanged: notifier.setQuotaUnit,
              ),
              if (!form.isNew)
                DropdownButtonFormField<int?>(
                  initialValue: form.trashRetentionOverrideDays,
                  decoration: InputDecoration(labelText: localized.serverTrashRetention),
                  hint: Text(localized.userTrashRetentionUsersChoice),
                  items: [
                    DropdownMenuItem(child: Text(localized.userTrashRetentionUsersChoice)),
                    for (final days in RetentionOptions.including(form.trashRetentionOverrideDays))
                      DropdownMenuItem(value: days, child: Text(context.retentionDuration(days))),
                  ],
                  onChanged: notifier.setTrashRetentionOverride,
                ),
              if (!form.isNew)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localized.disabled),
                  value: form.disabled,
                  onChanged: notifier.setDisabled,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(localized.cancel)),
        LoadingButton(
          label: localized.save,
          loading: form.saving,
          onPressed: form.isValid ? () => _save(context, notifier) : null,
        ),
      ],
    );
  }

  Future<void> _save(BuildContext context, UserFormNotifier notifier) async {
    final saved = await context.runWithFeedback(notifier.save());
    if (saved && context.mounted) Navigator.pop(context);
  }
}
