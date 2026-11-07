import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:intl/intl.dart";

import "package:polder_calendar/l10n/generated/calendar_localizations.dart";
import "package:polder_calendar/src/model/calendar_event.dart";
import "package:polder_calendar/src/model/calendar_info.dart";
import "package:polder_calendar/src/model/calendar_ref.dart";
import "package:polder_calendar/src/model/event_draft.dart";
import "package:polder_calendar/src/rrule/recurrence_rule.dart";
import "package:polder_calendar/src/state/calendar_providers.dart";
import "package:polder_calendar/src/time/date_math.dart";
import "package:polder_calendar/src/views/calendar_style.dart";
import "package:polder_calendar/src/views/event_presentation.dart";

typedef EditedEvent = ({CalendarRef calendar, EventDraft draft});

enum _RepeatChoice { none, custom }

class EventEditor extends StatefulWidget {
  const EventEditor({
    required this.draft,
    required this.calendar,
    required this.calendars,
    this.isNew = false,
    this.canChangeCalendar = true,
    super.key,
  });

  static const timedReminders = [0, -5, -10, -15, -30, -60, -24 * 60];
  static const allDayReminders = [9 * 60, -15 * 60, -(6 * 24 + 15) * 60];

  final EventDraft draft;
  final CalendarRef calendar;
  final List<CalendarInfo> calendars;
  final bool isNew;
  final bool canChangeCalendar;

  @override
  State<EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends State<EventEditor> {
  late final _title = TextEditingController(text: widget.draft.summary);
  late final _location = TextEditingController(text: widget.draft.location);
  late final _description = TextEditingController(text: widget.draft.description);
  late var _allDay = widget.draft.allDay;
  late var _start = widget.draft.start;
  late var _end = widget.draft.end;
  late Object _repeat = _initialRepeat();
  late var _reminders = [...widget.draft.reminders];
  late var _calendar = widget.calendar;
  var _repeatTouched = false;

  Object _initialRepeat() {
    final rule = RecurrenceRule.tryParse(widget.draft.rrule);
    if (rule != null) return RepeatOption.matching(rule, widget.draft.start) ?? _RepeatChoice.custom;
    return (widget.draft.rrule?.trim().isEmpty ?? true) ? _RepeatChoice.none : _RepeatChoice.custom;
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _rrule() => switch (_repeat) {
    _ when !_repeatTouched => widget.draft.rrule,
    final RepeatOption option => option.ruleFor(_start).encode(),
    _RepeatChoice.custom => widget.draft.rrule,
    _ => null,
  };

  String? _text(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  void _save() => Navigator.of(context).pop<EditedEvent>((
    calendar: _calendar,
    draft: widget.draft.copyWith(
      summary: _title.text.trim(),
      allDay: _allDay,
      start: _start,
      end: _end,
      rrule: _rrule(),
      location: _text(_location),
      description: _text(_description),
      reminders: _reminders,
    ),
  ));

  void _setStart(DateTime start) => setState(() {
    _end = _allDay ? _end.addDays(daysBetween(_start, start)) : start.add(_end.difference(_start));
    _start = start;
  });

  void _setEnd(DateTime end) => setState(() {
    _end = end;
    if (!_end.isAfter(_start)) _start = _allDay ? _end.addDays(-1) : _end.subtract(const Duration(hours: 1));
  });

  void _setAllDay(bool allDay) => setState(() {
    _allDay = allDay;
    if (allDay) {
      _start = _start.dateOnly;
      _end = _end == _end.dateOnly ? _end : _end.dateOnly.nextDay;
      if (!_end.isAfter(_start)) _end = _start.nextDay;
    } else {
      _start = DateTime(_start.year, _start.month, _start.day, 9);
      _end = _start.add(const Duration(hours: 1));
    }
  });

  Future<void> _pickDate(DateTime initial, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickTime(DateTime initial, ValueChanged<DateTime> onPicked) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (picked != null) onPicked(DateTime(initial.year, initial.month, initial.day, picked.hour, picked.minute));
  }

  DateTime _withDate(DateTime time, DateTime date) => DateTime(date.year, date.month, date.day, time.hour, time.minute);

  Future<void> _pickRepeat() async {
    final strings = CalendarLocalizations.of(context);
    final choices = <Object>[
      _RepeatChoice.none,
      ...RepeatOption.values,
      if (_initialRepeat() == _RepeatChoice.custom) _RepeatChoice.custom,
    ];
    final picked = await showDialog<Object>(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          RadioGroup<Object>(
            groupValue: _repeat,
            onChanged: (value) => Navigator.of(context).pop(value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final choice in choices)
                  RadioListTile<Object>(value: choice, title: Text(_repeatLabel(choice, strings))),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked == null || picked == _repeat) return;
    setState(() {
      _repeat = picked;
      _repeatTouched = true;
    });
  }

  String _repeatLabel(Object choice, CalendarLocalizations strings) => switch (choice) {
    final RepeatOption option => describeRepeat(context, option.ruleFor(_start).encode(), _start),
    _RepeatChoice.custom => describeRepeat(context, widget.draft.rrule, _start),
    _ => strings.repeatNone,
  };

  Future<void> _addReminder() async {
    final presets = [
      for (final offset in _allDay ? EventEditor.allDayReminders : EventEditor.timedReminders)
        if (!_reminders.any((reminder) => reminder.at == null && reminder.offsetMinutes == offset))
          EventReminder(offsetMinutes: offset),
    ];
    final picked = await showDialog<EventReminder>(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          for (final preset in presets)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(preset),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(describeReminder(context, preset, allDay: _allDay)),
              ),
            ),
        ],
      ),
    );
    if (picked != null) setState(() => _reminders = [..._reminders, picked]);
  }

