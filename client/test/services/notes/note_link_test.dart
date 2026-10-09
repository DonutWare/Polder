import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/services/notes/note_link.dart";

FileEntry _file(int id, String path) => FileEntry(
  id: id,
  path: path,
  name: path.split("/").last,
  mtime: DateTime.utc(2026),
  mime: path.endsWith(".md") ? markdownMime : "image/png",
);

void main() {
  const note = "/Notes/Projects/Plan.md";

  test("reads relative, absolute and id links", () {
    final relative = NoteLink.parse("../Ideas/Big%20idea.md?fileId=12#part", notePath: note)!;
    expect(relative.path, "/Notes/Ideas/Big idea.md");
    expect(relative.fileId, 12);
    expect(relative.fragment, "part");

    expect(NoteLink.parse("/Docs/x.pdf", notePath: note)!.path, "/Docs/x.pdf");
    expect(NoteLink.parse("../../../../escape.md", notePath: note)!.path, "/escape.md");
    expect(NoteLink.parse("attachments/图.png", notePath: note)!.path, "/Notes/Projects/attachments/图.png");
  });

  test("ignores web links and anchors", () {
    expect(NoteLink.parse("https://example.com/a.md", notePath: note), isNull);
    expect(NoteLink.parse("mailto:a@b.c", notePath: note), isNull);
    expect(NoteLink.parse("#heading", notePath: note), isNull);
  });

  test("writes links relative to the note with the target id", () {
    expect(NoteLink.destinationFor(_file(5, "/Notes/Projects/Budget.md"), notePath: note), "Budget.md?fileId=5");
    expect(
      NoteLink.destinationFor(_file(6, "/Docs/Q1 report.pdf"), notePath: note),
      "../../Docs/Q1%20report.pdf?fileId=6",
    );
    expect(NoteLink.destinationFor(_file(7, "/Notes/Projects/Plan/Sub.md"), notePath: note), "Plan/Sub.md?fileId=7");
    expect(
      NoteLink.destinationFor(_file(8, "/Notes/Projects/report (final)!.pdf"), notePath: note),
      "report%20%28final%29%21.pdf?fileId=8",
    );
  });

  test("written links read back to their target", () {
    for (final target in [
      "/Notes/Projects/Budget.md",
      "/Docs/Q1 report.pdf",
      "/a b/c#d.md",
      "/Notes/Projects/Plan/Sub.md",
    ]) {
      final destination = NoteLink.destinationFor(_file(1, target), notePath: note);
      expect(NoteLink.parse(destination, notePath: note)!.path, target);
    }
  });

  test("finds inline links outside code", () {
    const source =
        "See [plan](Plan.md?fileId=1) and ![img](<a b.png>).\n```\n[skip](x.md)\n```\n[last](y.md \"title\")";
    final links = findSourceLinks(source);
    expect(links.map((link) => link.destination), ["Plan.md?fileId=1", "a b.png", "y.md"]);
    for (final link in links) {
      expect(source.substring(link.start, link.end), link.destination);
    }
  });

  test("points moved links at the target's new path", () {
    const source = "A [plan](Old.md?fileId=3#top) and [web](https://x.y) and [same](Budget.md?fileId=5)\n";
    final rewritten = updateLinks(
      source,
      notePath: note,
      current: {3: _file(3, "/Notes/Archive/New name.md"), 5: _file(5, "/Notes/Projects/Budget.md")},
    );
    expect(
      rewritten,
      "A [plan](../Archive/New%20name.md?fileId=3#top) and [web](https://x.y) and [same](Budget.md?fileId=5)\n",
    );
  });

  test("labels that repeat the file name follow renames, chosen labels stay", () {
    const source =
        "[Old](Old.md?fileId=3) [Old.md](Old.md?fileId=3) [my plan](Old.md?fileId=3) "
        "![scan.png](scan.png?fileId=4) [](Old.md?fileId=3) ![](scan.png?fileId=4) [](Budget.md?fileId=5)\n";
    final rewritten = updateLinks(
      source,
      notePath: note,
      current: {
        3: _file(3, "/Notes/Projects/Roadmap [v2].md"),
        4: _file(4, "/Notes/Projects/photo.png"),
        5: _file(5, "/Notes/Projects/Budget.md"),
      },
    );
    expect(
      rewritten,
      "[Roadmap \\[v2\\]](Roadmap%20%5Bv2%5D.md?fileId=3) [Roadmap \\[v2\\].md](Roadmap%20%5Bv2%5D.md?fileId=3) "
      "[my plan](Roadmap%20%5Bv2%5D.md?fileId=3) ![photo.png](photo.png?fileId=4) "
      "[Roadmap \\[v2\\]](Roadmap%20%5Bv2%5D.md?fileId=3) ![photo.png](photo.png?fileId=4) [Budget](Budget.md?fileId=5)\n",
    );
  });
}
