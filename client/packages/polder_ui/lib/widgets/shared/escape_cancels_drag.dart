import "package:flutter/gestures.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";

class EscapeCancelsDrag extends StatefulWidget {
  const EscapeCancelsDrag({required this.child, this.onCancel, super.key});

  final Widget child;
  final VoidCallback? onCancel;

  @override
  State<EscapeCancelsDrag> createState() => _EscapeCancelsDragState();
}

class _EscapeCancelsDragState extends State<EscapeCancelsDrag> {
  PointerEvent? _pressed;

  @override
  void dispose() {
    _release();
    super.dispose();
  }

  void _press(PointerDownEvent event) {
    if (_pressed == null) HardwareKeyboard.instance.addHandler(_onKey);
    _pressed = event;
  }

  void _follow(PointerMoveEvent event) {
    if (_pressed?.pointer == event.pointer) _pressed = event;
  }

  void _end(PointerEvent event) {
    if (_pressed?.pointer == event.pointer) _release();
  }

  void _release() {
    if (_pressed == null) return;
    _pressed = null;
    HardwareKeyboard.instance.removeHandler(_onKey);
  }

  bool _onKey(KeyEvent event) {
    final pressed = _pressed;
    if (pressed == null || event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.escape) return false;
    widget.onCancel?.call();
    GestureBinding.instance.handlePointerEvent(
      PointerCancelEvent(
        viewId: pressed.viewId,
        pointer: pressed.pointer,
        device: pressed.device,
        kind: pressed.kind,
        position: pressed.position,
      ),
    );
    _release();
    return true;
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: _press,
    onPointerMove: _follow,
    onPointerUp: _end,
    onPointerCancel: _end,
    child: widget.child,
  );
}
