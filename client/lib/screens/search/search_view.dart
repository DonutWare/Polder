import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/search.dart";
import "package:polder/providers/search/app_destinations_provider.dart";
import "package:polder/providers/search/search_provider.dart";
import "package:polder/screens/search/widgets/search_filter_builder.dart";
import "package:polder/screens/search/widgets/outline_progress.dart";
import "package:polder/screens/search/widgets/search_query_controller.dart";
import "package:polder/screens/search/widgets/search_result_tiles.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/search_syntax.dart";
import "package:polder/widgets/shared/error_view.dart";
import "package:polder/widgets/shared/message_view.dart";

const _debounce = Duration(milliseconds: 150);
const _maxDestinations = 4;
const _tileExtent = 64.0;
const _exampleTags = ["type=image", "type=pdf", "modified>7d", "size>100mb", "type=folder"];

class SearchView extends ConsumerStatefulWidget {
  const SearchView({
    required this.onOpenEntry,
    required this.onShowInFolder,
    required this.onGo,
    required this.onClose,
    this.initialQuery = "",
    this.leading,
    super.key,
  });

  final String initialQuery;
  final ValueChanged<FileEntry> onOpenEntry;
  final ValueChanged<FileEntry> onShowInFolder;
  final ValueChanged<String> onGo;
  final VoidCallback onClose;

