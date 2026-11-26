import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_core/models/server_connection.dart";
import "package:polder_core/providers/connection/server_connection_provider.dart";
import "package:polder_core/providers/offline/offline_changes_provider.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_ui/screens/settings/widgets/sign_out.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/localization_helper.dart";

enum ConnectionProblem { sessionEnded, noNetwork, serverUnreachable, serverFull, serverReadOnly }

final connectionProblemProvider = Provider<ConnectionProblem?>((ref) {
  if (ref.watch(sessionEndedProvider)) return ConnectionProblem.sessionEnded;
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

  bool get keepsChangesOnDevice => isOffline || this == ConnectionProblem.sessionEnded;

  IconData get icon => switch (this) {
    ConnectionProblem.sessionEnded => IconsaxPlusLinear.lock,
    ConnectionProblem.noNetwork => IconsaxPlusLinear.wifi_square,
    ConnectionProblem.serverUnreachable => IconsaxPlusLinear.cloud_cross,
    ConnectionProblem.serverFull || ConnectionProblem.serverReadOnly => IconsaxPlusLinear.danger,
  };

  String message(BuildContext context) => switch (this) {
    ConnectionProblem.sessionEnded => context.localized.sessionEndedStatus,
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
    final tile = Container(
      margin: EdgeInsets.fromLTRB(4, 0, 4, problem == ConnectionProblem.sessionEnded ? 6 : 8),
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
                if (problem.keepsChangesOnDevice)
                  Text(
                    context.localized.changesSavedOnDevice(pending),
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.onErrorContainer.withValues(alpha: 0.8)),
                  ),
              ],
            ),
          ),
          if (problem.isOffline)
            _TileButton(
              label: context.localized.retry,
              onPressed: () => unawaited(ref.read(serverConnectionProvider.notifier).check()),
            ),
        ],
      ),
    );
    if (problem != ConnectionProblem.sessionEnded) return tile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tile,
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => unawaited(confirmSignOut(context, ref)),
                  child: Text(context.localized.signOut),
                ),
              ),
              Expanded(
                child: _TileButton(
                  label: context.localized.sessionEndedSignIn,
                  onPressed: ref.read(continueOfflineProvider.notifier).signInAgain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TileButton extends StatelessWidget {
  const _TileButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: colors.error,
        foregroundColor: colors.onError,
        visualDensity: VisualDensity.compact,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
