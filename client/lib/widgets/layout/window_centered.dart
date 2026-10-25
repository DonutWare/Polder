import "dart:math" as math;

import "package:flutter/material.dart";

class WindowCentered extends StatefulWidget {
  const WindowCentered({required this.contentWidth, required this.builder, this.minGutter = 16, super.key});

  final double contentWidth;
  final double minGutter;
  final Widget Function(BuildContext context, EdgeInsets gutters) builder;

  static EdgeInsets gutters({
    required double paneLeft,
    required double paneWidth,
    required double windowWidth,
    required double contentWidth,
    double minGutter = 16,
  }) {
    final width = math.max(0.0, math.min(contentWidth, paneWidth - 2 * minGutter));
    final free = math.max(0.0, paneWidth - width);
    final lowest = math.min(minGutter, free / 2);
    final left = ((windowWidth - width) / 2 - paneLeft).clamp(lowest, free - lowest);
    return EdgeInsets.only(left: left, right: free - left);
  }

  @override
  State<WindowCentered> createState() => _WindowCenteredState();
}

class _WindowCenteredState extends State<WindowCentered> {
  double? _paneLeft;

  void _measure() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final left = box.localToGlobal(Offset.zero).dx;
    if (left != _paneLeft) setState(() => _paneLeft = left);
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.sizeOf(context).width;
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    return LayoutBuilder(
      builder: (context, constraints) {
        final paneLeft = _paneLeft ?? (windowWidth - constraints.maxWidth) / 2;
        final gutters = WindowCentered.gutters(
          paneLeft: paneLeft,
          paneWidth: constraints.maxWidth,
          windowWidth: windowWidth,
          contentWidth: widget.contentWidth,
          minGutter: widget.minGutter,
        );
        return widget.builder(context, gutters);
      },
    );
  }
}
