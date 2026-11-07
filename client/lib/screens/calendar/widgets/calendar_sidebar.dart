import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/calendar.dart";
import "package:polder/providers/calendar/calendar_providers.dart";
import "package:polder/screens/calendar/widgets/agenda_dialog.dart";
import "package:polder/screens/calendar/widgets/agenda_share_sheet.dart";
import "package:polder/screens/calendar/widgets/calendar_files.dart";
import "package:polder/screens/calendar/widgets/external_calendar_dialog.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/icon_badge.dart";
import "package:polder/widgets/shared/icon_menu_item.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder_calendar/polder_calendar.dart";

class CalendarSidebar extends StatelessWidget {
  const CalendarSidebar({
    required this.anchor,
    required this.onSelectDay,
    this.controller,
    this.padding = const EdgeInsets.only(top: 12, bottom: 24),
    super.key,
  });

  final DateTime anchor;
  final ValueChanged<DateTime> onSelectDay;
  final ScrollController? controller;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => ListView(
    controller: controller,
    padding: padding,
    children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: MiniMonth(selected: anchor, onSelect: onSelectDay),
        ),
      ),
      const CalendarAgendaLists(),
    ],
  );
}

class CalendarAgendaLists extends ConsumerWidget {
  const CalendarAgendaLists({super.key});

  static const _agendas = "agendas";
  static const _imported = "imported";

  Future<void> _create(BuildContext context, WidgetRef ref, List<CalendarInfo> calendars) async {
    final localized = context.localized;
    final details = await showAgendaDialog(
      context,
      title: localized.calendarNew,
      confirmLabel: localized.create,
      color: unusedCalendarColor(calendars),
    );
    if (details == null || !context.mounted) return;
    await context.runWithFeedback(ref.read(calendarAgendasProvider).create(name: details.name, color: details.color));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final calendars = ref.watch(calendarListProvider).value ?? const <CalendarInfo>[];
    final collapsed = ref.watch(calendarSidebarSectionsProvider);
    final sections = ref.read(calendarSidebarSectionsProvider.notifier);
    final agendas = calendars.where((calendar) => !calendar.subscription).toList();
    final imported = calendars.where((calendar) => calendar.subscription).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NavGroup(
          title: localized.calendars,
          collapsed: collapsed.contains(_agendas),
          onToggle: () => sections.toggle(_agendas),
          trailing: IconButton(
            tooltip: localized.calendarNew,
            visualDensity: VisualDensity.compact,
            icon: const Icon(IconsaxPlusLinear.add),
            onPressed: () => _create(context, ref, calendars),
          ),
          children: [for (final calendar in agendas) _AgendaTile(calendar: calendar)],
        ),
        NavGroup(
          title: localized.calendarImported,
          collapsed: collapsed.contains(_imported),
          onToggle: () => sections.toggle(_imported),
          trailing: IconButton(
            tooltip: localized.calendarAddExternal,
            visualDensity: VisualDensity.compact,
            icon: const Icon(IconsaxPlusLinear.add),
            onPressed: () => showExternalCalendarDialog(context, calendars),
          ),
          children: [
            for (final calendar in imported) _AgendaTile(calendar: calendar),
            if (imported.isEmpty)
              ListTile(
                leading: const IconBadge(icon: IconsaxPlusLinear.import_1, size: 32),
                title: Text(localized.calendarAddExternal),
                subtitle: Text(localized.calendarNoImported),
                onTap: () => showExternalCalendarDialog(context, calendars),
              ),
          ],
        ),
      ],
    );
  }
}

enum _AgendaAction { edit, share, importFile, reminders, makeDefault, sync, remove }

class _AgendaTile extends ConsumerStatefulWidget {
  const _AgendaTile({required this.calendar});

  final CalendarInfo calendar;

  @override
  ConsumerState<_AgendaTile> createState() => _AgendaTileState();
}

class _AgendaTileState extends ConsumerState<_AgendaTile> {
  final _menu = GlobalKey<PopupMenuButtonState<_AgendaAction>>();

  CalendarInfo get calendar => widget.calendar;

  CalendarAgendas get _agendas => ref.read(calendarAgendasProvider);

  String? _subtitle(BuildContext context) {
    final localized = context.localized;
    if (calendar.subscription) {
      if (calendar.fetchError != null) return localized.calendarSyncFailed(calendar.fetchError!);
      if (calendar.fetchedAt == null) return localized.calendarSyncPending;
      return localized.calendarSyncedAt(calendar.fetchedAt!.formatted(context));
    }
    if (calendar.shared) return localized.calendarSharedBy(calendar.ownerName!);
    if (calendar.isDefault) return localized.calendarDefault;
    return null;
  }

