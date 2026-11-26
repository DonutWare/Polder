import "package:polder_core/models/account.dart";
import "package:polder_core/models/token_pair.dart";
import "package:polder/services/mount/file_browser_location.dart";

class FakeFileBrowserLocation implements FileBrowserLocation {
  String? accountId;
  FileBrowserSession? session;
  int signals = 0;

  @override
  Stream<bool?> watchEnabled() => Stream.value(accountId == null ? null : true);

  @override
  Future<String?> connectedAccount() async => accountId;

  @override
  Future<FileBrowserSession?> connect(Account account, TokenPair tokens, {required String deviceName}) async {
    final replaced = session;
    accountId = account.id;
    session = (serverUrl: account.serverUrl, refreshToken: tokens.refreshToken);
    return replaced;
  }

  @override
  Future<FileBrowserSession?> disconnect() async {
    final removed = session;
    accountId = null;
    session = null;
    return removed;
  }

  @override
  Future<void> signal() async => signals++;
}
