import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'calendar_localizations_en.dart';
import 'calendar_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CalendarLocalizations
/// returned by `CalendarLocalizations.of(context)`.
///
/// Applications need to include `CalendarLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/calendar_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CalendarLocalizations.localizationsDelegates,
///   supportedLocales: CalendarLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the CalendarLocalizations.supportedLocales
/// property.
abstract class CalendarLocalizations {
  CalendarLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CalendarLocalizations of(BuildContext context) {
    return Localizations.of<CalendarLocalizations>(context, CalendarLocalizations)!;
  }

  static const LocalizationsDelegate<CalendarLocalizations> delegate = _CalendarLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('nl')];

  /// No description provided for @viewSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get viewSchedule;

  /// No description provided for @viewDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get viewDay;

  /// No description provided for @viewThreeDays.
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get viewThreeDays;

  /// No description provided for @viewWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get viewWeek;

  /// No description provided for @viewMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get viewMonth;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @previousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousPeriod;

  /// No description provided for @nextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextPeriod;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// No description provided for @calendars.
  ///
  /// In en, this message translates to:
  /// **'Calendars'**
  String get calendars;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get noEvents;

  /// No description provided for @moreEvents.
  ///
  /// In en, this message translates to:
  /// **'{count} more'**
  String moreEvents(int count);

  /// No description provided for @untitledEvent.
  ///
  /// In en, this message translates to:
  /// **'(No title)'**
  String get untitledEvent;

  /// No description provided for @busy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load events'**
  String get loadFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @weekHeader.
  ///
  /// In en, this message translates to:
  /// **'Week {week}, {range}'**
  String weekHeader(int week, String range);

  /// No description provided for @nothingPlanned.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned'**
  String get nothingPlanned;

  /// No description provided for @showMonth.
  ///
  /// In en, this message translates to:
  /// **'Show month'**
  String get showMonth;

  /// No description provided for @newEvent.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get newEvent;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEvent;

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add title'**
  String get addTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete event?'**
  String get deleteEventTitle;

  /// No description provided for @deleteEventMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed from the calendar.'**
  String deleteEventMessage(String title);

  /// No description provided for @editRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring event'**
  String get editRecurringTitle;

  /// No description provided for @deleteRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recurring event'**
  String get deleteRecurringTitle;

  /// No description provided for @scopeThisEvent.
  ///
  /// In en, this message translates to:
  /// **'This event'**
  String get scopeThisEvent;

  /// No description provided for @scopeFollowing.
  ///
  /// In en, this message translates to:
  /// **'This and following events'**
  String get scopeFollowing;

  /// No description provided for @scopeAll.
  ///
  /// In en, this message translates to:
  /// **'All events'**
  String get scopeAll;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @addLocation.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get addLocation;

  /// No description provided for @addDescription.
  ///
  /// In en, this message translates to:
  /// **'Add description'**
  String get addDescription;

  /// No description provided for @addNotification.
  ///
  /// In en, this message translates to:
  /// **'Add notification'**
  String get addNotification;

  /// No description provided for @removeNotification.
  ///
  /// In en, this message translates to:
  /// **'Remove notification'**
  String get removeNotification;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @calendarColor.
  ///
  /// In en, this message translates to:
  /// **'Calendar color'**
  String get calendarColor;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get repeatNone;

  /// No description provided for @repeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Every weekday (Monday to Friday)'**
  String get repeatWeekdays;

  /// No description provided for @repeatCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get repeatCustom;

  /// No description provided for @ruleDaily.
  ///
  /// In en, this message translates to:
  /// **'{interval, plural, =1{Every day} other{Every {interval} days}}'**
  String ruleDaily(int interval);

  /// No description provided for @ruleWeekly.
  ///
  /// In en, this message translates to:
  /// **'{interval, plural, =1{Every week} other{Every {interval} weeks}}'**
  String ruleWeekly(int interval);

  /// No description provided for @ruleMonthly.
  ///
  /// In en, this message translates to:
  /// **'{interval, plural, =1{Every month} other{Every {interval} months}}'**
  String ruleMonthly(int interval);

  /// No description provided for @ruleYearly.
  ///
  /// In en, this message translates to:
  /// **'{interval, plural, =1{Every year} other{Every {interval} years}}'**
  String ruleYearly(int interval);

  /// No description provided for @ruleOn.
  ///
  /// In en, this message translates to:
  /// **'{rule} on {when}'**
  String ruleOn(String rule, String when);

  /// No description provided for @monthDay.
  ///
  /// In en, this message translates to:
  /// **'day {day}'**
  String monthDay(int day);

  /// No description provided for @ruleCount.
  ///
  /// In en, this message translates to:
  /// **'{rule}, {count, plural, =1{once} other{{count} times}}'**
  String ruleCount(String rule, int count);

  /// No description provided for @ruleUntil.
  ///
  /// In en, this message translates to:
  /// **'{rule}, until {date}'**
  String ruleUntil(String rule, String date);

  /// No description provided for @reminderAtStart.
  ///
  /// In en, this message translates to:
  /// **'At start of event'**
  String get reminderAtStart;

  /// No description provided for @reminderMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute before} other{{count} minutes before}}'**
  String reminderMinutes(int count);

  /// No description provided for @reminderHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour before} other{{count} hours before}}'**
  String reminderHours(int count);

  /// No description provided for @reminderDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day before} other{{count} days before}}'**
  String reminderDays(int count);

  /// No description provided for @reminderWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week before} other{{count} weeks before}}'**
  String reminderWeeks(int count);

  /// No description provided for @reminderOnDay.
  ///
  /// In en, this message translates to:
  /// **'On the day at {time}'**
  String reminderOnDay(String time);

  /// No description provided for @reminderDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The day before at {time}} other{{count} days before at {time}}}'**
  String reminderDaysBefore(int count, String time);

  /// No description provided for @reminderAt.
  ///
  /// In en, this message translates to:
  /// **'At {time}'**
  String reminderAt(String time);

  /// No description provided for @guests.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 guest} other{{count} guests}}'**
  String guests(int count);

  /// No description provided for @organizer.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get organizer;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the event'**
  String get saveFailed;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the event'**
  String get deleteFailed;

  /// No description provided for @noWritableCalendar.
  ///
  /// In en, this message translates to:
  /// **'There\'s no calendar you can add events to'**
  String get noWritableCalendar;
}

class _CalendarLocalizationsDelegate extends LocalizationsDelegate<CalendarLocalizations> {
  const _CalendarLocalizationsDelegate();

  @override
  Future<CalendarLocalizations> load(Locale locale) {
    return SynchronousFuture<CalendarLocalizations>(lookupCalendarLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_CalendarLocalizationsDelegate old) => false;
}

CalendarLocalizations lookupCalendarLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return CalendarLocalizationsEn();
    case 'nl':
      return CalendarLocalizationsNl();
  }

  throw FlutterError(
    'CalendarLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
