import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/providers/login_provider.dart";
import "package:nomad/theme/app_theme.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/shared/icon_badge.dart";

class ServerSummary extends ConsumerWidget {
  const ServerSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);
    return DecoratedBox(
      decoration: ShapeDecoration(color: AppColors.of(context).inset, shape: squircle(AppRadius.inset)),
      child: ListTile(
        leading: const IconBadge(icon: IconsaxPlusLinear.cloud_connection),
        title: Text(state.serverUrl, overflow: TextOverflow.ellipsis),
        trailing: state.serverLocked
            ? null
            : TextButton(
                onPressed: ref.read(loginProvider.notifier).backToServer,
                child: Text(context.localized.change),
              ),
      ),
    );
  }
}
