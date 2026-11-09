import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder_calendar/polder_calendar.dart";
import "package:polder_calendar/src/views/recurrence_dialog.dart";

final _wednesday = DateTime(2026, 11, 25, 10);

class _Harness {
  RecurrenceRule? result;

  Future<void> open(WidgetTester tester, RecurrenceRule initial, {Locale locale = const Locale("en")}) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [CalendarLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: CalendarLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showRecurrenceDialog(context, initial: initial, start: _wednesday),
            child: const Text("open"),
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets("builds a weekly rule with extra days and a count", (tester) async {
    final harness = _Harness();
    await harness.open(tester, RepeatOption.weekly.ruleFor(_wednesday));
    await tester.enterText(find.byType(TextField).first, "2");
    await harness.tapVisible(tester, find.byTooltip("Friday"));
    await harness.tapVisible(tester, find.text("After"));
    await harness.tapVisible(tester, find.text("Done"));
    expect(harness.result?.encode(), "FREQ=WEEKLY;INTERVAL=2;BYDAY=WE,FR;COUNT=13");
  });

  testWidgets("disables done when no weekday is selected", (tester) async {
    final harness = _Harness();
    await harness.open(tester, RepeatOption.weekly.ruleFor(_wednesday));
    await harness.tapVisible(tester, find.byTooltip("Wednesday"));
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, "Done")).onPressed, isNull);
  });

  testWidgets("offers ordinal weekdays for monthly rules in Dutch", (tester) async {
    final harness = _Harness();
    await harness.open(
      tester,
      const RecurrenceRule(RecurrenceFrequency.monthly, monthDay: 25),
      locale: const Locale("nl"),
    );
    await harness.tapVisible(tester, find.text("Maandelijks op dag 25"));
    expect(find.text("Maandelijks op de vierde woensdag"), findsWidgets);
    await tester.tap(find.text("Maandelijks op de laatste woensdag").last);
    await tester.pumpAndSettle();
    await harness.tapVisible(tester, find.text("Klaar"));
    expect(harness.result?.encode(), "FREQ=MONTHLY;BYDAY=-1WE");
  });
}
