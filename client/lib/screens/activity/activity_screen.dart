import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:intl/intl.dart";
import "package:polder/models/activity.dart";
import "package:polder/providers/activity/activity_history_provider.dart";
import "package:polder/providers/activity/activity_scope_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/screens/activity/widgets/activity_presentation.dart";
import "package:polder/screens/activity/widgets/activity_scope_button.dart";
import "package:polder/screens/activity/widgets/activity_tile.dart";
import "package:polder/screens/activity/widgets/live_transfers_card.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/shared/centered_progress.dart";
import "package:polder/widgets/shared/error_view.dart";
import "package:polder/widgets/shared/message_view.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/section_header.dart";
import "package:polder/widgets/shared/tag.dart";

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  static const _loadAhead = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(activityScopeProvider);
    final history = ref.watch(activityHistoryProvider(scope));
    final notifier = ref.read(activityHistoryProvider(scope).notifier);
    final rows = [
      const LiveTransfersCard(),
      SectionHeader(context.localized.activityHistory),
      ...switch (history) {
        AsyncValue(value: final ActivityHistory loaded?) => _historyRows(
          context,
          loaded,
          showUser: scope is! ActivityScopeMe,
        ),
        AsyncError(:final error) => [ErrorView(error: error, onRetry: notifier.refresh)],
        _ => [const SizedBox(height: 120, child: CenteredProgress())],
      },
    ];
    final hasMore = history.value?.hasMore ?? false;

    return AppPage(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Text(context.localized.navActivity),
          if (scope is! ActivityScopeMe) Tag(text: scope.label(context), color: Theme.of(context).colorScheme.primary),
        ],
      ),
      actions: [if (ref.watch(isAdminProvider)) const ActivityScopeButton()],
      body: ReadableWidth(
        maxWidth: 840,
        builder: (context, inset) => RefreshIndicator(
          edgeOffset: inset.top,
          onRefresh: notifier.refresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: inset + const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: rows.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (hasMore && index >= rows.length - _loadAhead) unawaited(Future.microtask(notifier.loadMore));
              return index < rows.length
                  ? rows[index]
                  : const Padding(padding: EdgeInsets.all(24), child: CenteredProgress());
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _historyRows(BuildContext context, ActivityHistory history, {required bool showUser}) {
    if (history.entries.isEmpty) {
      return [
        SizedBox(
          height: 160,
          child: MessageView(icon: IconsaxPlusLinear.activity, message: context.localized.activityEmpty),
        ),
      ];
    }
    final days = <DateTime, List<ActivityEntry>>{};
    for (final entry in history.entries) {
      days.putIfAbsent(DateUtils.dateOnly(entry.createdAt.toLocal()), () => []).add(entry);
    }
    return [
      for (final MapEntry(key: day, value: entries) in days.entries) ...[
        _DayHeader(day: day),
        for (final (index, entry) in entries.indexed)
          Padding(
            key: ValueKey(entry.id),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GroupedTile(
              index: index,
              count: entries.length,
              child: ActivityTile(entry: entry, showUser: showUser),
            ),
          ),
      ],
    ];
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final label = switch (today.difference(day).inDays) {
      0 => context.localized.today,
      1 => context.localized.yesterday,
      _ => DateFormat.yMMMMEEEEd(context.localeName).format(day),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