  // Shown at the start of the search bar, such as a back button.
  final Widget? leading;

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  late final _controller = SearchQueryController(text: widget.initialQuery)
    ..selection = TextSelection.collapsed(offset: widget.initialQuery.length);
  final _focus = FocusNode();
  final _scroll = ScrollController();
  Timer? _timer;
  bool _typing = false;
  late String _query = widget.initialQuery.trim();
  late ({String query, int cursor}) _suggestFor = (query: widget.initialQuery, cursor: widget.initialQuery.length);
  SearchResults? _shown;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onEdited);
    _scroll.addListener(_onScrolled);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onEdited() {
    final request = (query: _controller.text, cursor: _controller.selection.baseOffset);
    if (request == _suggestFor && _controller.text.trim() == _query) return;
    final queryChanges = _controller.text.trim() != _query && _controller.text.trim().isNotEmpty;
    if (queryChanges != _typing) setState(() => _typing = queryChanges);
    _timer?.cancel();
    _timer = Timer(_debounce, () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _suggestFor = request;
        if (_query != _controller.text.trim()) {
          _query = _controller.text.trim();
          _selected = 0;
        }
      });
    });
  }

  void _onScrolled() {
    if (_scroll.position.extentAfter < 400 && _query.isNotEmpty) {
      ref.read(searchResultsProvider(_query).notifier).loadMore();
    }
  }

  void _setText(String text, int caret) {
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: caret),
    );
    _focus.requestFocus();
  }

  void _applySuggestion(SearchSuggestions suggestions, SearchSuggestion suggestion) {
    final (text, caret) = replaceSearchRange(_controller.text, suggestions.range, suggestion.insert);
    _setText(text, caret);
  }

  Future<void> _addFilter() async {
    final filter = await showSearchFilterBuilder(context);
    if (filter == null || !mounted) return;
    final text = appendSearchTag(_controller.text, formatSearchFilter(filter));
    _setText(text, text.length);
  }

  void _moveSelection(int delta, int count) {
    if (count == 0) return;
    setState(() => _selected = (_selected + delta).clamp(0, count - 1));
    if (!_scroll.hasClients) return;
    final target = _selected * _tileExtent;
    final viewport = _scroll.position.viewportDimension;
    if (target < _scroll.offset || target + _tileExtent * 2 > _scroll.offset + viewport) {
      _scroll.animateTo(
        (target - viewport / 2).clamp(0, _scroll.position.maxScrollExtent),
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.localized;
    final results = _query.isEmpty ? null : ref.watch(searchResultsProvider(_query));
    if (results?.value case final current?) _shown = current;
    if (_query.isEmpty) _shown = null;
    final shown = _shown;
    final upToDate = shown != null && shown.query == _controller.text.trim();
    final warnings = upToDate ? [for (final warning in shown.warnings) warning.range] : const <TextRange>[];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.warnings = warnings;
    });

    final freeText = tokenizeSearch(_query).where((token) => !token.isTag).map((token) => token.text).join(" ");
    final destinations = freeText.isEmpty
        ? const <DestinationMatch>[]
        : matchDestinations(ref.watch(appDestinationsProvider), l, freeText).take(_maxDestinations).toList();
    final hits = shown?.hits ?? const <SearchHit>[];
    final count = destinations.length + hits.length;
    if (_selected >= count) _selected = count == 0 ? 0 : count - 1;

    void openSelected() {
      if (_selected < destinations.length) return widget.onGo(destinations[_selected].destination.route);
      final index = _selected - destinations.length;
      if (index < hits.length) widget.onOpenEntry(hits[index].entry);
    }

    final suggestions = _controller.text.isEmpty ? null : ref.watch(searchSuggestionsProvider(_suggestFor)).value;
    final visibleSuggestions = suggestions?.suggestions ?? const <SearchSuggestion>[];

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _moveSelection(1, count),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _moveSelection(-1, count),
        const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
        if (visibleSuggestions.isNotEmpty)
          const SingleActivator(LogicalKeyboardKey.tab): () => _applySuggestion(suggestions!, visibleSuggestions.first),
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: _SearchField(
              controller: _controller,
              focusNode: _focus,
              leading: widget.leading,
              onSubmitted: openSelected,
              onAddFilter: _addFilter,
              loading: _typing || (results?.isLoading ?? false),
            ),
          ),
          if (visibleSuggestions.isNotEmpty)
            _ChipStrip(
              children: [
                for (final suggestion in visibleSuggestions)
                  ActionChip(
                    avatar: Icon(suggestion.isKey ? IconsaxPlusLinear.filter_add : IconsaxPlusLinear.add, size: 16),
                    label: Text(suggestion.count > 0 ? "${suggestion.value} (${suggestion.count})" : suggestion.value),
                    onPressed: () => _applySuggestion(suggestions!, suggestion),
                  ),
              ],
            ),
          const SizedBox(height: 4),
          Expanded(
            child: switch ((results, shown)) {
              (null, _) => _SearchHints(
                onTag: (tag) {
                  final text = appendSearchTag(_controller.text, tag);
                  _setText(text, text.length);
                },
              ),
              (AsyncError(:final error), null) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(searchResultsProvider(_query)),
              ),
              (_, null) when destinations.isEmpty => const SizedBox.shrink(),
              _ when count == 0 => MessageView(icon: IconsaxPlusLinear.search_status, message: l.searchNoResults),
              _ => ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                children: [
                  if (destinations.isNotEmpty) ...[
                    _SectionHeader(text: l.searchGoTo),
                    for (final (i, match) in destinations.indexed)
                      DestinationTile(
                        match: match,
                        selected: i == _selected,
                        onOpen: () => widget.onGo(match.destination.route),
                      ),
                  ],
                  if (hits.isNotEmpty) ...[
                    _SectionHeader(text: l.searchFilesCount(shown!.total)),
                    for (final (i, hit) in hits.indexed)
                      SearchHitTile(
                        hit: hit,
                        selected: destinations.length + i == _selected,
                        onOpen: () => widget.onOpenEntry(hit.entry),
                        onShowInFolder: () => widget.onShowInFolder(hit.entry),
                      ),
                    if (shown.hasMore)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: SizedBox.square(dimension: 24, child: CircularProgressIndicator())),
                      ),
                  ],
                ],
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onAddFilter,
    required this.loading,
    this.leading,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmitted;
  final VoidCallback onAddFilter;
  final bool loading;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final l = context.localized;
    final colors = AppColors.of(context);
    return OutlineProgress(
      active: loading,
      shape: squircle(AppRadius.panel),
      child: Material(
        color: colors.inset,
        shape: squircle(AppRadius.panel, side: BorderSide(color: colors.border)),
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: leading == null ? 8 : 4, end: 6),
          child: Row(
            spacing: 4,
            children: [
              ?leading,
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l.searchHint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  ),
                  onSubmitted: (_) {
                    onSubmitted();
                    focusNode.requestFocus();
                  },
                ),
              ),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) => controller.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: l.searchClear,
                        icon: const Icon(IconsaxPlusLinear.close_circle, size: 20),
                        onPressed: () {
                          controller.clear();
                          focusNode.requestFocus();
                        },
                      ),
              ),
              TextButton.icon(
                icon: const Icon(IconsaxPlusLinear.filter_add, size: 18),
                label: Text(l.searchAddFilterButton),
                onPressed: onAddFilter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipStrip extends StatelessWidget {
  const _ChipStrip({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      children: [
        for (final child in children) Padding(padding: const EdgeInsetsDirectional.only(end: 8), child: child),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(text, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
    );
  }
}

class _SearchHints extends StatelessWidget {
  const _SearchHints({required this.onTag});

  final ValueChanged<String> onTag;

  @override
  Widget build(BuildContext context) {
    final l = context.localized;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Text(l.searchTipsTitle, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(height: 8),
        Text(l.searchTipsBody, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final tag in _exampleTags) ActionChip(label: Text(tag), onPressed: () => onTag(tag))],
        ),
      ],
    );
  }
}
