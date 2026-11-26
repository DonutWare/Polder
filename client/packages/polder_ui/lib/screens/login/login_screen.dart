import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "package:polder_core/models/login_state.dart";
import "package:polder_core/providers/login_provider.dart";
import "package:polder_ui/screens/login/widgets/credentials_step.dart";
import "package:polder_ui/screens/login/widgets/device_approval_step.dart";
import "package:polder_ui/screens/login/widgets/login_backdrop.dart";
import "package:polder_ui/screens/login/widgets/login_header.dart";
import "package:polder_ui/screens/login/widgets/session_ended_notice.dart";
import "package:polder_ui/screens/login/widgets/server_step.dart";
import "package:polder_ui/screens/login/widgets/two_factor_step.dart";
import "package:polder_ui/widgets/shared/loading_indicator.dart";
import "package:polder_ui/polder_ui_config.dart";

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);
    ref.listen(loginProvider.select((state) => state.completed), (_, completed) {
      if (completed) {
        context.go(readPolderUiConfig(context).afterSignIn(GoRouterState.of(context).uri));
      }
    });
    // A hosted web client connects to its own server first; don't flash the server form meanwhile.
    final probing = state.probingHostedServer;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const LoginBackdrop(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 28,
                        children: [
                          const LoginHeader(),
                          if (state.reauthenticating) const SessionEndedNotice(),
                          if (probing)
                            const Padding(padding: EdgeInsets.only(bottom: 16), child: LoadingIndicator())
                          else
                            switch (state.step) {
                              LoginStep.server => const ServerStep(),
                              LoginStep.credentials => const CredentialsStep(creatingAdmin: false),
                              LoginStep.setup => const CredentialsStep(creatingAdmin: true),
                              LoginStep.twoFactor => const TwoFactorStep(),
                              LoginStep.deviceApproval => const DeviceApprovalStep(),
                            },
                          if (state.reauthenticating) const SessionEndedActions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
