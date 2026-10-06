import "dart:async";
import "dart:math" as math;

import "package:flutter/material.dart";

class OutlineProgress extends StatefulWidget {
  const OutlineProgress({required this.active, required this.shape, required this.child, super.key});

  final bool active;
  final ShapeBorder shape;
  final Widget child;

  @override
  State<OutlineProgress> createState() => _OutlineProgressState();
}

class _OutlineProgressState extends State<OutlineProgress> with SingleTickerProviderStateMixin {
  static const _minimumVisible = Duration(milliseconds: 500);

  late final _lap = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  late bool _visible = widget.active;
  DateTime? _shownAt;
  Timer? _hide;

  @override
  void initState() {
    super.initState();
    if (_visible) _show();
  }

  @override
  void didUpdateWidget(OutlineProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      _hide?.cancel();
      if (!_visible) setState(_show);
      return;
    }
    final remaining = _minimumVisible - DateTime.now().difference(_shownAt ?? DateTime.now());
    _hide = Timer(remaining.isNegative ? Duration.zero : remaining, () {
      if (mounted && !widget.active) setState(() => _visible = false);
    });
  }

  void _show() {
    _visible = true;
    _shownAt = DateTime.now();
    if (!_lap.isAnimating) _lap.repeat();
  }

  @override
  void dispose() {
    _hide?.cancel();
    _lap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: _visible ? 1 : 0),
    duration: Duration(milliseconds: _visible ? 300 : 450),
    curve: Curves.easeInOut,
    onEnd: () {
      if (!_visible) _lap.stop();
    },
    builder: (context, opacity, child) => CustomPaint(
      foregroundPainter: _OutlinePainter(
        lap: _lap,
        shape: widget.shape,
        color: Theme.of(context).colorScheme.primary,
        opacity: opacity,
      ),
      child: child,
    ),
    child: widget.child,
  );
}

class _OutlinePainter extends CustomPainter {
  _OutlinePainter({required this.lap, required this.shape, required this.color, required this.opacity})
    : super(repaint: lap);

  static const _strokeWidth = 1.0;

  final Animation<double> lap;
  final ShapeBorder shape;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity == 0) return;
    final outlinePath = shape.getOuterPath((Offset.zero & size).deflate(_strokeWidth / 2));
    final outline = outlinePath.computeMetrics().firstOrNull;
    if (outline == null) return;

    Paint stroke(double alpha, double width) => Paint()
      ..color = color.withValues(alpha: color.a * alpha * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(outlinePath, stroke(0.25, _strokeWidth));

    final length = outline.length;
    final segment = length * (0.3 + 0.12 * math.sin(lap.value * 2 * math.pi));
    final start = lap.value * length;
    final path = outline.extractPath(start, math.min(start + segment, length));
    if (start + segment > length) path.addPath(outline.extractPath(0, start + segment - length), Offset.zero);
    canvas.drawPath(path, stroke(1, _strokeWidth));
  }

  @override
  bool shouldRepaint(_OutlinePainter old) => old.opacity != opacity || old.color != color || old.shape != shape;
}
