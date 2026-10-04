import "dart:async";
import "dart:math" as math;

import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:nomad/theme/app_theme.dart";

enum WindowSize {
  compact,
  medium,
  expanded,
  large;

  static WindowSize of(BuildContext context) => fromWidth(MediaQuery.sizeOf(context).width);

  static WindowSize fromWidth(double width) => switch (width) {
    < 600 => compact,
    < 840 => medium,
    < 1200 => expanded,
    _ => large,
  };
}

final sidebarExpandedProvider = NotifierProvider<SidebarExpanded, bool>(SidebarExpanded.new);

class SidebarExpanded extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

class ReadableWidth extends StatelessWidget {
  const ReadableWidth({super.key, this.maxWidth = 960, required this.builder});

  final double maxWidth;
  final Widget Function(BuildContext context, EdgeInsets inset) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final side = math.max(0.0, (box.maxWidth - maxWidth) / 2);
      final padding = MediaQuery.paddingOf(context);
      return builder(context, EdgeInsets.fromLTRB(side, padding.top, side, padding.bottom));
    },
  );
}

class SideSheetDrawer extends StatefulWidget {
  const SideSheetDrawer({super.key, required this.title, required this.sheet, this.canEdgeSwipe, required this.child});

  final String title;
  final Widget sheet;
  final bool Function()? canEdgeSwipe;
  final Widget child;

  static SideSheetDrawerState of(BuildContext context) => maybeOf(context)!;

  static SideSheetDrawerState? maybeOf(BuildContext context) => context.findAncestorStateOfType<SideSheetDrawerState>();

  @override
  State<SideSheetDrawer> createState() => SideSheetDrawerState();
}

class SideSheetDrawerState extends State<SideSheetDrawer> with SingleTickerProviderStateMixin {
  static const _edgeWidth = 20.0;
  static const _peekWidth = 24.0;
  static const _peekDelay = Duration(milliseconds: 160);
  static const _minFlingVelocity = 365.0;

  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250))
    ..addStatusListener((status) {
      if (status.isCompleted) _focusScope.requestFocus();
    });
  final _focusScope = FocusScopeNode(debugLabel: "SideSheetDrawer");
  Timer? _peekTimer;
  bool _peeking = false;
  double _width = 360;
  bool _rtl = false;

  bool get _closed => _controller.isDismissed || _peeking;

  void open() => _controller.fling(velocity: 1);

  void close() {
    _peeking = false;
    _controller.fling(velocity: -1);
  }

  @override
  void dispose() {
    _peekTimer?.cancel();
    _controller.dispose();
    _focusScope.dispose();
    super.dispose();
  }

  bool _allowDrag() => !_closed || (widget.canEdgeSwipe?.call() ?? false);

  void _onPointerDown(PointerDownEvent event) {
    if (!_controller.isDismissed || !(widget.canEdgeSwipe?.call() ?? false)) return;
    _peekTimer = Timer(_peekDelay, () {
      _peeking = true;
      _controller.animateTo(_peekWidth / _width, duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
    });
  }

  void _onPointerUp(PointerEvent event) {
    _peekTimer?.cancel();
    if (_peeking) close();
  }

  void _onDragStart(DragStartDetails details) {
    _peekTimer?.cancel();
    if (_closed) {
      final box = context.findRenderObject() as RenderBox;
      final x = _rtl ? box.size.width - details.localPosition.dx : details.localPosition.dx;
      _controller.value = math.max(_controller.value, x / _width);
    }
    _peeking = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta! / _width;
    _controller.value += _rtl ? -delta : delta;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx * (_rtl ? -1 : 1);
    if (velocity.abs() >= _minFlingVelocity) {
      _controller.fling(velocity: velocity / _width);
    } else if (_controller.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  @override
  Widget build(BuildContext context) {
    _rtl = Directionality.of(context) == TextDirection.rtl;
    _width = math.min(360.0, MediaQuery.sizeOf(context).width - 56);
    final padding = MediaQuery.paddingOf(context);
    final edgeWidth = _edgeWidth + (_rtl ? padding.right : padding.left);
    final scrim = Theme.of(context).colorScheme.scrim;
    final sheet = CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): close},
      child: FocusScope(
        node: _focusScope,
        child: RepaintBoundary(
          child: _SideSheet(title: widget.title, onClose: close, child: widget.sheet),
        ),
      ),
    );
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final value = _controller.value;
        final visible = value > 0;
        final open = visible && !_peeking;
        return Stack(
          children: [
            widget.child,
            if (visible)
              BlockSemantics(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Semantics(
                        label: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                        onTap: close,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: close,
                          child: ColoredBox(color: scrim.withValues(alpha: 0.32 * value)),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: 0,
                      top: 0,
                      bottom: 0,
                      child: Transform.translate(
                        offset: Offset((1 - value) * _width * (_rtl ? 1 : -1), 0),
                        child: sheet,
                      ),
                    ),
                  ],
                ),
              ),
            if (open && Router.maybeOf(context) != null)
              BackButtonListener(
                onBackButtonPressed: () async {
                  close();
                  return true;
                },
                child: const SizedBox.shrink(),
              ),
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              width: _closed ? edgeWidth : MediaQuery.sizeOf(context).width,
              child: RawGestureDetector(
                behavior: HitTestBehavior.translucent,
                gestures: {
                  _DrawerDragRecognizer: GestureRecognizerFactoryWithHandlers<_DrawerDragRecognizer>(
                    () => _DrawerDragRecognizer(_allowDrag),
                    (r) => r
                      ..onStart = _onDragStart
                      ..onUpdate = _onDragUpdate
                      ..onEnd = _onDragEnd
                      ..onCancel = () => _onDragEnd(DragEndDetails()),
                  ),
                },
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: _onPointerDown,
                  onPointerUp: _onPointerUp,
                  onPointerCancel: _onPointerUp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DrawerDragRecognizer extends HorizontalDragGestureRecognizer {
  _DrawerDragRecognizer(this.allow);

  final bool Function() allow;

  @override
  bool isPointerAllowed(PointerEvent event) => super.isPointerAllowed(event) && allow();
}

class _SideSheet extends StatelessWidget {
  const _SideSheet({required this.title, required this.onClose, required this.child});

  final String title;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final width = math.min(360.0, MediaQuery.sizeOf(context).width - 56);
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: title,
      child: Material(
        color: AppColors.of(context).panel,
        elevation: 2,
        shape: const RoundedSuperellipseBorder(
          borderRadius: BorderRadiusDirectional.horizontal(end: Radius.circular(AppRadius.panel + 4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: width,
          height: double.infinity,
          child: SafeArea(
            left: !rtl,
            right: rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(title, style: theme.textTheme.titleLarge, overflow: TextOverflow.ellipsis),
                      ),
                      IconButton(
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                        icon: const Icon(IconsaxPlusLinear.close_circle),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
