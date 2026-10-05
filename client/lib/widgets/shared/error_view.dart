import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/util/api_error_localization.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/message_view.dart";

class ErrorView extends StatelessWidget {
  const ErrorView({required this.error, this.onRetry, super.key});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => MessageView(
    icon: IconsaxPlusLinear.information,
    color: Theme.of(context).colorScheme.error,
    message: context.describeError(error),
    action: onRetry == null
        ? null
        : FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(IconsaxPlusLinear.refresh, size: 18),
            label: Text(context.localized.retry),
          ),
  );
}
