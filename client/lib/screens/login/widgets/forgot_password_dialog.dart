import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/polder_api_provider.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/util/credential_rules.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/loading_button.dart";
import "package:polder/widgets/shared/password_field.dart";

Future<void> showForgotPasswordDialog(
  BuildContext context, {
  required String serverUrl,
  required String login,
  required bool resetAvailable,
}) => showDialog<void>(
  context: context,
  builder: (_) =>
      resetAvailable ? ForgotPasswordDialog(serverUrl: serverUrl, initialLogin: login) : const ResetUnavailableDialog(),
);

class ResetUnavailableDialog extends StatelessWidget {
  const ResetUnavailableDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return AlertDialog(
      icon: const Icon(IconsaxPlusLinear.key),
      title: Text(localized.forgotPasswordTitle),
      content: _DialogBody(children: [Text(localized.resetUnavailable)]),
      actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(localized.done))],
    );
  }
}

enum _ResetStep { request, code, done }

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  const ForgotPasswordDialog({required this.serverUrl, required this.initialLogin, super.key});

  static const loginFieldKey = Key("forgotPassword.login");
  static const submitButtonKey = Key("forgotPassword.submit");
  static const codeFieldKey = Key("forgotPassword.code");
  static const passwordFieldKey = Key("forgotPassword.password");
  static const confirmFieldKey = Key("forgotPassword.confirm");
  static const resetButtonKey = Key("forgotPassword.reset");

  final String serverUrl;
  final String initialLogin;

  @override
  ConsumerState<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  static const _codeLength = 8;

  late final _login = TextEditingController(text: widget.initialLogin);
  final _code = TextEditingController();
  var _password = "";
  var _confirm = "";
  var _step = _ResetStep.request;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _login.dispose();
    _code.dispose();
    super.dispose();
  }

  String get _normalizedCode => _code.text.replaceAll(RegExp(r"[\s-]"), "").toUpperCase();

  bool get _canRequest => _login.text.trim().isNotEmpty && !_busy;

  bool get _canReset =>
      _normalizedCode.length == _codeLength &&
      CredentialRules.isValidPassword(_password) &&
      _password == _confirm &&
      !_busy;

  @override
  Widget build(BuildContext context) => switch (_step) {
    _ResetStep.request => _requestDialog(context),
    _ResetStep.code => _codeDialog(context),
    _ResetStep.done => _doneDialog(context),
  };

  Widget _requestDialog(BuildContext context) {
    final localized = context.localized;
    return AlertDialog(
      title: Text(localized.forgotPasswordTitle),
      content: _DialogBody(
        children: [
          Text(localized.forgotPasswordHint),
          TextField(
            key: ForgotPasswordDialog.loginFieldKey,
            controller: _login,
            autofocus: true,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: localized.usernameOrEmail, errorText: _error, errorMaxLines: 3),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _canRequest ? _request() : null,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(localized.cancel)),
        LoadingButton(
          key: ForgotPasswordDialog.submitButtonKey,
          label: localized.sendResetCode,
          loading: _busy,
          onPressed: _canRequest ? _request : null,
        ),
      ],
    );
  }

  Widget _codeDialog(BuildContext context) {
    final localized = context.localized;
    final mismatch = _confirm.isNotEmpty && _password != _confirm;
    return AlertDialog(
      icon: const Icon(IconsaxPlusLinear.sms_tracking),
      title: Text(localized.resetCodeTitle),
      content: _DialogBody(
        children: [
          Text(localized.resetCodeSent),
          const _NoLinksNote(),
          TextField(
            key: ForgotPasswordDialog.codeFieldKey,
            controller: _code,
            autofocus: true,
            autofillHints: const [AutofillHints.oneTimeCode],
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: 4, fontWeight: FontWeight.w600),
            decoration: InputDecoration(labelText: localized.resetCode, hintText: "XXXX-XXXX"),
            onChanged: (_) => setState(() => _error = null),
          ),
          PasswordField(
            key: ForgotPasswordDialog.passwordFieldKey,
            label: localized.newPassword,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.next,
            helperText: localized.passwordRequirements(CredentialRules.minPasswordLength),
            onChanged: (value) => setState(() => _password = value),
          ),
          PasswordField(
            key: ForgotPasswordDialog.confirmFieldKey,
            label: localized.confirmPassword,
            autofillHints: const [AutofillHints.newPassword],
            errorText: mismatch ? localized.passwordsDoNotMatch : null,
            onChanged: (value) => setState(() => _confirm = value),
            onSubmitted: (_) => _canReset ? _reset() : null,
          ),
          if (_error case final error?) Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ),
      actions: [
        TextButton(onPressed: _busy ? null : _request, child: Text(localized.sendResetCodeAgain)),
        LoadingButton(
          key: ForgotPasswordDialog.resetButtonKey,
          label: localized.changePassword,
          loading: _busy,
          onPressed: _canReset ? _reset : null,
        ),
      ],
    );
  }

  Widget _doneDialog(BuildContext context) {
    final localized = context.localized;
    return AlertDialog(
      icon: const Icon(IconsaxPlusLinear.shield_tick),
      title: Text(localized.passwordResetDoneTitle),
      content: _DialogBody(children: [Text(localized.passwordResetDone)]),
      actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(localized.done))],
    );
  }

  Future<void> _request() => _run(
    () => ref.read(serverPolderApiProvider(widget.serverUrl)).requestPasswordReset(_login.text.trim()),
    next: _ResetStep.code,
  );

  Future<void> _reset() => _run(
    () => ref
        .read(serverPolderApiProvider(widget.serverUrl))
        .resetPasswordWithCode(login: _login.text.trim(), code: _normalizedCode, password: _password),
    next: _ResetStep.done,
  );

  Future<void> _run(Future<void> Function() action, {required _ResetStep next}) async {
    final localized = context.localized;
    setState(() {
      _busy = true;
      _error = null;
    });
    String? error;
    try {
      await action();
    } on ApiException catch (failure) {
      error = localized.describeError(failure);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
      if (error == null) _step = next;
    });
  }
}

class _DialogBody extends StatelessWidget {
  const _DialogBody({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 400,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: children,
      ),
    ),
  );
}

class _NoLinksNote extends StatelessWidget {
  const _NoLinksNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      spacing: 8,
      children: [
        Icon(IconsaxPlusLinear.shield_security, size: 18, color: theme.colorScheme.primary),
        Expanded(child: Text(context.localized.resetCodeNeverLinks, style: theme.textTheme.bodySmall)),
      ],
    );
  }
}
