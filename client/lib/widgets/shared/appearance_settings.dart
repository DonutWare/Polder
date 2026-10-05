import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:nomad/l10n/generated/app_localizations.dart";
import "package:nomad/models/appearance.dart";
import "package:nomad/providers/appearance/appearance_provider.dart";
import "package:nomad/theme/app_theme.dart";
import "package:nomad/util/localization_helper.dart";

Future<void> showAppearanceDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    icon: const Icon(IconsaxPlusLinear.brush_2),
    title: Text(context.localized.appearance),
    content: const SizedBox(width: 360, child: SingleChildScrollView(child: AppearanceSettings())),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.localized.done))],
  ),
);

extension AccentPresetLabel on AccentPreset {
  String label(AppLocalizations localized) => switch (this) {
    AccentPreset.polder => localized.accentPolder,
    AccentPreset.blue => localized.accentBlue,
    AccentPreset.teal => localized.accentTeal,
    AccentPreset.green => localized.accentGreen,
    AccentPreset.violet => localized.accentViolet,
    AccentPreset.rose => localized.accentRose,
    AccentPreset.orange => localized.accentOrange,
    AccentPreset.slate => localized.accentSlate,
  };
}

class AppearanceSettings extends ConsumerWidget {
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localized = context.localized;
    final appearance = ref.watch(appearanceProvider);
    final notifier = ref.read(appearanceProvider.notifier);
    final label = theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.6);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(localized.theme.toUpperCase(), style: label),
        const SizedBox(height: 10),
        Row(
          spacing: 8,
          children: [
            for (final (mode, icon, name) in [
              (ThemeMode.system, IconsaxPlusLinear.monitor, localized.themeSystem),
              (ThemeMode.light, IconsaxPlusLinear.sun_1, localized.themeLight),
              (ThemeMode.dark, IconsaxPlusLinear.moon, localized.themeDark),
            ])
              Expanded(
                child: _ModeOption(
                  icon: icon,
                  label: name,
                  selected: appearance.mode == mode,
                  onTap: () => notifier.setMode(mode),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(localized.accentColor.toUpperCase(), style: label),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Swatch(
              tooltip: appearance.systemAccent == null ? localized.systemAccentUnavailable : localized.themeSystem,
              system: true,
              selected: appearance.accent == null,
              onTap: () => notifier.setAccent(null),
            ),
            for (final preset in AccentPreset.values)
              _Swatch(
                color: preset.color,
                tooltip: preset.label(localized),
                selected: appearance.isAccent(preset.color),
                onTap: () => notifier.setAccent(preset.color),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          appearance.accent != null
              ? localized.accentCustomHint
              : appearance.systemAccent == null
              ? localized.accentNoSystemHint
              : localized.accentSystemHint,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final colors = AppColors.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? cs.primaryContainer : colors.inset,
        shape: squircle(
          AppRadius.inset,
          side: BorderSide(color: selected ? cs.primary.withValues(alpha: 0.4) : colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
            child: Column(
              spacing: 6,
              children: [
                Icon(icon, color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.tooltip, required this.selected, required this.onTap, this.color, this.system = false});

  static const _rainbow = SweepGradient(
    colors: [Color(0xFF4285F4), Color(0xFF34A853), Color(0xFFFBBC05), Color(0xFFEA4335), Color(0xFF4285F4)],
    stops: [0, 0.25, 0.5, 0.75, 1],
  );

  final Color? color;
  final String tooltip;
  final bool selected;
  final bool system;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = this.color;
    final fg = color == null || ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: tooltip,
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selected ? cs.onSurface : Colors.transparent, width: 2),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                gradient: color == null ? _rainbow : null,
              ),
              child: Icon(
                selected ? IconsaxPlusBold.tick_circle : (system ? IconsaxPlusLinear.magicpen : null),
                size: 18,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
