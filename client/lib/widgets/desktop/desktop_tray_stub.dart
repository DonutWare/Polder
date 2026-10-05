import "package:flutter/widgets.dart";

Future<void> initializeDesktopWindow() async {}

class DesktopTray extends StatelessWidget {
  const DesktopTray({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
