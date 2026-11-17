import "package:polder/util/remote_path.dart";

class SharedFile {
  const SharedFile({required this.uri, required this.name});

  final String uri;
  final String name;
}

class SharedContent {
  const SharedContent({this.files = const [], this.text, this.subject});

  static const fallbackFileName = "Shared file";
  static const fallbackTextName = "Shared text";

  static SharedContent? fromMap(Object? arguments) {
    if (arguments is! Map) return null;
    final taken = <String>{};
    final files = [
      for (final file in arguments["files"] as List? ?? const [])
        if (file is Map && file["uri"] is String)
          SharedFile(uri: file["uri"] as String, name: _unique(_fileName(file["name"], file["extension"]), taken)),
    ];
    final text = _text(arguments["text"]);
    if (files.isEmpty && text == null) return null;
    return SharedContent(files: files, text: text, subject: _text(arguments["subject"]));
  }

  final List<SharedFile> files;
  final String? text;
  final String? subject;

  bool get isText => files.isEmpty;

  int get count => isText ? 1 : files.length;

  String get textFileName => "${_safeName(subject) ?? fallbackTextName}.txt";

  static String _fileName(Object? name, Object? extension) {
    final base = _safeName(name) ?? fallbackFileName;
    if (RemotePath.extension(base).isNotEmpty || extension is! String || extension.isEmpty) return base;
    return "$base.$extension";
  }

  static String _unique(String name, Set<String> taken) {
    var candidate = name;
    for (var copy = 2; !taken.add(candidate.toLowerCase()); copy++) {
      final extension = RemotePath.extension(name);
      final base = RemotePath.withoutExtension(name);
      candidate = extension.isEmpty ? "$base ($copy)" : "$base ($copy).$extension";
    }
    return candidate;
  }

  static String? _safeName(Object? value) {
    final cleaned = _text(value)?.replaceAll(RegExp(r"[/\\\u0000]"), "_");
    return cleaned != null && RemotePath.isValidName(cleaned) ? cleaned : null;
  }

  static String? _text(Object? value) => value is String && value.trim().isNotEmpty ? value.trim() : null;
}
