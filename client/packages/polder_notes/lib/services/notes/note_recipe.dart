class Recipe {
  const Recipe({this.image, this.servings, required this.ingredients, required this.steps});

  final String? image;
  final int? servings;
  final List<IngredientGroup> ingredients;
  final List<RecipeStep> steps;

  Iterable<Ingredient> get allIngredients => ingredients.expand((group) => group.items);

  List<Ingredient> ingredientsFor(RecipeStep step) {
    final words = RecipeWords.stemsIn(step.text);
    return [
      for (final ingredient in allIngredients)
        if (ingredient.keywords.any(words.contains)) ingredient,
    ];
  }
}

class IngredientGroup {
  const IngredientGroup(this.name, this.items);

  final String? name;
  final List<Ingredient> items;
}

class RecipeStep {
  const RecipeStep({required this.number, required this.text, this.group, this.image});

  final int number;
  final String text;
  final String? group;
  final String? image;

  String get plainText => RecipeText.plain(text);

  List<RecipeTimer> get timers => RecipeTimer.findIn(plainText);
}

abstract final class NoteRecipe {
  static const template =
      "**Servings:** 4 · **Prep:** 15 min · **Cook:** 30 min\n"
      "\n"
      "## Ingredients\n"
      "- [ ] \n"
      "\n"
      "## Steps\n"
      "1. \n";

  static final _heading = RegExp(r"^(#{1,6})\s+(.*?)\s*#*\s*$");
  static final _ingredientHeading = RegExp(r"^(ingredients?|ingrediënten|ingredienten)\b", caseSensitive: false);
  static final _stepsHeading = RegExp(
    r"^(steps|instructions|method|directions|preparation|bereiding|bereidingswijze|werkwijze)\b",
    caseSensitive: false,
  );
  static final _listItem = RegExp(r"^(\s*)(?:[-*+]|\d{1,9}[.)])\s+(?:\[[ xX]\]\s*)?(.*)$");
  static final _image = RegExp(r"!\[[^\]]*\]\(([^)\s]+)[^)]*\)");
  static final _servings = RegExp(
    r"(?:servings|serves|porties|personen)\W{0,4}\s*(\d{1,3})\b|\b(\d{1,3})\s*(?:servings|people|porties|personen)\b",
    caseSensitive: false,
  );

  static bool isRecipe(String text) => parse(text) != null;

  static Recipe? parse(String text) {
    final reader = _RecipeReader();
    for (final line in text.split("\n")) {
      final heading = _heading.firstMatch(line);
      if (heading != null) {
        reader.heading(heading.group(1)!.length, heading.group(2)!);
      } else {
        reader.line(line);
      }
    }
    return reader.recipe();
  }

  static String? imageIn(String line) => _image.firstMatch(line)?.group(1);
}

enum _Section { header, ingredients, steps, other }

class _RecipeReader {
  _Section _section = _Section.header;
  int _sectionLevel = 0;
  bool _sawIngredients = false;
  bool _sawSteps = false;
  String? _group;
  String? _image;
  int? _servings;
  final _groups = <IngredientGroup>[];
  final _steps = <_StepDraft>[];
  bool _previousBlank = true;

  void heading(int level, String title) {
    _previousBlank = true;
    if (_section != _Section.header && _section != _Section.other && level > _sectionLevel) {
      _group = RecipeText.plain(title);
      if (_section == _Section.ingredients) _groups.add(IngredientGroup(_group, []));
      return;
    }
    _group = null;
    _sectionLevel = level;
    if (NoteRecipe._ingredientHeading.hasMatch(title.trim())) {
      _section = _Section.ingredients;
      _sawIngredients = true;
      _groups.add(IngredientGroup(_group, []));
    } else if (NoteRecipe._stepsHeading.hasMatch(title.trim())) {
      _section = _Section.steps;
      _sawSteps = true;
    } else if (_section != _Section.header) {
      _section = _Section.other;
    }
  }

  void line(String line) {
    final blank = line.trim().isEmpty;
    switch (_section) {
      case _Section.header:
        _image ??= NoteRecipe.imageIn(line);
        _servings ??= _servingsIn(line);
      case _Section.ingredients:
        _ingredientLine(line);
      case _Section.steps:
        _stepLine(line);
      case _Section.other:
        break;
    }
    _previousBlank = blank;
  }

