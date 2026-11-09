import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:intl/intl.dart";

import "package:polder_calendar/l10n/generated/calendar_localizations.dart";
import "package:polder_calendar/src/rrule/recurrence_rule.dart";
import "package:polder_calendar/src/time/date_math.dart";
import "package:polder_calendar/src/views/calendar_style.dart";
import "package:polder_calendar/src/views/event_presentation.dart";

typedef _MonthlyWeekday = ({int weekday, int position});

enum _Ending { never, on, after }

Future<RecurrenceRule?> showRecurrenceDialog(
  BuildContext context, {
  required RecurrenceRule initial,
  required DateTime start,
}) => showDialog<RecurrenceRule>(
  context: context,
  builder: (context) => RecurrenceDialog(initial: initial, start: start),
);

class RecurrenceDialog extends StatefulWidget {
  const RecurrenceDialog({required this.initial, required this.start, super.key});

  static const defaultCount = 13;

  final RecurrenceRule initial;
  final DateTime start;

  @override
  State<RecurrenceDialog> createState() => _RecurrenceDialogState();
}

class _RecurrenceDialogState extends State<RecurrenceDialog> {
  late var _frequency = widget.initial.frequency;
  late final _interval = TextEditingController(text: "${widget.initial.interval}");
  late var _weekdays = widget.initial.frequency == RecurrenceFrequency.weekly && widget.initial.weekdays.isNotEmpty
      ? {...widget.initial.weekdays}
      : {widget.start.weekday};
  late _MonthlyWeekday? _monthly = _initialMonthly();
  late var _ending = _initialEnding();
  late var _until = widget.initial.until?.dateOnly ?? widget.start.addMonths(3).dateOnly;
  late final _count = TextEditingController(text: "${widget.initial.count ?? RecurrenceDialog.defaultCount}");

  _MonthlyWeekday? _initialMonthly() {
    final rule = widget.initial;
    if (rule.frequency != RecurrenceFrequency.monthly || rule.weekdays.length != 1) return null;
    return (weekday: rule.weekdays.single, position: rule.weekdayPosition ?? 1);
  }

  _Ending _initialEnding() {
    if (widget.initial.until != null) return _Ending.on;
    if (widget.initial.count != null) return _Ending.after;
    return _Ending.never;
  }

  @override
  void initState() {
    super.initState();
    _interval.addListener(_refresh);
    _count.addListener(_refresh);
  }

