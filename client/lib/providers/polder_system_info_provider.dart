import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder/models/server_info.dart";
import "package:polder/providers/polder_api_provider.dart";

final polderServerInfoProvider = FutureProvider.autoDispose<ServerInfo>((ref) async {
  final api = ref.watch(polderApiProvider);
  return api.serverInfo();
});
