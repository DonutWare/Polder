import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/theme/app_theme.dart";
import "package:polder/widgets/shared/icon_badge.dart";

/// A titled stack of tiles on panel surfaces; the outer corners are round, the joins tight.
class NavGroup extends StatelessWidget {
  const NavGroup({
    required this.title,
    required this.children,
    this.trailing,
    this.collapsed = false,
    this.onToggle,
    super.key,
  });

  final String title;
  final Widget? trailing;
  final List<Widget> children;
  final bool collapsed;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NavGroupHeader(title: title, trailing: trailing, collapsed: collapsed, onToggle: onToggle),
        AnimatedSize(
          duration: AppMotion.spatialDuration,
          curve: AppMotion.spatial,
          alignment: Alignment.topCenter,
          child: collapsed
              ? const SizedBox(width: double.infinity)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, child) in children.indexed)
                      GroupedTile(index: i, count: children.length, child: child),
                  ],
                ),
        ),
      ],
    ),
  );
}

class NavGroupHeader extends StatelessWidget {
  const NavGroupHeader({required this.title, this.trailing, this.collapsed = false, this.onToggle, super.key});

  final String title;
  final Widget? trailing;
  final bool collapsed;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary));
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: onToggle == null
                ? label
                : Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: InkWell(
                      customBorder: squircle(AppRadius.control),
                      onTap: onToggle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            Flexible(child: label),
                            AnimatedRotation(
                              turns: collapsed ? -0.25 : 0,
                              duration: AppMotion.spatialDuration,
                              curve: AppMotion.spatial,
                              child: Icon(IconsaxPlusLinear.arrow_down, size: 16, color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          ?trailing,
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
    this.selected = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final String? badge;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => ListTile(
    selected: selected,
    selectedTileColor: Theme.of(context).colorScheme.secondaryContainer.withAlpha(175),
    selectedColor: Theme.of(context).colorScheme.onSecondaryContainer,
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
