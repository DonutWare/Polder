import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";

import "package:polder/models/offline_models.dart";
import "package:polder/models/transfer.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/offline/offline_storage_provider.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/transfer/file_picker_service.dart";

import "../support/fake_server.dart";
import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

void main() {
  late FakePolderServer server;
  late SignedInServer signedIn;
  late ProviderHarness harness;

  setUp(() async {
    server = FakePolderServer();
    signedIn = SignedInServer(server);
    harness = ProviderHarness(httpClient: signedIn, account: testAccount());
    await harness.container.read(accountProvider.future);
  });

  tearDown(() => harness.dispose());

  TransfersNotifier transfers() => harness.container.read(transfersProvider.notifier);

  Transfer only() => harness.container.read(transfersProvider).single;

  test("an upload that does not fit the quota fails before anything is sent", () async {
    signedIn.me = {...userJson(), "quotaBytes": 1000, "usedBytes": 900};

    await transfers().upload("/", BytesPickedFile("a.bin", Uint8List(200)));

    expect(only().status, TransferStatus.failed);
    expect(only().error, isA<QuotaExceededException>());
    expect(server.contentOf("/a.bin"), isNull);
  });

  test("an upload is checked against fresh usage before it is refused", () async {
    signedIn.me = {...userJson(), "quotaBytes": 1000, "usedBytes": 900};
    await harness.container.read(currentUserProvider.future);
    signedIn.me = {...userJson(), "quotaBytes": 1000, "usedBytes": 0};

    await transfers().upload("/", BytesPickedFile("a.bin", Uint8List(200)));

    expect(only().status, TransferStatus.done);
    expect(server.contentOf("/a.bin"), Uint8List(200));
  });

  test("an upload the server cannot store is kept on the device and sent once it can", () async {
    server.failWrites = (status: 507, code: "storage_full");

    await transfers().upload("/", BytesPickedFile("a.bin", Uint8List.fromList([1, 2, 3])));

    expect(harness.container.read(transfersProvider), isEmpty);
    final files = await harness.container.read(offlineFilesProvider.future);
    expect((await files.file("/a.bin"))!.state, OfflineFileState.pending);

    await files.push();
    expect((await files.file("/a.bin"))!.error!.kind, OutboxErrorKind.storageFull);

    server.failWrites = null;
    await files.retryNow();
    await files.push();
    expect(server.contentOf("/a.bin"), Uint8List.fromList([1, 2, 3]));
    expect(await files.file("/a.bin"), isNull);
  });
}
