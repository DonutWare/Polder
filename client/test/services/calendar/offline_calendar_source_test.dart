import "dart:async";

import "package:drift/native.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:polder/models/offline_models.dart";
import "package:polder/models/sync/conflict.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/calendar/offline_calendar_source.dart";
import "package:polder/services/calendar/polder_calendar_source.dart";
import "package:polder/services/offline/offline_database.dart";
import "package:polder/services/offline/offline_store.dart";
import "package:polder_calendar/polder_calendar.dart";

import "../../support/scripted_client.dart";

class _FakeCalendarServer {
  final events = <int, Map<String, dynamic>>{};
  final ifMatches = <String?>[];
  var unreachable = false;
  ({int status, String code})? failWrites;
  var _nextId = 100;
  var _etag = 0;

  Map<String, dynamic> add(String summary, DateTime start, {String? uid}) {
    final id = _nextId++;
    final event = {
      "id": id,
      "calendarId": 3,
      "uid": uid ?? "uid-$id",
      "etag": "\"e${_etag++}\"",
      "summary": summary,
      "start": start.toUtc().toIso8601String(),
      "end": start.add(const Duration(hours: 1)).toUtc().toIso8601String(),
      "allDay": false,
      "recurring": false,
      "override": false,
      "sequence": 0,
      "showAs": "busy",
      "status": "CONFIRMED",
      "busyOnly": false,
      "attendees": <Object>[],
      "alarms": <Object>[],
      "updatedAt": DateTime.utc(2026).toIso8601String(),
    };
    events[id] = event;
    return event;
  }

  void editElsewhere(int id, String summary) {
    events[id] = {...events[id]!, "summary": summary, "etag": "\"e${_etag++}\""};
  }

  Map<String, dynamic> get calendar => {
    "id": 3,
    "uri": "personal",
    "name": "Personal",
    "description": "",
    "color": "#3366ff",
    "timezone": "UTC",
    "order": 0,
    "kind": "local",
    "access": "owner",
    "hidden": false,
    "notify": true,
    "isDefault": true,
    "createdAt": DateTime.utc(2026).toIso8601String(),
    "updatedAt": DateTime.utc(2026).toIso8601String(),
  };

  Future<http.StreamedResponse> handle(RecordedRequest request) async {
    if (unreachable) throw http.ClientException("Connection refused", request.url);
    final segments = request.path.split("/").where((segment) => segment.isNotEmpty).toList();
    if (request.method != "GET" && failWrites != null) {
      return jsonResponse(failWrites!.status, {
        "error": {"code": failWrites!.code, "message": failWrites!.code},
      });
    }
    return switch ((request.method, segments)) {
      ("GET", ["calendars"]) => jsonResponse(200, [calendar]),
      ("GET", ["calendars", "events"]) => jsonResponse(200, events.values.toList()),
      ("POST", ["calendars", "3", "events"]) => _create(request.data! as Map<String, dynamic>),
      ("PUT", ["calendars", "3", "events", final id]) => _update(int.parse(id), request),
      ("DELETE", ["calendars", "3", "events", final id]) => _delete(int.parse(id), request),
      _ => jsonResponse(404, {
        "error": {"code": "not_found", "message": "no route"},
      }),
    };
  }

  http.StreamedResponse _create(Map<String, dynamic> input) {
    final uid = input["uid"] as String?;
    final existing = events.values.where((event) => uid != null && event["uid"] == uid).firstOrNull;
    final event = existing ?? add(input["summary"] as String, DateTime.parse(input["start"] as String), uid: uid);
    return jsonResponse(200, {...event, "overrides": <Object>[]});
  }

  http.StreamedResponse? _precondition(int id, RecordedRequest request) {
    final ifMatch = request.headers["if-match"] ?? request.headers["If-Match"];
    ifMatches.add(ifMatch);
    if (ifMatch != null && ifMatch.isNotEmpty && ifMatch != events[id]!["etag"]) {
      return jsonResponse(412, {
        "error": {"code": "precondition_failed", "message": "the event has changed"},
      });
    }
    return null;
  }

