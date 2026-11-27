import "package:material_ui/material_ui.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_core/providers/login_provider.dart";
import "package:polder_ui/screens/login/widgets/login_failure_text.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/shared/loading_button.dart";

class TwoFactorStep extends ConsumerStatefulWidget {
  const TwoFactorStep({super.key});

  static const codeFieldKey = Key("login.twoFactorCode");
  static const submitKey = Key("login.twoFactorSubmit");

  @override
  ConsumerState<TwoFactorStep> createState() => _TwoFactorStepState();
}

class _TwoFactorStepState extends ConsumerState<TwoFactorStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);
    final localized = context.localized;
    final recovery = state.useRecoveryCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Text(recovery ? localized.twoFactorRecoveryPrompt : localized.twoFactorCodePrompt, textAlign: TextAlign.center),
        TextField(
          key: TwoFactorStep.codeFieldKey,
          controller: _controller,
          autofocus: true,
          textAlign: TextAlign.center,
          autofillHints: recovery ? null : const [AutofillHints.oneTimeCode],
          keyboardType: recovery ? TextInputType.visiblePassword : TextInputType.number,
          inputFormatters: recovery
              ? null
              : [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: recovery ? 2 : 8),
          decoration: InputDecoration(
            labelText: recovery ? localized.recoveryCode : localized.authenticatorCode,
            hintText: recovery ? "XXXXX-XXXXX" : "000000",
          ),
          onChanged: notifier.setCode,
          onSubmitted: (_) => state.canSubmitCode ? notifier.verifyTwoFactor() : null,
        ),
        const LoginFailureText(),
        LoadingButton(
          key: TwoFactorStep.submitKey,
          label: localized.verify,
          loading: state.loading,
          onPressed: state.canSubmitCode ? notifier.verifyTwoFactor : null,
        ),
        if (state.deviceApprovalAvailable)
          OutlinedButton.icon(
            icon: const Icon(IconsaxPlusLinear.devices, size: 18),
            label: Text(localized.approveOnAnotherDevice),
            onPressed: state.loading ? null : notifier.askAnotherDevice,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: notifier.backToCredentials, child: Text(localized.back)),
            TextButton(
              onPressed: () {
                _controller.clear();
                notifier.toggleRecoveryCode();
              },
              child: Text(recovery ? localized.useAuthenticatorCode : localized.useRecoveryCode),
            ),
          ],
        ),
      ],
    );
  }
}