  int? _servingsIn(String line) {
    final match = NoteRecipe._servings.firstMatch(line);
    return int.tryParse(match?.group(1) ?? match?.group(2) ?? "");
  }

  void _ingredientLine(String line) {
    if (line.trim().isEmpty || NoteRecipe.imageIn(line) != null) return;
    final item = NoteRecipe._listItem.firstMatch(line);
    final text = (item?.group(2) ?? line).trim();
    if (text.isEmpty) return;
    _groups.last.items.add(Ingredient.parse(text));
  }

  void _stepLine(String line) {
    if (line.trim().isEmpty) return;
    final image = NoteRecipe.imageIn(line);
    if (image != null && line.trim().startsWith("![")) {
      if (_steps.isNotEmpty) _steps.last.image ??= image;
      return;
    }
    final item = NoteRecipe._listItem.firstMatch(line);
    final startsStep = item != null && item.group(1)!.length < 2;
    if (startsStep || _steps.isEmpty || (_previousBlank && !line.startsWith(" "))) {
      _steps.add(_StepDraft(_group, (item?.group(2) ?? line).trim()));
    } else {
      _steps.last.text.write(" ${(item?.group(2) ?? line).trim()}");
    }
  }

  Recipe? recipe() {
    if (!_sawIngredients || !_sawSteps) return null;
    final steps = [for (final draft in _steps.where((draft) => draft.text.toString().trim().isNotEmpty)) draft];
    return Recipe(
      image: _image,
      servings: _servings,
      ingredients: [
        for (final group in _groups)
          if (group.items.isNotEmpty) group,
      ],
      steps: [
        for (final (index, draft) in steps.indexed)
          RecipeStep(number: index + 1, text: draft.text.toString().trim(), group: draft.group, image: draft.image),
      ],
    );
  }
}

class _StepDraft {
  _StepDraft(this.group, String text) : text = StringBuffer(text);

  final String? group;
  final StringBuffer text;
  String? image;
}

class Quantity {
  const Quantity(this.from, [this.to]);

  final double from;
  final double? to;

  Quantity operator *(double factor) => Quantity(from * factor, to == null ? null : to! * factor);
}

class Ingredient {
  const Ingredient({required this.text, this.quantity, this.quantityEnd = 0, this.unit, required this.name});

  final String text;
  final Quantity? quantity;
  final int quantityEnd;
  final String? unit;
  final String name;

  static final _unitPattern = RegExp(
    r"^\s*(" + RecipeUnits.all.map(RegExp.escape).join("|") + r")\.?(?=\s|$|[,)])",
    caseSensitive: false,
  );

  factory Ingredient.parse(String text) {
    final parsed = RecipeQuantity.parse(text);
    if (parsed == null) return Ingredient(text: text, name: RecipeText.plain(text));
    final rest = text.substring(parsed.end);
    final unit = _unitPattern.firstMatch(rest);
    final name = unit == null ? rest : rest.substring(unit.end);
    return Ingredient(
      text: text,
      quantity: parsed.quantity,
      quantityEnd: parsed.end,
      unit: unit?.group(1),
      name: RecipeText.plain(name).replaceFirst(RegExp(r"^\s*(of|van)\s+", caseSensitive: false), "").trim(),
    );
  }

  List<String> get keywords => RecipeWords.keywordsOf(name);

  String get plainText => RecipeText.plain(text);

  String scaled(double factor) {
    final amount = quantity;
    if (amount == null || (factor - 1).abs() < 0.001) return plainText;
    final metric = unit != null && RecipeUnits.metric.contains(unit!.toLowerCase());
    final scaledAmount = amount * factor;
    final formatted = scaledAmount.to == null
        ? RecipeQuantity.format(scaledAmount.from, metric: metric)
        : "${RecipeQuantity.format(scaledAmount.from, metric: metric)}–${RecipeQuantity.format(scaledAmount.to!, metric: metric)}";
    return RecipeText.plain("$formatted${text.substring(quantityEnd)}");
  }
}

