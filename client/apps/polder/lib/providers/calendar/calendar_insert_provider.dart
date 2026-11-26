import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/shortcuts/app_shortcut_runner.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder_core/services/calendar/calendar_insert_request.dart";

const _channel = MethodChannel("polder/calendar_insert");

final calendarInsertHandlerProvider = Provider<void>((ref) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  void open(Object? arguments) {
    final request = CalendarInsertRequest.fromMap(arguments);
    if (request == null) return;
    unawaited(ref.read(appShortcutRunnerProvider).perform(AppRoutes.calendar, request.open));
  }

  _channel.setMethodCallHandler((call) async {
    if (call.method == "insert") open(call.arguments);
  });
  unawaited(_channel.invokeMethod<Object?>("takePending").then(open));
  ref.onDispose(() => _channel.setMethodCallHandler(null));
});
