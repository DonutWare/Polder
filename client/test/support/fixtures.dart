import "package:nomad/models/file_entry.dart";
import "package:nomad/models/sync/local_file_state.dart";
import "package:nomad/models/sync/sync_entry.dart";

final fixedTime = DateTime.utc(2026, 9, 30, 12);

LocalFileState localFile(String path, {String hash = "h1", int size = 10}) =>
    LocalFileState(relativePath: path, size: size, mtime: fixedTime, hash: hash);

LocalFileState localDir(String path) => LocalFileState(relativePath: path, isDir: true, mtime: fixedTime);

SyncEntry syncedFile(String path, {String hash = "h1", int rev = 1, EntryState state = EntryState.hydrated}) =>
    SyncEntry(
      syncRootId: "root",
      relativePath: path,
      localHash: hash,
      localSize: 10,
      localMtime: fixedTime,
      syncedRev: rev,
      syncedHash: hash,
      state: state,
    );

SyncEntry syncedDir(String path, {int rev = 1}) =>
    SyncEntry(syncRootId: "root", relativePath: path, isDir: true, syncedRev: rev);

FileEntry remoteFile(String path, {String hash = "h1", int rev = 1}) =>
    FileEntry(path: path, name: path.split("/").last, size: 10, mtime: fixedTime, rev: rev, hash: hash);

FileEntry remoteDir(String path, {int rev = 1}) =>
    FileEntry(path: path, name: path.split("/").last, isDir: true, mtime: fixedTime, rev: rev);
