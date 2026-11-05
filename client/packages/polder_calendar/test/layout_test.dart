import "package:flutter_test/flutter_test.dart";

import "package:polder_calendar/polder_calendar.dart";

void main() {
  group("timed slots", () {
    PlacedSlot<String> slot(List<PlacedSlot<String>> placed, String id) => placed.firstWhere((p) => p.item == id);

    test("separate events take the full width", () {
      final placed = layoutTimedSlots([const TimedSlot("a", 60, 120), const TimedSlot("b", 120, 180)]);
      expect(placed.map((p) => (p.column, p.columns, p.span)), [(0, 1, 1), (0, 1, 1)]);
    });

    test("overlapping events share columns", () {
      final placed = layoutTimedSlots([
        const TimedSlot("a", 540, 660),
        const TimedSlot("b", 570, 600),
        const TimedSlot("c", 600, 630),
      ]);
      expect(slot(placed, "a").column, 0);
      expect(slot(placed, "b").column, 1);
      expect(slot(placed, "c").column, 1);
      expect(placed.every((p) => p.columns == 2), isTrue);
    });

    test("events expand into free columns to their right", () {
      final placed = layoutTimedSlots([
        const TimedSlot("a", 540, 600),
        const TimedSlot("b", 540, 570),
        const TimedSlot("c", 540, 570),
        const TimedSlot("d", 575, 660),
      ]);
      expect(slot(placed, "a").columns, 3);
      expect(slot(placed, "d").column, 1);
      expect(slot(placed, "d").span, 2);
      expect(slot(placed, "b").span, 1);
    });

    test("short events are treated as the minimum height for overlap", () {
      final placed = layoutTimedSlots([const TimedSlot("a", 600, 605), const TimedSlot("b", 610, 640)]);
      expect(slot(placed, "b").column, 1);
    });
  });

  group("day spans", () {
    test("longer spans get the lower lanes", () {
      final row = layoutDaySpans([
        const DaySpan("short", 1, 1),
        const DaySpan("long", 1, 4),
        const DaySpan("later", 2, 2),
      ], columns: 7);
      final lanes = {for (final span in row.spans) span.item: span.lane};
      expect(lanes, {"long": 0, "short": 1, "later": 1});
      expect(row.laneCount, 2);
    });

    test("spans are clipped to the row and marked as continuing", () {
      final row = layoutDaySpans([const DaySpan("trip", -2, 9)], columns: 7);
      final span = row.spans.single;
      expect((span.firstColumn, span.lastColumn), (0, 6));
      expect((span.continuesBefore, span.continuesAfter), (true, true));
    });

    test("hidden counts only spans beyond the visible lanes", () {
      final row = layoutDaySpans([for (var index = 0; index < 4; index++) DaySpan("event$index", 3, 3)], columns: 7);
      expect(row.visible(2).length, 2);
      expect(row.hiddenAt(3, 2), 2);
      expect(row.hiddenAt(4, 2), 0);
    });
  });
}
