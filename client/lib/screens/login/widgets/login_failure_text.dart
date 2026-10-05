import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/login_state.dart";
import "package:polder/providers/login_provider.dart";
import "package:polder/util/localization_helper.dart";

class LoginFailureText extends ConsumerWidget {
  const LoginFailureText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failure = ref.watch(loginProvider.select((state) => state.failure));
    if (failure == null) return const SizedBox.shrink();
    return Text(
      _message(context, failure),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
      textAlign: TextAlign.center,
    );
  }

  String _message(BuildContext context, LoginFailure failure) => switch (failure) {
    LoginFailure.unreachable => context.localized.loginErrorUnreachable,
    LoginFailure.invalidCredentials => context.localized.loginErrorInvalidCredentials,
    LoginFailure.accountDisabled => context.localized.loginErrorDisabled,
    LoginFailure.setupUnavailable => context.localized.loginErrorSetupUnavailable,
    LoginFailure.unknown => context.localized.errorUnknown,
  };
}
