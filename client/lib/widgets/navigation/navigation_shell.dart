import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/theme/app_theme.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/layout/adaptive.dart";
import "package:nomad/widgets/layout/app_page.dart";
import "package:nomad/widgets/navigation/app_mark.dart";

@immutable
class NavItem {
  const NavItem({required this.icon, required this.selectedIcon, required this.label, this.badge});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? badge;
}

@immutable
class NavAction {
  const NavAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Adapts navigation to the window: a floating bar on phones, a rail on tablets and small
/// windows, and a sidebar that can collapse to the rail on large screens.
class NavigationShell extends ConsumerWidget {
  const NavigationShell({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.title,
    required this.subtitle,
    required this.markIcon,
    required this.child,
    this.sidebarFooter,
    this.exitAction,
    super.key,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Shown at the top of the sidebar; tapping it opens the side sheet.
  final String title;
  final String subtitle;
  final IconData markIcon;

  /// Extra content at the bottom of the expanded sidebar.
  final Widget? sidebarFooter;

  /// A way out of this shell (for example back from administration), shown in the rail and sidebar.
  final NavAction? exitAction;

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = WindowSize.of(context);
    final colors = AppColors.of(context);
    final border = BorderSide(color: colors.border);
    if (size == WindowSize.compact) {
      return Scaffold(
        extendBody: true,
        body: child,
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: squircle(AppRadius.panel),
                shadows: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: Material(
                color: colors.panel,
                shape: squircle(AppRadius.panel, side: border),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 64,
                  child: _SlidingSelection(
                    axis: Axis.horizontal,
                    selected: selectedIndex,
                    indicator: const Center(child: SizedBox(width: 56, height: 44, child: _SelectionSurface())),
                    children: [
                      for (final (i, item) in items.indexed)
                        Expanded(
                          child: Center(
                            child: _NavTile(item: item, selected: i == selectedIndex, onTap: () => onSelected(i)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final canExpand = size == WindowSize.large;
    final extended = canExpand && ref.watch(sidebarExpandedProvider);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final exit = exitAction;
    final Widget navigation = extended
        ? _Sidebar(
            items: items,
            selectedIndex: selectedIndex,
            onSelected: onSelected,
            title: title,
            subtitle: subtitle,
            markIcon: markIcon,
            footer: sidebarFooter,
            exitAction: exit,
          )
        : SizedBox(
            width: 80,
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: MoreOptionsButton()),
                _SlidingSelection(
                  axis: Axis.vertical,
                  selected: selectedIndex,
                  indicator: const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: _SelectionSurface()),
                  children: [
                    for (final (i, item) in items.indexed)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _NavTile(item: item, selected: i == selectedIndex, onTap: () => onSelected(i)),
                      ),
                  ],
                ),
                const Spacer(),
                if (exit != null) IconButton(tooltip: exit.label, icon: Icon(exit.icon), onPressed: exit.onTap),
                if (canExpand)
                  IconButton(
                    tooltip: context.localized.expandSidebar,
                    icon: Icon(rtl ? IconsaxPlusLinear.sidebar_left : IconsaxPlusLinear.sidebar_right),
                    onPressed: ref.read(sidebarExpandedProvider.notifier).toggle,
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );
    return Scaffold(
      body: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.panel,
              border: BorderDirectional(end: border),
            ),
            child: SafeArea(left: !rtl, right: rtl, child: navigation),
          ),
          Expanded(
            child: MediaQuery.removePadding(context: context, removeLeft: !rtl, removeRight: rtl, child: child),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.title,
    required this.subtitle,
    required this.markIcon,
    this.footer,
    this.exitAction,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String title;
  final String subtitle;
  final IconData markIcon;
  final Widget? footer;
  final NavAction? exitAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final colors = AppColors.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final exit = exitAction;
    return SizedBox(
      width: 264,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Tooltip(
              message: context.localized.moreOptions,
              child: Material(
                color: colors.inset,
                shape: squircle(AppRadius.inset),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => SideSheetDrawer.of(context).open(),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        AppMark(icon: markIcon),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall,
                              ),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Icon(IconsaxPlusLinear.arrow_swap, size: 16, color: cs.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Divider(color: colors.border),
          const SizedBox(height: 12),
          _SlidingSelection(
            axis: Axis.vertical,
            selected: selectedIndex,
            indicator: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: _SelectionSurface(),
            ),
            children: [
              for (final (i, item) in items.indexed)
                _SidebarItem(
                  icon: i == selectedIndex ? item.selectedIcon : item.icon,
                  label: item.label,
                  selected: i == selectedIndex,
                  badge: item.badge,
                  onTap: () => onSelected(i),
                ),
            ],
          ),
          const Spacer(),
          if (footer != null) Padding(padding: const EdgeInsets.fromLTRB(28, 8, 28, 8), child: footer),
          if (exit != null) _SidebarItem(icon: exit.icon, label: exit.label, selected: false, onTap: exit.onTap),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                tooltip: context.localized.collapseSidebar,
                icon: Icon(rtl ? IconsaxPlusLinear.sidebar_right : IconsaxPlusLinear.sidebar_left),
                onPressed: ref.read(sidebarExpandedProvider.notifier).toggle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: _NavSurface(
        selected: selected,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (badge != null) Badge(label: Text(badge!)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.selected, required this.onTap});

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final icon = Icon(selected ? item.selectedIcon : item.icon);
    final badge = item.badge;
    return Tooltip(
      message: item.label,
      child: SizedBox(
        width: 56,
        height: 44,
        child: _NavSurface(
          selected: selected,
          onTap: onTap,
          label: item.label,
          child: Center(
            child: IconTheme.merge(
              data: IconThemeData(color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant),
              child: badge == null ? icon : Badge(label: Text(badge), child: icon),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSurface extends StatelessWidget {
  const _NavSurface({required this.selected, required this.onTap, required this.child, this.label});

  final bool selected;
  final VoidCallback onTap;
  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    label: label,
    child: Material(
      color: Colors.transparent,
      shape: squircle(AppRadius.control),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, hoverColor: AppColors.of(context).inset, child: child),
    ),
  );
}

class _SelectionSurface extends StatelessWidget {
  const _SelectionSurface();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: cs.secondaryContainer.withAlpha(175),
        shape: squircle(AppRadius.control, side: tintedSide(cs.secondary)),
      ),
    );
  }
}

/// Slides one indicator between equally sized children instead of fading it per item.
class _SlidingSelection extends StatelessWidget {
  const _SlidingSelection({
    required this.axis,
    required this.selected,
    required this.indicator,
    required this.children,
  });

  final Axis axis;
  final int selected;
  final Widget indicator;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final n = children.length;
    final t = n < 2 ? 0.0 : -1 + 2 * selected / (n - 1);
    final vertical = axis == Axis.vertical;
    return Stack(
      children: [
        if (selected >= 0)
          Positioned.fill(
            child: AnimatedAlign(
              duration: AppMotion.spatialDuration,
              curve: AppMotion.spatial,
              alignment: vertical ? AlignmentDirectional(0, t) : AlignmentDirectional(t, 0),
              child: FractionallySizedBox(
                widthFactor: vertical ? 1 : 1 / n,
                heightFactor: vertical ? 1 / n : 1,
                child: indicator,
              ),
            ),
          ),
        Flex(direction: axis, mainAxisSize: MainAxisSize.min, children: children),
      ],
    );
  }
}