  @override
  void dispose() {
    _interval.dispose();
    _count.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  int? get _intervalValue => _positive(_interval.text);

  int? get _countValue => _positive(_count.text);

  int? _positive(String text) {
    final value = int.tryParse(text);
    return value != null && value > 0 ? value : null;
  }

  List<_MonthlyWeekday> get _monthlyOptions {
    final start = widget.start;
    final nth = (start.day - 1) ~/ 7 + 1;
    final daysInMonth = DateTime(start.year, start.month + 1, 0).day;
    return {
      if (nth <= 4) (weekday: start.weekday, position: nth),
      if (start.day + 7 > daysInMonth) (weekday: start.weekday, position: -1),
      ?_initialMonthly(),
    }.toList();
  }

  RecurrenceRule? _rule() {
    final interval = _intervalValue;
    if (interval == null) return null;
    if (_ending == _Ending.after && _countValue == null) return null;
    if (_frequency == RecurrenceFrequency.weekly && _weekdays.isEmpty) return null;
    final monthly = _frequency == RecurrenceFrequency.monthly ? _monthly : null;
    return RecurrenceRule(
      _frequency,
      interval: interval,
      weekdays: switch (_frequency) {
        RecurrenceFrequency.weekly => _weekdays,
        _ when monthly != null => {monthly.weekday},
        _ => const {},
      },
      weekdayPosition: monthly?.position,
      monthDay: _frequency == RecurrenceFrequency.monthly && monthly == null ? widget.start.day : null,
      count: _ending == _Ending.after ? _countValue : null,
      until: _ending == _Ending.on ? DateTime(_until.year, _until.month, _until.day, 23, 59, 59) : null,
    );
  }

  void _step(TextEditingController controller, int delta) {
    final next = ((_positive(controller.text) ?? 1) + delta).clamp(1, 999);
    controller.text = "$next";
  }

  void _selectEnding(_Ending ending) => setState(() => _ending = ending);

  void _toggleWeekday(int weekday) => setState(() {
    _weekdays = _weekdays.contains(weekday) ? ({..._weekdays}..remove(weekday)) : {..._weekdays, weekday};
  });

  Future<void> _pickUntil() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _until,
      firstDate: widget.start.dateOnly,
      lastDate: DateTime(2200),
    );
    if (picked != null) setState(() => _until = picked);
  }

  String _unitLabel(CalendarLocalizations strings, RecurrenceFrequency frequency, int count) => switch (frequency) {
    RecurrenceFrequency.daily => strings.unitDays(count),
    RecurrenceFrequency.weekly => strings.unitWeeks(count),
    RecurrenceFrequency.monthly => strings.unitMonths(count),
    RecurrenceFrequency.yearly => strings.unitYears(count),
  };

  @override
  Widget build(BuildContext context) {
    final strings = CalendarLocalizations.of(context);
    final rule = _rule();
    return AlertDialog(
      title: Text(strings.customRepeatTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _intervalRow(strings),
            if (_frequency == RecurrenceFrequency.weekly) ..._weekdaySection(strings),
            if (_frequency == RecurrenceFrequency.monthly) _monthlyField(strings),
            const SizedBox(height: 24),
            _SectionLabel(strings.ends),
            _endingSection(strings),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(strings.cancel)),
        FilledButton(onPressed: rule == null ? null : () => Navigator.of(context).pop(rule), child: Text(strings.done)),
      ],
    );
  }

  Widget _intervalRow(CalendarLocalizations strings) => Wrap(
    spacing: 12,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(strings.repeatEvery),
      _NumberField(controller: _interval, onStep: (delta) => _step(_interval, delta)),
      _Boxed(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<RecurrenceFrequency>(
            value: _frequency,
            onChanged: (frequency) => setState(() => _frequency = frequency ?? _frequency),
            items: [
              for (final frequency in RecurrenceFrequency.values)
                DropdownMenuItem(value: frequency, child: Text(_unitLabel(strings, frequency, _intervalValue ?? 1))),
            ],
          ),
        ),
      ),
    ],
  );

  List<Widget> _weekdaySection(CalendarLocalizations strings) {
    final firstDay = firstDayOfWeek(context);
    final weekdays = [for (var offset = 0; offset < 7; offset++) (firstDay + offset - 1) % 7 + 1];
    return [
      const SizedBox(height: 24),
      _SectionLabel(strings.repeatOn),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final weekday in weekdays)
            _WeekdayToggle(
              date: widget.start.addDays(weekday - widget.start.weekday),
              selected: _weekdays.contains(weekday),
              onTap: () => _toggleWeekday(weekday),
            ),
        ],
      ),
    ];
  }

  Widget _monthlyField(CalendarLocalizations strings) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: _Boxed(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_MonthlyWeekday?>(
          value: _monthly,
          isExpanded: true,
          onChanged: (monthly) => setState(() => _monthly = monthly),
          items: [
            DropdownMenuItem(value: null, child: Text(strings.monthlyOn(strings.monthDay(widget.start.day)))),
            for (final option in _monthlyOptions)
              DropdownMenuItem(
                value: option,
                child: Text(
                  strings.monthlyOn(describeNthWeekday(context, option.position, option.weekday, widget.start)),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _endingSection(CalendarLocalizations strings) => RadioGroup<_Ending>(
    groupValue: _ending,
    onChanged: (ending) => _selectEnding(ending ?? _ending),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EndingRow(value: _Ending.never, label: strings.endsNever, onSelect: _selectEnding),
        _EndingRow(
          value: _Ending.on,
          label: strings.endsOn,
          onSelect: _selectEnding,
          child: _Boxed(
            enabled: _ending == _Ending.on,
            child: TextButton(
              onPressed: _ending == _Ending.on ? _pickUntil : null,
              child: Text(DateFormat.yMMMd(localeTag(context)).format(_until)),
            ),
          ),
        ),
        _EndingRow(
          value: _Ending.after,
          label: strings.endsAfter,
          onSelect: _selectEnding,
          child: Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _NumberField(
                controller: _count,
                enabled: _ending == _Ending.after,
                onStep: (delta) => _step(_count, delta),
              ),
              Text(strings.occurrences(_countValue ?? RecurrenceDialog.defaultCount)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _Boxed extends StatelessWidget {
  const _Boxed({required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    duration: const Duration(milliseconds: 150),
    opacity: enabled ? 1 : 0.5,
    child: Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: AlignmentDirectional.centerStart,
      decoration: ShapeDecoration(
        color: CalendarStyle.of(context).inset,
        shape: CalendarStyle.squircle(CalendarStyle.controlRadius),
      ),
      child: child,
    ),
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.onStep, this.enabled = true});

  final TextEditingController controller;
  final ValueChanged<int> onStep;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _Boxed(
        enabled: enabled,
        child: SizedBox(
          width: 40,
          child: TextField(
            controller: controller,
            enabled: enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
            decoration: const InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
        ),
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.arrow_drop_up, onPressed: enabled ? () => onStep(1) : null),
          _StepButton(icon: Icons.arrow_drop_down, onPressed: enabled ? () => onStep(-1) : null),
        ],
      ),
    ],
  );
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    icon: Icon(icon),
    iconSize: 20,
    padding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
    constraints: const BoxConstraints.tightFor(width: 28, height: 22),
  );
}

class _WeekdayToggle extends StatelessWidget {
  const _WeekdayToggle({required this.date, required this.selected, required this.onTap});

  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = localeTag(context);
    return Tooltip(
      message: DateFormat.EEEE(locale).format(date),
      child: Material(
        color: selected ? scheme.primary : CalendarStyle.of(context).inset,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: 36,
            child: Center(
              child: Text(
                DateFormat.EEEEE(locale).format(date).toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EndingRow extends StatelessWidget {
  const _EndingRow({required this.value, required this.label, required this.onSelect, this.child});

  final _Ending value;
  final String label;
  final ValueChanged<_Ending> onSelect;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Radio<_Ending>(value: value),
        SizedBox(
          width: 64,
          child: GestureDetector(onTap: () => onSelect(value), child: Text(label)),
        ),
        if (child case final child?) Flexible(child: child),
      ],
    ),
  );
}