abstract final class RecipeUnits {
  static const metric = {
    "g",
    "gr",
    "gram",
    "grams",
    "kg",
    "mg",
    "ml",
    "cl",
    "dl",
    "l",
    "liter",
    "litre",
    "liters",
    "litres",
  };

  static const all = [
    ...metric,
    "tablespoons",
    "tablespoon",
    "tbsp",
    "tbs",
    "teaspoons",
    "teaspoon",
    "tsp",
    "cups",
    "cup",
    "oz",
    "ounces",
    "ounce",
    "lbs",
    "lb",
    "pounds",
    "pound",
    "pinch",
    "pinches",
    "cloves",
    "clove",
    "cans",
    "can",
    "slices",
    "slice",
    "bunch",
    "bunches",
    "handful",
    "handfuls",
    "sprigs",
    "sprig",
    "eetlepels",
    "eetlepel",
    "el",
    "theelepels",
    "theelepel",
    "tl",
    "snufje",
    "snuf",
    "kopjes",
    "kopje",
    "stuks",
    "stuk",
    "tenen",
    "teentjes",
    "teentje",
    "teen",
    "blikken",
    "blik",
    "bosje",
    "bos",
    "handje",
    "plakken",
    "plak",
    "takjes",
    "takje",
  ];
}

typedef ParsedQuantity = ({Quantity quantity, int end});

abstract final class RecipeQuantity {
  static const _fractions = {
    "½": 0.5,
    "⅓": 1 / 3,
    "⅔": 2 / 3,
    "¼": 0.25,
    "¾": 0.75,
    "⅛": 0.125,
    "⅜": 0.375,
    "⅝": 0.625,
    "⅞": 0.875,
  };
  static final _glyphs = _fractions.keys.join();
  static final _number = "(?:\\d+\\s+\\d+/\\d+|\\d+\\s*[$_glyphs]|\\d+/\\d+|\\d+(?:[.,]\\d+)?|[$_glyphs])";
  static final _pattern = RegExp("^\\s*($_number)(?:\\s*(?:-|–|to|tot)\\s*($_number))?");

  static ParsedQuantity? parse(String text) {
    final match = _pattern.firstMatch(text);
    if (match == null) return null;
    final from = value(match.group(1)!);
    final to = match.group(2) == null ? null : value(match.group(2)!);
    if (from == null) return null;
    return (quantity: Quantity(from, to), end: match.end);
  }

  static double? value(String text) {
    final trimmed = text.trim();
    final glyph = _fractions[trimmed];
    if (glyph != null) return glyph;
    final mixedGlyph = RegExp("^(\\d+)\\s*([$_glyphs])\$").firstMatch(trimmed);
    if (mixedGlyph != null) return int.parse(mixedGlyph.group(1)!) + _fractions[mixedGlyph.group(2)!]!;
    final mixed = RegExp(r"^(\d+)\s+(\d+)/(\d+)$").firstMatch(trimmed);
    if (mixed != null) return int.parse(mixed.group(1)!) + _ratio(mixed.group(2)!, mixed.group(3)!);
    final fraction = RegExp(r"^(\d+)/(\d+)$").firstMatch(trimmed);
    if (fraction != null) return _ratio(fraction.group(1)!, fraction.group(2)!);
    return double.tryParse(trimmed.replaceFirst(",", "."));
  }

  static double _ratio(String numerator, String denominator) {
    final below = int.parse(denominator);
    return below == 0 ? 0 : int.parse(numerator) / below;
  }

  static String format(double amount, {bool metric = false}) {
    if (metric || amount >= 10) return _decimal(amount >= 10 ? amount.roundToDouble() : amount);
    final whole = amount.floor();
    final rest = amount - whole;
    if (rest < 0.04) return "$whole";
    if (rest > 0.96) return "${whole + 1}";
    for (final MapEntry(key: glyph, value: fraction) in _fractions.entries) {
      if ((rest - fraction).abs() < 0.04) return whole == 0 ? glyph : "$whole$glyph";
    }
    return _decimal(amount);
  }

