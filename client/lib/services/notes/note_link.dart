import "package:polder/models/file_entry.dart";
import "package:polder/util/remote_path.dart";

const fileIdParameter = "fileId";

class NoteLink {
  const NoteLink({this.path, this.fileId, this.fragment});

  final String? path;
  final int? fileId;
  final String? fragment;

  static NoteLink? parse(String destination, {required String notePath}) {
    final trimmed = destination.trim();
    if (trimmed.isEmpty || trimmed.startsWith("#") || trimmed.startsWith("//")) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.hasScheme) return null;
    final fileId = int.tryParse(uri.queryParameters[fileIdParameter] ?? "");
    final path = uri.path.isEmpty ? null : _resolve(RemotePath.parent(notePath), Uri.decodeComponent(uri.path));
    if (path == null && fileId == null) return null;
    return NoteLink(path: path, fileId: fileId, fragment: uri.hasFragment ? uri.fragment : null);
  }

  static final _reservedInComponents = RegExp(r"[!'()*]");

  static String _escapeSegment(String segment) => Uri.encodeComponent(
    segment,
  ).replaceAllMapped(_reservedInComponents, (match) => "%${match[0]!.codeUnitAt(0).toRadixString(16).toUpperCase()}");

  static String destinationFor(FileEntry target, {required String notePath}) {
    final relative = relativeRemotePath(from: RemotePath.parent(notePath), to: target.path);
    final encoded = relative.split("/").map((segment) => segment == ".." ? segment : _escapeSegment(segment));
    final query = target.id > 0 ? "?$fileIdParameter=${target.id}" : "";
    return "${encoded.join("/")}$query";
  }

  static String _resolve(String directory, String path) {
    final segments = path.startsWith("/") ? <String>[] : RemotePath.segments(directory);
    for (final segment in path.split("/")) {
      switch (segment) {
        case "" || ".":
          continue;
        case "..":
          if (segments.isNotEmpty) segments.removeLast();
        default:
          segments.add(segment);
      }
    }
    return "/${segments.join("/")}";
  }
}

String relativeRemotePath({required String from, required String to}) {
  final fromSegments = RemotePath.segments(from);
  final toSegments = RemotePath.segments(to);
  var shared = 0;
  while (shared < fromSegments.length && shared < toSegments.length - 1 && fromSegments[shared] == toSegments[shared]) {
    shared++;
  }
  return [for (var i = shared; i < fromSegments.length; i++) "..", ...toSegments.skip(shared)].join("/");
}

class SourceLink {
  const SourceLink({required this.label, required this.labelStart, required this.destination, required this.start});

  final String label;
  final int labelStart;
  final String destination;
  final int start;

  int get labelEnd => labelStart + label.length;

  int get end => start + destination.length;
}

final _inlineLink = RegExp(
  r"(!?)\[((?:[^\[\]\\]|\\.)*)\]\(\s*(<[^>\n]*>|[^\s()]+)(?:\s+(?:\x22[^\x22]*\x22|'[^']*'))?\s*\)",
);
final markdownFenceLine = RegExp(r"^ {0,3}(`{3,}|~{3,})");

List<SourceLink> findSourceLinks(String source) {
  final links = <SourceLink>[];
  var offset = 0;
  String? fence;
  for (final line in source.split("\n")) {
    final fenceMatch = markdownFenceLine.firstMatch(line);
    if (fenceMatch != null) {
      final marker = fenceMatch.group(1)!;
      if (fence == null) {
        fence = marker;
      } else if (marker[0] == fence[0] && marker.length >= fence.length) {
        fence = null;
      }
    } else if (fence == null) {
      for (final match in _inlineLink.allMatches(line)) {
        var destination = match.group(3)!;
        final openingParenthesis = match.start + match.group(1)!.length + match.group(2)!.length + 2;
        var start = offset + line.indexOf(destination, openingParenthesis + 1);
        if (destination.startsWith("<")) {
          destination = destination.substring(1, destination.length - 1);
          start++;
        }
        links.add(
          SourceLink(
            label: match.group(2)!,
            labelStart: offset + match.start + match.group(1)!.length + 1,
            destination: destination,
            start: start,
          ),
        );
      }
    }
    offset += line.length + 1;
  }
  return links;
}

String escapeLinkLabel(String label) => label.replaceAllMapped(RegExp(r"[\[\]]"), (match) => "\\${match[0]}");

String updateLinks(String source, {required String notePath, required Map<int, FileEntry> current}) {
  final buffer = StringBuffer();
  var copied = 0;
  for (final link in findSourceLinks(source)) {
    final parsed = NoteLink.parse(link.destination, notePath: notePath);
    final target = parsed?.fileId == null ? null : current[parsed!.fileId];
    if (target == null) continue;
    final previousPath = parsed!.path;
    final label = _labelAfterRename(
      link.label,
      previousName: previousPath == null ? null : RemotePath.name(previousPath),
      target: target,
    );
    if (label != null) {
      buffer
        ..write(source.substring(copied, link.labelStart))
        ..write(label);
      copied = link.labelEnd;
    }
    if (target.path != previousPath) {
      var destination = NoteLink.destinationFor(target, notePath: notePath);
      if (parsed.fragment != null) destination += "#${parsed.fragment}";
      buffer
        ..write(source.substring(copied, link.start))
        ..write(destination);
      copied = link.end;
    }
  }
  if (copied == 0) return source;
  buffer.write(source.substring(copied));
  return buffer.toString();
}

String? _labelAfterRename(String label, {required String? previousName, required FileEntry target}) {
  if (label.isEmpty) return escapeLinkLabel(target.displayName);
  if (previousName == null) return null;
  final String followed;
  if (label == escapeLinkLabel(previousName)) {
    followed = target.name;
  } else if (label == escapeLinkLabel(RemotePath.withoutExtension(previousName))) {
    followed = RemotePath.withoutExtension(target.name);
  } else {
    return null;
  }
  final escaped = escapeLinkLabel(followed);
  return escaped == label ? null : escaped;
}
