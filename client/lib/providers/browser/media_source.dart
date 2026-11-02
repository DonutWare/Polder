import "package:flutter/foundation.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/file_space.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/sharing/file_space_providers.dart";

typedef MediaSource = ({Uri url, Map<String, String> headers});

Future<MediaSource> resolveMediaSource(WidgetRef ref, FileEntry entry, {FileSpace? space}) async {
  if (space != null) return ref.read(fileSpaceApiProvider(space)).mediaSource(entry.path, inBrowser: kIsWeb);
  if (kIsWeb) return (url: await ref.read(polderApiProvider).streamUrl(entry.path), headers: const <String, String>{});
  await ref.read(polderApiProvider).stat(entry.path);
  final account = ref.read(currentAccountProvider);
  if (account == null) throw StateError("No account is signed in");
  final server = Uri.parse(account.serverUrl);
  return (
    url: server.replace(
      path: "${server.path.replaceAll(RegExp(r"/+$"), "")}/api/v1/files/content",
      queryParameters: {"path": entry.path},
    ),
    headers: {"Authorization": "Bearer ${account.accessToken}"},
  );
}
