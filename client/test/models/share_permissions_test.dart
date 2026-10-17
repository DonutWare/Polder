import "package:flutter_test/flutter_test.dart";

import "package:polder/models/sharing.dart";

void main() {
  const editor = SharePermissions(create: true, edit: true, delete: true);

  test("presets", () {
    expect(SharePermissions.viewOnly.isViewOnly, isTrue);
    expect(editor.isEditor, isTrue);
    expect(const SharePermissions(edit: true).isEditor, isFalse);
  });

  test("files never get create or delete", () {
    expect(editor.forEntry(isDir: false), const SharePermissions(edit: true));
    expect(editor.forEntry(isDir: true), editor);
  });
}
