import "package:polder/models/account.dart";
import "package:polder/models/token_pair.dart";
import "package:polder/services/mount/finder_location.dart";

class FakeFinderLocation implements FinderLocation {
  String? accountId;
  FinderSession? session;
  int signals = 0;

  @override
  Stream<bool?> watchEnabled() => Stream.value(accountId == null ? null : true);

  @override
  Future<String?> connectedAccount() async => accountId;

  @override
  Future<FinderSession?> connect(Account account, TokenPair tokens, {required String deviceName}) async {
    final replaced = session;
    accountId = account.id;
    session = (serverUrl: account.serverUrl, refreshToken: tokens.refreshToken);
    return replaced;
  }

  @override
  Future<FinderSession?> disconnect() async {
    final removed = session;
    accountId = null;
    session = null;
    return removed;
  }

  @override
  Future<void> signal() async => signals++;
}
