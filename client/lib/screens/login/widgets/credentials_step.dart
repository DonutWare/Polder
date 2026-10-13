import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/login_provider.dart";
import "package:polder/screens/login/widgets/login_failure_text.dart";
import "package:polder/screens/login/widgets/server_summary.dart";
import "package:polder/util/credential_rules.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/loading_button.dart";
import "package:polder/widgets/shared/password_field.dart";

class CredentialsStep extends ConsumerWidget {
  const CredentialsStep({required this.creatingAdmin, super.key});

  static const usernameFieldKey = Key("login.username");
  static const passwordFieldKey = Key("login.password");
  static const passwordConfirmationFieldKey = Key("login.passwordConfirmation");
  static const submitButtonKey = Key("login.submit");

  final bool creatingAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);
    final submit = creatingAdmin ? notifier.createAdmin : notifier.signIn;
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          const ServerSummary(),
          if (creatingAdmin) Text(context.localized.setupIntro, textAlign: TextAlign.center),
          TextFormField(
            key: usernameFieldKey,
            initialValue: state.username,
            autofillHints: const [AutofillHints.username],
            decoration: InputDecoration(
              labelText: context.localized.username,
              helperText: creatingAdmin ? context.localized.usernameRequirements : null,
              helperMaxLines: 2,
              errorText: creatingAdmin && state.username.isNotEmpty && !CredentialRules.isValidUsername(state.username)
                  ? context.localized.usernameRequirements
                  : null,
              errorMaxLines: 2,
            ),
            onChanged: notifier.setUsername,
          ),
          PasswordField(
            key: passwordFieldKey,
            label: context.localized.password,
            autofillHints: [creatingAdmin ? AutofillHints.newPassword : AutofillHints.password],
            textInputAction: creatingAdmin ? TextInputAction.next : TextInputAction.done,
            helperText: creatingAdmin
                ? context.localized.passwordRequirements(CredentialRules.minPasswordLength)
                : null,
            errorText: creatingAdmin && state.password.isNotEmpty && !CredentialRules.isValidPassword(state.password)
                ? context.localized.passwordRequirements(CredentialRules.minPasswordLength)
                : null,
            onChanged: notifier.setPassword,
            onSubmitted: creatingAdmin ? null : (_) => state.canSubmitCredentials ? submit() : null,
          ),
          if (creatingAdmin)
            PasswordField(
              key: passwordConfirmationFieldKey,
              label: context.localized.confirmPassword,
              autofillHints: const [AutofillHints.newPassword],
              errorText: state.passwordConfirmation.isEmpty || state.passwordsMatch
                  ? null
                  : context.localized.passwordsDoNotMatch,
              onChanged: notifier.setPasswordConfirmation,
              onSubmitted: (_) => state.canSubmitCredentials ? submit() : null,
            ),
          const LoginFailureText(),
          LoadingButton(
            key: submitButtonKey,
            label: creatingAdmin ? context.localized.createAdmin : context.localized.signIn,
            loading: state.loading,
            onPressed: state.canSubmitCredentials ? submit : null,
          ),
        ],
      ),
    );
  }
}
