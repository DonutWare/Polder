import "dart:math" as math;

import "package:flutter/material.dart";

import "package:polder/theme/app_theme.dart";

class FabMenuItem {
  const FabMenuItem({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

class FabMenu extends StatefulWidget {
  const FabMenu({required this.icon, required this.tooltip, required this.groups, super.key});

  final IconData icon;
  final String tooltip;
  final List<List<FabMenuItem>> groups;

  @override
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> {
  final _buttonKey = GlobalKey();
  bool _open = false;

  Future<void> _show() async {
    final box = _buttonKey.currentContext!.findRenderObject()! as RenderBox;
    final anchor = box.localToGlobal(Offset.zero) & box.size;
    setState(() => _open = true);
    final chosen = await Navigator.of(context, rootNavigator: true).push(
      _FabMenuRoute(
        anchor: anchor,
        icon: widget.icon,
        groups: [
          for (final group in widget.groups)
            if (group.isNotEmpty) group,
        ],
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      ),
    );
    if (mounted) setState(() => _open = false);
    chosen?.onPressed();
  }

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: _open ? 0 : 1,
    child: FloatingActionButton(key: _buttonKey, tooltip: widget.tooltip, onPressed: _show, child: Icon(widget.icon)),
  );
}

class _FabMenuRoute extends PopupRoute<FabMenuItem> {
  _FabMenuRoute({required this.anchor, required this.icon, required this.groups, required this.barrierLabel});

  static const _itemGap = 4.0;
  static const _groupGap = 20.0;
  static const _buttonGap = 8.0;
  static const _itemHeight = 56.0;

  final Rect anchor;
  final IconData icon;
  final List<List<FabMenuItem>> groups;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black.withValues(alpha: 0.12);

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => AppMotion.spatialDuration;

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 250);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final padding = MediaQuery.paddingOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final fromLeft = anchor.center.dx < size.width / 2;
        final children = <Widget>[];
        var order = groups.fold(0, (count, group) => count + group.length);
        for (final (groupIndex, group) in groups.indexed) {
          if (groupIndex > 0) children.add(const SizedBox(height: _groupGap));
          for (final (itemIndex, item) in group.indexed) {
            if (itemIndex > 0) children.add(const SizedBox(height: _itemGap));
            children.add(_staggered(animation, --order, fromLeft, _MenuItem(item: item)));
          }
        }
        return Stack(
          children: [
            Positioned(
              top: padding.top + 16,
              bottom: size.height - anchor.top + _buttonGap,
              left: fromLeft ? anchor.left : 16,
              right: fromLeft ? 16 : size.width - anchor.right,
              child: Align(
                alignment: fromLeft ? Alignment.bottomLeft : Alignment.bottomRight,
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: fromLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: children,
                  ),
                ),
              ),
            ),
            Positioned.fromRect(
              rect: anchor,
              child: _CloseButton(animation: animation, icon: icon),
            ),
          ],
        );
      },
    );
  }

  Widget _staggered(Animation<double> animation, int order, bool fromLeft, Widget child) {
    final start = math.min(order * 0.06, 0.4);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, start + 0.6, curve: AppMotion.spatial),
      reverseCurve: const Interval(0, 0.7, curve: AppMotion.effects),
    );
    final alignment = fromLeft ? Alignment.centerLeft : Alignment.centerRight;
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Interval(start, start + 0.3)),
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(curved),
        child: ScaleTransition(alignment: alignment, scale: Tween(begin: 0.6, end: 1.0).animate(curved), child: child),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.item});

  final FabMenuItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.tertiaryContainer,
      shape: const StadiumBorder(),
      elevation: 3,
      shadowColor: cs.shadow.withValues(alpha: 0.4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pop(context, item),
        child: SizedBox(
          height: _FabMenuRoute._itemHeight,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 20, end: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: cs.onTertiaryContainer),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onTertiaryContainer),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.animation, required this.icon});

  final Animation<double> animation;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fab = theme.floatingActionButtonTheme;
    final closedShape = fab.shape ?? const StadiumBorder();
    final curved = CurvedAnimation(parent: animation, curve: AppMotion.spatial, reverseCurve: AppMotion.effects);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        final t = curved.value;
        return Tooltip(
          message: MaterialLocalizations.of(context).closeButtonTooltip,
          child: Material(
            color: Color.lerp(fab.backgroundColor ?? cs.tertiaryContainer, cs.tertiary, t.clamp(0, 1)),
            shape: ShapeBorder.lerp(closedShape, const CircleBorder(), t.clamp(0, 1)),
            elevation: 3,
            shadowColor: cs.shadow.withValues(alpha: 0.4),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Center(
                child: Transform.rotate(
                  angle: t * math.pi / 4,
                  child: Icon(
                    icon,
                    color: Color.lerp(fab.foregroundColor ?? cs.onTertiaryContainer, cs.onTertiary, t.clamp(0, 1)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
