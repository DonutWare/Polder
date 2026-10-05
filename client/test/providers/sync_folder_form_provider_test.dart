import "package:flutter_test/flutter_test.dart";

import "package:polder/models/sync/sync_root.dart";
import "package:polder/providers/sync/auto_upload_settings_provider.dart";
import "package:polder/providers/sync/sync_folder_form_provider.dart";
import "package:polder/providers/sync/sync_roots_provider.dart";

import "../support/fake_server.dart";
import "../support/provider_harness.dart";

void main() {
  late ProviderHarness harness;
  late FakePolderServer server;

  setUp(() {
    server = FakePolderServer();
    harness = ProviderHarness(account: testAccount(), httpClient: server);
    harness.container
      ..listen(syncRootsProvider, (_, _) {})
      ..listen(syncFolderFormProvider(SyncMode.autoUpload), (_, _) {});
  });

  tearDown(() => harness.dispose());

  SyncFolderFormNotifier form() => harness.container.read(syncFolderFormProvider(SyncMode.autoUpload).notifier);

  test("adding an auto-upload folder turns auto-upload on", () async {
    harness.filePicker.directory = "/storage/DCIM/Camera";

    await form().pickLocalFolder();
    expect(await form().submit(), isTrue);

    expect((await harness.container.read(autoUploadSettingsProvider.future)).enabled, isTrue);
    expect(harness.syncPlatform.scheduled.last.enabled, isTrue);
    final root = (await harness.container.read(syncRootsProvider.future)).single;
    expect(root.remotePath, "/Camera Uploads/Camera");
    expect(server.nodes["/Camera Uploads/Camera"]?.isDir, isTrue);
    expect(harness.syncPlatform.service.skippedRoots, isEmpty);
  });

  test("existing files are skipped only when the user opts out of uploading them", () async {
    harness.filePicker.directory = "/storage/DCIM/Camera";
    harness.syncPlatform.hasFiles = true;

    await form().pickLocalFolder();
    expect(harness.container.read(syncFolderFormProvider(SyncMode.autoUpload)).hasExistingFiles, isTrue);
    form().setUploadExisting(false);
    await form().submit();

    final root = (await harness.container.read(syncRootsProvider.future)).single;
    expect(harness.syncPlatform.service.skippedRoots, [root.id]);
  });

  test("a denied storage permission keeps the folder unpicked", () async {
    harness.filePicker.directory = "/storage/DCIM/Camera";
    harness.syncPlatform.storageAccess = false;

    await form().pickLocalFolder();

    final state = harness.container.read(syncFolderFormProvider(SyncMode.autoUpload));
    expect(state.storageDenied, isTrue);
    expect(state.localPath, isNull);
  });
}
