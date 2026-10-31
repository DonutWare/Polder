import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/notes/cooking_timers_provider.dart";
import "package:polder/services/notes/note_recipe.dart";
import "package:polder/util/duration_format.dart";
import "package:polder/util/localization_helper.dart";

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
        tooltip: context.localized.recipeStartTimer(timer.duration.clock),
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
        finished ? context.localized.recipeTimerDone(timer.label) : "${timer.label} · ${timer.remainingAt(now).clock}",
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
