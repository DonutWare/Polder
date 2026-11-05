// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'calendar_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class CalendarLocalizationsNl extends CalendarLocalizations {
  CalendarLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get viewSchedule => 'Planning';

  @override
  String get viewDay => 'Dag';

  @override
  String get viewThreeDays => '3 dagen';

  @override
  String get viewWeek => 'Week';

  @override
  String get viewMonth => 'Maand';

  @override
  String get today => 'Vandaag';

  @override
  String get previousPeriod => 'Vorige';

  @override
  String get nextPeriod => 'Volgende';

  @override
  String get allDay => 'Hele dag';

  @override
  String get calendars => 'Agenda\'s';

  @override
  String get noEvents => 'Geen afspraken';

  @override
  String moreEvents(int count) {
    return 'Nog $count';
  }

  @override
  String get untitledEvent => '(Geen titel)';

  @override
  String get busy => 'Bezet';

  @override
  String get loadFailed => 'Afspraken laden mislukt';

  @override
  String get retry => 'Opnieuw';

  @override
  String weekHeader(int week, String range) {
    return 'Week $week, $range';
  }

  @override
  String get nothingPlanned => 'Niets gepland';

  @override
  String get showMonth => 'Maand tonen';

  @override
  String get newEvent => 'Nieuwe afspraak';

  @override
  String get editEvent => 'Afspraak bewerken';

  @override
  String get addTitle => 'Titel toevoegen';

  @override
  String get save => 'Opslaan';

  @override
  String get cancel => 'Annuleren';

  @override
  String get close => 'Sluiten';

  @override
  String get edit => 'Bewerken';

  @override
  String get delete => 'Verwijderen';

  @override
  String get deleteEventTitle => 'Afspraak verwijderen?';

  @override
  String deleteEventMessage(String title) {
    return '\"$title\" wordt uit de agenda verwijderd.';
  }

  @override
  String get editRecurringTitle => 'Terugkerende afspraak bewerken';

  @override
  String get deleteRecurringTitle => 'Terugkerende afspraak verwijderen';

  @override
  String get scopeThisEvent => 'Deze afspraak';

  @override
  String get scopeFollowing => 'Deze en volgende afspraken';

  @override
  String get scopeAll => 'Alle afspraken';

  @override
  String get ok => 'OK';

  @override
  String get addLocation => 'Locatie toevoegen';

  @override
  String get addDescription => 'Beschrijving toevoegen';

  @override
  String get addNotification => 'Melding toevoegen';

  @override
  String get removeNotification => 'Melding verwijderen';

  @override
  String get calendar => 'Agenda';

  @override
  String get color => 'Kleur';

  @override
  String get repeatNone => 'Herhaalt niet';

  @override
  String get repeatWeekdays => 'Elke werkdag (maandag t/m vrijdag)';

  @override
  String get repeatCustom => 'Aangepast';

  @override
  String ruleDaily(int interval) {
    String _temp0 = intl.Intl.pluralLogic(interval, locale: localeName, other: 'Elke $interval dagen', one: 'Elke dag');
    return '$_temp0';
  }

  @override
  String ruleWeekly(int interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'Elke $interval weken',
      one: 'Elke week',
    );
    return '$_temp0';
  }

  @override
  String ruleMonthly(int interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'Elke $interval maanden',
      one: 'Elke maand',
    );
    return '$_temp0';
  }

  @override
  String ruleYearly(int interval) {
    String _temp0 = intl.Intl.pluralLogic(interval, locale: localeName, other: 'Elke $interval jaar', one: 'Elk jaar');
    return '$_temp0';
  }

  @override
  String ruleOn(String rule, String when) {
    return '$rule op $when';
  }

  @override
  String monthDay(int day) {
    return 'dag $day';
  }

  @override
  String ruleCount(String rule, int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count keer', one: 'één keer');
    return '$rule, $_temp0';
  }

  @override
  String ruleUntil(String rule, String date) {
    return '$rule, tot $date';
  }

  @override
  String get reminderAtStart => 'Bij aanvang';

  @override
  String reminderMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuten van tevoren',
      one: '1 minuut van tevoren',
    );
    return '$_temp0';
  }

  @override
  String reminderHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uur van tevoren',
      one: '1 uur van tevoren',
    );
    return '$_temp0';
  }

  @override
  String reminderDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen van tevoren',
      one: '1 dag van tevoren',
    );
    return '$_temp0';
  }

  @override
  String reminderWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weken van tevoren',
      one: '1 week van tevoren',
    );
    return '$_temp0';
  }

  @override
  String reminderOnDay(String time) {
    return 'Op de dag om $time';
  }

  @override
  String reminderDaysBefore(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen ervoor om $time',
      one: 'De dag ervoor om $time',
    );
    return '$_temp0';
  }

  @override
  String reminderAt(String time) {
    return 'Om $time';
  }

  @override
  String guests(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count gasten', one: '1 gast');
    return '$_temp0';
  }

  @override
  String get organizer => 'Organisator';

  @override
  String get saveFailed => 'Kon de afspraak niet opslaan';

  @override
  String get deleteFailed => 'Kon de afspraak niet verwijderen';

  @override
  String get noWritableCalendar => 'Er is geen agenda waaraan je afspraken kunt toevoegen';
}
