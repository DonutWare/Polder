import "package:freezed_annotation/freezed_annotation.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_version.dart";

part "document_editor.freezed.dart";

@freezed
abstract class EditorCapabilities with _$EditorCapabilities {
  const EditorCapabilities._();

  const factory EditorCapabilities({
    @Default(false) bool enabled,
    @Default(<String>{}) Set<String> editableMimes,
    @Default(<String>{}) Set<String> editableExtensions,
    @Default(<String>{}) Set<String> viewableMimes,
    @Default(<String>{}) Set<String> viewableExtensions,
    @Default(<String, List<String>>{}) Map<String, List<String>> creatable,
  }) = _EditorCapabilities;

  List<String> extensionsFor(NewDocumentKind kind) => enabled ? creatable[kind.app] ?? const [] : const [];

  bool canEdit(FileEntry entry) =>
      enabled && !entry.isDir && (editableMimes.contains(entry.mime) || editableExtensions.contains(_extension(entry)));

  bool canOpen(FileEntry entry) =>
      canEdit(entry) ||
      (enabled &&
          !entry.isDir &&
          (viewableMimes.contains(entry.mime) || viewableExtensions.contains(_extension(entry))));

  static String _extension(FileEntry entry) {
    final dot = entry.name.lastIndexOf(".");
    return dot <= 0 ? "" : entry.name.substring(dot + 1).toLowerCase();
  }
}

enum NewDocumentKind {
  document("writer", "docx"),
  spreadsheet("calc", "xlsx"),
  presentation("impress", "pptx"),
  pdf("pdf", "pdf");

  const NewDocumentKind(this.app, this.preferredExtension);

  final String app;
  final String preferredExtension;

  String defaultExtension(List<String> available) =>
      available.contains(preferredExtension) ? preferredExtension : available.first;
}

@freezed
abstract class EditorSession with _$EditorSession {
  const factory EditorSession({
    required String editorUrl,
    required String hostPage,
    required String accessToken,
    required int accessTokenTtl,
    @Default(false) bool readOnly,
  }) = _EditorSession;
}

class EditorTarget {
  const EditorTarget(this.entry, {this.version});

  final FileEntry entry;
  final FileVersion? version;
}
