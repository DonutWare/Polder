import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/models/search.dart";

extension SearchKeyLabel on SearchKey {
  String label(AppLocalizations l) => switch (this) {
    SearchKey.type || SearchKey.ext => l.searchFieldType,
    SearchKey.folder => l.searchFieldFolder,
    SearchKey.modified => l.searchFieldModified,
    SearchKey.size => l.searchFieldSize,
  };
}

String searchOpLabel(AppLocalizations l, SearchKey key, SearchOp op) {
  final isSize = key == SearchKey.size;
  return switch (op) {
    SearchOp.equals => key == SearchKey.modified ? l.searchOpOn : l.searchOpIs,
    SearchOp.notEquals => l.searchOpIsNot,
    SearchOp.greater => isSize ? l.searchOpLarger : l.searchOpAfter,
    SearchOp.greaterOrEqual => isSize ? l.searchOpAtLeast : l.searchOpFrom,
    SearchOp.less => isSize ? l.searchOpSmaller : l.searchOpBefore,
    SearchOp.lessOrEqual => isSize ? l.searchOpAtMost : l.searchOpUntil,
    SearchOp.between => l.searchOpBetween,
  };
}

final _relative = RegExp(r"^(\d+)([dwmy])$");

String searchValueLabel(AppLocalizations l, SearchKey key, String value) {
  if (key != SearchKey.modified) return value;
  if (value == "today") return l.searchPresetToday;
  if (value == "yesterday") return l.searchPresetYesterday;
  final match = _relative.firstMatch(value);
  if (match == null) return value;
  final count = int.parse(match.group(1)!);
  return switch (match.group(2)) {
    "d" => l.searchDaysAgo(count),
    "w" => l.searchWeeksAgo(count),
    "m" => l.searchMonthsAgo(count),
    _ => l.searchYearsAgo(count),
  };
}
