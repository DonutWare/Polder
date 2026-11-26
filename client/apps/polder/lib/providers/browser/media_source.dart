import "package:flutter/foundation.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/file_space.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder/providers/sharing/file_space_providers.dart";
import "package:polder_core/services/api/polder_api.dart";

typedef MediaSource = ({Uri url, Map<String, String> headers});

Future<MediaSource> resolveMediaSource(WidgetRef ref, FileEntry entry, {FileSpace? space}) async {
  if (space != null) return ref.read(fileSpaceApiProvider(space)).mediaSource(entry.path, inBrowser: kIsWeb);
  if (kIsWeb) return (url: await ref.read(polderApiProvider).streamUrl(entry.path), headers: const <String, String>{});
  await ref.read(polderApiProvider).stat(entry.path);
  final account = ref.read(currentAccountProvider);
  if (account == null) throw StateError("No account is signed in");
  return (
    url: DownloadPurpose.view.contentUrl(account.serverUrl, entry.path),
    headers: {"Authorization": "Bearer ${account.accessToken}"},
  );
}
