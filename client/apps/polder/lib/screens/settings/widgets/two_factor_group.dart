import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:intl/intl.dart";

import "package:polder_core/models/security.dart";
import "package:polder_ui/providers/auth/two_factor_provider.dart";
import "package:polder_core/services/api/api_exceptions.dart";
import "package:polder_ui/util/api_error_localization.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/auth/two_factor_enrollment.dart";
import "package:polder_ui/widgets/shared/loading_button.dart";
import "package:polder_ui/widgets/shared/nav_group.dart";
import "package:polder_ui/widgets/shared/password_field.dart";

class TwoFactorGroup extends ConsumerWidget {
  const TwoFactorGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final state = ref.watch(twoFactorProvider);
    return NavGroup(
      title: localized.twoFactorTitle,
      children: switch (state) {
        AsyncData(:final value) => _tiles(context, value),
        AsyncError(:final error) => [ListTile(title: Text(localized.describeError(error)))],
        _ => [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      },
    );
  }

  List<Widget> _tiles(BuildContext context, TwoFactorState state) {
    final localized = context.localized;
    final theme = Theme.of(context);
    if (!state.enabled) {
      final deadline = state.deadline;
      return [
        ListTile(
          leading: const Icon(IconsaxPlusLinear.shield_cross),
          title: Text(localized.twoFactorOff),
          subtitle: Text(
            deadline == null
                ? localized.twoFactorOffHint
                : localized.twoFactorRequiredBy(DateFormat.yMMMd(localized.localeName).format(deadline.toLocal())),
          ),
          trailing: FilledButton(onPressed: () => showTwoFactorEnrollment(context), child: Text(localized.setUp)),
        ),
      ];
    }
    return [
      ListTile(
        leading: Icon(IconsaxPlusLinear.shield_tick, color: theme.colorScheme.primary),
        title: Text(localized.twoFactorOn),
        subtitle: Text(localized.recoveryCodesLeft(state.recoveryCodesRemaining)),
      ),
      ListTile(
        leading: const Icon(IconsaxPlusLinear.refresh),
        title: Text(localized.regenerateRecoveryCodes),
        onTap: () =>
            showDialog<void>(context: context, builder: (_) => const _TwoFactorPasswordDialog(regenerate: true)),
      ),
      ListTile(
        leading: Icon(IconsaxPlusLinear.shield_slash, color: state.required ? null : theme.colorScheme.error),
        title: Text(localized.turnOffTwoFactor),
        subtitle: state.required ? Text(localized.twoFactorRequiredByAdmin) : null,
        enabled: !state.required,
        onTap: () =>
            showDialog<void>(context: context, builder: (_) => const _TwoFactorPasswordDialog(regenerate: false)),
      ),
    ];
  }
}

class _TwoFactorPasswordDialog extends ConsumerStatefulWidget {
  const _TwoFactorPasswordDialog({required this.regenerate});

  final bool regenerate;

  @override
  ConsumerState<_TwoFactorPasswordDialog> createState() => _TwoFactorPasswordDialogState();
}

class _TwoFactorPasswordDialogState extends ConsumerState<_TwoFactorPasswordDialog> {
  final _password = TextEditingController();
  List<String>? _codes;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    if (_codes case final codes?) {
      return TwoFactorDialog(
        child: RecoveryCodesView(codes: codes, onDone: () => Navigator.of(context).pop()),
      );
    }
    return AlertDialog(
      title: Text(widget.regenerate ? localized.regenerateRecoveryCodes : localized.turnOffTwoFactor),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(widget.regenerate ? localized.regenerateRecoveryCodesHint : localized.turnOffTwoFactorHint),
            PasswordField(
              controller: _password,
              label: localized.currentPassword,
              autofocus: true,
              errorText: _error,
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(localized.cancel)),
        LoadingButton(
          label: widget.regenerate ? localized.regenerate : localized.turnOff,
          loading: _busy,
          onPressed: _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final notifier = ref.read(twoFactorProvider.notifier);
    try {
      if (widget.regenerate) {
        final codes = await notifier.regenerate(_password.text);
        if (mounted) setState(() => _codes = codes);
      } else {
        await notifier.disable(_password.text);
        if (mounted) Navigator.of(context).pop();
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(
          () => _error = error is ForbiddenException
              ? context.localized.currentPasswordIncorrect
              : context.localized.describeError(error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
