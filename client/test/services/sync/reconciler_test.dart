import "package:flutter_test/flutter_test.dart";

import "package:polder/models/sync/conflict.dart";
import "package:polder/models/sync/local_file_state.dart";
import "package:polder/models/sync/remote_state.dart";
import "package:polder/models/sync/sync_action.dart";
import "package:polder/models/sync/sync_entry.dart";
import "package:polder/models/sync/sync_root.dart";
import "package:polder/services/sync/reconciler.dart";

import "../../support/fixtures.dart";

void main() {
  List<SyncAction> reconcile({
    Map<String, LocalFileState> local = const {},
    Map<String, SyncEntry> synced = const {},
    Map<String, RemoteState> remote = const {},
    SyncMode mode = SyncMode.sync,
  }) => Reconciler(rootId: "root", mode: mode).reconcile(local: local, synced: synced, remote: remote);

  ConflictKind conflictKindOf(List<SyncAction> actions) => (actions.single as ConflictAction).conflict.kind;

  group("untracked paths", () {
    test("a new local file is uploaded as a new remote file", () {
      final actions = reconcile(local: {"a.txt": localFile("a.txt")});

      expect(actions.single, isA<UploadAction>().having((action) => action.baseRev, "baseRev", 0));
    });

    test("a new local directory is created remotely", () {
      expect(reconcile(local: {"docs": localDir("docs")}).single, isA<CreateRemoteDirAction>());
    });

    test("a new remote file is downloaded", () {
      final actions = reconcile(remote: {"a.txt": RemoteState.upserted(remoteFile("/a.txt"))});

      expect(actions.single, isA<DownloadAction>());
    });

    test("a new remote directory is created locally", () {
      final actions = reconcile(remote: {"docs": RemoteState.upserted(remoteDir("/docs"))});

      expect(actions.single, isA<CreateLocalDirAction>());
    });

    test("identical files created on both sides are just recorded", () {
      final actions = reconcile(
        local: {"a.txt": localFile("a.txt")},
        remote: {"a.txt": RemoteState.upserted(remoteFile("/a.txt"))},
      );

      expect(actions.single, isA<RecordSyncedAction>());
    });

    test("different files created on both sides conflict", () {
      final actions = reconcile(
        local: {"a.txt": localFile("a.txt", hash: "mine")},
        remote: {"a.txt": RemoteState.upserted(remoteFile("/a.txt", hash: "theirs"))},
      );

      expect(conflictKindOf(actions), ConflictKind.bothCreated);
    });

    test("a remote delete of something never synced is ignored", () {
      expect(reconcile(remote: {"gone.txt": const RemoteState.deleted()}), isEmpty);
    });
  });

  group("tracked files", () {
    test("an unchanged file produces no action", () {
      final actions = reconcile(local: {"a.txt": localFile("a.txt")}, synced: {"a.txt": syncedFile("a.txt")});

      expect(actions, isEmpty);
    });

    test("a local modification is uploaded against the synced rev", () {
      final actions = reconcile(
        local: {"a.txt": localFile("a.txt", hash: "h2")},
        synced: {"a.txt": syncedFile("a.txt", rev: 4)},
      );

      expect(actions.single, isA<UploadAction>().having((action) => action.baseRev, "baseRev", 4));
    });

    test("a remote modification is downloaded", () {
      final actions = reconcile(
        local: {"a.txt": localFile("a.txt")},
        synced: {"a.txt": syncedFile("a.txt")},
        remote: {"a.txt": RemoteState.upserted(remoteFile("/a.txt", hash: "h2", rev: 2))},
      );

      expect(actions.single, isA<DownloadAction>());
    });

    test("a remote rev bump without content change only records the new rev", () {
      final actions = reconcile(
        local: {"a.txt": localFile("a.txt")},
        synced: {"a.txt": syncedFile("a.txt")},
        remote: {"a.txt": RemoteState.upserted(remoteFile("/a.txt", rev: 2))},
      );

      expect(actions.single, isA<RecordSyncedAction>().having((action) => action.remote.rev, "rev", 2));
    });

    test("both sides changed differently is a conflict", () {
      final actions = reconcile(
        local: {"a.txt": localFile("a.txt", hash: "mine")},
        synced: {"a.txt": syncedFile("a.txt")},
        remote: {"a.txt": RemoteState.upserted(remoteFile("/a.txt", hash: "theirs", rev: 2))},
      );

      expect(conflictKindOf(actions), ConflictKind.bothModified);
      final conflict = (actions.single as ConflictAction).conflict;
      expect(conflict.local?.hash, "mine");
      expect(conflict.remote?.hash, "theirs");
    });

    test("both sides changed to identical content is recorded without conflict", () {
      final actions = reconcile(
        local: {"a.txt": localFile("a.txt", hash: "same")},
        synced: {"a.txt": syncedFile("a.txt")},
        remote: {"a.txt": RemoteState.upserted(remoteFile("/a.txt", hash: "same", rev: 2))},
      );

      expect(actions.single, isA<RecordSyncedAction>());
    });

    test("a local delete deletes remotely against the synced rev", () {
      final actions = reconcile(synced: {"a.txt": syncedFile("a.txt", rev: 3)});

      expect(actions.single, isA<DeleteRemoteAction>().having((action) => action.baseRev, "baseRev", 3));
    });

    test("a remote delete deletes locally", () {
      final actions = reconcile(
        local: {"a.txt": localFile("a.txt")},
        synced: {"a.txt": syncedFile("a.txt")},
        remote: {"a.txt": const RemoteState.deleted()},
      );

      expect(actions.single, isA<DeleteLocalAction>());
    });

    test("deleted on both sides is forgotten", () {
      final actions = reconcile(synced: {"a.txt": syncedFile("a.txt")}, remote: {"a.txt": const RemoteState.deleted()});

      expect(actions.single, isA<ForgetAction>());
    });
  });

  group("delete versus modify", () {
    test("local modify with remote delete is a conflict", () {
      final actions = reconcile(
        local: {"a.txt": localFile("a.txt", hash: "h2")},
        synced: {"a.txt": syncedFile("a.txt")},
        remote: {"a.txt": const RemoteState.deleted()},
      );

      expect(conflictKindOf(actions), ConflictKind.localModifiedRemoteDeleted);
    });

    test("local delete with remote modify is a conflict", () {
      final actions = reconcile(
        synced: {"a.txt": syncedFile("a.txt")},
        remote: {"a.txt": RemoteState.upserted(remoteFile("/a.txt", hash: "h2", rev: 2))},
      );

      expect(conflictKindOf(actions), ConflictKind.localDeletedRemoteModified);
    });
  });

  group("placeholders", () {
    test("a placeholder that is not on disk is not treated as a local delete", () {
      final actions = reconcile(synced: {"a.txt": syncedFile("a.txt", state: EntryState.placeholder)});

      expect(actions, isEmpty);
    });

    test("a remote change to a placeholder only updates its metadata", () {
      final actions = reconcile(
        synced: {"a.txt": syncedFile("a.txt", state: EntryState.placeholder)},
        remote: {"a.txt": RemoteState.upserted(remoteFile("/a.txt", hash: "h2", rev: 2))},
      );

      expect(actions.single, isA<UpdatePlaceholderAction>());
    });
  });

  group("directories", () {
    test("deleting a local directory deletes only the directory remotely", () {
      final actions = reconcile(
        synced: {"docs": syncedDir("docs"), "docs/a.txt": syncedFile("docs/a.txt"), "docs/b": syncedDir("docs/b")},
      );

      expect(actions.single, isA<DeleteRemoteAction>().having((action) => action.path, "path", "docs"));
    });

    test("a remotely deleted directory keeps new local files inside it", () {
      final actions = reconcile(
        local: {
          "docs": localDir("docs"),
          "docs/old.txt": localFile("docs/old.txt"),
          "docs/new.txt": localFile("docs/new.txt"),
        },
        synced: {"docs": syncedDir("docs"), "docs/old.txt": syncedFile("docs/old.txt")},
        remote: {"docs": const RemoteState.deleted(), "docs/old.txt": const RemoteState.deleted()},
      );

      expect(actions.map((action) => (action.runtimeType, action.path)), [
        (UploadAction, "docs/new.txt"),
        (DeleteLocalAction, "docs/old.txt"),
      ]);
    });

    test("directories are created before files and deletes run deepest first", () {
      final actions = reconcile(
        local: {
          "new": localDir("new"),
          "new/a.txt": localFile("new/a.txt"),
          "x": localDir("x"),
          "x/y": localDir("x/y"),
        },
        synced: {
          "x": syncedDir("x"),
          "x/y": syncedDir("x/y"),
          "x/y/z.txt": syncedFile("x/y/z.txt"),
          "top.txt": syncedFile("top.txt"),
        },
      );

      expect(actions.map((action) => action.path), ["new", "new/a.txt", "x/y/z.txt", "top.txt"]);
    });
  });

  group("auto-upload mode", () {
    test("uploads new and changed files but never deletes or downloads", () {
      final actions = reconcile(
        mode: SyncMode.autoUpload,
        local: {
          "new.jpg": localFile("new.jpg"),
          "changed.jpg": localFile("changed.jpg", hash: "h2"),
        },
        synced: {"changed.jpg": syncedFile("changed.jpg", rev: 2), "removed.jpg": syncedFile("removed.jpg")},
        remote: {"remote.jpg": RemoteState.upserted(remoteFile("/remote.jpg"))},
      );

      expect(actions.map((action) => (action.runtimeType, action.path)), [
        (UploadAction, "changed.jpg"),
        (UploadAction, "new.jpg"),
      ]);
    });
  });
}
