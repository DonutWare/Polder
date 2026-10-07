import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/document_editor.dart";
import "package:polder/providers/polder_api_provider.dart";

final editorCapabilitiesProvider = FutureProvider<EditorCapabilities>(
  (ref) => ref.watch(polderApiProvider).editorCapabilities(),
);
