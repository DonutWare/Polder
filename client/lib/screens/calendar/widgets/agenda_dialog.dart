import "package:flutter/material.dart";

import "package:polder/screens/calendar/widgets/calendar_panel.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder_calendar/polder_calendar.dart";

typedef AgendaDetails = ({String name, Color color});

Color unusedCalendarColor(List<CalendarInfo> calendars) {
  final used = {for (final calendar in calendars) calendar.color?.toARGB32()};
  return CalendarColorPicker.palette.where((color) => !used.contains(color.toARGB32())).firstOrNull ??
      CalendarColorPicker.palette[calendars.length % CalendarColorPicker.palette.length];
}

Future<AgendaDetails?> showAgendaDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required Color color,
  String name = "",
}) => showCalendarPanel<AgendaDetails>(
  context,
  initialSize: 0.6,
  builder: (context, controller) =>
      _AgendaForm(title: title, confirmLabel: confirmLabel, name: name, color: color, controller: controller),
);

class _AgendaForm extends StatefulWidget {
  const _AgendaForm({
    required this.title,
    required this.confirmLabel,
    required this.name,
    required this.color,
    this.controller,
  });

  final String title;
  final String confirmLabel;
  final String name;
  final Color color;
  final ScrollController? controller;

  @override
  State<_AgendaForm> createState() => _AgendaFormState();
}

class _AgendaFormState extends State<_AgendaForm> {
  late final _name = TextEditingController(text: widget.name);
  late var _color = widget.color;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty;

  void _save() {
    if (_valid) Navigator.pop<AgendaDetails>(context, (name: _name.text.trim(), color: _color));
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return CalendarPanelBody(
      title: widget.title,
      controller: widget.controller,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(localized.cancel)),
        FilledButton(onPressed: _valid ? _save : null, child: Text(widget.confirmLabel)),
      ],
      children: [
        TextField(
          controller: _name,
          autofocus: widget.name.isEmpty,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: localized.calendarName),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _save(),
        ),
        CalendarFieldLabel(localized.calendarColorLabel),
        CalendarColorPicker(selected: _color, onChanged: (color) => setState(() => _color = color)),
      ],
    );
  }
}
