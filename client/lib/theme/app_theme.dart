import "dart:math" as math;

import "package:flutter/cupertino.dart" show CupertinoPageTransitionsBuilder;
import "package:flutter/material.dart";

import "package:dynamic_color/dynamic_color.dart";
import "package:iconsax_plus/iconsax_plus.dart";

abstract final class AppRadius {
  static const panel = 24.0;

  static const inset = 16.0;

  static const control = 14.0;

  static const tag = 8.0;
}

RoundedSuperellipseBorder squircle(double radius, {BorderSide side = BorderSide.none}) =>
    RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(radius), side: side);

BorderSide tintedSide(Color color) => BorderSide(color: color.withValues(alpha: 0.3));

abstract final class AppShapes {
  static const cookie = CookieBorder(lobes: 9, depth: 0.1);
  static const sunny = CookieBorder(lobes: 12, depth: 0.09);
}

/// A circle with scalloped edges, like the M3 Expressive cookie shapes.
class CookieBorder extends ShapeBorder {
  const CookieBorder({required this.lobes, required this.depth});

  final int lobes;
  final double depth;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    const steps = 144;
    final path = Path();
    for (var i = 0; i < steps; i++) {
      final a = i / steps * 2 * math.pi;
      final r = 1 - depth * (1 - math.cos(lobes * a)) / 2;
      final p = Offset(
        rect.center.dx + rect.width / 2 * r * math.cos(a - math.pi / 2),
        rect.center.dy + rect.height / 2 * r * math.sin(a - math.pi / 2),
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  bool operator ==(Object other) => other is CookieBorder && other.lobes == lobes && other.depth == depth;

  @override
  int get hashCode => Object.hash(lobes, depth);
}

abstract final class AppMotion {
  static const spatial = Cubic(0.38, 1.21, 0.22, 1.0);
  static const spatialDuration = Duration(milliseconds: 450);

  static const effects = Cubic(0.34, 0.8, 0.34, 1.0);
  static const effectsDuration = Duration(milliseconds: 200);
}

/// Surfaces come from a near-grey palette so only accents carry the seed color.
ColorScheme buildColorScheme(Color seed, Brightness brightness) {
  final muted = HSLColor.fromColor(seed).saturation < 0.3;
  final accents = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    dynamicSchemeVariant: muted ? DynamicSchemeVariant.tonalSpot : DynamicSchemeVariant.vibrant,
  );
  final neutral = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.neutral,
  );
  return accents.copyWith(
    surface: neutral.surface,
    surfaceDim: neutral.surfaceDim,
    surfaceBright: neutral.surfaceBright,
    surfaceContainerLowest: neutral.surfaceContainerLowest,
    surfaceContainerLow: neutral.surfaceContainerLow,
    surfaceContainer: neutral.surfaceContainer,
    surfaceContainerHigh: neutral.surfaceContainerHigh,
    surfaceContainerHighest: neutral.surfaceContainerHighest,
    onSurface: neutral.onSurface,
    onSurfaceVariant: neutral.onSurfaceVariant,
    outline: neutral.outline,
    outlineVariant: neutral.outlineVariant,
    inverseSurface: neutral.inverseSurface,
    onInverseSurface: neutral.onInverseSurface,
    surfaceTint: Colors.transparent,
  );
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.canvas,
    required this.panel,
    required this.inset,
    required this.border,
    required this.success,
    required this.warning,
    required this.info,
    required this.sky,
    required this.rose,
  });

  final Color canvas;

  final Color panel;

  final Color inset;

  final Color border;

  final Color success;
  final Color warning;
  final Color info;

  final Color sky;
  final Color rose;

  static AppColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppColors>() ?? AppColors.fromScheme(theme.colorScheme);
  }

  factory AppColors.fromScheme(ColorScheme cs) {
    final dark = cs.brightness == Brightness.dark;

    Color status(Color base) =>
        ColorScheme.fromSeed(seedColor: base.harmonizeWith(cs.primary), brightness: cs.brightness).primary;

    return AppColors(
      canvas: dark ? cs.surface : cs.surfaceContainer,
      panel: dark ? cs.surfaceContainer : cs.surfaceContainerLowest,
      inset: dark ? cs.surfaceContainerHigh : cs.surfaceContainerLow,
      border: cs.outlineVariant.withValues(alpha: dark ? 0.35 : 0.5),
      success: status(const Color(0xFF22C55E)),
      warning: status(const Color(0xFFF59E0B)),
      info: cs.primary,
      sky: status(const Color(0xFF0EA5E9)),
      rose: status(const Color(0xFFEC4899)),
    );
  }

  Color forLevel(BuildContext context, double? fraction, {double warnAt = 0.75, double errorAt = 0.9}) {
    final f = fraction ?? 0;
    if (f > errorAt) return Theme.of(context).colorScheme.error;
    if (f > warnAt) return warning;
    return info;
  }

  @override
  AppColors copyWith({
    Color? canvas,
    Color? panel,
    Color? inset,
    Color? border,
    Color? success,
    Color? warning,
    Color? info,
    Color? sky,
    Color? rose,
  }) => AppColors(
    canvas: canvas ?? this.canvas,
    panel: panel ?? this.panel,
    inset: inset ?? this.inset,
    border: border ?? this.border,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    info: info ?? this.info,
    sky: sky ?? this.sky,
    rose: rose ?? this.rose,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      inset: Color.lerp(inset, other.inset, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      sky: Color.lerp(sky, other.sky, t)!,
      rose: Color.lerp(rose, other.rose, t)!,
    );
  }
}