  static String _decimal(double amount) {
    final rounded = (amount * 10).round() / 10;
    return rounded == rounded.roundToDouble() ? "${rounded.round()}" : rounded.toStringAsFixed(1);
  }
}

class RecipeTimer {
  const RecipeTimer(this.label, this.duration);

  final String label;
  final Duration duration;

  static final _pattern = RegExp(
    r"(\d+(?:[.,]\d+)?|[½¼¾])(?:\s*(?:-|–|to|tot|à)\s*(\d+(?:[.,]\d+)?))?\s*"
    r"(hours?|hrs?|uur|uren|h|minutes?|minuten|minuutjes|minuut|mins?|seconds?|seconden|secs?)\b",
    caseSensitive: false,
  );

  static List<RecipeTimer> findIn(String text) {
    final timers = <RecipeTimer>[];
    RegExpMatch? previous;
    for (final match in _pattern.allMatches(text)) {
      final duration = _durationOf(match);
      if (duration == null) continue;
      final joinsPrevious =
          previous != null &&
          _isHours(previous.group(3)!) &&
          !_isHours(match.group(3)!) &&
          RegExp(r"^\s*(and|en|,)?\s*$").hasMatch(text.substring(previous.end, match.start));
      if (joinsPrevious) {
        final last = timers.removeLast();
        timers.add(RecipeTimer(text.substring(previous.start, match.end), last.duration + duration));
      } else {
        timers.add(RecipeTimer(match.group(0)!, duration));
      }
      previous = match;
    }
    return timers;
  }

  static bool _isHours(String unit) => RegExp(r"^(h|hours?|hrs?|uur|uren)$", caseSensitive: false).hasMatch(unit);

  static Duration? _durationOf(RegExpMatch match) {
    final amount = RecipeQuantity.value(match.group(2) ?? match.group(1)!);
    if (amount == null || amount <= 0) return null;
    final unit = match.group(3)!.toLowerCase();
    final seconds = _isHours(unit)
        ? amount * 3600
        : unit.startsWith("s")
        ? amount
        : amount * 60;
    return Duration(seconds: seconds.round());
  }
}

abstract final class RecipeWords {
  static const _ignored = {
    "and",
    "the",
    "with",
    "for",
    "fresh",
    "large",
    "small",
    "medium",
    "chopped",
    "sliced",
    "diced",
    "minced",
    "ground",
    "finely",
    "roughly",
    "about",
    "some",
    "optional",
    "taste",
    "van",
    "een",
    "het",
    "met",
    "voor",
    "verse",
    "grote",
    "kleine",
    "gehakte",
    "fijngesneden",
    "naar",
    "smaak",
  };

  static final _word = RegExp(r"[\p{L}]+", unicode: true);

  static Set<String> stemsIn(String text) => {
    for (final word in _word.allMatches(text.toLowerCase())) stem(word.group(0)!),
  };

  static List<String> keywordsOf(String name) {
    final core = name.replaceAll(RegExp(r"\([^)]*\)"), " ").split(RegExp(r"[,;]")).first.toLowerCase();
    return [
      for (final word in _word.allMatches(core))
        if (word.group(0)!.length >= 3 && !_ignored.contains(word.group(0))) stem(word.group(0)!),
    ];
  }

  static String stem(String word) {
    if (word.length <= 3) return word;
    for (final ending in const ["es", "s", "e"]) {
      if (word.endsWith(ending)) return word.substring(0, word.length - ending.length);
    }
    if (word.length > 4 && word.endsWith("en")) return word.substring(0, word.length - 2);
    return word;
  }
}

abstract final class RecipeText {
  static final _image = RegExp(r"!\[[^\]]*\]\([^)]*\)");
  static final _link = RegExp(r"\[([^\]]*)\]\([^)]*\)");
  static final _emphasis = RegExp(r"(\*\*|__)");
  static final _escape = RegExp(r"\\([\\`*_\[\]<#])");

  static String plain(String text) => text
      .replaceAll(_image, "")
      .replaceAllMapped(_link, (match) => match.group(1)!)
      .replaceAll(_emphasis, "")
      .replaceAllMapped(_escape, (match) => match.group(1)!)
      .trim();
}