  http.StreamedResponse _notFound() => jsonResponse(404, {
    "error": {"code": "not_found"},
  });

  http.StreamedResponse _update(int id, RecordedRequest request) {
    if (!events.containsKey(id)) return _notFound();
    final rejected = _precondition(id, request);
    if (rejected != null) return rejected;
    final input = request.data! as Map<String, dynamic>;
    events[id] = {...events[id]!, "summary": input["summary"], "etag": "\"e${_etag++}\""};
    return jsonResponse(200, {...events[id]!, "overrides": <Object>[]});
  }

  http.StreamedResponse _delete(int id, RecordedRequest request) {
    if (!events.containsKey(id)) return _notFound();
    final rejected = _precondition(id, request);
    if (rejected != null) return rejected;
    events.remove(id);
    return emptyResponse(204);
  }
}

void main() {
  late _FakeCalendarServer server;
  late OfflineStore store;
  late OfflineCalendarSource source;
  const calendar = CalendarRef(sourceId: "polder:alice", calendarId: "3");
  final november = DateTimeRange(start: DateTime(2026, 11), end: DateTime(2026, 12));
  final meeting = DateTime(2026, 11, 12, 10);

  setUp(() {
    server = _FakeCalendarServer();
    final api = PolderApi(ApiClientFactory.create("https://cloud.test", httpClient: ScriptedClient(server.handle)));
    store = OfflineStore(OfflineDatabase(NativeDatabase.memory()));
    source = OfflineCalendarSource(
      remote: PolderCalendarSource(api, id: "polder:alice", label: "alice", changes: const Stream.empty()),
      api: api,
      store: Future.value(store),
    );
  });

  tearDown(() async {
    await source.dispose();
    await store.close();
  });

  Future<List<String>> summaries() async => [for (final event in await source.events(november)) event.summary];

  EventDraft draft(String summary, [DateTime? start]) =>
      EventDraft(summary: summary, start: start ?? meeting, end: (start ?? meeting).add(const Duration(hours: 1)));

  Future<List<OutboxEntry>> queued() => store.outbox(OutboxDomain.calendar);

  test("events seen online are shown while the server is unreachable", () async {
    server.add("Dentist", meeting);
    expect(await summaries(), ["Dentist"]);
    await source.calendars();

    server.unreachable = true;

    expect(await summaries(), ["Dentist"]);
    expect((await source.calendars()).single.name, "Personal");
  });

  test("events removed on the server disappear from the cache on the next fetch", () async {
    final old = server.add("GFT+E", meeting);
    await summaries();
    server.events.remove(old["id"]);
    server.add("GFT+E", meeting);

    await summaries();
    server.unreachable = true;

    expect(await summaries(), ["GFT+E"]);
  });

  test("a month never seen online still reports that the server is unreachable", () async {
    server.unreachable = true;

    expect(source.events(november), throwsA(anything));
  });

  test("an event created offline shows at once and is created once the server is back", () async {
    server.add("Dentist", meeting);
    await summaries();
    server.unreachable = true;

    final created = await source.create(calendar, draft("Lunch", meeting.add(const Duration(hours: 3))));

    expect(OfflineCalendarSource.isLocal(created.ref), isTrue);
    expect(await summaries(), ["Dentist", "Lunch"]);
    expect(await source.push(), isNotNull);
    expect((await queued()).single.error!.kind, OutboxErrorKind.unreachable);

    server.unreachable = false;
    await clearBackoff(store);
    await source.push();

    expect(server.events.values.map((event) => event["summary"]), containsAll(["Dentist", "Lunch"]));
    expect(await queued(), isEmpty);
    expect(await summaries(), ["Dentist", "Lunch"]);
  });

  test("replaying a create that already reached the server does not duplicate it", () async {
    await summaries();
    await source.create(calendar, draft("Lunch"));
    final uid = ((await queued()).single.op as CalendarOp).change["uid"] as String;
    server.add("Lunch", meeting, uid: uid);

    await source.push();

    expect(server.events.values.where((event) => event["summary"] == "Lunch"), hasLength(1));
  });

  test("editing or deleting an event that was never synced changes the queued create", () async {
    await summaries();
    final created = await source.create(calendar, draft("Lunch"));
    final edited = await source.update(created, draft("Long lunch"), RecurrenceScope.all);
    expect(await queued(), hasLength(1));
    expect(await summaries(), ["Long lunch"]);

    await source.delete(edited, RecurrenceScope.all);

    expect(await queued(), isEmpty);
    expect(await summaries(), isEmpty);
  });

  test("an offline edit is shown at once and sent with the version it was based on", () async {
    server.add("Dentist", meeting);
    final event = (await source.events(november)).single;
    server.unreachable = true;

    await source.update(event, draft("Dentist, moved"), RecurrenceScope.thisEvent);

    expect(await summaries(), ["Dentist, moved"]);
    server.unreachable = false;
    await source.push();
    expect(server.events.values.single["summary"], "Dentist, moved");
    expect(server.ifMatches.single, event.etag);
  });

  test("two offline edits to the same event both reach the server without a conflict", () async {
    server.add("Dentist", meeting);
    final event = (await source.events(november)).single;
    server.unreachable = true;

    final first = await source.update(event, draft("Dentist, moved"), RecurrenceScope.thisEvent);
    await source.update(first, draft("Dentist, moved again"), RecurrenceScope.thisEvent);
    server.unreachable = false;
    await source.push();

    expect(server.events.values.single["summary"], "Dentist, moved again");
    expect(await queued(), isEmpty);
  });

  test("an event created offline stays visible offline after it synced", () async {
    await summaries();
    await source.create(calendar, draft("Lunch"));
    await source.push();
    server.unreachable = true;

    expect(await summaries(), ["Lunch"]);
  });

  test("an event changed on the server meanwhile becomes a conflict the user resolves", () async {
    final added = server.add("Dentist", meeting);
    final event = (await source.events(november)).single;
    await source.update(event, draft("Mine"), RecurrenceScope.thisEvent);
    server.editElsewhere(added["id"] as int, "Theirs");

    await source.push();

    final entry = (await queued()).single;
    expect(entry.error!.kind, OutboxErrorKind.conflict);
    expect(server.events.values.single["summary"], "Theirs");

    await source.resolve(entry.id, ConflictResolution.keepMine);
    await source.push();

    expect(server.events.values.single["summary"], "Mine");
    expect(await queued(), isEmpty);
  });

  test("keeping the server version drops the local edit", () async {
    final added = server.add("Dentist", meeting);
    final event = (await source.events(november)).single;
    await source.update(event, draft("Mine"), RecurrenceScope.thisEvent);
    server.editElsewhere(added["id"] as int, "Theirs");
    await source.push();

    await source.resolve((await queued()).single.id, ConflictResolution.keepServer);

    expect(await queued(), isEmpty);
    expect(await summaries(), ["Theirs"]);
  });

  test("a delete made offline hides the event and reaches the server later", () async {
    server.add("Dentist", meeting);
    final event = (await source.events(november)).single;
    server.unreachable = true;

    await source.delete(event, RecurrenceScope.all);

    expect(await summaries(), isEmpty);
    server.unreachable = false;
    await source.push();
    expect(server.events, isEmpty);
  });

  test("a server that cannot store keeps the change queued and retries it", () async {
    await summaries();
    server.failWrites = (status: 507, code: "storage_full");

    await source.create(calendar, draft("Lunch"));
    await source.push();

    final entry = (await queued()).single;
    expect(entry.error!.kind, OutboxErrorKind.storageFull);
    expect(entry.error!.kind.retries, isTrue);
    expect(await summaries(), ["Lunch"]);
  });
}

Future<void> clearBackoff(OfflineStore store) async {
  for (final entry in await store.outbox(OutboxDomain.calendar)) {
    await store.saveEntry(entry.copyWith(nextAttemptAt: null));
  }
}
