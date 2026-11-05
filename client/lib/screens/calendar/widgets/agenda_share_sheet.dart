import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/calendar.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/calendar/calendar_providers.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/screens/calendar/widgets/calendar_panel.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/sharing/share_target_avatar.dart";
import "package:polder_calendar/polder_calendar.dart";

Future<void> showAgendaShareSheet(BuildContext context, CalendarInfo calendar) => showCalendarPanel<void>(
  context,
  builder: (context, controller) =>
      _AgendaSharePanel(calendarId: int.parse(calendar.ref.calendarId), name: calendar.name, controller: controller),
);

String calendarAccessLabel(BuildContext context, CalendarShareAccess access) => switch (access) {
  CalendarShareAccess.freeBusy => context.localized.calendarAccessFreeBusy,
  CalendarShareAccess.read => context.localized.calendarAccessRead,
  CalendarShareAccess.readWrite => context.localized.calendarAccessReadWrite,
};

class _AgendaSharePanel extends ConsumerStatefulWidget {
  const _AgendaSharePanel({required this.calendarId, required this.name, this.controller});

  final int calendarId;
  final String name;
  final ScrollController? controller;

  @override
  ConsumerState<_AgendaSharePanel> createState() => _AgendaSharePanelState();
}

class _AgendaSharePanelState extends ConsumerState<_AgendaSharePanel> {
  final _search = TextEditingController();
  var _query = "";
  var _access = CalendarShareAccess.read;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  CalendarSharesNotifier get _shares => ref.read(calendarSharesProvider(widget.calendarId).notifier);

  Future<void> _add(ShareTarget target) async {
    final ok = await context.runWithFeedback(_shares.add(target, _access));
    if (ok && mounted) {
      _search.clear();
      setState(() => _query = "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return CalendarPanelBody(
      title: localized.shareTitle(widget.name),
      controller: widget.controller,
      children: [
        TextField(
          controller: _search,
          decoration: InputDecoration(
            prefixIcon: const Icon(IconsaxPlusLinear.search_normal_1),
            hintText: localized.shareSearchHint,
          ),
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<CalendarShareAccess>(
          initialValue: _access,
          decoration: const InputDecoration(prefixIcon: Icon(IconsaxPlusLinear.key)),
          items: [
            for (final access in CalendarShareAccess.values.reversed)
              DropdownMenuItem(value: access, child: Text(calendarAccessLabel(context, access))),
          ],
          onChanged: (access) => setState(() => _access = access ?? _access),
        ),
        if (_query.isNotEmpty)
          _Matches(calendarId: widget.calendarId, query: _query, onPick: _add)
        else ...[
          CalendarFieldLabel(localized.shareRecipients),
          _Recipients(calendarId: widget.calendarId),
        ],
      ],
    );
  }
}

class _Matches extends ConsumerWidget {
  const _Matches({required this.calendarId, required this.query, required this.onPick});

  final int calendarId;
  final String query;
  final ValueChanged<ShareTarget> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shared = {
      for (final share in ref.watch(calendarSharesProvider(calendarId)).value ?? const <CalendarShare>[])
        (share.recipient.kind, share.recipient.id),
    };
    return AsyncValueView<ShareTargets>(
      value: ref.watch(shareTargetSearchProvider(query)),
      data: (found) {
        final targets = [
          ...found.groups,
          ...found.users,
        ].where((target) => !shared.contains((target.kind, target.id))).toList();
        if (targets.isEmpty) return _Quiet(text: context.localized.shareNoMatches);
        return Column(
          children: [
            for (final target in targets)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ShareTargetAvatar(target: target),
                title: Text(target.name, overflow: TextOverflow.ellipsis),
                subtitle: target.isGroup ? Text(context.localized.shareGroupMembers(target.memberCount ?? 0)) : null,
                trailing: const Icon(IconsaxPlusLinear.add),
                onTap: () => onPick(target),
              ),
          ],
        );
      },
    );
  }
}

const _stopSharing = #stopSharing;

class _Recipients extends ConsumerWidget {
  const _Recipients({required this.calendarId});

  final int calendarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(calendarSharesProvider(calendarId).notifier);
    return AsyncValueView<List<CalendarShare>>(
      value: ref.watch(calendarSharesProvider(calendarId)),
      onRetry: () => ref.invalidate(calendarSharesProvider(calendarId)),
      data: (shares) => shares.isEmpty
          ? _Quiet(text: context.localized.shareNotSharedYet)
          : Column(
              children: [
                for (final share in shares)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ShareTargetAvatar(target: share.recipient),
                    title: Text(share.recipient.name, overflow: TextOverflow.ellipsis),
                    subtitle: Text(calendarAccessLabel(context, share.access)),
                    trailing: PopupMenuButton<Object>(
                      icon: const Icon(IconsaxPlusLinear.more),
                      onSelected: (choice) => context.runWithFeedback(
                        choice is CalendarShareAccess ? notifier.change(share, choice) : notifier.remove(share),
                      ),
                      itemBuilder: (context) => [
                        for (final access in CalendarShareAccess.values.reversed)
                          CheckedPopupMenuItem(
                            value: access,
                            checked: share.access == access,
                            child: Text(calendarAccessLabel(context, access)),
                          ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: _stopSharing,
                          child: Text(
                            context.localized.calendarStopSharing,
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Quiet extends StatelessWidget {
  const _Quiet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}
