import "package:polder/models/branding.dart";
import "package:polder/models/calendar.dart";
import "package:polder/services/api/generated/polder.swagger.dart" as wire;

extension CalendarToModel on wire.Calendar {
  CalendarSummary toModel() => CalendarSummary(
    id: id,
    uri: uri,
    name: name,
    color: parseHexColor(color),
    access: switch (access) {
      wire.CalendarAccess.owner => CalendarAccess.owner,
      wire.CalendarAccess.readwrite => CalendarAccess.readWrite,
      wire.CalendarAccess.freebusy => CalendarAccess.freeBusy,
      _ => CalendarAccess.read,
    },
    subscription: kind == wire.CalendarKind.subscription,
    ownerName: owner?.displayName,
  );
}

extension FeedToModel on wire.Feed {
  CalendarFeed toModel() => CalendarFeed(
    id: id,
    calendarId: calendarId,
    name: name,
    mode: mode == wire.FeedMode.busy ? CalendarFeedMode.busy : CalendarFeedMode.full,
    createdAt: createdAt.toLocal(),
    lastUsedAt: lastUsedAt?.toLocal(),
  );

  CreatedCalendarFeed toCreated() => CreatedCalendarFeed(feed: toModel(), url: url ?? "");
}

extension CalendarFeedModeToWire on CalendarFeedMode {
  wire.NewFeedMode toWire() => switch (this) {
    CalendarFeedMode.full => wire.NewFeedMode.full,
    CalendarFeedMode.busy => wire.NewFeedMode.busy,
  };
}
