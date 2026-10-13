import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/user.dart";
import "package:polder/providers/admin/user_form_provider.dart";
import "package:polder/screens/admin/widgets/quota_input.dart";
import "package:polder/screens/admin/widgets/role_selector.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/credential_rules.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/loading_button.dart";
import "package:polder/widgets/shared/password_field.dart";

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
                  decoration: InputDecoration(
                    labelText: localized.username,
                    helperText: localized.usernameRequirements,
                    helperMaxLines: 2,
                    errorText: form.username.isEmpty || form.isUsernameValid ? null : localized.usernameRequirements,
                    errorMaxLines: 2,
                  ),
                  onChanged: notifier.setUsername,
                ),
              PasswordField(
                label: form.isNew ? localized.password : localized.newPasswordOptional,
                autofillHints: const [AutofillHints.newPassword],
                helperText: localized.passwordRequirements(CredentialRules.minPasswordLength),
                errorText: form.password.isEmpty || form.isPasswordValid
                    ? null
                    : localized.passwordRequirements(CredentialRules.minPasswordLength),
                onChanged: notifier.setPassword,
              ),
              if (form.isNew || form.password.isNotEmpty || form.passwordConfirmation.isNotEmpty)
                PasswordField(
                  label: form.isNew ? localized.confirmPassword : localized.confirmNewPassword,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: form.passwordConfirmation.isEmpty || form.passwordsMatch
                      ? null
                      : localized.passwordsDoNotMatch,
                  onChanged: notifier.setPasswordConfirmation,
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
