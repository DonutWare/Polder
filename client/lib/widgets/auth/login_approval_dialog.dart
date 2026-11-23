import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/security.dart";
import "package:polder/providers/auth/login_requests_provider.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/icon_badge.dart";

Future<void> showLoginApprovalDialog(BuildContext context, LoginRequest request) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (context) => LoginApprovalDialog(request: request),
);

class LoginApprovalDialog extends ConsumerStatefulWidget {
  const LoginApprovalDialog({required this.request, super.key});

  final LoginRequest request;

  @override
  ConsumerState<LoginApprovalDialog> createState() => _LoginApprovalDialogState();
}

class _LoginApprovalDialogState extends ConsumerState<LoginApprovalDialog> {
  static const numberLength = 3;

  final _number = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  bool get _complete => _number.text.length == numberLength;

  @override
  Widget build(BuildContext context) {
    ref.listen(loginRequestsProvider, (_, pending) {
      if (!_busy && !pending.any((request) => request.id == widget.request.id)) Navigator.of(context).pop();
    });
    final localized = context.localized;
    final theme = Theme.of(context);
    final request = widget.request;
    return AlertDialog(
      icon: IconBadge(icon: IconsaxPlusLinear.devices, color: theme.colorScheme.primary),
      title: Text(localized.loginApprovalTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(localized.loginApprovalBody(request.device, request.address), textAlign: TextAlign.center),
            Text(localized.loginApprovalTypeNumber, style: theme.textTheme.titleSmall, textAlign: TextAlign.center),
            SizedBox(
              width: 160,
              child: TextField(
                controller: _number,
                autofocus: true,
                enabled: !_busy,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 8),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(numberLength),
                ],
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _approve(),
              ),
            ),
            if (_error case final error?) Text(error, style: TextStyle(color: theme.colorScheme.error)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : _deny,
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          child: Text(localized.loginApprovalDeny),
        ),
        FilledButton(onPressed: _busy || !_complete ? null : _approve, child: Text(localized.loginApprovalApprove)),
      ],
    );
  }

  Future<void> _approve() async {
    if (_busy || !_complete) return;
    await _answer(() => ref.read(loginRequestsProvider.notifier).approve(widget.request, int.parse(_number.text)));
  }

  Future<void> _deny() => _answer(() => ref.read(loginRequestsProvider.notifier).deny(widget.request));

  Future<void> _answer(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) Navigator.of(context).pop();
    } on ForbiddenException {
      if (mounted) {
        setState(() => _error = context.localized.loginApprovalWrongNumber);
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.of(context).pop();
      }
    } on ApiException {
      if (mounted) Navigator.of(context).pop();
    }
  }
}

class LoginApprovalListener extends ConsumerStatefulWidget {
  const LoginApprovalListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<LoginApprovalListener> createState() => _LoginApprovalListenerState();
}

class _LoginApprovalListenerState extends ConsumerState<LoginApprovalListener> {
  final _shown = <String>{};

  @override
  Widget build(BuildContext context) {
    ref.listen(loginRequestsProvider, (_, pending) {
      for (final request in pending) {
        if (_shown.add(request.id)) showLoginApprovalDialog(context, request);
      }
    });
    return widget.child;
  }
}
