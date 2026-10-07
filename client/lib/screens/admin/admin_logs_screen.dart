import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:intl/intl.dart";

import "package:polder/models/server_log.dart";
import "package:polder/providers/admin/server_logs_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/byte_format.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/shared/centered_progress.dart";
import "package:polder/widgets/shared/error_view.dart";
import "package:polder/widgets/shared/message_view.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/tag.dart";

const _monospace = TextStyle(fontFamily: "monospace", fontFamilyFallback: ["Menlo", "Consolas", "Courier New"]);

class AdminLogsScreen extends ConsumerStatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  ConsumerState<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends ConsumerState<AdminLogsScreen> {
  static const _loadAhead = 20;

  var _filter = const ServerLogFilter();
  var _following = false;
  late var _components = ref.read(polderApiProvider).logComponents();

  ServerLogsNotifier get _notifier => ref.read(serverLogsProvider(_filter).notifier);

  void _setFilter(ServerLogFilter filter) {
    setState(() => _filter = filter);
    if (_following) _notifier.follow(true);
  }

  void _toggleFollowing() {
    setState(() => _following = !_following);
    _notifier.follow(_following);
  }

  void _refresh() {
    setState(() => _components = ref.read(polderApiProvider).logComponents());
    unawaited(_notifier.refresh());
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final logs = ref.watch(serverLogsProvider(_filter));
    final notifier = _notifier;
    final rows = [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: _LogFilterBar(filter: _filter, components: _components, onChanged: _setFilter),
      ),
      ...switch (logs) {
        AsyncValue(value: final ServerLogPage page?) => _entryRows(context, page.entries),
        AsyncError(:final error) => [ErrorView(error: error, onRetry: notifier.refresh)],
        _ => [const SizedBox(height: 120, child: CenteredProgress())],
      },
    ];
    final hasMore = logs.value?.hasMore ?? false;

    return AppPage(
      title: Text(localized.serverLogs),
      actions: [
        IconButton(
          tooltip: _following ? localized.logStopFollowing : localized.logFollow,
          isSelected: _following,
          icon: const Icon(IconsaxPlusLinear.play),
          selectedIcon: const Icon(IconsaxPlusLinear.pause),
          onPressed: _toggleFollowing,
        ),
        const _DownloadButton(),
        IconButton(tooltip: localized.refresh, icon: const Icon(IconsaxPlusLinear.refresh), onPressed: _refresh),
      ],
      body: ReadableWidth(
        maxWidth: 1080,
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

  List<Widget> _entryRows(BuildContext context, List<ServerLogEntry> entries) {
    if (entries.isEmpty) {
      return [
        SizedBox(
          height: 160,
          child: MessageView(icon: IconsaxPlusLinear.document_text, message: context.localized.logsEmpty),
        ),
      ];
    }
    final days = <DateTime?, List<ServerLogEntry>>{};
    DateTime? lastDay;
    for (final entry in entries) {
      final time = entry.time;
      final day = time == null ? lastDay : DateUtils.dateOnly(time.toLocal());
      lastDay = day;
      days.putIfAbsent(day, () => []).add(entry);
    }
    return [
      for (final MapEntry(key: day, value: dayEntries) in days.entries) ...[
        if (day != null) _DayHeader(day: day),
        for (final (index, entry) in dayEntries.indexed)
          Padding(
            key: ValueKey(entry.id),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GroupedTile(
              index: index,
              count: dayEntries.length,
              child: _LogEntryTile(entry: entry),
            ),
          ),
      ],
    ];
  }
}

class _LogFilterBar extends StatefulWidget {
  const _LogFilterBar({required this.filter, required this.components, required this.onChanged});

  final ServerLogFilter filter;
  final Future<List<String>> components;
  final ValueChanged<ServerLogFilter> onChanged;

  @override
  State<_LogFilterBar> createState() => _LogFilterBarState();
}

class _LogFilterBarState extends State<_LogFilterBar> {
  static const _searchDelay = Duration(milliseconds: 300);

  late final _search = TextEditingController(text: widget.filter.query);
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final filter = widget.filter;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 280,
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(IconsaxPlusLinear.search_normal_1, size: 18),
              hintText: localized.logSearchHint,
            ),
            onChanged: (text) {
              _debounce?.cancel();
              _debounce = Timer(_searchDelay, () => widget.onChanged(widget.filter.copyWith(query: text.trim())));
            },
          ),
        ),
        DropdownMenu<LogLevel>(
          label: Text(localized.logMinimumLevel),
          initialSelection: filter.minLevel,
          requestFocusOnTap: false,
          onSelected: (level) {
            if (level != null) widget.onChanged(filter.copyWith(minLevel: level));
          },
          dropdownMenuEntries: [
            for (final level in LogLevel.values) DropdownMenuEntry(value: level, label: level.label(context)),
          ],
        ),
        FutureBuilder(
          future: widget.components,
          builder: (context, snapshot) => DropdownMenu<String?>(
            label: Text(localized.logComponent),
            initialSelection: filter.component,
            requestFocusOnTap: false,
            onSelected: (component) => widget.onChanged(filter.copyWith(component: component)),
            dropdownMenuEntries: [
              DropdownMenuEntry(value: null, label: localized.logAllComponents),
              for (final component in {...?snapshot.data, ?filter.component})
                DropdownMenuEntry(value: component, label: component),
            ],
          ),
        ),
      ],
    );
  }
}

