import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/screens/notes/cooking/cooking_pages.dart";
import "package:polder/services/notes/note_recipe.dart";

class _CheckableIngredients extends StatefulWidget {
  const _CheckableIngredients({required this.recipe});

  final Recipe recipe;

  @override
  State<_CheckableIngredients> createState() => _CheckableIngredientsState();
}

class _CheckableIngredientsState extends State<_CheckableIngredients> {
  final _checked = <int>{};

  @override
  Widget build(BuildContext context) => IngredientsPage(
    recipe: widget.recipe,
    notePath: "/Notes/Stew.md",
    factor: 1,
    servings: null,
    onServingsChanged: (_) {},
    checked: _checked,
    onToggle: (index) => setState(() => _checked.contains(index) ? _checked.remove(index) : _checked.add(index)),
  );
}

bool _isChecked(WidgetTester tester, String text) =>
    tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, text)).value!;

void main() {
  testWidgets("ticking an ingredient checks that ingredient only", (tester) async {
    final recipe = NoteRecipe.parse(
      "## Ingredients\n- 2 onions\n- 1 carrot\n\n### Topping\n- 1 lemon\n\n## Steps\n1. Cook.\n",
    )!;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: _CheckableIngredients(recipe: recipe)),
      ),
    );

    await tester.tap(find.text("1 carrot"));
    await tester.pump();
    expect(
      [_isChecked(tester, "2 onions"), _isChecked(tester, "1 carrot"), _isChecked(tester, "1 lemon")],
      [false, true, false],
    );

    await tester.tap(find.text("1 lemon"));
    await tester.tap(find.text("1 carrot"));
    await tester.pump();
    expect(
      [_isChecked(tester, "2 onions"), _isChecked(tester, "1 carrot"), _isChecked(tester, "1 lemon")],
      [false, false, true],
    );
  });
}
