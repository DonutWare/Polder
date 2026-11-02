import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:intl/intl.dart";
import "package:polder/models/account.dart";
import "package:polder/models/calendar.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/calendar/calendar_providers.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/util/clipboard.dart";
import "package:polder/util/dav_addresses.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/loading_button.dart";
import "package:polder/widgets/shared/nav_group.dart";

class CalendarsGroup extends ConsumerWidget {
  const CalendarsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final account = ref.watch(currentAccountProvider);
    final calendars = ref.watch(calendarsProvider);
    if (account == null) return const SizedBox.shrink();
    return NavGroup(
      title: localized.calendars,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(localized.calendarsHint, style: Theme.of(context).textTheme.bodySmall),
        ),
        ...switch (calendars) {
          AsyncData(:final value) when value.isEmpty => [ListTile(title: Text(localized.noCalendars))],
          AsyncData(:final value) => [
            for (final calendar in value.where((calendar) => calendar.access != CalendarAccess.freeBusy))
              _CalendarTile(account: account, calendar: calendar),
          ],
          AsyncError(:final error) => [
            ListTile(
              title: Text(error is ApiException ? localized.describeError(error) : "$error"),
              trailing: IconButton(
                tooltip: localized.refresh,
                icon: const Icon(IconsaxPlusLinear.refresh),
                onPressed: () => ref.invalidate(calendarsProvider),
              ),
            ),
          ],
          _ => [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        },
      ],
    );
  }
}

class _CalendarTile extends StatelessWidget {
  const _CalendarTile({required this.account, required this.calendar});

  final Account account;
  final CalendarSummary calendar;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final theme = Theme.of(context);
    final address = calendarAddress(account.serverUrl, account.user.username, calendar.homeSegment);
    final details = [
      if (!calendar.owned && calendar.ownerName != null) localized.calendarSharedBy(calendar.ownerName!),
      if (calendar.subscription) localized.calendarSubscribedFeed,
    ];
    return ExpansionTile(
      leading: Icon(IconsaxPlusBold.calendar_1, color: calendar.color ?? theme.colorScheme.primary),
      title: Text(calendar.name, overflow: TextOverflow.ellipsis),
      subtitle: details.isEmpty ? null : Text(details.join(" · ")),
      shape: const Border(),
      children: [
        ListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 32, end: 16),
          leading: const Icon(IconsaxPlusLinear.link),
          title: Text(localized.caldavAddress),
          subtitle: Text(address, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            tooltip: localized.copy,
            icon: const Icon(IconsaxPlusLinear.copy),
            onPressed: () => copyWithNotice(context, address, localized.calendarAddressCopied),
          ),
        ),
        if (calendar.owned) _SubscriptionLinks(account: account, calendar: calendar),
      ],
    );
  }
}

class _SubscriptionLinks extends ConsumerWidget {
  const _SubscriptionLinks({required this.account, required this.calendar});

  final Account account;
  final CalendarSummary calendar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final feeds = ref.watch(calendarFeedsProvider(calendar.id));
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(localized.subscriptionLinks, style: Theme.of(context).textTheme.titleSmall),
            trailing: TextButton.icon(
              icon: const Icon(IconsaxPlusLinear.add),
              label: Text(localized.createSubscriptionLink),
              onPressed: () => _create(context),
            ),
          ),
          ...switch (feeds) {
            AsyncData(:final value) when value.isEmpty => [ListTile(title: Text(localized.noSubscriptionLinks))],
            AsyncData(:final value) => [for (final feed in value) _FeedTile(feed: feed)],
            AsyncError(:final error) => [
              ListTile(title: Text(error is ApiException ? localized.describeError(error) : "$error")),
            ],
            _ => [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          },
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final created = await showDialog<CreatedCalendarFeed>(
      context: context,
      builder: (_) => _CreateFeedDialog(calendarId: calendar.id),
    );
    if (created == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _CreatedFeedDialog(address: subscriptionAddress(account.serverUrl, created.url)),
    );
  }
}

class _FeedTile extends ConsumerWidget {
  const _FeedTile({required this.feed});

