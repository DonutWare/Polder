import "package:polder/util/build_channel.dart";

enum UpdateTarget { macos, windows, linux }

class UpdateAsset {
  const UpdateAsset({required this.name, required this.sha256, required this.size});

  factory UpdateAsset.fromJson(Map<String, dynamic> json) =>
      UpdateAsset(name: json["name"] as String, sha256: json["sha256"] as String, size: json["size"] as int);

  final String name;
  final String sha256;
  final int size;
}

class UpdateManifest {
  const UpdateManifest({
    required this.channel,
    required this.version,
    required this.build,
    required this.tag,
    required this.notesUrl,
    required this.assets,
  });

  factory UpdateManifest.fromJson(Map<String, dynamic> json) => UpdateManifest(
    channel: BuildChannel.parse(json["channel"] as String),
    version: json["version"] as String,
    build: json["build"] as int,
    tag: json["tag"] as String,
    notesUrl: Uri.parse(json["notesUrl"] as String),
    assets: {
      for (final MapEntry(:key, :value) in (json["assets"] as Map<String, dynamic>).entries)
        ?_target(key): UpdateAsset.fromJson(value as Map<String, dynamic>),
    },
  );

  final BuildChannel channel;
  final String version;
  final int build;
  final String tag;
  final Uri notesUrl;
  final Map<UpdateTarget, UpdateAsset> assets;

  Uri downloadUrl(UpdateAsset asset) => releaseDownloadUrl(tag, asset.name);

  static UpdateTarget? _target(String name) => UpdateTarget.values.asNameMap()[name];
}

const updateRepository = "DonutWare/Polder";

Uri releaseDownloadUrl(String tag, String file) =>
    Uri.https("github.com", "/$updateRepository/releases/download/$tag/$file");

Uri latestReleaseDownloadUrl(String file) =>
    Uri.https("github.com", "/$updateRepository/releases/latest/download/$file");
