import "package:flutter/material.dart";

@immutable
class CalendarStyle extends ThemeExtension<CalendarStyle> {
  const CalendarStyle({required this.canvas, required this.panel, required this.inset, required this.border});

  factory CalendarStyle.fromScheme(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    return CalendarStyle(
      canvas: dark ? scheme.surface : scheme.surfaceContainer,
      panel: dark ? scheme.surfaceContainer : scheme.surfaceContainerLowest,
      inset: dark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
      border: scheme.outlineVariant.withValues(alpha: dark ? 0.35 : 0.5),
    );
  }

  static const panelRadius = 24.0;
  static const insetRadius = 16.0;
  static const controlRadius = 14.0;
  static const tagRadius = 8.0;

  final Color canvas;
  final Color panel;
  final Color inset;
  final Color border;

  static CalendarStyle of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<CalendarStyle>() ?? CalendarStyle.fromScheme(theme.colorScheme);
  }

  static ShapeBorder squircle(double radius, {BorderSide side = BorderSide.none}) =>
      RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(radius), side: side);

  static Color tint(BuildContext context, Color color) =>
      color.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.24 : 0.16);

  static BorderSide tintedSide(Color color) => BorderSide(color: color.withValues(alpha: 0.35));

  @override
  CalendarStyle copyWith({Color? canvas, Color? panel, Color? inset, Color? border}) => CalendarStyle(
    canvas: canvas ?? this.canvas,
    panel: panel ?? this.panel,
    inset: inset ?? this.inset,
    border: border ?? this.border,
  );

  @override
  CalendarStyle lerp(CalendarStyle? other, double t) {
    if (other == null) return this;
    return CalendarStyle(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      inset: Color.lerp(inset, other.inset, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

class CalendarPanel extends StatelessWidget {
  const CalendarPanel({required this.child, this.margin = const EdgeInsets.fromLTRB(12, 4, 12, 12), super.key});

  final EdgeInsets margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = CalendarStyle.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: margin,
      child: Material(
        color: style.panel,
        shape: CalendarStyle.squircle(
          CalendarStyle.panelRadius,
          side: dark ? BorderSide(color: style.border) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

class TodayBadge extends StatelessWidget {
  const TodayBadge({required this.size, required this.child, super.key});

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: ShapeDecoration(color: CalendarStyle.tint(context, primary), shape: const CircleBorder()),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: primary, fontWeight: FontWeight.w700),
        child: child,
      ),
    );
  }
}