/// Lists the log files when opened, so the newest sizes show.
class _DownloadButton extends ConsumerWidget {
  const _DownloadButton();

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final localized = context.localized;
    final button = context.findRenderObject()! as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final files = await ref.read(polderApiProvider).logFiles();
    if (!context.mounted) return;
    final file = await showMenu<ServerLogFile>(
      context: context,
      position: position,
      items: files.isEmpty
          ? [PopupMenuItem(enabled: false, child: Text(localized.logNoFiles))]
          : [
              for (final file in files)
                PopupMenuItem(
                  value: file,
                  child: Text(
                    "${DateFormat.yMMMEd(context.localeName).format(file.day)}  ·  "
                    "${ByteFormat.format(file.size, locale: context.localeName)}",
                  ),
                ),
            ],
    );
    if (file != null) await ref.read(transfersProvider.notifier).downloadLogFile(file);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
    tooltip: context.localized.logDownload,
    icon: const Icon(IconsaxPlusLinear.document_download),
    onPressed: () => unawaited(_open(context, ref)),
  );
}

class _LogEntryTile extends StatefulWidget {
  const _LogEntryTile({required this.entry});

  final ServerLogEntry entry;

  @override
  State<_LogEntryTile> createState() => _LogEntryTileState();
}

class _LogEntryTileState extends State<_LogEntryTile> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final time = entry.time;
    final level = entry.level;
    final details = [for (final MapEntry(:key, :value) in entry.attrs.entries) "$key=$value"];
    return InkWell(
      onTap: details.isEmpty ? null : () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Row(
              spacing: 8,
              children: [
                if (time != null)
                  Text(
                    DateFormat.Hms(context.localeName).format(time.toLocal()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: muted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                if (level != null) Tag(text: level.name.toUpperCase(), color: level.color(context)),
                if (entry.component.isNotEmpty)
                  Flexible(
                    child: Text(
                      entry.component,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.merge(_monospace).copyWith(color: muted),
                    ),
                  ),
              ],
            ),
            Text(entry.message, style: theme.textTheme.bodyMedium),
            if (details.isNotEmpty)
              _expanded
                  ? SelectableText(details.join("\n"), style: theme.textTheme.bodySmall?.merge(_monospace))
                  : Text(
                      details.join("  "),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.merge(_monospace).copyWith(color: muted),
                    ),
          ],
        ),
      ),
    );
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

extension on LogLevel {
  String label(BuildContext context) => switch (this) {
    LogLevel.debug => context.localized.logLevelDebug,
    LogLevel.info => context.localized.logLevelInfo,
    LogLevel.warn => context.localized.logLevelWarn,
    LogLevel.error => context.localized.logLevelError,
  };

  Color color(BuildContext context) => switch (this) {
    LogLevel.debug => Theme.of(context).colorScheme.onSurfaceVariant,
    LogLevel.info => AppColors.of(context).info,
    LogLevel.warn => AppColors.of(context).warning,
    LogLevel.error => Theme.of(context).colorScheme.error,
  };
}