abstract final class AppTheme {
  static ThemeData build(Color seed, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final cs = buildColorScheme(seed, brightness);

    final colors = AppColors.fromScheme(cs);
    final base = ThemeData(colorScheme: cs, useMaterial3: true, fontFamily: "Rubik");
    final text = base.textTheme.copyWith(
      headlineLarge: base.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.8),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.6),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.4),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    // ThemeData's text theme only gets sizes once localized; the styles below need them now.
    final sized = Typography.material2021().englishLike.merge(text);

    const rounded = squircle;
    final hairline = BorderSide(color: colors.border);
    const controlPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);

    // Controls squeeze their corners while pressed.
    WidgetStateProperty<OutlinedBorder> pressable(double r, {BorderSide side = BorderSide.none}) =>
        WidgetStateProperty.resolveWith((s) => rounded(s.contains(WidgetState.pressed) ? r * 0.55 : r, side: side));

    OutlineInputBorder field(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.inset),
      borderSide: BorderSide(color: color, width: width),
    );

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: colors.canvas,
      canvasColor: colors.canvas,
      extensions: [colors],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
      dividerTheme: DividerThemeData(color: colors.border, space: 1, thickness: 1),
      iconTheme: IconThemeData(color: cs.onSurfaceVariant, size: 22),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) => const Icon(IconsaxPlusLinear.arrow_left),
        closeButtonIconBuilder: (_) => const Icon(IconsaxPlusLinear.close_circle),
        drawerButtonIconBuilder: (_) => const Icon(IconsaxPlusLinear.menu),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: sized.titleLarge?.copyWith(color: cs.onSurface),
        iconTheme: IconThemeData(color: cs.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        color: colors.panel,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: rounded(AppRadius.panel, side: dark ? hairline : BorderSide.none),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.panel,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: cs.secondaryContainer,
        indicatorShape: rounded(AppRadius.control, side: tintedSide(cs.secondary)),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => sized.labelMedium?.copyWith(
            color: s.contains(WidgetState.selected) ? cs.onSurface : cs.onSurfaceVariant,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? cs.onSecondaryContainer : cs.onSurfaceVariant),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.panel,
        elevation: 0,
        indicatorColor: cs.secondaryContainer,
        indicatorShape: rounded(AppRadius.control, side: tintedSide(cs.secondary)),
        selectedIconTheme: IconThemeData(color: cs.onSecondaryContainer),
        unselectedIconTheme: IconThemeData(color: cs.onSurfaceVariant),
        selectedLabelTextStyle: sized.labelLarge?.copyWith(color: cs.onSurface),
        unselectedLabelTextStyle: sized.labelLarge?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
      ),
      tabBarTheme: TabBarThemeData(
        dividerHeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: ShapeDecoration(
          color: cs.secondaryContainer,
          shape: rounded(AppRadius.control, side: tintedSide(cs.secondary)),
        ),
        labelColor: cs.onSecondaryContainer,
        unselectedLabelColor: cs.onSurfaceVariant,
        labelStyle: sized.labelLarge,
        splashBorderRadius: BorderRadius.circular(AppRadius.control),
        overlayColor: WidgetStatePropertyAll(cs.primary.withValues(alpha: 0.06)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: controlPadding,
          textStyle: sized.labelLarge,
          animationDuration: AppMotion.effectsDuration,
        ).copyWith(shape: pressable(AppRadius.control)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: controlPadding,
          elevation: 0,
          animationDuration: AppMotion.effectsDuration,
        ).copyWith(shape: pressable(AppRadius.control)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: controlPadding,
          side: BorderSide(color: cs.outlineVariant),
          textStyle: sized.labelLarge,
          animationDuration: AppMotion.effectsDuration,
        ).copyWith(shape: pressable(AppRadius.control)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: sized.labelLarge,
          animationDuration: AppMotion.effectsDuration,
        ).copyWith(shape: pressable(AppRadius.control)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: cs.onSurfaceVariant,
          animationDuration: AppMotion.effectsDuration,
        ).copyWith(shape: pressable(AppRadius.control)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: rounded(AppRadius.control),
          side: BorderSide(color: cs.outlineVariant),
          selectedBackgroundColor: cs.secondaryContainer,
          selectedForegroundColor: cs.onSecondaryContainer,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.tertiaryContainer,
        foregroundColor: cs.onTertiaryContainer,
        elevation: 1,
        highlightElevation: 2,
        shape: rounded(AppRadius.inset + 4),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: rounded(AppRadius.control - 2),
        side: BorderSide(color: cs.outlineVariant),
        backgroundColor: colors.panel,
        selectedColor: cs.secondaryContainer,
        checkmarkColor: cs.onSecondaryContainer,
      ),
      checkboxTheme: CheckboxThemeData(shape: rounded(AppRadius.tag - 2)),
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? const Icon(IconsaxPlusLinear.check, size: 16) : null,
        ),
      ),
      // ignore: deprecated_member_use
      sliderTheme: const SliderThemeData(year2023: false),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inset,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: field(colors.border),
        enabledBorder: field(colors.border),
        focusedBorder: field(cs.primary, 1.5),
        errorBorder: field(cs.error),
        focusedErrorBorder: field(cs.error, 1.5),
        disabledBorder: field(colors.border.withValues(alpha: 0.3)),
        prefixIconColor: cs.onSurfaceVariant,
        suffixIconColor: cs.onSurfaceVariant,
      ),
      listTileTheme: ListTileThemeData(shape: rounded(AppRadius.inset), iconColor: cs.onSurfaceVariant),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.panel,
        surfaceTintColor: Colors.transparent,
        shape: rounded(AppRadius.panel + 4),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.panel,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedSuperellipseBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.panel + 4)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.panel,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: rounded(AppRadius.inset, side: hairline),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colors.panel),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(rounded(AppRadius.inset, side: hairline)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: rounded(AppRadius.inset),
        insetPadding: const EdgeInsets.all(16),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: ShapeDecoration(
          color: dark ? cs.surfaceContainerHighest : cs.inverseSurface,
          shape: rounded(AppRadius.tag + 2, side: dark ? hairline : BorderSide.none),
        ),
        textStyle: sized.bodySmall?.copyWith(color: dark ? cs.onSurface : cs.onInverseSurface),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        waitDuration: const Duration(milliseconds: 400),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        // ignore: deprecated_member_use
        year2023: false,
        linearTrackColor: cs.secondaryContainer,
        circularTrackColor: Colors.transparent,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: rounded(AppRadius.inset),
        collapsedShape: rounded(AppRadius.inset),
      ),
    );
  }
}
