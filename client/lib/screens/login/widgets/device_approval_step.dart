import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/login_provider.dart";
import "package:polder/util/localization_helper.dart";

class DeviceApprovalStep extends ConsumerStatefulWidget {
  const DeviceApprovalStep({super.key});

  static const numberKey = Key("login.approvalNumber");

  @override
  ConsumerState<DeviceApprovalStep> createState() => _DeviceApprovalStepState();
}

class _DeviceApprovalStepState extends ConsumerState<DeviceApprovalStep> {
  final _shownAt = DateTime.now();
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final started = state.deviceLogin;
    if (started == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final total = started.expiresIn.inSeconds;
    final left = (started.expiresIn - DateTime.now().difference(_shownAt)).inSeconds.clamp(0, total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Text(context.localized.deviceApprovalPrompt, textAlign: TextAlign.center),
        Center(
          child: Container(
            key: DeviceApprovalStep.numberKey,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              "${started.number}",
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        LinearProgressIndicator(value: total == 0 ? 0 : left / total),
        Text(
          context.localized.deviceApprovalHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        TextButton(
          onPressed: ref.read(loginProvider.notifier).cancelDeviceApproval,
          child: Text(context.localized.cancel),
        ),
      ],
    );
  }
}
