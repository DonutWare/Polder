class DaySpan<T> {
  const DaySpan(this.item, this.firstDay, this.lastDay);

  final T item;
  final int firstDay;
  final int lastDay;

  int get length => lastDay - firstDay + 1;
}

class PlacedSpan<T> {
  const PlacedSpan({
    required this.item,
    required this.firstColumn,
    required this.lastColumn,
    required this.lane,
    required this.continuesBefore,
    required this.continuesAfter,
  });

  final T item;
  final int firstColumn;
  final int lastColumn;
  final int lane;
  final bool continuesBefore;
  final bool continuesAfter;

  int get length => lastColumn - firstColumn + 1;

  bool covers(int column) => column >= firstColumn && column <= lastColumn;
}

class SpanRow<T> {
  const SpanRow(this.spans, this.columns);

  final List<PlacedSpan<T>> spans;
  final int columns;

  int get laneCount => spans.fold(0, (lanes, span) => span.lane + 1 > lanes ? span.lane + 1 : lanes);

  Iterable<PlacedSpan<T>> visible(int maxLanes) => spans.where((span) => span.lane < maxLanes);

  int hiddenAt(int column, int maxLanes) => spans.where((span) => span.lane >= maxLanes && span.covers(column)).length;
}

SpanRow<T> layoutDaySpans<T>(Iterable<DaySpan<T>> spans, {required int columns, int Function(T a, T b)? tieBreak}) {
  final clipped =
      [
        for (final span in spans)
          if (span.lastDay >= 0 && span.firstDay < columns) span,
      ]..sort((a, b) {
        final byStart = a.firstDay.compareTo(b.firstDay);
        if (byStart != 0) return byStart;
        final byLength = b.length.compareTo(a.length);
        if (byLength != 0) return byLength;
        return tieBreak?.call(a.item, b.item) ?? 0;
      });

  final laneEnds = <int>[];
  final placed = <PlacedSpan<T>>[];
  for (final span in clipped) {
    final first = span.firstDay < 0 ? 0 : span.firstDay;
    final last = span.lastDay >= columns ? columns - 1 : span.lastDay;
    var lane = laneEnds.indexWhere((end) => end < first);
    if (lane == -1) {
      lane = laneEnds.length;
      laneEnds.add(last);
    } else {
      laneEnds[lane] = last;
    }
    placed.add(
      PlacedSpan(
        item: span.item,
        firstColumn: first,
        lastColumn: last,
        lane: lane,
        continuesBefore: span.firstDay < 0,
        continuesAfter: span.lastDay >= columns,
      ),
    );
  }
  return SpanRow(placed, columns);
}
