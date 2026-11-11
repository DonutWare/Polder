import "dart:async";
import "dart:convert";

import "package:flutter/material.dart";
import "package:uuid/uuid.dart";

import "package:polder/models/offline_models.dart";
import "package:polder/models/sync/conflict.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/calendar/calendar_cache.dart";
import "package:polder/services/calendar/polder_calendar_source.dart";
import "package:polder/services/offline/offline_store.dart";
import "package:polder/services/offline/outbox_errors.dart";
import "package:polder/util/async_lock.dart";
import "package:polder_calendar/polder_calendar.dart";

enum CalendarChangeType { create, update, delete, move, respond }

class OfflineCalendarSource implements CalendarSource {
  OfflineCalendarSource({
    required this._remote,
    required this._api,
    required Future<OfflineStore> store,
    this._onQueued,
    this._clock = DateTime.now,
  }) : _storeFuture = store;

  final PolderCalendarSource _remote;
  final PolderApi _api;
  final Future<OfflineStore> _storeFuture;
  final void Function()? _onQueued;
  final DateTime Function() _clock;
  final _lock = AsyncLock();
  final _localChanges = StreamController<CalendarRef>.broadcast();
  final _inFlight = <int>{};

  static const localPrefix = "local:";
  static const _calendarsKey = "calendar.list";
  static const _prefetchKey = "calendar.prefetched";
  static const _createdKey = "calendar.created.";
  static const prefetchEvery = Duration(hours: 6);

  @override
  String get id => _remote.id;

  @override
  String get label => _remote.label;

  @override
  CalendarCapabilities get capabilities => _remote.capabilities;

  @override
  Stream<CalendarRef> get changes => StreamGroupMerge.merge(_remote.changes, _localChanges.stream);

  Future<OfflineStore> get _store => _storeFuture;

  Future<CalendarCache> get _cache async => CalendarCache((await _store).db);

  static bool isLocal(EventRef ref) => ref.eventId.startsWith(localPrefix);

  @override
  Future<List<CalendarInfo>> calendars() async {
    final store = await _store;
    try {
      final calendars = await _remote.calendars();
      await store.saveMeta(_calendarsKey, jsonEncode([for (final calendar in calendars) CalendarCodec.info(calendar)]));
      return calendars;
    } on ApiException catch (error) {
      if (!_offlineError(error)) rethrow;
      final cached = await store.meta(_calendarsKey);
      if (cached == null) rethrow;
      return [
        for (final json in (jsonDecode(cached) as List<dynamic>).cast<Map<String, dynamic>>())
          CalendarCodec.infoFrom(json),
      ];
    }
  }

