import "package:flutter_test/flutter_test.dart";

import "package:nomad/models/change.dart";
import "package:nomad/models/sync/remote_state.dart";
import "package:nomad/services/sync/remote_change_set.dart";

import "../../support/fixtures.dart";

void main() {
  Change upsert(int seq, String path) => Change(seq: seq, type: ChangeType.upsert, path: path, entry: remoteFile(path));

  Change delete(int seq, String path) => Change(seq: seq, type: ChangeType.delete, path: path);

  Change move(int seq, String from, String to, {bool superseded = false, bool dir = false}) => Change(
    seq: seq,
    type: ChangeType.move,
    path: to,
    fromPath: from,
    entry: superseded ? null : (dir ? remoteDir(to) : remoteFile(to)),
  );

  String describe(RemoteMove move) => "${move.from} -> ${move.to} @${move.entry.rev}";

  test("only keeps changes under the remote root, relative to it", () {
    final set = RemoteChangeSet(remoteRoot: "/Docs", synced: const {})
      ..applyAll([upsert(1, "/Docs/a.txt"), upsert(2, "/Other/b.txt"), upsert(3, "/Docs")]);

    expect(set.states.keys, ["a.txt"]);
  });

  test("a directory delete marks every synced descendant deleted", () {
    final set = RemoteChangeSet(
      remoteRoot: "/",
      synced: {"dir": syncedDir("dir"), "dir/a.txt": syncedFile("dir/a.txt"), "dir2/b.txt": syncedFile("dir2/b.txt")},
    )..apply(delete(1, "/dir"));

    expect(set.states, {"dir": const RemoteState.deleted(), "dir/a.txt": const RemoteState.deleted()});
  });

  test("a delete and an unrelated upsert stay independent changes", () {
    final set = RemoteChangeSet(remoteRoot: "/", synced: {"old.txt": syncedFile("old.txt")})
      ..applyAll([delete(1, "/old.txt"), upsert(2, "/new.txt")]);

    expect(set.states["old.txt"], const RemoteState.deleted());
    expect(set.states["new.txt"], isA<RemoteUpserted>());
  });

  test("later changes win", () {
    final set = RemoteChangeSet(remoteRoot: "/", synced: const {})
      ..applyAll([delete(1, "/a.txt"), upsert(2, "/a.txt")]);

    expect(set.states["a.txt"], isA<RemoteUpserted>());
  });

  group("moves", () {
    test("a rename deletes the source, upserts the target and is reported as a move", () {
      final set = RemoteChangeSet(remoteRoot: "/", synced: {"old.txt": syncedFile("old.txt")})
        ..apply(move(1, "/old.txt", "/new.txt"));

      expect(set.states["old.txt"], const RemoteState.deleted());
      expect(set.states["new.txt"], isA<RemoteUpserted>());
      expect(set.moves.map(describe), ["/old.txt -> /new.txt @1"]);
    });

    test("moves out of the root are still reported, so another sync root can pick them up", () {
      final set = RemoteChangeSet(remoteRoot: "/Docs", synced: {"a.txt": syncedFile("a.txt")})
        ..apply(move(1, "/Docs/a.txt", "/Photos/a.txt"));

      expect(set.states, {"a.txt": const RemoteState.deleted()});
      expect(set.moves.map(describe), ["/Docs/a.txt -> /Photos/a.txt @1"]);
    });

    test("a superseded move takes the entry of the change that superseded it", () {
      final edited = Change(seq: 2, type: ChangeType.upsert, path: "/b.txt", entry: remoteFile("/b.txt", rev: 2));
      final set = RemoteChangeSet(remoteRoot: "/", synced: const {})
        ..applyAll([move(1, "/a.txt", "/b.txt", superseded: true), edited]);

      expect(set.moves.map(describe), ["/a.txt -> /b.txt @2"]);
    });

    test("consecutive moves collapse into one from the original path", () {
      final set = RemoteChangeSet(remoteRoot: "/", synced: const {})
        ..applyAll([move(1, "/a.txt", "/b.txt", superseded: true), move(2, "/b.txt", "/c.txt")]);

      expect(set.moves.map(describe), ["/a.txt -> /c.txt @1"]);
      expect(set.states["b.txt"], const RemoteState.deleted());
    });

    test("a moved file that is deleted afterwards is no move", () {
      final set = RemoteChangeSet(remoteRoot: "/", synced: const {})
        ..applyAll([move(1, "/dir/a.txt", "/other/a.txt", superseded: true), delete(2, "/other")]);

      expect(set.moves, isEmpty);
    });

    test("a file created where one moved away from has no local origin", () {
      final set = RemoteChangeSet(remoteRoot: "/", synced: const {})
        ..applyAll([move(1, "/a.txt", "/b.txt"), upsert(2, "/a.txt")]);

      expect(set.moves.map(describe), ["/a.txt -> /b.txt @1"]);
      expect(set.states["a.txt"], isA<RemoteUpserted>());
    });

    test("directories are not moves themselves; their files are", () {
      final set = RemoteChangeSet(remoteRoot: "/", synced: const {})
        ..applyAll([move(1, "/Photos", "/Pictures", dir: true), move(2, "/Photos/a.jpg", "/Pictures/a.jpg")]);

      expect(set.moves.map(describe), ["/Photos/a.jpg -> /Pictures/a.jpg @1"]);
    });
  });
}
