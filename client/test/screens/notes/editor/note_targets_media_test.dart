import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/screens/notes/editor/note_embeds.dart";

void main() {
  FileEntry file(int id, String name, String mime) =>
      FileEntry(id: id, path: "/Notes/attachments/$name", name: name, mime: mime, mtime: DateTime.utc(2026));

  final first = file(1, "first.jpg", "image/jpeg");
  final clip = file(2, "clip.mp4", "video/mp4");
  final unused = file(3, "unused.jpg", "image/jpeg");
  final document = file(4, "plan.pdf", "application/pdf");
  final targets = NoteTargets(
    notePath: "/Notes/trip.md",
    byId: {
      for (final entry in [first, clip, unused, document]) entry.id: entry,
    },
  );

  const source = """
# Trip
![clip](attachments/clip.mp4?fileId=2)
Some text with [the plan](attachments/plan.pdf?fileId=4).
![first](attachments/first.jpg?fileId=1)
![again](attachments/clip.mp4?fileId=2)
![by path](attachments/loose.png)
""";

  test("the gallery holds the note's own photos and videos in the order they appear", () {
    expect(targets.mediaIn(source, opened: first), [clip, first]);
  });

  test("a file opened by path alone joins the gallery where the note embeds it", () {
    final loose = FileEntry(
      path: "/Notes/attachments/loose.png",
      name: "loose.png",
      mime: "image/png",
      mtime: DateTime.utc(2026),
    );
    expect(targets.mediaIn(source, opened: loose), [clip, first, loose]);
  });

  test("a file the note does not embed opens on its own", () {
    expect(targets.mediaIn(source, opened: unused), [unused]);
  });
}
