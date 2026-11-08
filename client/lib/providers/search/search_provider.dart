import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/search.dart";
import "package:polder/providers/calendar/calendar_providers.dart";
import "package:polder/providers/polder_api_provider.dart";

const searchPageSize = 50;

final searchResultsProvider = AsyncNotifierProvider.autoDispose.family<SearchResultsNotifier, SearchResults, String>(
  SearchResultsNotifier.new,
);

class SearchResultsNotifier extends AsyncNotifier<SearchResults> {
  SearchResultsNotifier(this.query);

  final String query;
  bool _loadingMore = false;

  @override
  Future<SearchResults> build() => ref.watch(polderApiProvider).search(query, limit: searchPageSize);

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final next = await ref.read(polderApiProvider).search(query, limit: searchPageSize, offset: current.hits.length);
      if (ref.mounted) state = AsyncData(current.copyWith(hits: [...current.hits, ...next.hits], total: next.total));
    } finally {
      _loadingMore = false;
    }
  }
}

final eventSearchResultsProvider = AsyncNotifierProvider.autoDispose
    .family<EventSearchResultsNotifier, EventSearchResults, String>(EventSearchResultsNotifier.new);

class EventSearchResultsNotifier extends AsyncNotifier<EventSearchResults> {
  EventSearchResultsNotifier(this.query);

  final String query;
  bool _loadingMore = false;

  @override
  Future<EventSearchResults> build() async {
    final source = ref.watch(polderCalendarSourceProvider);
    if (source == null) return EventSearchResults(query: query);
    return ref.watch(polderApiProvider).searchEvents(source.id, query, limit: searchPageSize);
  }

  Future<void> loadMore() async {
    final current = state.value;
    final source = ref.read(polderCalendarSourceProvider);
    if (current == null || source == null || !current.hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final next = await ref
          .read(polderApiProvider)
          .searchEvents(source.id, query, limit: searchPageSize, offset: current.hits.length);
      if (ref.mounted) state = AsyncData(current.copyWith(hits: [...current.hits, ...next.hits], total: next.total));
    } finally {
      _loadingMore = false;
    }
  }
}

final searchSuggestionsProvider = FutureProvider.autoDispose.family<SearchSuggestions, ({String query, int cursor})>(
  (ref, request) => ref.watch(polderApiProvider).suggestSearch(request.query, request.cursor),
);
