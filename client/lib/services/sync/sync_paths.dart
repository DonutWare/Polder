import "dart:io";

import "package:path/path.dart" as p;

import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/util/remote_path.dart";

class SyncPaths {
  const SyncPaths(this.root);

  final SyncRoot root;

  String localPath(String relativePath) => p.joinAll([root.localPath, ...relativePath.split("/")]);

  File file(String relativePath) => File(localPath(relativePath));

  Directory directory(String relativePath) => Directory(localPath(relativePath));

  String remotePath(String relativePath) => RemotePath.join(root.remotePath, relativePath);

  String relativePath(String absoluteLocalPath) =>
      p.split(p.relative(absoluteLocalPath, from: root.localPath)).join("/");
}
