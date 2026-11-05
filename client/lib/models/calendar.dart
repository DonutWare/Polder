import "package:flutter/material.dart";

import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/sharing.dart";

part "calendar.freezed.dart";

enum CalendarAccess { owner, readWrite, read, freeBusy }

enum CalendarFeedMode { full, busy }

enum CalendarShareAccess { freeBusy, read, readWrite }

@freezed
abstract class CalendarSummary with _$CalendarSummary {
  const CalendarSummary._();

  const factory CalendarSummary({
    required int id,
    required String uri,
    required String name,
    Color? color,
    required CalendarAccess access,
    @Default(false) bool subscription,
    String? ownerName,
  }) = _CalendarSummary;

  bool get owned => access == CalendarAccess.owner;

  String get homeSegment => owned ? uri : "shared-$id";
}

@freezed
abstract class CalendarFeed with _$CalendarFeed {
  const factory CalendarFeed({
    required int id,
    required int calendarId,
    @Default("") String name,
    required CalendarFeedMode mode,
    required DateTime createdAt,
    DateTime? lastUsedAt,
  }) = _CalendarFeed;
}

@freezed
abstract class CreatedCalendarFeed with _$CreatedCalendarFeed {
  const factory CreatedCalendarFeed({required CalendarFeed feed, required String url}) = _CreatedCalendarFeed;
}

@freezed
abstract class CalendarShare with _$CalendarShare {
  const factory CalendarShare({
    required int id,
    required int calendarId,
    required ShareTarget recipient,
    required CalendarShareAccess access,
  }) = _CalendarShare;
}

@freezed
abstract class CalendarImportResult with _$CalendarImportResult {
  const factory CalendarImportResult({
    required int created,
    required int updated,
    required int skipped,
    @Default([]) List<String> errors,
  }) = _CalendarImportResult;
}
