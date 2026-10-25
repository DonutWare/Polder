import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/shared/user_avatar.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";

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

    final canExpand = !AdaptiveLayout.isSingle(context);
    final extended = canExpand && ref.watch(sidebarExpandedProvider);
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
          )
        : SizedBox(
            width: 80,
            child: _FillOrScroll(
              children: [
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: _AvatarButton()),
                _railGroup(items, selectedIndex, onSelected),
                const Spacer(),
                if (launchers.isNotEmpty && onLaunch != null) _railGroup(launchers, selectedLauncher, onLaunch!),
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
          child: _NavTile(item: item, selected: i == selected, onTap: () => onTap(i)),
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
  });

  final List<NavItem> items;
  final List<NavItem> launchers;
  final int selectedLauncher;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<int>? onLaunch;
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final colors = AppColors.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final launch = onLaunch;
    return SizedBox(
      width: 224,
      child: _FillOrScroll(
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
                    child: AccountIdentity(
                      trailing: Icon(IconsaxPlusLinear.arrow_swap, size: 16, color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Divider(color: colors.border),
          const SizedBox(height: 12),
          _group(items, selectedIndex, onSelected),
          const Spacer(),
          if (launchers.isNotEmpty && launch != null) _group(launchers, selectedLauncher, launch),
          if (footer != null) Padding(padding: const EdgeInsets.fromLTRB(28, 8, 28, 8), child: footer),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 14, 16),
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

class _AvatarButton extends StatelessWidget {
  const _AvatarButton();

  @override
  Widget build(BuildContext context) => Tooltip(
    message: context.localized.moreOptions,
    child: Material(
      color: Colors.transparent,
      shape: squircle(AppRadius.inset),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => SideSheetDrawer.of(context).open(),
        child: const Padding(padding: EdgeInsets.all(6), child: SignedInAvatar(size: 40)),
      ),
    ),
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
