import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/server_connection.dart";
import "package:polder/providers/connection/server_connection_provider.dart";
import "package:polder/util/localization_helper.dart";

class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({required this.child, super.key});

  static const height = 30.0;
  static const fade = 18.0;

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(serverConnectionProvider);
    final problem = _problemOf(context, connection);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: problem == null ? 0 : height),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, extra, child) {
        final media = MediaQuery.of(context);
        return Stack(
          children: [
            MediaQuery(
              data: media.copyWith(
                padding: media.padding.copyWith(top: media.padding.top + extra),
                viewPadding: media.viewPadding.copyWith(top: media.viewPadding.top + extra),
              ),
              child: child!,
            ),
            if (extra > 0 && problem != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: media.padding.top + extra + fade,
                child: IgnorePointer(
                  child: _Strip(problem: problem, topInset: media.padding.top, height: extra),
                ),
              ),
          ],
        );
      },
    );
  }

  static (IconData, String)? _problemOf(BuildContext context, ServerConnection connection) {
    final localized = context.localized;
    if (connection.isOffline) {
      return connection.cause == OfflineCause.noNetwork
          ? (IconsaxPlusLinear.wifi_square, localized.connectionNoNetwork)
          : (IconsaxPlusLinear.cloud_cross, localized.connectionServerUnreachable);
    }
    return switch (connection.storage) {
      ServerStorage.full => (IconsaxPlusLinear.danger, localized.connectionServerFull),
      ServerStorage.readOnly => (IconsaxPlusLinear.danger, localized.connectionServerReadOnly),
      _ => null,
    };
  }
}

class _Strip extends StatelessWidget {
  const _Strip({required this.problem, required this.topInset, required this.height});

  final (IconData, String) problem;
  final double topInset;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (icon, message) = problem;
    final solid = topInset + height;
    final total = solid + ConnectionBanner.fade;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.errorContainer, colors.errorContainer, colors.errorContainer.withValues(alpha: 0)],
          stops: [0, solid / total, 1],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: height,
            child: Opacity(
              opacity: (height / ConnectionBanner.height).clamp(0.0, 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Icon(icon, size: 16, color: colors.onErrorContainer),
                  Flexible(
                    child: Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: colors.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
