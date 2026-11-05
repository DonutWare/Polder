// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'calendar_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CalendarLocalizationsEn extends CalendarLocalizations {
  CalendarLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get viewSchedule => 'Schedule';

  @override
  String get viewDay => 'Day';

  @override
  String get viewThreeDays => '3 days';

  @override
  String get viewWeek => 'Week';

  @override
  String get viewMonth => 'Month';

  @override
  String get today => 'Today';

  @override
  String get previousPeriod => 'Previous';

  @override
  String get nextPeriod => 'Next';

  @override
  String get allDay => 'All day';

  @override
  String get calendars => 'Calendars';

  @override
  String get noEvents => 'No events';

  @override
  String moreEvents(int count) {
    return '$count more';
  }

  @override
  String get untitledEvent => '(No title)';

  @override
  String get busy => 'Busy';

  @override
  String get loadFailed => 'Couldn\'t load events';

  @override
  String get retry => 'Retry';

  @override
  String weekHeader(int week, String range) {
    return 'Week $week, $range';
  }

  @override
  String get nothingPlanned => 'Nothing planned';

  @override
  String get showMonth => 'Show month';

  @override
  String get newEvent => 'New event';

  @override
  String get editEvent => 'Edit event';

  @override
  String get addTitle => 'Add title';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteEventTitle => 'Delete event?';

  @override
  String deleteEventMessage(String title) {
    return '\"$title\" will be removed from the calendar.';
  }

  @override
  String get editRecurringTitle => 'Edit recurring event';

  @override
  String get deleteRecurringTitle => 'Delete recurring event';

  @override
  String get scopeThisEvent => 'This event';

  @override
  String get scopeFollowing => 'This and following events';

  @override
  String get scopeAll => 'All events';

  @override
  String get ok => 'OK';

  @override
  String get addLocation => 'Add location';

  @override
  String get addDescription => 'Add description';

  @override
  String get addNotification => 'Add notification';

  @override
  String get removeNotification => 'Remove notification';

  @override
  String get calendar => 'Calendar';

  @override
  String get color => 'Color';

  @override
  String get repeatNone => 'Does not repeat';

  @override
  String get repeatWeekdays => 'Every weekday (Monday to Friday)';

  @override
  String get repeatCustom => 'Custom';

  @override
  String ruleDaily(int interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'Every $interval days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String ruleWeekly(int interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'Every $interval weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String ruleMonthly(int interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'Every $interval months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String ruleYearly(int interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'Every $interval years',
      one: 'Every year',
    );
    return '$_temp0';
  }

  @override
  String ruleOn(String rule, String when) {
    return '$rule on $when';
  }

  @override
  String monthDay(int day) {
    return 'day $day';
  }

  @override
  String ruleCount(String rule, int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count times', one: 'once');
    return '$rule, $_temp0';
  }

  @override
  String ruleUntil(String rule, String date) {
    return '$rule, until $date';
  }

  @override
  String get reminderAtStart => 'At start of event';

  @override
  String reminderMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes before',
      one: '1 minute before',
    );
    return '$_temp0';
  }

  @override
  String reminderHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours before',
      one: '1 hour before',
    );
    return '$_temp0';
  }

  @override
  String reminderDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count days before', one: '1 day before');
    return '$_temp0';
  }

  @override
  String reminderWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks before',
      one: '1 week before',
    );
    return '$_temp0';
  }

  @override
  String reminderOnDay(String time) {
    return 'On the day at $time';
  }

  @override
  String reminderDaysBefore(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before at $time',
      one: 'The day before at $time',
    );
    return '$_temp0';
  }

  @override
  String reminderAt(String time) {
    return 'At $time';
  }

  @override
  String guests(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count guests', one: '1 guest');
    return '$_temp0';
  }

  @override
  String get organizer => 'Organizer';

  @override
  String get saveFailed => 'Couldn\'t save the event';

  @override
  String get deleteFailed => 'Couldn\'t delete the event';

  @override
  String get noWritableCalendar => 'There\'s no calendar you can add events to';
}
