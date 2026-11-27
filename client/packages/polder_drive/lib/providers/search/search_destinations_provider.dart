import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_ui/l10n/generated/app_localizations.dart";
import "package:polder_ui/util/fuzzy_match.dart";

@immutable
class SearchDestination {
  const SearchDestination({required this.route, required this.icon, required this.label, required this.keywords});

  final String route;
  final IconData icon;
  final String Function(AppLocalizations) label;

  final String Function(AppLocalizations) keywords;
}

@immutable
class DestinationMatch {
  const DestinationMatch({required this.destination, required this.label, required this.match});

  final SearchDestination destination;
  final String label;

  final FuzzyMatch match;
}

final searchDestinationsProvider = Provider<List<SearchDestination>>((_) => const []);

List<DestinationMatch> matchDestinations(List<SearchDestination> destinations, AppLocalizations l, String query) {
  final matches = <DestinationMatch>[];
  for (final destination in destinations) {
    final label = destination.label(l);
    final byLabel = fuzzyMatch(query, label);
    final byKeyword = destination
        .keywords(l)
        .split(",")
        .map((keyword) => fuzzyMatch(query, keyword.trim()))
        .whereType<FuzzyMatch>()
        .fold<FuzzyMatch?>(null, (best, match) => best == null || match.score > best.score ? match : best);
    final match = switch ((byLabel, byKeyword)) {
      (final label?, final keyword?) when keyword.score > label.score + 20 => FuzzyMatch(keyword.score - 10, const []),
      (final label?, _) => label,
      (null, final keyword?) => FuzzyMatch(keyword.score - 10, const []),
      _ => null,
    };
    if (match != null) matches.add(DestinationMatch(destination: destination, label: label, match: match));
  }
  return matches..sort((a, b) => b.match.score.compareTo(a.match.score));
}
