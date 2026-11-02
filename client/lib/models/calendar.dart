import "package:flutter/material.dart";

import "package:freezed_annotation/freezed_annotation.dart";

part "calendar.freezed.dart";

enum CalendarAccess { owner, readWrite, read, freeBusy }

enum CalendarFeedMode { full, busy }

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
