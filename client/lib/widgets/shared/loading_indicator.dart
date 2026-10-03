import "dart:math" as math;

import "package:flutter/material.dart";

import "package:material_expressive/shapes.dart";

import "package:nomad/theme/app_theme.dart";

/// The M3 Expressive loading indicator: a shape that morphs through the Material shape set.
class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({this.size = 48, this.color, super.key});

  final double size;
  final Color? color;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> with SingleTickerProviderStateMixin {
  static final _shapes = [
    MaterialShapes.softBurst,
    MaterialShapes.cookie9Sided,
    MaterialShapes.pentagon,
    MaterialShapes.pill,
    MaterialShapes.sunny,
    MaterialShapes.cookie4Sided,
    MaterialShapes.oval,
  ];
  static const _step = Duration(milliseconds: 650);

  late final _controller = AnimationController(vsync: this, duration: _step * _shapes.length)..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return Center(
      child: SizedBox.square(
        dimension: widget.size,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final pos = _controller.value * _shapes.length;
              final i = pos.floor() % _shapes.length;
              final t = AppMotion.spatial.transform(pos - pos.floor());
              final points = lerpShapePoints(_shapes[i], _shapes[(i + 1) % _shapes.length], t);
              return Transform.rotate(
                angle: (_controller.value + (i + t) / _shapes.length) * 2 * math.pi,
                child: CustomPaint(painter: _ShapePainter(points, color), size: Size.square(widget.size)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.points, this.color);

  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scaled = [for (final p in points) Offset(p.dx * size.width, p.dy * size.height)];
    canvas.drawPath(smoothPathFromScaled(scaled), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ShapePainter old) => points != old.points || color != old.color;
}
