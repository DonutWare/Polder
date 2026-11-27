import "package:flutter/foundation.dart";
import "package:material_ui/material_ui.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:qr_flutter/qr_flutter.dart";
import "package:url_launcher/url_launcher.dart";

import "package:polder_core/models/security.dart";
import "package:polder_ui/providers/auth/two_factor_provider.dart";
import "package:polder_core/providers/current_user_provider.dart";
import "package:polder_core/services/api/api_exceptions.dart";
import "package:polder_ui/util/api_error_localization.dart";
import "package:polder_ui/util/clipboard.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/shared/loading_button.dart";
import "package:polder_ui/widgets/shared/password_field.dart";

Future<void> showTwoFactorEnrollment(BuildContext context) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (context) => TwoFactorDialog(
    child: TwoFactorEnrollment(onDone: () => Navigator.of(context).pop(), onCancel: () => Navigator.of(context).pop()),
  ),
);

class TwoFactorDialog extends StatelessWidget {
  const TwoFactorDialog({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: child),
    ),
  );
}

class TwoFactorEnrollment extends ConsumerStatefulWidget {
  const TwoFactorEnrollment({required this.onDone, this.onCancel, super.key});

  final VoidCallback onDone;
  final VoidCallback? onCancel;

  @override
  ConsumerState<TwoFactorEnrollment> createState() => _TwoFactorEnrollmentState();
}

class _TwoFactorEnrollmentState extends ConsumerState<TwoFactorEnrollment> {
  final _password = TextEditingController();
  final _code = TextEditingController();
  TwoFactorSetup? _setup;
  List<String>? _codes;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).value;
    if (user != null && !user.hasPassword) WidgetsBinding.instance.addPostFrameCallback((_) => _begin());
  }

  @override
  void dispose() {
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => switch ((_setup, _codes)) {
    (_, final codes?) => RecoveryCodesView(codes: codes, onDone: _finish),
    (final setup?, _) => _scan(context, setup),
    _ => _confirmPassword(context),
  };

  Widget _confirmPassword(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: [
      Text(context.localized.twoFactorSetupTitle, style: Theme.of(context).textTheme.titleLarge),
      Text(context.localized.twoFactorSetupIntro),
      PasswordField(
        controller: _password,
        label: context.localized.currentPassword,
        autofocus: true,
        autofillHints: const [AutofillHints.password],
        errorText: _error,
        onSubmitted: (_) => _begin(),
      ),
      _buttons(context, LoadingButton(label: context.localized.twoFactorContinue, loading: _busy, onPressed: _begin)),
    ],
  );

  Widget _scan(BuildContext context, TwoFactorSetup setup) {
    final theme = Theme.of(context);
    final mobile =
        !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Text(context.localized.twoFactorSetupTitle, style: theme.textTheme.titleLarge),
        Text(context.localized.twoFactorScanIntro),
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: QrImageView(data: setup.url, size: 200, backgroundColor: Colors.white),
          ),
        ),
        if (mobile)
          OutlinedButton.icon(
            icon: const Icon(IconsaxPlusLinear.export_3, size: 18),
            label: Text(context.localized.twoFactorOpenAuthenticator),
            onPressed: () => launchUrl(Uri.parse(setup.url), mode: LaunchMode.externalApplication),
          ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.localized.twoFactorManualKey, style: theme.textTheme.labelMedium),
          subtitle: SelectableText(
            setup.groupedSecret,
            style: theme.textTheme.titleMedium?.copyWith(fontFamily: "monospace"),
          ),
          trailing: IconButton(
            icon: const Icon(IconsaxPlusLinear.copy),
            tooltip: context.localized.copy,
            onPressed: () => copyWithNotice(context, setup.secret, context.localized.copied),
          ),
        ),
        TextField(
          controller: _code,
          autofocus: true,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
          decoration: InputDecoration(labelText: context.localized.authenticatorCode, errorText: _error),
          onSubmitted: (_) => _confirm(),
        ),
        _buttons(context, LoadingButton(label: context.localized.verify, loading: _busy, onPressed: _confirm)),
      ],
    );
  }

  Widget _buttons(BuildContext context, Widget primary) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    spacing: 8,
    children: [
      if (widget.onCancel case final cancel?)
        TextButton(onPressed: _busy ? null : cancel, child: Text(context.localized.cancel)),
      primary,
    ],
  );

  Future<void> _finish() async {
    final notifier = ref.read(twoFactorProvider.notifier);
    widget.onDone();
    await notifier.finishSetup();
  }

  Future<void> _begin() => _run(() async {
    final setup = await ref.read(twoFactorProvider.notifier).begin(_password.text);
    if (mounted) setState(() => _setup = setup);
  });

  Future<void> _confirm() => _run(() async {
    final codes = await ref.read(twoFactorProvider.notifier).confirm(_code.text);
    if (mounted) setState(() => _codes = codes);
  });

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on ApiException catch (error) {
      if (mounted) {
        setState(
          () => _error = switch (error) {
            ForbiddenException() when _setup == null => context.localized.currentPasswordIncorrect,
            InvalidRequestException() => context.localized.twoFactorCodeMismatch,
            _ => context.localized.describeError(error),
          },
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class RecoveryCodesView extends StatelessWidget {
  const RecoveryCodesView({required this.codes, required this.onDone, super.key});

  final List<String> codes;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Text(context.localized.recoveryCodesTitle, style: theme.textTheme.titleLarge),
        Text(context.localized.recoveryCodesIntro),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Wrap(
            spacing: 24,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final code in codes)
                SelectableText(code, style: theme.textTheme.titleMedium?.copyWith(fontFamily: "monospace")),
            ],
          ),
        ),
        OutlinedButton.icon(
          icon: const Icon(IconsaxPlusLinear.copy, size: 18),
          label: Text(context.localized.copyRecoveryCodes),
          onPressed: () => copyWithNotice(context, codes.join("\n"), context.localized.copied),
        ),
        FilledButton(onPressed: onDone, child: Text(context.localized.recoveryCodesSaved)),
      ],
    );
  }
}
