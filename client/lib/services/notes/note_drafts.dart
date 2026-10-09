import "package:polder/models/file_entry.dart";
import "package:polder/services/storage/preferences_store.dart";

class NoteDraft {
  const NoteDraft({required this.text, required this.baseHash, required this.updatedAt});

  final String text;

  final String baseHash;
  final DateTime updatedAt;
}

class NoteDrafts {
  const NoteDrafts(this._store);

  final PreferencesStore _store;

  static String _key(FileEntry entry) => "noteDraft:${entry.id > 0 ? entry.id : entry.path}";

  Future<NoteDraft?> read(FileEntry entry) async {
    try {
      final json = await _store.readJson(_key(entry));
      if (json == null || json["text"] is! String) return null;
      return NoteDraft(
        text: json["text"] as String,
        baseHash: json["baseHash"] as String? ?? "",
        updatedAt: DateTime.tryParse(json["updatedAt"] as String? ?? "") ?? DateTime.now(),
      );
    } on Object {
      return null;
    }
  }

  Future<void> write(FileEntry entry, String text) => _store.writeJson(_key(entry), {
    "text": text,
    "baseHash": entry.hash,
    "updatedAt": DateTime.now().toUtc().toIso8601String(),
  });

  Future<void> remove(FileEntry entry) => _store.remove(_key(entry));
}
