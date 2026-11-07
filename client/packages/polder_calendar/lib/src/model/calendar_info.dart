import "package:flutter/painting.dart";

import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder_calendar/src/model/calendar_ref.dart";

part "calendar_info.freezed.dart";

enum CalendarAccess { owner, readWrite, read, freeBusy }

@freezed
abstract class CalendarInfo with _$CalendarInfo {
  const CalendarInfo._();

  const factory CalendarInfo({
    required CalendarRef ref,
    required String name,
    Color? color,
    required CalendarAccess access,
    @Default(false) bool hidden,
    @Default(true) bool notify,
    @Default(false) bool isDefault,
    @Default(false) bool subscription,
    String? ownerName,
    String? sourceUrl,
    DateTime? fetchedAt,
    String? fetchError,
  }) = _CalendarInfo;

  bool get shared => access != CalendarAccess.owner;

  bool get writable => !subscription && (access == CalendarAccess.owner || access == CalendarAccess.readWrite);
}
