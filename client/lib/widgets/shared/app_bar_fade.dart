import "package:flutter/material.dart";

/// Fades page content out under a transparent app bar.
class AppBarFade extends StatelessWidget {
  const AppBarFade({this.color, super.key});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).scaffoldBackgroundColor;
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c, c.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
