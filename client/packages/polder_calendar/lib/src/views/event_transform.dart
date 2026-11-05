import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";

import "package:polder_calendar/src/model/calendar_event.dart";
import "package:polder_calendar/src/model/calendar_ref.dart";
import "package:polder_calendar/src/views/calendar_style.dart";

const _spatial = Cubic(0.38, 1.21, 0.22, 1.0);

class EventOrigin {
  const EventOrigin._(this.ref, this.rect, this.radius);

  static EventOrigin? _last;

  final EventRef ref;
  final Rect rect;
  final double radius;

  static void remember(BuildContext context, CalendarEvent event, {double radius = CalendarStyle.tagRadius}) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    _last = EventOrigin._(event.ref, box.localToGlobal(Offset.zero) & box.size, radius);
  }

  static EventOrigin? take(CalendarEvent event) {
    final origin = _last;
    _last = null;
    return origin?.ref == event.ref ? origin : null;
  }
}

class EventTransformRoute<T> extends PopupRoute<T> {
  EventTransformRoute({
    required this.builder,
    required this.color,
    required this.compact,
    required this.barrierLabel,
    this.origin,
  });

  final WidgetBuilder builder;
  final Color color;
  final bool compact;
  final EventOrigin? origin;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black45;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 480);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 320);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      _EventTransform(
        route: this,
        animation: animation,
        child: Builder(builder: builder),
      );
}

class _EventTransform extends StatefulWidget {
  const _EventTransform({required this.route, required this.animation, required this.child});

  final EventTransformRoute<Object?> route;
  final Animation<double> animation;
  final Widget child;

  @override
  State<_EventTransform> createState() => _EventTransformState();
}

class _EventTransformState extends State<_EventTransform> {
  static const _dialogWidth = 440.0;

  double? _height;

  void _measured(Size size) {
    if (size.height != _height) setState(() => _height = size.height);
  }

  void _dragged(DragEndDetails details) {
    if ((details.primaryVelocity ?? 0) > 600) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    final style = CalendarStyle.of(context);
    final padding = MediaQuery.paddingOf(context);
    final fill = Color.alphaBlend(CalendarStyle.tint(context, route.color), style.panel);
    final content = Padding(
      padding: EdgeInsets.only(bottom: route.compact ? padding.bottom : 0),
      child: widget.child,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final width = route.compact ? size.width : math.min(_dialogWidth, size.width - 48);
        final maxHeight = route.compact ? size.height - padding.top - 48 : size.height - 96;
        final height = math.min(_height ?? maxHeight / 2, maxHeight);
        final target = route.compact
            ? Rect.fromLTWH(0, size.height - height, width, height)
            : Rect.fromCenter(center: size.center(Offset.zero), width: width, height: height);
        final origin =
            route.origin?.rect ??
            Rect.fromCenter(
              center: route.compact ? target.bottomCenter : target.center,
              width: width * 0.6,
              height: 48,
            );
        return AnimatedBuilder(
          animation: widget.animation,
          builder: (context, child) {
            final reversing = widget.animation.status == AnimationStatus.reverse;
            final progress = widget.animation.value;
            final travel = (reversing ? Curves.easeInOutCubic : _spatial).transform(progress);
            final rect = Rect.lerp(origin, target, travel)!;
            final settle = Curves.easeOut.transform(progress);
            final startRadius = route.origin?.radius ?? CalendarStyle.panelRadius;
            final radius = startRadius + (CalendarStyle.panelRadius + 4 - startRadius) * settle;
            final shape = RoundedSuperellipseBorder(
              borderRadius: route.compact
                  ? BorderRadius.vertical(
                      top: Radius.circular(radius),
                      bottom: Radius.circular(startRadius * (1 - settle)),
                    )
                  : BorderRadius.circular(radius),
            );
            final reveal = const Interval(0.2, 0.7, curve: Curves.easeOut).transform(progress);
            return Stack(
              children: [
                Positioned.fromRect(
                  rect: rect,
                  child: Material(
                    color: Color.lerp(fill, style.panel, settle),
                    elevation: 6 * settle,
                    shadowColor: Colors.black26,
                    shape: shape,
                    clipBehavior: Clip.antiAlias,
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      minWidth: width,
                      maxWidth: width,
                      minHeight: 0,
                      maxHeight: maxHeight,
                      child: Transform.scale(
                        scale: rect.width / width,
                        alignment: Alignment.topCenter,
                        child: Opacity(opacity: reveal, child: child),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          child: GestureDetector(
            onVerticalDragEnd: route.compact ? _dragged : null,
            child: _Measure(onSize: _measured, child: content),
          ),
        );
      },
    );
  }
}

class _Measure extends SingleChildRenderObjectWidget {
  const _Measure({required this.onSize, super.child});

  final ValueChanged<Size> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMeasure(onSize);

  @override
  void updateRenderObject(BuildContext context, _RenderMeasure renderObject) => renderObject.onSize = onSize;
}

class _RenderMeasure extends RenderProxyBox {
  _RenderMeasure(this.onSize);

  ValueChanged<Size> onSize;
  Size? _reported;

  @override
  void performLayout() {
    super.performLayout();
    if (size == _reported) return;
    _reported = size;
    final measured = size;
    WidgetsBinding.instance.addPostFrameCallback((_) => onSize(measured));
  }
}
