import "dart:convert";

import "package:polder/models/document_editor.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_version.dart";
import "package:polder/models/scan_session.dart";

/// Turns the objects routes take as `extra` into JSON and back, so they survive when the router
/// restores its history, as it does on the web and after the app is brought back by the system.
/// Without it the router keeps only what `jsonEncode` makes of them, which reads back as a map.
class RouteExtraCodec extends Codec<Object?, Object?> {
  const RouteExtraCodec();

  @override
  Converter<Object?, Object?> get encoder => const _Encoder();

  @override
  Converter<Object?, Object?> get decoder => const _Decoder();
}

class _Encoder extends Converter<Object?, Object?> {
  const _Encoder();

  @override
  Object? convert(Object? input) => switch (input) {
    final FileEntry entry => {"type": "file", "entry": entry.toJson()},
    final EditorTarget target => {
      "type": "editor",
      "entry": target.entry.toJson(),
      if (target.version case final version?)
        "version": {
          "id": version.id,
          "size": version.size,
          "hash": version.hash,
          "modifiedAt": version.modifiedAt.toIso8601String(),
          "replacedAt": version.replacedAt.toIso8601String(),
          "hasPreview": version.hasPreview,
        },
    },
    final ScanRequest request => {"type": "scan", "directory": request.directory, "pages": request.pages},
    _ => null,
  };
}

class _Decoder extends Converter<Object?, Object?> {
  const _Decoder();

  @override
  Object? convert(Object? input) {
    if (input is! Map) return null;
    final json = input.cast<String, dynamic>();
    try {
      return switch (json["type"]) {
        "file" => _entry(json["entry"]),
        "editor" => EditorTarget(_entry(json["entry"]), version: _version(json["version"])),
        "scan" => ScanRequest(directory: json["directory"] as String, pages: (json["pages"] as List).cast<String>()),
        _ => null,
      };
    } on Object {
      // A history entry written by an older version of the app; the route sends it back to the files.
      return null;
    }
  }

  static FileEntry _entry(Object? json) => FileEntry.fromJson((json! as Map).cast<String, dynamic>());

  static FileVersion? _version(Object? json) {
    if (json is! Map) return null;
    return FileVersion(
      id: json["id"] as int,
      size: json["size"] as int,
      hash: json["hash"] as String,
      modifiedAt: DateTime.parse(json["modifiedAt"] as String),
      replacedAt: DateTime.parse(json["replacedAt"] as String),
      hasPreview: json["hasPreview"] as bool,
    );
  }
}
