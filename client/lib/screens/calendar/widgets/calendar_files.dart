import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/service_providers.dart";
import "package:polder/services/transfer/file_picker_service.dart";

final _calendarExtension = RegExp(r"\.(ics|ical|icalendar|ifb|zip)$", caseSensitive: false);

String calendarNameFromFile(String fileName) => fileName.replaceFirst(_calendarExtension, "");

Future<PickedFile?> pickCalendarFile(WidgetRef ref) async =>
    (await ref.read(filePickerServiceProvider).pickFiles()).firstOrNull;

Future<Uint8List> readCalendarFile(PickedFile file) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in file.openRead()) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}