  @override
  Future<List<CalendarEvent>> events(DateTimeRange range, {Set<CalendarRef>? calendars}) async {
    final cache = await _cache;
    final ids = calendars == null ? null : {for (final calendar in calendars) calendar.calendarId};
    try {
      final fresh = await _remote.events(range, calendars: calendars);
      await _lock.run(() => cache.replaceFromServer(range, fresh, calendarIds: ids));
    } on ApiException catch (error) {
      if (!_offlineError(error) || !await cache.covers(range)) rethrow;
    }
    return [
      for (final cached in await cache.overlapping(range, calendarIds: ids))
        if (cached.state != CachedEventState.deleted) cached.event,
    ]..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Future<CalendarEventDetails> event(EventRef ref) async {
    if (!isLocal(ref)) {
      try {
        return await _remote.event(ref);
      } on ApiException catch (error) {
        if (!_offlineError(error)) rethrow;
      }
    }
    final series = await (await _cache).series(ref);
    final visible = [
      for (final cached in series)
        if (cached.state != CachedEventState.deleted) cached.event,
    ];
    if (visible.isEmpty) throw const NotFoundException();
    final main = visible.where((event) => event.ref.recurrenceId == null).firstOrNull ?? visible.first;
    return CalendarEventDetails(series: main.copyWith(ref: ref.series));
  }

  @override
  Future<CalendarEvent> create(CalendarRef calendar, EventDraft draft) =>
      _queue(() => _createLocal(calendar, CalendarCodec.draft(draft)), calendar);

  Future<CalendarEvent> _createLocal(CalendarRef calendar, Map<String, dynamic> draft) async {
    final uid = "${const Uuid().v4()}@polder";
    final event = _eventFrom(CalendarCodec.draftFrom(draft), EventRef(calendar: calendar, eventId: "$localPrefix$uid"));
    await (await _cache).save(event, CachedEventState.pending);
    await _enqueue(event.ref, {
      "type": CalendarChangeType.create.name,
      "calendar": CalendarCodec.calendarRef(calendar),
      "uid": uid,
      "draft": draft,
    });
    return event;
  }

  @override
  Future<CalendarEvent> update(CalendarEvent event, EventDraft draft, RecurrenceScope scope) => _queue(() async {
    final local = await _updateLocal(event, draft);
    if (local != null) return local;
    final target = await _serverVersionOf(event);
    final updated = await _applyUpdate(event, draft, scope);
    await _enqueue(target.ref, {
      "type": CalendarChangeType.update.name,
      "event": CalendarCodec.event(target),
      "draft": CalendarCodec.draft(draft),
      "scope": scope.name,
    });
    return updated;
  }, event.calendar);

  @override
  Future<void> delete(CalendarEvent event, RecurrenceScope scope) => _queue(() async {
    final cache = await _cache;
    if (isLocal(event.ref) && await _dropQueuedCreate(event.ref)) {
      await cache.removeSeries(event.ref);
      return;
    }
    final target = await _serverVersionOf(event);
    for (final cached in await _affected(event, scope)) {
      await cache.save(cached.event, CachedEventState.deleted);
    }
    await _enqueue(target.ref, {
      "type": CalendarChangeType.delete.name,
      "event": CalendarCodec.event(target),
      "scope": scope.name,
    });
  }, event.calendar);

  @override
  Future<CalendarEvent> move(CalendarEvent event, CalendarRef target) => _queue(() async {
    final cache = await _cache;
    final moved = event.copyWith(
      ref: EventRef(calendar: target, eventId: event.ref.eventId),
    );
    for (final cached in await cache.series(event.ref)) {
      await cache.remove(cached.key);
      final relocated = cached.event.copyWith(
        ref: EventRef(calendar: target, eventId: cached.event.ref.eventId, recurrenceId: cached.event.ref.recurrenceId),
      );
      await cache.save(relocated, CachedEventState.pending);
    }
    if (isLocal(event.ref) &&
        await _rewriteQueuedCreate(event.ref, (change) => {...change, "calendar": CalendarCodec.calendarRef(target)})) {
      return moved;
    }
    final source = await _serverVersionOf(event);
    await _enqueue(moved.ref, {
      "type": CalendarChangeType.move.name,
      "event": CalendarCodec.event(source),
      "target": CalendarCodec.calendarRef(target),
    });
    return moved;
  }, event.calendar);

  @override
  Future<void> respond(CalendarEvent event, AttendeeStatus status) => _queue(() async {
    final cache = await _cache;
    for (final cached in await cache.series(event.ref)) {
      final attendees = [
        for (final attendee in cached.event.attendees)
          attendee.person.self ? attendee.copyWith(status: status) : attendee,
      ];
      await cache.save(cached.event.copyWith(attendees: attendees), CachedEventState.pending);
    }
    final target = await _serverVersionOf(event);
    await _enqueue(target.ref, {
      "type": CalendarChangeType.respond.name,
      "event": CalendarCodec.event(target),
      "status": status.name,
    });
  }, event.calendar);

  @override
  Future<void> setHidden(CalendarRef calendar, bool hidden) => _remote.setHidden(calendar, hidden);

  Future<DateTime?> push() async {
    final store = await _store;
    var changed = false;
    try {
      final handled = <int>{};
      while (true) {
        final entry = [
          for (final queued in await store.outbox(OutboxDomain.calendar))
            if (!queued.blocked && !handled.contains(queued.id)) queued,
        ].firstOrNull;
        if (entry == null) return null;
        handled.add(entry.id);
        if (!entry.readyAt(_clock())) return entry.nextAttemptAt;
        _inFlight.add(entry.id);
        try {
          final result = await _execute((entry.op as CalendarOp).change);
          await _lock.run(() => _complete(entry, result));
          changed = true;
        } on Object catch (error) {
          final failure = OutboxErrors.classify(error);
          await _lock.run(() => _fail(entry, failure));
          changed = true;
          if (failure.kind.retries) return _clock().add(OutboxErrors.retryDelay(entry.attempts + 1));
        } finally {
          _inFlight.remove(entry.id);
        }
      }
    } finally {
      if (changed) _announceAll();
    }
  }

  Future<void> prefetch() async {
    final store = await _store;
    final last = DateTime.tryParse(await store.meta(_prefetchKey) ?? "");
    final now = _clock();
    if (last != null && now.difference(last) < prefetchEvery) return;
    final start = DateTime(now.year, now.month - 1);
    final middle = DateTime(now.year, now.month + 6);
    final end = DateTime(now.year, now.month + 12);
    await calendars();
    await events(DateTimeRange(start: start, end: middle));
    await events(DateTimeRange(start: middle, end: end));
    await store.saveMeta(_prefetchKey, now.toIso8601String());
  }

  Future<void> retryNow() => _lock.run(() async {
    final store = await _store;
    for (final entry in await store.outbox(OutboxDomain.calendar)) {
      if (entry.error?.kind.retries ?? entry.nextAttemptAt != null) {
        await store.saveEntry(entry.copyWith(nextAttemptAt: null));
      }
    }
  });

  Future<void> discard(int entryId) => _lock.run(() async {
    final store = await _store;
    final entry = (await store.outbox(OutboxDomain.calendar)).where((entry) => entry.id == entryId).firstOrNull;
    if (entry == null || _inFlight.contains(entry.id)) return;
    await store.removeEntry(entry.id);
    await _forgetOverlay(entry);
    _announceAll();
  });

  Future<void> resolve(int entryId, ConflictResolution resolution) => _lock.run(() async {
    final store = await _store;
    final entry = (await store.outbox(OutboxDomain.calendar)).where((entry) => entry.id == entryId).firstOrNull;
    if (entry == null) return;
    final change = (entry.op as CalendarOp).change;
    switch (resolution) {
      case ConflictResolution.keepMine:
        final unconditional = {
          ...change,
          if (change["event"] case final Map<String, dynamic> event) "event": {...event, "etag": ""},
        };
        await store.saveEntry(
          entry.copyWith(
            op: OutboxOp.calendar(eventKey: entry.path, change: unconditional),
            error: null,
            attempts: 0,
            nextAttemptAt: null,
          ),
        );
      case ConflictResolution.keepServer:
        await store.removeEntry(entry.id);
        await _forgetOverlay(entry);
      case ConflictResolution.keepBoth:
        await store.removeEntry(entry.id);
        await _forgetOverlay(entry);
        if (change["draft"] case final Map<String, dynamic> draft) {
          await _createLocal(CalendarCodec.eventFrom(change["event"] as Map<String, dynamic>).calendar, draft);
        }
    }
    _announceAll();
    _onQueued?.call();
  });

  static String summaryOf(OutboxEntry entry) {
    final change = (entry.op as CalendarOp).change;
    if (change["draft"] case final Map<String, dynamic> draft) return draft["summary"] as String? ?? "";
    if (change["event"] case final Map<String, dynamic> event) return event["summary"] as String? ?? "";
    return "";
  }

  Future<void> dispose() => _localChanges.close();

  Future<T> _queue<T>(Future<T> Function() change, CalendarRef calendar) async {
    final result = await _lock.run(change);
    if (!_localChanges.isClosed) _localChanges.add(calendar);
    _onQueued?.call();
    return result;
  }

  Future<void> _enqueue(EventRef ref, Map<String, dynamic> change) async => (await _store).enqueue(
    OutboxOp.calendar(eventKey: CalendarCache.keyOf(ref), change: change),
    at: _clock(),
  );

  Future<List<OutboxEntry>> _queuedFor(EventRef ref) async {
    final series = CalendarCache.seriesKeyOf(ref);
    return [
      for (final entry in await (await _store).outbox(OutboxDomain.calendar))
        if (entry.path.startsWith("$series/")) entry,
    ];
  }

  Future<OutboxEntry?> _queuedCreate(EventRef ref) async => [
    for (final entry in await _queuedFor(ref))
      if ((entry.op as CalendarOp).change["type"] == CalendarChangeType.create.name && !_inFlight.contains(entry.id))
        entry,
  ].firstOrNull;

  Future<bool> _dropQueuedCreate(EventRef ref) async {
    if (await _queuedCreate(ref) == null) return false;
    final store = await _store;
    for (final entry in await _queuedFor(ref)) {
      await store.removeEntry(entry.id);
    }
    return true;
  }

  Future<bool> _rewriteQueuedCreate(EventRef ref, Map<String, dynamic> Function(Map<String, dynamic>) rewrite) async {
    final entry = await _queuedCreate(ref);
    if (entry == null) return false;
    final updated = rewrite((entry.op as CalendarOp).change);
    final calendar = CalendarCodec.calendarRefFrom(updated["calendar"] as Map<String, dynamic>);
    final key = CalendarCache.keyOf(EventRef(calendar: calendar, eventId: ref.eventId));
    await (await _store).saveEntry(
      entry.copyWith(
        op: OutboxOp.calendar(eventKey: key, change: updated),
      ),
    );
    return true;
  }

  Future<CalendarEvent?> _updateLocal(CalendarEvent event, EventDraft draft) async {
    if (!isLocal(event.ref)) return null;
    if (!await _rewriteQueuedCreate(event.ref, (change) => {...change, "draft": CalendarCodec.draft(draft)})) {
      return null;
    }
    final updated = _eventFrom(draft, event.ref);
    await (await _cache).save(updated, CachedEventState.pending);
    return updated;
  }

  Future<CalendarEvent> _serverVersionOf(CalendarEvent event) async {
    if (!isLocal(event.ref)) return event;
    final known = await (await _store).meta("$_createdKey${event.ref.eventId}");
    if (known == null) return event;
    final created = CalendarCodec.eventRefFrom(jsonDecode(known) as Map<String, dynamic>);
    return event.copyWith(
      etag: "",
      ref: EventRef(calendar: created.calendar, eventId: created.eventId, recurrenceId: event.ref.recurrenceId),
    );
  }

  Future<CalendarEvent> _applyUpdate(CalendarEvent event, EventDraft draft, RecurrenceScope scope) async {
    final cache = await _cache;
    final shift = draft.start.difference(event.start);
    final duration = draft.end.difference(draft.start);
    CalendarEvent? edited;
    for (final cached in await _affected(event, scope)) {
      final start = cached.event.start.add(shift);
      final updated = _withDraft(cached.event, draft).copyWith(start: start, end: start.add(duration));
      if (cached.key == CalendarCache.keyOf(event.ref)) edited = updated;
      await cache.save(updated, CachedEventState.pending);
    }
    if (edited != null) return edited;
    final fallback = _withDraft(event, draft);
    await cache.save(fallback, CachedEventState.pending);
    return fallback;
  }

  Future<List<CachedEvent>> _affected(CalendarEvent event, RecurrenceScope scope) async {
    final cache = await _cache;
    if (!event.recurring || scope == RecurrenceScope.thisEvent) {
      final cached = await cache.event(CalendarCache.keyOf(event.ref));
      return [cached ?? CachedEvent(event, CachedEventState.synced)];
    }
    return [
      for (final cached in await cache.series(event.ref))
        if (scope == RecurrenceScope.all || !cached.event.start.isBefore(event.start)) cached,
    ];
  }

  Future<CalendarEvent?> _execute(Map<String, dynamic> change) async {
    final type = CalendarChangeType.values.byName(change["type"] as String);
    switch (type) {
      case CalendarChangeType.create:
        return _api.createCalendarEvent(
          CalendarCodec.calendarRefFrom(change["calendar"] as Map<String, dynamic>),
          CalendarCodec.draftFrom(change["draft"] as Map<String, dynamic>),
          uid: change["uid"] as String,
        );
      case CalendarChangeType.update:
        return _api.updateCalendarEvent(
          CalendarCodec.eventFrom(change["event"] as Map<String, dynamic>),
          CalendarCodec.draftFrom(change["draft"] as Map<String, dynamic>),
          RecurrenceScope.values.byName(change["scope"] as String),
        );
      case CalendarChangeType.delete:
        try {
          await _api.deleteCalendarEvent(
            CalendarCodec.eventFrom(change["event"] as Map<String, dynamic>),
            RecurrenceScope.values.byName(change["scope"] as String),
          );
        } on NotFoundException {
          return null;
        }
        return null;
      case CalendarChangeType.move:
        return _api.moveCalendarEvent(
          CalendarCodec.eventFrom(change["event"] as Map<String, dynamic>),
          CalendarCodec.calendarRefFrom(change["target"] as Map<String, dynamic>),
        );
      case CalendarChangeType.respond:
        final event = CalendarCodec.eventFrom(change["event"] as Map<String, dynamic>);
        await _api.respondToCalendarEvent(event, AttendeeStatus.values.byName(change["status"] as String));
        return event.copyWith(etag: "");
    }
  }

  Future<void> _complete(OutboxEntry entry, CalendarEvent? result) async {
    final store = await _store;
    await store.removeEntry(entry.id);
    final change = (entry.op as CalendarOp).change;
    if (result != null && change["type"] == CalendarChangeType.create.name) {
      final localId = entry.path.split("/")[1];
      await store.saveMeta("$_createdKey$localId", jsonEncode(CalendarCodec.eventRef(result.ref)));
    }
    final series = entry.path.substring(0, entry.path.lastIndexOf("/"));
    final later = [
      for (final other in await store.outbox(OutboxDomain.calendar))
        if (other.path.startsWith("$series/")) other,
    ];
    if (result != null) {
      for (final other in later) {
        await _rebase(other, result);
      }
    }
    final created = change["type"] == CalendarChangeType.create.name;
    if (later.isNotEmpty && !created) return;
    await _forgetOverlay(entry);
    final shown = later.isEmpty && change["type"] != CalendarChangeType.respond.name && result != null;
    if (shown && !result.recurring) await (await _cache).save(result, CachedEventState.synced);
  }

  Future<void> _rebase(OutboxEntry entry, CalendarEvent result) async {
    final change = (entry.op as CalendarOp).change;
    if (change["event"] case final Map<String, dynamic> json) {
      final queued = CalendarCodec.eventFrom(json);
      final rebased = queued.copyWith(
        etag: result.etag,
        ref: EventRef(calendar: result.calendar, eventId: result.ref.eventId, recurrenceId: queued.ref.recurrenceId),
      );
      final parts = entry.path.split("/")..[1] = result.ref.eventId;
      await (await _store).saveEntry(
        entry.copyWith(
          op: OutboxOp.calendar(eventKey: parts.join("/"), change: {...change, "event": CalendarCodec.event(rebased)}),
        ),
      );
    }
  }

  Future<void> _fail(OutboxEntry entry, OutboxError failure) async => (await _store).saveEntry(
    entry.copyWith(
      attempts: entry.attempts + 1,
      nextAttemptAt: failure.kind.retries ? _clock().add(OutboxErrors.retryDelay(entry.attempts + 1)) : null,
      error: failure,
    ),
  );

  Future<void> _forgetOverlay(OutboxEntry entry) async {
    final change = (entry.op as CalendarOp).change;
    final cache = await _cache;
    final parts = entry.path.split("/");
    final calendar = switch (change["calendar"] ?? change["target"]) {
      final Map<String, dynamic> json => CalendarCodec.calendarRefFrom(json),
      _ => CalendarCodec.eventFrom(change["event"] as Map<String, dynamic>).calendar,
    };
    final ref = EventRef(calendar: calendar, eventId: parts[1]);
    if (isLocal(ref)) {
      await cache.removeSeries(ref);
    } else {
      await cache.forgetLocalChanges(ref);
      if (change["event"] case final Map<String, dynamic> original) {
        await cache.forgetLocalChanges(CalendarCodec.eventFrom(original).ref);
      }
    }
  }

  void _announceAll() {
    if (_localChanges.isClosed) return;
    _localChanges.add(CalendarRef(sourceId: id, calendarId: "*"));
  }

  CalendarEvent _eventFrom(EventDraft draft, EventRef ref) => CalendarEvent(
    ref: ref,
    etag: "",
    summary: draft.summary,
    start: draft.start,
    end: draft.end,
    allDay: draft.allDay,
    description: draft.description,
    location: draft.location,
    url: draft.url,
    timezone: draft.timezone,
    rrule: draft.rrule,
    recurring: draft.rrule != null && draft.rrule!.isNotEmpty,
    status: draft.status,
    showAs: draft.showAs,
    attendees: [for (final person in draft.attendees) EventAttendee(person: person)],
    reminders: draft.reminders,
  );

  static CalendarEvent _withDraft(CalendarEvent event, EventDraft draft) => event.copyWith(
    summary: draft.summary,
    allDay: draft.allDay,
    description: draft.description,
    location: draft.location,
    url: draft.url,
    timezone: draft.timezone,
    rrule: draft.rrule,
    status: draft.status,
    showAs: draft.showAs,
    reminders: draft.reminders,
  );

  static bool _offlineError(ApiException error) =>
      error is NetworkException || error is UnavailableException || error is ServerException;
}

abstract final class StreamGroupMerge {
  static Stream<T> merge<T>(Stream<T> first, Stream<T> second) {
    late StreamController<T> controller;
    final subscriptions = <StreamSubscription<T>>[];
    controller = StreamController<T>.broadcast(
      onListen: () {
        subscriptions
          ..add(first.listen(controller.add, onError: controller.addError))
          ..add(second.listen(controller.add, onError: controller.addError));
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
        subscriptions.clear();
      },
    );
    return controller.stream;
  }
}
