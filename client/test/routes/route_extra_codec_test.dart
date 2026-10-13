import "dart:convert";

import "package:flutter_test/flutter_test.dart";

import "package:polder/models/document_editor.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_version.dart";
import "package:polder/models/scan_session.dart";
import "package:polder/routes/route_extra_codec.dart";

void main() {
  const codec = RouteExtraCodec();
  final entry = FileEntry(id: 3, path: "/report.pdf", name: "report.pdf", mtime: DateTime.utc(2026, 10, 12));

  // The router stores the encoded extra as JSON, so the round trip goes through a string.
  Object? roundTrip(Object? extra) => codec.decode(jsonDecode(jsonEncode(codec.encode(extra))));

  test("keeps a file entry", () {
    expect(roundTrip(entry), entry);
  });

  test("keeps an editor target with its version", () {
    final version = FileVersion(
      id: 7,
      size: 12,
      hash: "abc",
      modifiedAt: DateTime.utc(2026, 10, 1),
      replacedAt: DateTime.utc(2026, 10, 2),
    );
    final restored = roundTrip(EditorTarget(entry, version: version))! as EditorTarget;
    expect(restored.entry, entry);
    expect(restored.version, version);
  });

  test("keeps a scan request", () {
    final restored = roundTrip(const ScanRequest(directory: "/scans", pages: ["/tmp/a.jpg"]))! as ScanRequest;
    expect(restored.directory, "/scans");
    expect(restored.pages, ["/tmp/a.jpg"]);
  });

  test("reads anything else as nothing", () {
    expect(codec.decode({"path": "/report.pdf"}), isNull);
    expect(codec.encode("other"), isNull);
  });
}
