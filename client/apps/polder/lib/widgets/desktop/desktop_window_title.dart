import "dart:async";

import "package:flutter/widgets.dart";

import "package:polder_drive/desktop/sync_tray.dart";

class DesktopWindowTitle extends StatefulWidget {
  const DesktopWindowTitle({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  State<DesktopWindowTitle> createState() => _DesktopWindowTitleState();
}

class _DesktopWindowTitleState extends State<DesktopWindowTitle> {
  @override
  void initState() {
    super.initState();
    unawaited(setDesktopWindowTitle(widget.title));
  }

  @override
  void didUpdateWidget(DesktopWindowTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) unawaited(setDesktopWindowTitle(widget.title));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
