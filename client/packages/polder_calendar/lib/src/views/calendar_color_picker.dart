import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_calendar/src/views/event_presentation.dart";

class CalendarColorPicker extends StatelessWidget {
  const CalendarColorPicker({required this.selected, required this.onChanged, super.key});

  static const palette = [
    Color(0xFF3E63DD),
    Color(0xFFE5484D),
    Color(0xFF46A758),
    Color(0xFFF76B15),
    Color(0xFF8E4EC6),
    Color(0xFF12A594),
    Color(0xFFFFC53D),
    Color(0xFFD6409F),
    Color(0xFF0090FF),
    Color(0xFF8D8D8D),
  ];

  final Color? selected;
  final ValueChanged<Color> onChanged;

  bool _matches(Color color) => selected != null && selected!.toARGB32() == color.toARGB32();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final color in palette)
        CalendarColorDot(color: color, selected: _matches(color), onTap: () => onChanged(color)),
      if (selected != null && !palette.any(_matches))
        CalendarColorDot(color: selected!, selected: true, onTap: () => onChanged(selected!)),
    ],
  );
}

class CalendarColorDot extends StatelessWidget {
  const CalendarColorDot({required this.color, required this.selected, required this.onTap, super.key});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkResponse(
    onTap: onTap,
    radius: 22,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: selected ? Icon(IconsaxPlusLinear.tick_circle, size: 18, color: foregroundOn(color)) : null,
    ),
  );
}
