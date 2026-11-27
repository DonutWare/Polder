import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/widgets/layout/adaptive.dart";
import "package:polder_ui/widgets/navigation/sidebar_account.dart";
import "package:polder_ui/util/adaptive_layout/adaptive_layout.dart";

@immutable
class NavItem {
  const NavItem({required this.icon, required this.selectedIcon, required this.label, this.badge});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? badge;
}

class NavigationShell extends ConsumerWidget {
  const NavigationShell({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.child,
    this.showNavigation = true,
    this.launchers = const [],
    this.selectedLauncher = -1,
    this.onLaunch,
    this.sidebarFooter,
    this.sidebar,
    this.rail,
    this.railFooter,
    this.sidebarWidth = 224,
    this.canExpand = true,
    super.key,
  });

  final bool showNavigation;
  final List<NavItem> items;

  final List<NavItem> launchers;
  final int selectedLauncher;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<int>? onLaunch;

  final Widget? sidebarFooter;
  final Widget? sidebar;
  final Widget? rail;
  final Widget? railFooter;
  final double sidebarWidth;
  final bool canExpand;

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final border = BorderSide(color: colors.border);
    if (AdaptiveLayout.isPhone(context)) {
      return Scaffold(
        extendBody: true,
        body: child,
        bottomNavigationBar: !showNavigation
            ? null
            : SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: squircle(AppRadius.panel),
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
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
                          selected: _validSelection(selectedIndex, items.length),
                          indicator: const Center(child: SizedBox(width: 56, height: 44, child: _SelectionSurface())),
                          children: [
                            for (final (i, item) in items.indexed)
                              Expanded(
                                child: Center(
                                  child: RailTile.item(
                                    item: item,
                                    selected: i == selectedIndex,
                                    onTap: () => onSelected(i),
                                  ),
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

    final expandable = canExpand && !AdaptiveLayout.isSingle(context);
    final extended = expandable && ref.watch(sidebarExpandedProvider);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final Widget navigation = extended
        ? _Sidebar(
            items: items,
            launchers: launchers,
            selectedLauncher: selectedLauncher,
            selectedIndex: selectedIndex,
            onSelected: onSelected,
            onLaunch: onLaunch,
            footer: sidebarFooter,
            body: sidebar,
            width: sidebarWidth,
          )
        : SizedBox(
            width: 80,
            child: _FillOrScroll(
              children: [
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: SidebarAccountButton()),
                _railGroup(items, selectedIndex, onSelected),
                ?rail,
                const Spacer(),
                if (launchers.isNotEmpty && onLaunch != null) _railGroup(launchers, selectedLauncher, onLaunch!),
                ?railFooter,
                if (expandable) const SidebarToggle(expanded: false),
                const SizedBox(height: 16),
              ],
            ),
          );
    return Scaffold(
      body: Row(
        children: [
          if (showNavigation)
            DecoratedBox(
              key: const ValueKey("navigation"),
              decoration: BoxDecoration(
                color: colors.panel,
                border: BorderDirectional(end: border),
              ),
              child: SafeArea(left: !rtl, right: rtl, child: navigation),
            ),
          Expanded(
            key: const ValueKey("content"),
            child: MediaQuery.removePadding(
              context: context,
              removeLeft: showNavigation && !rtl,
              removeRight: showNavigation && rtl,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _railGroup(List<NavItem> group, int selected, ValueChanged<int> onTap) => _SlidingSelection(
    axis: Axis.vertical,
    selected: _validSelection(selected, group.length),
    indicator: const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: _SelectionSurface()),
    children: [
      for (final (i, item) in group.indexed)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: RailTile.item(item: item, selected: i == selected, onTap: () => onTap(i)),
        ),
    ],
  );
}

class _FillOrScroll extends StatelessWidget {
  const _FillOrScroll({required this.children, this.crossAxisAlignment = CrossAxisAlignment.center});

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: IntrinsicHeight(
          child: Column(crossAxisAlignment: crossAxisAlignment, children: children),
        ),
      ),
    ),
  );
}

int _validSelection(int selected, int length) => selected >= 0 && selected < length ? selected : -1;

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.launchers = const [],
    this.selectedLauncher = -1,
    this.onLaunch,
    this.footer,
    this.body,
    this.width = 224,
  });

  final List<NavItem> items;
  final List<NavItem> launchers;
  final int selectedLauncher;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<int>? onLaunch;
  final Widget? footer;
  final Widget? body;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final launch = onLaunch;
    final content = body;
    if (content != null) {
      return SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SidebarAccountCard(),
            Divider(color: colors.border),
            _group(items, selectedIndex, onSelected),
            Expanded(child: content),
            if (footer != null) Padding(padding: const EdgeInsets.fromLTRB(28, 8, 28, 8), child: footer),
            _toggle,
          ],
        ),
      );
    }
    return SizedBox(
      width: width,
      child: _FillOrScroll(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SidebarAccountCard(),
          Divider(color: colors.border),
          const SizedBox(height: 12),
          _group(items, selectedIndex, onSelected),
          const Spacer(),
          if (launchers.isNotEmpty && launch != null) _group(launchers, selectedLauncher, launch),
          if (footer != null) Padding(padding: const EdgeInsets.fromLTRB(28, 8, 28, 8), child: footer),
          _toggle,
        ],
      ),
    );
  }

  static const _toggle = Padding(
    padding: EdgeInsetsDirectional.fromSTEB(14, 4, 14, 16),
    child: Align(alignment: AlignmentDirectional.centerStart, child: SidebarToggle(expanded: true)),
  );

  Widget _group(List<NavItem> group, int selected, ValueChanged<int> onTap) => _SlidingSelection(
    axis: Axis.vertical,
    selected: _validSelection(selected, group.length),
    indicator: const Padding(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 2), child: _SelectionSurface()),
    children: [
      for (final (i, item) in group.indexed)
        SidebarItem(
          icon: i == selected ? item.selectedIcon : item.icon,
          label: item.label,
          selected: i == selected,
          badge: item.badge,
          onTap: () => onTap(i),
        ),
    ],
  );
}

class SidebarItem extends StatelessWidget {
  const SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
    this.detail,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final String? badge;
  final String? detail;
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
              if (detail != null)
                Text(detail!, style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class RailTile extends StatelessWidget {
  const RailTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selectedIcon,
    this.selected = false,
    this.badge,
    super.key,
  });

  RailTile.item({required NavItem item, required this.selected, required this.onTap, super.key})
    : icon = item.icon,
      selectedIcon = item.selectedIcon,
      label = item.label,
      badge = item.badge;

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final glyph = Icon(selected ? selectedIcon ?? icon : icon);
    final badge = this.badge;
    return Tooltip(
      message: label,
      child: SizedBox(
        width: 56,
        height: 44,
        child: _NavSurface(
          selected: selected,
          onTap: onTap,
          label: label,
          child: Center(
            child: IconTheme.merge(
              data: IconThemeData(color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant),
              child: badge == null ? glyph : Badge(label: Text(badge), child: glyph),
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
