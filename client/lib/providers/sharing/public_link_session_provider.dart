import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_space.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";

class PublicLinkSession {
  const PublicLinkSession({required this.info, this.unlocked});

  final PublicLinkInfo info;
  final PublicLinkUnlock? unlocked;

  bool get isUnlocked => unlocked != null;

  PublicLinkInfo get shownInfo => unlocked?.info ?? info;
}

final publicLinkSessionProvider = AsyncNotifierProvider.autoDispose
    .family<PublicLinkSessionNotifier, PublicLinkSession, LinkSpace>(PublicLinkSessionNotifier.new);

class PublicLinkSessionNotifier extends AsyncNotifier<PublicLinkSession> {
  PublicLinkSessionNotifier(this.space);

  final LinkSpace space;
  String? _password;

  PolderApi get _api => ref.read(serverPolderApiProvider(space.serverUrl));

  @override
  Future<PublicLinkSession> build() async {
    final info = await ref.watch(serverPolderApiProvider(space.serverUrl)).publicLink(space.code);
    if (info.needsPassword) return PublicLinkSession(info: info);
    return PublicLinkSession(info: info, unlocked: await _api.unlockPublicLink(space.code));
  }

  Future<void> unlock(String password) async {
    final current = await future;
    final unlocked = await _api.unlockPublicLink(space.code, password: password);
    _password = password;
    state = AsyncData(PublicLinkSession(info: current.info, unlocked: unlocked));
  }

  Future<String> token() async {
    final session = await future;
    final unlocked = session.unlocked;
    if (unlocked == null) throw const UnauthorizedException(statusCode: 401);
    if (DateTime.now().isBefore(unlocked.expiresAt.subtract(const Duration(minutes: 1)))) return unlocked.token;
    final renewed = await _api.unlockPublicLink(space.code, password: _password);
    state = AsyncData(PublicLinkSession(info: session.info, unlocked: renewed));
    return renewed.token;
  }
}
