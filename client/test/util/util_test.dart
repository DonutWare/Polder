import "package:flutter_test/flutter_test.dart";

import "package:nomad/util/byte_format.dart";
import "package:nomad/util/conflict_file_name.dart";
import "package:nomad/util/quota_unit.dart";
import "package:nomad/util/remote_path.dart";

void main() {
  group("ConflictFileName", () {
    final at = DateTime(2026, 9, 30, 9, 7);

    test("inserts the suffix before the extension", () {
      expect(
        ConflictFileName.build("report.final.pdf", device: "Laptop", at: at),
        "report.final (conflict Laptop 2026-09-30 0907).pdf",
      );
    });

    test("appends the suffix when there is no extension", () {
      expect(
        ConflictFileName.build("Makefile", device: "Laptop", at: at),
        "Makefile (conflict Laptop 2026-09-30 0907)",
      );
      expect(ConflictFileName.build(".env", device: "Laptop", at: at), ".env (conflict Laptop 2026-09-30 0907)");
    });
  });

  group("RemotePath", () {
    test("joins, splits and relativizes", () {
      expect(RemotePath.join("/", "a"), "/a");
      expect(RemotePath.join("/a", "b"), "/a/b");
      expect(RemotePath.parent("/a/b"), "/a");
      expect(RemotePath.parent("/a"), "/");
      expect(RemotePath.name("/a/b.txt"), "b.txt");
      expect(RemotePath.ancestry("/a/b"), ["/", "/a", "/a/b"]);
      expect(RemotePath.relativeTo("/a/b/c", "/a"), "b/c");
      expect(RemotePath.relativeTo("/ab/c", "/a"), isNull);
      expect(RemotePath.relativeTo("/x", "/"), "x");
    });

    test("rejects names the protocol forbids", () {
      expect(RemotePath.isValidName("ok.txt"), isTrue);
      for (final name in ["", "..", "a/b", "a\\b", ".nomad-tmp"]) {
        expect(RemotePath.isValidName(name), isFalse, reason: name);
      }
    });
  });

  test("QuotaUnit picks the largest exact unit", () {
    expect(QuotaUnit.bestFor(2 * QuotaUnit.tb.bytes), QuotaUnit.tb);
    expect(QuotaUnit.bestFor(1536 * QuotaUnit.mb.bytes), QuotaUnit.mb);
    expect(QuotaUnit.bestFor(0), QuotaUnit.gb);
  });

  test("ByteFormat uses binary units", () {
    expect(ByteFormat.format(512, locale: "en"), "512 B");
    expect(ByteFormat.format(1536, locale: "en"), "1.5 KB");
    expect(ByteFormat.format(5 * 1024 * 1024 * 1024, locale: "en"), "5 GB");
  });
}
