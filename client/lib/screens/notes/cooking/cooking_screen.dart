import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:wakelock_plus/wakelock_plus.dart";

import "package:polder/providers/notes/note_document_provider.dart";
import "package:polder/screens/notes/cooking/cooking_pages.dart";
import "package:polder/screens/notes/cooking/cooking_timer_bar.dart";
import "package:polder/services/notes/note_recipe.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/message_view.dart";

class CookingScreen extends ConsumerStatefulWidget {
  const CookingScreen({required this.path, super.key});

  final String path;

  @override
  ConsumerState<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends ConsumerState<CookingScreen> {
  final _pages = PageController();
  int _page = 0;
  int? _servings;
  final _checked = <int>{};

  @override
  void initState() {
    super.initState();
    _keepScreenOn(true);
  }

  @override
  void dispose() {
    _keepScreenOn(false);
    _pages.dispose();
    super.dispose();
  }

  void _keepScreenOn(bool on) {
    unawaited(WakelockPlus.toggle(enable: on).catchError((Object _) {}));
  }

  void _goTo(int page, int pageCount) {
    final target = page.clamp(0, pageCount - 1);
    if (target == _page || !_pages.hasClients) return;
    unawaited(_pages.animateToPage(target, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic));
  }

  void _close() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final document = ref.watch(noteDocumentProvider(widget.path));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: const Icon(IconsaxPlusLinear.close_circle),
          onPressed: _close,
        ),
        title: Text(RemotePath.withoutExtension(RemotePath.name(widget.path))),
      ),
      body: AsyncValueView(
        value: document,
        onRetry: () => ref.invalidate(noteDocumentProvider(widget.path)),
        data: (document) => switch (NoteRecipe.parse(document.text)) {
          final recipe? when recipe.steps.isNotEmpty => _cooking(context, recipe),
          _ => MessageView(icon: IconsaxPlusLinear.cake, message: context.localized.recipeNoSteps),
        },
      ),
    );
  }

  Widget _cooking(BuildContext context, Recipe recipe) {
    final pageCount = recipe.steps.length + 1;
    final page = _page.clamp(0, pageCount - 1);
    final factor = recipe.servings == null ? 1.0 : (_servings ?? recipe.servings!) / recipe.servings!;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _goTo(page + 1, pageCount),
        const SingleActivator(LogicalKeyboardKey.space): () => _goTo(page + 1, pageCount),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _goTo(page - 1, pageCount),
        const SingleActivator(LogicalKeyboardKey.escape): _close,
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            LinearProgressIndicator(value: page / (pageCount - 1)),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: pageCount,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) => index == 0
                    ? IngredientsPage(
                        recipe: recipe,
                        notePath: widget.path,
                        factor: factor,
                        servings: _servings ?? recipe.servings,
                        onServingsChanged: (servings) => setState(() => _servings = servings),
                        checked: _checked,
                        onToggle: (index) =>
                            setState(() => _checked.contains(index) ? _checked.remove(index) : _checked.add(index)),
                      )
                    : StepPage(recipe: recipe, step: recipe.steps[index - 1], notePath: widget.path, factor: factor),
              ),
            ),
            const CookingTimerBar(),
            _StepNavigation(
              page: page,
              pageCount: pageCount,
              onPrevious: () => _goTo(page - 1, pageCount),
              onNext: () => _goTo(page + 1, pageCount),
              onDone: _close,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepNavigation extends StatelessWidget {
  const _StepNavigation({
    required this.page,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
    required this.onDone,
  });

  final int page;
  final int pageCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final last = page == pageCount - 1;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (page > 0)
              OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(IconsaxPlusLinear.arrow_left),
                label: Text(localized.recipePrevious),
              ),
            const Spacer(),
            if (page > 0) Text(localized.recipeStepOf(page, pageCount - 1)),
            const Spacer(),
            FilledButton.icon(
              onPressed: last ? onDone : onNext,
              icon: Icon(last ? IconsaxPlusLinear.tick_circle : IconsaxPlusLinear.arrow_right),
              iconAlignment: IconAlignment.end,
              label: Text(
                last
                    ? localized.recipeDone
                    : page == 0
                    ? localized.recipeBegin
                    : localized.recipeNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
