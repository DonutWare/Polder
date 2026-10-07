import "package:flutter/widgets.dart";

import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/file_entry.dart";

part "search.freezed.dart";

enum SearchKey { type, ext, folder, modified, size }

enum SearchOp { equals, notEquals, greater, greaterOrEqual, less, lessOrEqual, between }

@freezed
abstract class SearchFilter with _$SearchFilter {
  const factory SearchFilter({
    required SearchKey key,
    required SearchOp op,
    @Default(<String>[]) List<String> values,
    @Default(TextRange.empty) TextRange range,
  }) = _SearchFilter;
}

@freezed
abstract class SearchHit with _$SearchHit {
  const factory SearchHit({
    required FileEntry entry,
    @Default(0) double score,
    @Default(<TextRange>[]) List<TextRange> nameMatches,
    String? snippet,
    @Default(<TextRange>[]) List<TextRange> snippetMatches,
  }) = _SearchHit;
}

@freezed
abstract class SearchFacet with _$SearchFacet {
  const factory SearchFacet({required String value, required int count}) = _SearchFacet;
}

@freezed
abstract class SearchWarning with _$SearchWarning {
  const factory SearchWarning({required TextRange range, required String message}) = _SearchWarning;
}

@freezed
abstract class SearchResults with _$SearchResults {
  const SearchResults._();

  const factory SearchResults({
    required String query,
    @Default(0) int total,
    @Default(<SearchHit>[]) List<SearchHit> hits,
    @Default(<SearchFilter>[]) List<SearchFilter> filters,
    @Default(<SearchFacet>[]) List<SearchFacet> typeFacets,
    @Default(<SearchFacet>[]) List<SearchFacet> extFacets,
    @Default(<SearchWarning>[]) List<SearchWarning> warnings,
  }) = _SearchResults;

  bool get hasMore => hits.length < total;
}

@freezed
abstract class SearchSuggestion with _$SearchSuggestion {
  const factory SearchSuggestion({
    required String value,
    required String insert,
    @Default(false) bool isKey,
    @Default(0) int count,
  }) = _SearchSuggestion;
}

@freezed
abstract class SearchSuggestions with _$SearchSuggestions {
  const factory SearchSuggestions({
    @Default(TextRange.empty) TextRange range,
    @Default(<SearchSuggestion>[]) List<SearchSuggestion> suggestions,
  }) = _SearchSuggestions;
}

enum OcrState { off, ready, unavailable }

@freezed
abstract class TextExtractionStatus with _$TextExtractionStatus {
  const factory TextExtractionStatus({
    @Default(0) int pending,
    @Default(OcrState.off) OcrState ocr,
    String? ocrProblem,
  }) = _TextExtractionStatus;
}
