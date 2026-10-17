import "package:flutter/material.dart";

import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";

class Breadcrumbs extends StatelessWidget {
  const Breadcrumbs({required this.path, this.rootLabel, this.onNavigate, super.key});

  final String path;
  final String? rootLabel;
  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context) {
    final crumbs = RemotePath.ancestry(path);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      height: 44,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: crumbs.length,
          separatorBuilder: (context, _) => Icon(
            rtl ? IconsaxPlusLinear.arrow_left_2 : IconsaxPlusLinear.arrow_right_3,
            size: 14,
            color: Theme.of(context).colorScheme.outline,
          ),
          itemBuilder: (context, index) {
            final crumb = crumbs[crumbs.length - 1 - index];
            return _Crumb(path: crumb, isCurrent: crumb == path, rootLabel: rootLabel, onNavigate: onNavigate);
          },
        ),
      ),
    );
  }
}

class _Crumb extends StatelessWidget {
  const _Crumb({required this.path, required this.isCurrent, this.rootLabel, this.onNavigate});

  final String path;
  final bool isCurrent;
  final String? rootLabel;
  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isRoot = path == RemotePath.root;
    final label = isRoot ? rootLabel ?? context.localized.rootFolder : RemotePath.name(path);
    return Center(
      child: TextButton.icon(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(0, 34),
          foregroundColor: cs.onSurfaceVariant,
          disabledForegroundColor: cs.onSurface,
          backgroundColor: isCurrent ? AppColors.of(context).panel : null,
        ),
        onPressed: isCurrent ? null : () => (onNavigate ?? (path) => context.go(AppRoutes.filesAt(path)))(path),
        icon: isRoot ? const Icon(IconsaxPlusLinear.home_2, size: 16) : null,
        label: Text(label),
      ),
    );
  }
}
