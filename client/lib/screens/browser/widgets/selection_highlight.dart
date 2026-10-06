import "package:flutter/material.dart";

import "package:polder/theme/app_theme.dart";

class SelectionHighlight extends StatefulWidget {
  const SelectionHighlight({required this.child, this.shape, super.key});

  final Widget child;

  // Must match the highlighted tile's own shape; defaults to the grid tile's.
  final ShapeBorder Function(BorderSide side)? shape;

  @override
  State<SelectionHighlight> createState() => _SelectionHighlightState();
}

class _SelectionHighlightState extends State<SelectionHighlight> {
  var _visible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(context, alignment: 0.3, duration: const Duration(milliseconds: 250));
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) setState(() => _visible = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final side = BorderSide(color: color.withValues(alpha: _visible ? 0.8 : 0), width: 2);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      foregroundDecoration: ShapeDecoration(
        shape: widget.shape?.call(side) ?? squircle(AppRadius.inset + 4, side: side),
        color: color.withValues(alpha: _visible ? 0.12 : 0),
      ),
      child: widget.child,
    );
  }
}