  List<PopupMenuEntry<_AgendaAction>> _items(BuildContext context) {
    final localized = context.localized;
    final error = Theme.of(context).colorScheme.error;
    return [
      iconMenuItem(_AgendaAction.edit, IconsaxPlusLinear.edit_2, localized.edit),
      if (!calendar.shared) iconMenuItem(_AgendaAction.share, IconsaxPlusLinear.people, localized.share),
      if (calendar.writable)
        iconMenuItem(_AgendaAction.importFile, IconsaxPlusLinear.document_upload, localized.calendarImportInto),
      iconMenuItem(
        _AgendaAction.reminders,
        calendar.notify ? IconsaxPlusLinear.notification_bing : IconsaxPlusLinear.notification,
        calendar.notify ? localized.calendarRemindersOff : localized.calendarRemindersOn,
      ),
      if (calendar.subscription && !calendar.shared)
        iconMenuItem(_AgendaAction.sync, IconsaxPlusLinear.refresh, localized.calendarSyncNow),
      if (!calendar.shared && !calendar.subscription && !calendar.isDefault)
        iconMenuItem(_AgendaAction.makeDefault, IconsaxPlusLinear.sms_tracking, localized.calendarSetDefault),
      if (!calendar.isDefault || calendar.shared) ...[
        const PopupMenuDivider(),
        iconMenuItem(
          _AgendaAction.remove,
          calendar.shared ? IconsaxPlusLinear.logout : IconsaxPlusLinear.trash,
          calendar.shared ? localized.calendarLeave : localized.delete,
          color: error,
        ),
      ],
    ];
  }

  Future<void> _run(_AgendaAction action) async {
    switch (action) {
      case _AgendaAction.edit:
        await _edit();
      case _AgendaAction.share:
        await showAgendaShareSheet(context, calendar);
      case _AgendaAction.importFile:
        await _import();
      case _AgendaAction.reminders:
        await context.runWithFeedback(_agendas.setNotify(calendar, !calendar.notify));
      case _AgendaAction.makeDefault:
        await context.runWithFeedback(_agendas.makeDefault(calendar));
      case _AgendaAction.sync:
        final messenger = ScaffoldMessenger.maybeOf(context);
        final notice = context.localized.calendarSyncRequested(calendar.name);
        if (await context.runWithFeedback(_agendas.refresh(calendar))) {
          messenger?.showSnackBar(SnackBar(content: Text(notice)));
        }
      case _AgendaAction.remove:
        await _remove();
    }
  }

  Future<void> _import() async {
    final file = await pickCalendarFile(ref);
    if (file == null || !mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    CalendarImportResult? result;
    final ok = await context.runWithFeedback(() async {
      result = await _agendas.importInto(calendar, await readCalendarFile(file));
    }());
    if (ok && result != null && mounted) {
      messenger?.showSnackBar(SnackBar(content: Text(importNotice(context, result!))));
    }
  }

  Future<void> _edit() async {
    final localized = context.localized;
    final details = await showAgendaDialog(
      context,
      title: localized.calendarEdit,
      confirmLabel: localized.save,
      name: calendar.name,
      color: calendar.color ?? CalendarColorPicker.palette.first,
    );
    if (details == null || !mounted) return;
    await context.runWithFeedback(_agendas.edit(calendar, name: details.name, color: details.color));
  }

  Future<void> _remove() async {
    final localized = context.localized;
    final (title, message, label) = calendar.shared
        ? (localized.calendarLeaveTitle(calendar.name), localized.calendarLeaveMessage, localized.calendarLeave)
        : calendar.subscription
        ? (
            localized.calendarRemoveImportedTitle(calendar.name),
            localized.calendarRemoveImportedMessage,
            localized.calendarRemove,
          )
        : (localized.calendarDeleteTitle(calendar.name), localized.calendarDeleteMessage, localized.delete);
    final confirmed = await showConfirmDialog(
      context,
      title: title,
      message: message,
      confirmLabel: label,
      destructive: true,
    );
    if (confirmed && mounted) await context.runWithFeedback(_agendas.remove(calendar));
  }

  @override
  Widget build(BuildContext context) {
    final visible = !ref.watch(hiddenCalendarsProvider).contains(calendar.ref);
    final primary = Theme.of(context).colorScheme.primary;
    final subtitle = _subtitle(context);
    final failed = calendar.subscription && calendar.fetchError != null;
    void toggle() => context.runWithFeedback(ref.read(hiddenCalendarsProvider.notifier).toggle(calendar.ref));
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 8, end: 0),
      leading: _ColorCheckbox(color: calendar.color ?? primary, value: visible, onChanged: toggle),
      title: Text(calendar.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: failed ? TextStyle(color: Theme.of(context).colorScheme.error) : null,
            ),
      trailing: PopupMenuButton<_AgendaAction>(
        key: _menu,
        icon: const Icon(IconsaxPlusLinear.more, size: 20),
        onSelected: _run,
        itemBuilder: _items,
      ),
      onTap: toggle,
      onLongPress: () => _menu.currentState?.showButtonMenu(),
    );
  }
}

class _ColorCheckbox extends StatelessWidget {
  const _ColorCheckbox({required this.color, required this.value, required this.onChanged});

  final Color color;
  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Checkbox(
    value: value,
    onChanged: (_) => onChanged(),
    activeColor: color,
    checkColor: foregroundOn(color),
    side: BorderSide(color: color, width: 2),
  );
}
