import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_core/models/server_info.dart";
import "package:polder_core/providers/polder_api_provider.dart";

final polderServerInfoProvider = FutureProvider.autoDispose<ServerInfo>((ref) async {
  final api = ref.watch(polderApiProvider);
  return api.serverInfo();
});
