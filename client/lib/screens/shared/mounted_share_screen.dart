import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/providers/federation/federation_providers.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/browser_stack.dart";
import "package:polder/screens/browser/widgets/browser_scope.dart";
import "package:polder/screens/browser/widgets/file_open_action.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/message_view.dart";

enum ShareOrigin { local, federated }

class MountedShareScreen extends ConsumerWidget {
  const MountedShareScreen({
    required this.origin,
    required this.shareId,
    required this.path,
    required this.exitRoute,
    super.key,
  });

  final ShareOrigin origin;
  final int shareId;
  final String path;
  final String exitRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (origin) {
    ShareOrigin.local => AsyncValueView<Object?>(
      value: ref.watch(incomingSharesProvider),
      onRetry: () => ref.invalidate(incomingSharesProvider),
      data: (_) {
        final share = ref.watch(incomingShareProvider(shareId));
        return _scopedBrowser(context, mountPath: share?.mountPath, name: share?.entry.name);
      },
    ),
    ShareOrigin.federated => AsyncValueView<Object?>(
      value: ref.watch(incomingFederatedSharesProvider),
      onRetry: () => ref.invalidate(incomingFederatedSharesProvider),
      data: (_) {
        final share = ref.watch(incomingFederatedShareProvider(shareId));
        return _scopedBrowser(context, mountPath: share?.mountPath, name: share?.name);
      },
    ),
  };

  Widget _scopedBrowser(BuildContext context, {required String? mountPath, required String? name}) {
    if (mountPath == null || mountPath.isEmpty) {
      return MessageView(icon: IconsaxPlusLinear.share, message: context.localized.nothingSelected);
    }
    final browsed = path == RemotePath.root ? mountPath : "$mountPath$path";
    return BrowserScope(
      routes: BrowserRoutes(
        root: mountPath,
        rootLabel: name,
        exitRoute: exitRoute,
        routeFor: (target, {select}) => shareRoute(origin, shareId, path: target.substring(mountPath.length)),
      ),
      child: BrowserStack(path: browsed),
    );
  }
}

String shareRoute(ShareOrigin origin, int shareId, {String path = RemotePath.root}) {
  final relative = path.isEmpty ? RemotePath.root : path;
  return switch (origin) {
    ShareOrigin.local => AppRoutes.sharedAt(shareId, path: relative),
    ShareOrigin.federated => AppRoutes.federatedAt(shareId, path: relative),
  };
}

Future<void> openMountedShare(
  BuildContext context,
  WidgetRef ref, {
  required ShareOrigin origin,
  required int shareId,
  required bool isDir,
  required String mountPath,
}) async {
  if (isDir || mountPath.isEmpty) return context.go(shareRoute(origin, shareId));
  FileEntry? entry;
  final found = await context.runWithFeedback(
    ref.read(polderApiProvider).stat(mountPath).then((value) => entry = value),
  );
  if (!found || !context.mounted) return;
  await openEntry(context, entry!);
}
