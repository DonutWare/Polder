import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/notes/cooking_timers_provider.dart";
import "package:polder/services/notes/note_recipe.dart";
import "package:polder/util/localization_helper.dart";

String formatCountdown(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(hours > 0 ? 2 : 1, "0");
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, "0");
  return hours > 0 ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
}

class CookingTimerChip extends ConsumerWidget {
  const CookingTimerChip({required this.stepNumber, required this.timer, super.key});

  final int stepNumber;
  final RecipeTimer timer;

  String get _key => "$stepNumber:${timer.label}";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final running = ref.watch(cookingTimersProvider).where((candidate) => candidate.key == _key).firstOrNull;
    final timers = ref.read(cookingTimersProvider.notifier);
    if (running == null) {
      return ActionChip(
        avatar: const Icon(IconsaxPlusLinear.timer_1),
        label: Text(timer.label),
        tooltip: context.localized.recipeStartTimer(formatCountdown(timer.duration)),
        onPressed: () => timers.start(_key, timer.label, timer.duration),
      );
    }
    return _RunningTimerChip(timer: running, onStop: () => timers.stop(_key));
  }
}

class CookingTimerBar extends ConsumerWidget {
  const CookingTimerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timers = ref.watch(cookingTimersProvider);
    if (timers.isEmpty) return const SizedBox.shrink();
    final notifier = ref.read(cookingTimersProvider.notifier);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final timer in timers)
                _RunningTimerChip(key: ValueKey(timer.key), timer: timer, onStop: () => notifier.stop(timer.key)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RunningTimerChip extends StatelessWidget {
  const _RunningTimerChip({required this.timer, required this.onStop, super.key});

  final CookingTimer timer;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final finished = timer.finishedAt(now);
    return InputChip(
      avatar: Icon(IconsaxPlusLinear.timer_1, color: finished ? colors.onErrorContainer : colors.onSecondaryContainer),
      label: Text(
        finished
            ? context.localized.recipeTimerDone(timer.label)
            : "${timer.label} · ${formatCountdown(timer.remainingAt(now))}",
        style: TextStyle(
          color: finished ? colors.onErrorContainer : colors.onSecondaryContainer,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      backgroundColor: finished ? colors.errorContainer : colors.secondaryContainer,
      deleteButtonTooltipMessage: context.localized.recipeStopTimer,
      deleteIconColor: finished ? colors.onErrorContainer : colors.onSecondaryContainer,
      onDeleted: onStop,
      onPressed: finished ? onStop : null,
    );
  }
}