  final CalendarFeed feed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final lastUsed = feed.lastUsedAt;
    final mode = feed.mode == CalendarFeedMode.busy
        ? localized.subscriptionLinkModeBusy
        : localized.subscriptionLinkModeFull;
    final details = [
      if (feed.name.isNotEmpty) mode,
      lastUsed == null
          ? localized.appPasswordNeverUsed
          : localized.subscriptionLinkLastUsed(DateFormat.yMMMd().add_Hm().format(lastUsed)),
    ];
    return ListTile(
      leading: Icon(feed.mode == CalendarFeedMode.busy ? IconsaxPlusLinear.eye_slash : IconsaxPlusLinear.eye),
      title: Text(feed.name.isEmpty ? mode : feed.name, overflow: TextOverflow.ellipsis),
      subtitle: Text(details.join(" · ")),
      trailing: IconButton(
        tooltip: localized.revokeSubscriptionLink,
        icon: const Icon(IconsaxPlusLinear.trash),
        onPressed: () => _revoke(context, ref),
      ),
    );
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    final localized = context.localized;
    final confirmed = await showConfirmDialog(
      context,
      title: localized.revokeSubscriptionLinkTitle,
      message: localized.revokeSubscriptionLinkMessage,
      confirmLabel: localized.revokeSubscriptionLink,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await context.runWithFeedback(ref.read(calendarFeedsProvider(feed.calendarId).notifier).revoke(feed));
  }
}

class _CreateFeedDialog extends ConsumerStatefulWidget {
  const _CreateFeedDialog({required this.calendarId});

  final int calendarId;

  @override
  ConsumerState<_CreateFeedDialog> createState() => _CreateFeedDialogState();
}

class _CreateFeedDialogState extends ConsumerState<_CreateFeedDialog> {
  final _name = TextEditingController();
  var _mode = CalendarFeedMode.full;
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return AlertDialog(
      title: Text(localized.createSubscriptionLink),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              maxLength: 128,
              decoration: InputDecoration(labelText: localized.name, hintText: localized.subscriptionLinkNameHint),
            ),
            RadioGroup<CalendarFeedMode>(
              groupValue: _mode,
              onChanged: (mode) => setState(() => _mode = mode ?? _mode),
              child: Column(
                children: [
                  RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    value: CalendarFeedMode.full,
                    title: Text(localized.subscriptionLinkModeFull),
                    subtitle: Text(localized.subscriptionLinkModeFullHint),
                  ),
                  RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    value: CalendarFeedMode.busy,
                    title: Text(localized.subscriptionLinkModeBusy),
                    subtitle: Text(localized.subscriptionLinkModeBusyHint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(localized.cancel)),
        LoadingButton(label: localized.create, loading: _saving, onPressed: _saving ? null : _save),
      ],
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final localizations = context.localized;
    setState(() => _saving = true);
    try {
      final name = _name.text.trim();
      final created = await ref
          .read(calendarFeedsProvider(widget.calendarId).notifier)
          .create(mode: _mode, name: name.isEmpty ? null : name);
      if (mounted) Navigator.of(context).pop(created);
      return;
    } on ApiException catch (error) {
      messenger?.showSnackBar(SnackBar(content: Text(localizations.describeError(error))));
    }
    if (mounted) setState(() => _saving = false);
  }
}

class _CreatedFeedDialog extends StatelessWidget {
  const _CreatedFeedDialog({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final webcal = webcalAddress(address);
    return AlertDialog(
      title: Text(localized.subscriptionLinkCreatedTitle),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(localized.subscriptionLinkCreatedMessage),
            _CopyableAddress(value: address),
            if (webcal != address) ...[
              Text(localized.subscriptionLinkWebcal, style: Theme.of(context).textTheme.labelLarge),
              _CopyableAddress(value: webcal),
            ],
          ],
        ),
      ),
      actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(localized.done))],
    );
  }
}

class _CopyableAddress extends StatelessWidget {
  const _CopyableAddress({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localized = context.localized;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12, top: 4, bottom: 4, end: 4),
        child: Row(
          children: [
            Expanded(
              child: SelectableText(value, style: theme.textTheme.bodySmall?.copyWith(fontFamily: "monospace")),
            ),
            IconButton(
              tooltip: localized.copy,
              icon: const Icon(IconsaxPlusLinear.copy),
              onPressed: () => copyWithNotice(context, value, localized.subscriptionLinkCopied),
            ),
          ],
        ),
      ),
    );
  }
}
