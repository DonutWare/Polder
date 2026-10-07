import "package:flutter/material.dart";

import "package:polder/theme/app_theme.dart";

// css_variables lands in a :root rule that overrides Collabora's own --color-* palette, in both its light and dark theme.
@immutable
class EditorTheme {
  const EditorTheme({required this.uiDefaults, required this.cssVariables, required this.background});

  factory EditorTheme.of(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final colors = AppColors.of(context);
    final dark = theme.brightness == Brightness.dark;
    Color blend(Color top, double opacity, Color bottom) => Color.alphaBlend(top.withValues(alpha: opacity), bottom);

    final variables = {
      "--color-primary": cs.primary,
      "--color-primary-dark": blend(Colors.black, 0.2, cs.primary),
      "--color-primary-darker": blend(Colors.black, 0.35, cs.primary),
      "--color-primary-lighter": blend(cs.primary, 0.45, colors.panel),
      "--color-primary-text": cs.onPrimary,
      "--color-btn-primary-hover-bg": blend(cs.primary, 0.12, colors.panel),
      "--color-overlay": cs.primary.withValues(alpha: 0.08),
      "--color-hyperlink": cs.primary,
      "--color-main-text": cs.onSurface,
      "--color-text-dark": cs.onSurface,
      "--color-text-darker": cs.onSurface,
      "--color-text-light": cs.onSurfaceVariant,
      "--color-text-lighter": cs.onSurfaceVariant,
      "--color-main-background": colors.panel,
      "--color-canvas": colors.canvas,
      "--color-backstage-background": colors.canvas,
      "--color-background-lighter": dark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
      "--color-background-dark": dark ? cs.surfaceContainerLow : cs.surfaceContainerHigh,
      "--color-background-darker": dark ? cs.surfaceContainerLowest : cs.surfaceContainerHighest,
      "--color-background-tabs-group": colors.inset,
      "--color-background-hover": blend(cs.onSurface, 0.08, colors.panel),
      "--color-border": cs.outlineVariant,
      "--color-border-dark": cs.outline,
      "--color-border-darker": cs.outline,
      "--color-border-lighter": colors.border,
      "--color-toolbar-border": colors.border,
      "--color-scrollbar-thumb": cs.outline,
      "--color-scrollbar-railway": colors.inset,
      "--color-box-shadow": cs.shadow.withValues(alpha: 0.3),
      "--color-error": cs.error,
      "--color-warning": colors.warning,
      "--color-success": colors.success,
    };
    return EditorTheme(
      uiDefaults: "UIMode=tabbed;UITheme=${dark ? "dark" : "light"};SaveAsMode=group",
      cssVariables: [
        for (final MapEntry(:key, :value) in variables.entries) "$key=${_css(value)}",
        "--border-radius=${AppRadius.tag.round()}px",
        "--border-radius-large=${AppRadius.control.round()}px",
      ].join(";"),
      background: _css(colors.canvas),
    );
  }

  final String uiDefaults;
  final String cssVariables;
  final String background;

  static String _css(Color color) {
    final rgb = (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, "0");
    if (color.a >= 1) return "#$rgb";
    return "rgba(${(color.r * 255).round()},${(color.g * 255).round()},${(color.b * 255).round()},${color.a.toStringAsFixed(2)})";
  }

  @override
  bool operator ==(Object other) =>
      other is EditorTheme &&
      other.uiDefaults == uiDefaults &&
      other.cssVariables == cssVariables &&
      other.background == background;

  @override
  int get hashCode => Object.hash(uiDefaults, cssVariables, background);
}
