import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/branding/branding_provider.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/polder_logo.dart";
import "package:polder/widgets/shared/server_icon.dart";

class LoginHeader extends ConsumerWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final branding = ref.watch(brandingProvider);
    return Column(
      spacing: 16,
      children: [
        const ServerIcon(size: 72, fallback: PolderIcon(size: 72)),
        Text(
          branding.nameOr(context.localized.appTitle),
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        if (branding.message.isNotEmpty)
          Text(
            branding.message,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
