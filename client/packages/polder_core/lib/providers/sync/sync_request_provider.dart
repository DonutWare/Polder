import "package:flutter_riverpod/flutter_riverpod.dart";

typedef SyncRequest = void Function();

final syncRequestProvider = Provider<SyncRequest>((ref) => () {});
