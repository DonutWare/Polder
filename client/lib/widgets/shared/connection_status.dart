import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/server_connection.dart";
import "package:polder/providers/connection/server_connection_provider.dart";
import "package:polder/providers/offline/offline_changes_provider.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";

enum ConnectionProblem { noNetwork, serverUnreachable, serverFull, serverReadOnly }

final connectionProblemProvider = Provider<ConnectionProblem?>((ref) {
  final connection = ref.watch(serverConnectionProvider);
  if (connection.isOffline) {
    return connection.cause == OfflineCause.noNetwork
        ? ConnectionProblem.noNetwork
        : ConnectionProblem.serverUnreachable;
  }
  return switch (connection.storage) {
    ServerStorage.full => ConnectionProblem.serverFull,
    ServerStorage.readOnly => ConnectionProblem.serverReadOnly,
    _ => null,
  };
});

extension ConnectionProblemDisplay on ConnectionProblem {
  bool get isOffline => this == ConnectionProblem.noNetwork || this == ConnectionProblem.serverUnreachable;

  IconData get icon => switch (this) {
    ConnectionProblem.noNetwork => IconsaxPlusLinear.wifi_square,
    ConnectionProblem.serverUnreachable => IconsaxPlusLinear.cloud_cross,
    ConnectionProblem.serverFull || ConnectionProblem.serverReadOnly => IconsaxPlusLinear.danger,
  };

  String message(BuildContext context) => switch (this) {
    ConnectionProblem.noNetwork => context.localized.connectionNoNetwork,
    ConnectionProblem.serverUnreachable => context.localized.connectionServerUnreachable,
    ConnectionProblem.serverFull => context.localized.connectionServerFull,
    ConnectionProblem.serverReadOnly => context.localized.connectionServerReadOnly,
  };
}

class ConnectionBadge extends ConsumerWidget {
  const ConnectionBadge({required this.child, this.fallback, super.key});

  final Widget child;
  final bool? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problem = ref.watch(connectionProblemProvider);
    final colors = Theme.of(context).colorScheme;
    if (problem != null) {
      return Badge(backgroundColor: colors.error, textColor: colors.onError, label: const Text("!"), child: child);
    }
    return Badge(isLabelVisible: fallback ?? false, child: child);
  }
}

class ConnectionStatusTile extends ConsumerWidget {
  const ConnectionStatusTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problem = ref.watch(connectionProblemProvider);
    if (problem == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final pending = ref.watch(offlineChangesProvider.select((changes) => changes.length));
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: ShapeDecoration(color: colors.errorContainer, shape: squircle(AppRadius.inset + 4)),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: colors.error, shape: BoxShape.circle),
            child: Icon(problem.icon, size: 18, color: colors.onError),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  problem.message(context),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (problem.isOffline)
                  Text(
                    context.localized.changesSavedOnDevice(pending),
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.onErrorContainer.withValues(alpha: 0.8)),
                  ),
              ],
            ),
          ),
          if (problem.isOffline)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => unawaited(ref.read(serverConnectionProvider.notifier).check()),
              child: Text(context.localized.retry),
            ),
        ],
      ),
    );
  }
}
