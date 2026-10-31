import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/polder_api_provider.dart";
import "package:polder/screens/notes/cooking/cooking_timer_bar.dart";
import "package:polder/screens/notes/editor/note_embeds.dart";
import "package:polder/services/notes/note_recipe.dart";
import "package:polder/util/localization_helper.dart";

const _readableWidth = 720.0;

class _CookingPage extends StatelessWidget {
  const _CookingPage({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _readableWidth),
      child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 32), children: children),
    ),
  );
}

class IngredientsPage extends StatelessWidget {
  const IngredientsPage({
    required this.recipe,
    required this.notePath,
    required this.factor,
    required this.servings,
    required this.onServingsChanged,
    required this.checked,
    required this.onToggle,
    super.key,
  });

  final Recipe recipe;
  final String notePath;
  final double factor;
  final int? servings;
  final ValueChanged<int> onServingsChanged;
  final Set<int> checked;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = recipe.image;
    final firstOfGroup = _firstIndexOfEachGroup();
    return _CookingPage(
      children: [
        if (image != null) ...[_RecipeImage(notePath: notePath, destination: image), const SizedBox(height: 24)],
        Row(
          children: [
            Expanded(child: Text(context.localized.recipeIngredients, style: theme.textTheme.headlineSmall)),
            if (servings != null) _ServingsStepper(servings: servings!, onChanged: onServingsChanged),
          ],
        ),
        for (final (groupIndex, group) in recipe.ingredients.indexed) ...[
          if (group.name != null) _GroupLabel(group.name!),
          for (final (itemIndex, ingredient) in group.items.indexed)
            _IngredientTile(
              key: ValueKey(firstOfGroup[groupIndex] + itemIndex),
              text: ingredient.scaled(factor),
              checked: checked.contains(firstOfGroup[groupIndex] + itemIndex),
              onChanged: () => onToggle(firstOfGroup[groupIndex] + itemIndex),
            ),
        ],
      ],
    );
  }

  List<int> _firstIndexOfEachGroup() {
    var next = 0;
    return [for (final group in recipe.ingredients) (next += group.items.length) - group.items.length];
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({required this.text, required this.checked, required this.onChanged, super.key});

  final String text;
  final bool checked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    value: checked,
    onChanged: (_) => onChanged(),
    controlAffinity: ListTileControlAffinity.leading,
    contentPadding: EdgeInsets.zero,
    title: Text(
      text,
      style: TextStyle(
        decoration: checked ? TextDecoration.lineThrough : null,
        color: checked ? Theme.of(context).colorScheme.onSurfaceVariant : null,
      ),
    ),
  );
}

class _ServingsStepper extends StatelessWidget {
  const _ServingsStepper({required this.servings, required this.onChanged});

  final int servings;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: localized.recipeFewerServings,
          icon: const Icon(IconsaxPlusLinear.minus),
          onPressed: servings > 1 ? () => onChanged(servings - 1) : null,
        ),
        Text("$servings ${localized.recipeServings.toLowerCase()}", style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          tooltip: localized.recipeMoreServings,
          icon: const Icon(IconsaxPlusLinear.add),
          onPressed: servings < 99 ? () => onChanged(servings + 1) : null,
        ),
      ],
    );
  }
}

class StepPage extends StatelessWidget {
  const StepPage({required this.recipe, required this.step, required this.notePath, required this.factor, super.key});

  final Recipe recipe;
  final RecipeStep step;
  final String notePath;
  final double factor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = step.image;
    final ingredients = recipe.ingredientsFor(step);
    final timers = step.timers;
    return _CookingPage(
      children: [
        if (step.group != null) _GroupLabel(step.group!),
        Text("${step.number}", style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(height: 8),
        Text(step.plainText, style: theme.textTheme.headlineSmall?.copyWith(height: 1.4)),
        if (timers.isNotEmpty) ...[
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final timer in timers)
                CookingTimerChip(key: ValueKey(timer.label), stepNumber: step.number, timer: timer),
            ],
          ),
        ],
        if (ingredients.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(context.localized.recipeYouNeed, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final ingredient in ingredients) Chip(label: Text(ingredient.scaled(factor)))],
          ),
        ],
        if (image != null) ...[const SizedBox(height: 28), _RecipeImage(notePath: notePath, destination: image)],
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(name, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
    );
  }
}

class _RecipeImage extends ConsumerWidget {
  const _RecipeImage({required this.notePath, required this.destination});

  final String notePath;
  final String destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ConstrainedBox(
    constraints: const BoxConstraints(maxHeight: 320),
    child: ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Image(
        image: noteImage(ref.watch(polderApiProvider), NoteTargets(notePath: notePath, byId: const {}), destination),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    ),
  );
}
