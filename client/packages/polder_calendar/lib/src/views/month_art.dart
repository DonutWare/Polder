import "package:flutter/material.dart";

import "package:flutter_svg/flutter_svg.dart";

class MonthArt extends StatelessWidget {
  const MonthArt({required this.month, this.child, super.key});

  final DateTime month;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      SvgPicture.asset(
        "assets/months/${month.month.toString().padLeft(2, "0")}.svg",
        package: "polder_calendar",
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
      ),
      if (Theme.of(context).brightness == Brightness.dark) const ColoredBox(color: Color(0x47000000)),
      ?child,
    ],
  );
}
