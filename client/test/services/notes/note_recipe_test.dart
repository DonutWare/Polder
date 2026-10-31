import "package:flutter_test/flutter_test.dart";

import "package:polder/services/notes/note_recipe.dart";

const _imported = r"""![Pasta / Pesto](attachments/pasta-pesto.png?fileId=2)

**Servings:** 4 · **Prep:** 15 min
Source: [example.com](https://example.com/pesto)

## Ingredients
- [ ] 200 g pasta
- [x] 1 jar \*green\* pesto

### Topping
- [ ] 2 tbsp pine nuts

## Steps
1. Boil the pasta for 8 minutes.
   ![](attachments/pasta-pesto-1.png?fileId=3)
2. Stir in the pesto
   and serve.

### Finish
1. Toast the pine nuts and sprinkle them on top.

## Notes
- Leftovers keep for 2 days.
""";

void main() {
  group("NoteRecipe.parse", () {
    test("reads an imported recipe", () {
      final recipe = NoteRecipe.parse(_imported)!;

      expect(recipe.image, "attachments/pasta-pesto.png?fileId=2");
      expect(recipe.servings, 4);
      expect(recipe.ingredients.map((group) => group.name), [null, "Topping"]);
      expect(recipe.allIngredients.map((item) => item.plainText), [
        "200 g pasta",
        "1 jar *green* pesto",
        "2 tbsp pine nuts",
      ]);
      expect(recipe.steps.map((step) => step.plainText), [
        "Boil the pasta for 8 minutes.",
        "Stir in the pesto and serve.",
        "Toast the pine nuts and sprinkle them on top.",
      ]);
      expect(recipe.steps.map((step) => step.number), [1, 2, 3]);
      expect(recipe.steps.first.image, "attachments/pasta-pesto-1.png?fileId=3");
      expect(recipe.steps.last.group, "Finish");
    });

    test("reads the template and Dutch headings", () {
      expect(NoteRecipe.parse(NoteRecipe.template), isNotNull);
      final dutch = NoteRecipe.parse("Voor 2 personen\n\n## Ingrediënten\n- 2 uien\n\n## Bereiding\nSnijd de uien.\n")!;
      expect(dutch.servings, 2);
      expect(dutch.steps.single.text, "Snijd de uien.");
    });

    test("ignores notes without both sections", () {
      expect(NoteRecipe.parse("# Shopping\n- [ ] milk\n"), isNull);
      expect(NoteRecipe.parse("## Ingredients\n- milk\n"), isNull);
    });
  });

  group("Ingredient", () {
    test("splits quantity, unit and name", () {
      final ingredient = Ingredient.parse("500 g minced beef, browned");
      expect(ingredient.quantity!.from, 500);
      expect(ingredient.unit, "g");
      expect(ingredient.name, "minced beef, browned");
      expect(ingredient.keywords, ["beef"]);
    });

    test("scales quantities", () {
      expect(Ingredient.parse("1½ tbsp tomato paste").scaled(2), "3 tbsp tomato paste");
      expect(Ingredient.parse("2-3 cloves garlic").scaled(0.5), "1–1½ cloves garlic");
      expect(Ingredient.parse("500 g beef").scaled(1.5), "750 g beef");
      expect(Ingredient.parse("1/3 cup milk").scaled(2), "⅔ cup milk");
      expect(Ingredient.parse("0,5 l bouillon").scaled(3), "1.5 l bouillon");
      expect(Ingredient.parse("salt to taste").scaled(2), "salt to taste");
      expect(Ingredient.parse("2 onions").scaled(1), "2 onions");
    });
  });

  group("RecipeTimer.findIn", () {
    Map<String, Duration> timers(String text) => {
      for (final timer in RecipeTimer.findIn(text)) timer.label: timer.duration,
    };

    test("finds durations in English and Dutch", () {
      expect(timers("Slice 2 onions and cook them for 5 minutes."), {"5 minutes": const Duration(minutes: 5)});
      expect(timers("Brown for 8–10 min, then rest 30 seconds."), {
        "8–10 min": const Duration(minutes: 10),
        "30 seconds": const Duration(seconds: 30),
      });
      expect(timers("Laat 1 uur en 15 minuten sudderen."), {"1 uur en 15 minuten": const Duration(minutes: 75)});
      expect(timers("Bake for 1.5 hours."), {"1.5 hours": const Duration(minutes: 90)});
      expect(timers("Add 2 eggs."), isEmpty);
    });
  });

  test("matches ingredients to the steps that use them", () {
    final recipe = NoteRecipe.parse(
      "## Ingredients\n- 2 onions\n- 3 cloves garlic\n- 400 g tomatoes (canned)\n- 1 tbsp olive oil\n\n"
      "## Steps\n1. Slice the onion and fry in the oil.\n2. Add the tomatoes.\n",
    )!;
    expect(recipe.ingredientsFor(recipe.steps[0]).map((item) => item.plainText), ["2 onions", "1 tbsp olive oil"]);
    expect(recipe.ingredientsFor(recipe.steps[1]).map((item) => item.plainText), ["400 g tomatoes (canned)"]);
  });
}
