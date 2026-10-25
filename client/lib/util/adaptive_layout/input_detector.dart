import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:polder/util/adaptive_layout/adaptive_layout.dart";

class InputDetector extends StatefulWidget {
  const InputDetector({required this.isDesktop, required this.child, super.key});

  final bool isDesktop;
  final Widget Function(InputDevice input) child;

  @override
  State<InputDetector> createState() => _InputDetectorState();
}

class _InputDetectorState extends State<InputDetector> {
  late InputDevice _currentInput = widget.isDesktop || kIsWeb ? InputDevice.pointer : InputDevice.touch;

  static final _directionalKeys = {
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.select,
  };

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_handleKeyPress);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_handleKeyPress);
    super.dispose();
  }

  bool _handleKeyPress(KeyEvent event) {
    if (widget.isDesktop || kIsWeb || event is! KeyDownEvent) return false;
    if (_directionalKeys.contains(event.logicalKey) && !_isEditableTextFocused()) _update(InputDevice.dPad);
    return false;
  }

  void _handlePointerDown(PointerDownEvent event) => switch (event.kind) {
    PointerDeviceKind.touch => _update(InputDevice.touch),
    PointerDeviceKind.mouse => _update(InputDevice.pointer),
    _ => null,
  };

  void _update(InputDevice device) {
    if (_currentInput == device) return;
    if (device != InputDevice.dPad) FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _currentInput = device);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: _handlePointerDown,
    behavior: HitTestBehavior.translucent,
    child: IgnorePointer(
      ignoring: _currentInput == InputDevice.dPad,
      child: Builder(builder: (context) => widget.child(_currentInput)),
    ),
  );
}

bool _isEditableTextFocused() {
  final focused = FocusManager.instance.primaryFocus?.context;
  if (focused == null) return false;
  return focused.widget is EditableText || focused.findAncestorWidgetOfExactType<EditableText>() != null;
}