  @override
  Widget build(BuildContext context) {
    final strings = CalendarLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = localeTag(context);
    final dateFormat = DateFormat.yMMMEd(locale);
    final calendarColor = widget.calendars.where((calendar) => calendar.ref == _calendar).firstOrNull?.color;
    final shownEnd = _allDay ? _end.addDays(-1) : _end;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: strings.close,
          icon: const Icon(IconsaxPlusLinear.close_circle),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.isNew ? strings.newEvent : strings.editEvent),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FilledButton(onPressed: _save, child: Text(strings.save)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Section(
            children: [
              _FieldRow(
                leading: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 18,
                  height: 18,
                  decoration: ShapeDecoration(
                    color: calendarColor ?? theme.colorScheme.primary,
                    shape: CalendarStyle.squircle(6),
                  ),
                ),
                child: TextField(
                  controller: _title,
                  autofocus: widget.isNew,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.headlineSmall,
                  decoration: _plain(strings.addTitle),
                  onSubmitted: (_) => _save(),
                ),
              ),
            ],
          ),
          _Section(
            children: [
              SwitchListTile(
                secondary: const Icon(IconsaxPlusLinear.clock),
                title: Text(strings.allDay),
                value: _allDay,
                onChanged: _setAllDay,
              ),
              _DateTimeRow(
                date: dateFormat.format(_start),
                time: _allDay ? null : formatTime(context, _start),
                onDate: () => _pickDate(_start, (date) => _setStart(_withDate(_start, date))),
                onTime: () => _pickTime(_start, _setStart),
              ),
              _DateTimeRow(
                date: dateFormat.format(shownEnd),
                time: _allDay ? null : formatTime(context, _end),
                onDate: () =>
                    _pickDate(shownEnd, (date) => _setEnd(_allDay ? date.dateOnly.nextDay : _withDate(_end, date))),
                onTime: () => _pickTime(_end, _setEnd),
              ),
              ListTile(
                leading: const Icon(IconsaxPlusLinear.repeat),
                title: Text(_repeatLabel(_repeat, strings)),
                trailing: const Icon(IconsaxPlusLinear.arrow_down, size: 18),
                onTap: _pickRepeat,
              ),
            ],
          ),
          _Section(
            children: [
              _FieldRow(
                leading: const Icon(IconsaxPlusLinear.location),
                child: TextField(controller: _location, decoration: _plain(strings.addLocation)),
              ),
              _FieldRow(
                leading: const Icon(IconsaxPlusLinear.note_text),
                child: TextField(
                  controller: _description,
                  minLines: 1,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _plain(strings.addDescription),
                ),
              ),
            ],
          ),
          if (_reminders.isNotEmpty)
            Consumer(
              builder: (context, ref, _) => switch (ref.watch(calendarReminderNoticeProvider)) {
                final notice? => Padding(padding: const EdgeInsets.only(bottom: 10), child: notice),
                null => const SizedBox.shrink(),
              },
            ),
          _Section(
            children: [
              for (final (index, reminder) in _reminders.indexed)
                ListTile(
                  key: ObjectKey(reminder),
                  leading: Icon(IconsaxPlusLinear.notification, color: index == 0 ? null : Colors.transparent),
                  title: Text(describeReminder(context, reminder, allDay: _allDay)),
                  trailing: IconButton(
                    tooltip: strings.removeNotification,
                    icon: const Icon(IconsaxPlusLinear.close_circle),
                    onPressed: () => setState(() => _reminders = [..._reminders]..removeAt(index)),
                  ),
                ),
              ListTile(
                leading: Icon(_reminders.isEmpty ? IconsaxPlusLinear.notification : IconsaxPlusLinear.add),
                title: Text(strings.addNotification),
                onTap: _addReminder,
              ),
            ],
          ),
          if (widget.canChangeCalendar &&
              widget.calendars.length > 1 &&
              widget.calendars.any((calendar) => calendar.ref == _calendar))
            _Section(
              children: [
                _FieldRow(
                  leading: const Icon(IconsaxPlusLinear.calendar_1),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CalendarRef>(
                      value: _calendar,
                      isExpanded: true,
                      onChanged: (calendar) => setState(() => _calendar = calendar ?? _calendar),
                      items: [
                        for (final calendar in widget.calendars)
                          DropdownMenuItem(
                            value: calendar.ref,
                            child: Row(
                              spacing: 12,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: calendar.color ?? theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Flexible(child: Text(calendar.name, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  InputDecoration _plain(String hint) => InputDecoration(
    contentPadding: const EdgeInsets.symmetric(vertical: 14),
    hintText: hint,
    filled: false,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: CalendarStyle.of(context).panel,
      shape: CalendarStyle.squircle(CalendarStyle.insetRadius + 4),
      clipBehavior: Clip.antiAlias,
      child: ListTileTheme.merge(
        shape: const RoundedRectangleBorder(),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    ),
  );
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({required this.date, required this.onDate, this.time, this.onTime});

  final String date;
  final String? time;
  final VoidCallback onDate;
  final VoidCallback? onTime;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 44, end: 8),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: onDate,
                child: Text(date, style: style),
              ),
            ),
          ),
          if (time != null)
            TextButton(
              onPressed: onTime,
              child: Text(time!, style: style),
            ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.leading, required this.child});

  final Widget leading;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 16),
    child: Row(
      children: [
        SizedBox(
          width: 56,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: IconTheme.merge(
                data: IconThemeData(color: Theme.of(context).colorScheme.onSurfaceVariant),
                child: SizedBox(width: 24, child: Center(child: leading)),
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );
}
