import "dart:math" as math;

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";

/// On macOS the app draws under the transparent title bar (macos/Runner/MainFlutterWindow.swift).
/// This adds the title bar's height to the top padding so content stays clear of the window buttons.
class WindowTitlebar extends StatefulWidget {
  const WindowTitlebar({required this.child, super.key});

  final Widget child;

  @override
  State<WindowTitlebar> createState() => _WindowTitlebarState();
}

class _WindowTitlebarState extends State<WindowTitlebar> {
  static const _channel = MethodChannel("polder/titlebar");
  static final _enabled = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  static _WindowTitlebarState? _current;

  double _height = _enabled ? 28 : 0;

  @override
  void initState() {
    super.initState();
    if (!_enabled) return;
    _current = this;
    _channel.setMethodCallHandler((call) async {
      if (call.method == "heightChanged") _setHeight(call.arguments);
    });
    _channel.invokeMethod<double>("height").then(_setHeight, onError: (_) {});
  }

  @override
  void dispose() {
    if (_current == this) {
      _current = null;
      _channel.setMethodCallHandler(null);
    }
    super.dispose();
  }

  void _setHeight(Object? height) {
    if (height is num && mounted && height != _height) setState(() => _height = height.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    if (_height == 0) return widget.child;
    final data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(
        padding: data.padding.copyWith(top: math.max(data.padding.top, _height)),
        viewPadding: data.viewPadding.copyWith(top: math.max(data.viewPadding.top, _height)),
      ),
      child: widget.child,
    );
  }
}
