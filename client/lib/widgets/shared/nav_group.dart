import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/theme/app_theme.dart";
import "package:polder/widgets/shared/icon_badge.dart";

/// A titled stack of tiles on panel surfaces; the outer corners are round, the joins tight.
class NavGroup extends StatelessWidget {
  const NavGroup({required this.title, required this.children, this.trailing, super.key});

  final String title;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
                ),
                ?trailing,
              ],
            ),
          ),
          for (final (i, child) in children.indexed) GroupedTile(index: i, count: children.length, child: child),
        ],
      ),
    );
  }
}

/// One tile of a [NavGroup]-style stack, for lists that build their tiles lazily.
class GroupedTile extends StatelessWidget {
  const GroupedTile({required this.index, required this.count, required this.child, super.key});

  static const outer = AppRadius.inset + 4;
  static const inner = AppRadius.tag / 2;

  final int index;
  final int count;
  final Widget child;

  static ShapeBorder shapeFor(int index, int count, {BorderSide side = BorderSide.none}) => RoundedSuperellipseBorder(
    side: side,
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(index == 0 ? outer : inner),
      bottom: Radius.circular(index == count - 1 ? outer : inner),
    ),
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: index > 0 ? 2 : 0),
    child: Material(
      color: AppColors.of(context).panel,
      shape: shapeFor(index, count),
      clipBehavior: Clip.antiAlias,
      child: ListTileTheme.merge(shape: const RoundedRectangleBorder(), child: child),
    ),
  );
}

class NavEntry extends StatelessWidget {
  const NavEntry({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.badge,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final String? badge;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: IconBadge(icon: icon, color: iconColor),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        if (badge != null) Badge(label: Text(badge!)),
        ?trailing,
        if (onTap != null && trailing == null)
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? IconsaxPlusLinear.arrow_left_2
                : IconsaxPlusLinear.arrow_right_3,
            size: 18,
          ),
      ],
    ),
    onTap: onTap,
  );
}
