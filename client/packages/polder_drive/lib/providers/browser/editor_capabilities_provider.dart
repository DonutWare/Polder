import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/document_editor.dart";
import "package:polder_core/providers/polder_api_provider.dart";

final editorCapabilitiesProvider = FutureProvider<EditorCapabilities>(
  (ref) => ref.watch(polderApiProvider).editorCapabilities(),
);
