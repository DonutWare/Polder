import "dart:async";

import "package:drift/drift.dart" show driftRuntimeOptions;
import "package:drift/native.dart";
import "package:flutter/painting.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/misc.dart";
import "package:http/http.dart" as http;

import "package:polder_core/models/account.dart";
import "package:polder_core/models/server_connection.dart";
import "package:polder_core/providers/connection/server_connection_provider.dart";
import "package:polder_core/providers/offline/offline_storage_provider.dart";
import "package:polder_core/services/api/polder_api.dart";
import "package:polder_core/services/offline/content_downloader.dart";

import "package:polder_core/services/offline/db_content_store.dart";
import "package:polder_core/services/offline/streaming_content_downloader.dart";
import "package:polder_core/services/offline/offline_database.dart";
import "package:polder_core/services/offline/offline_storage.dart";
import "package:polder_core/models/user.dart";
import "package:polder_ui/providers/appearance/appearance_provider.dart";
import "package:polder_core/providers/service_providers.dart";
import "package:polder/providers/platform_service_providers.dart";
import "package:polder_drive/providers/sync/sync_platform_provider.dart";
import "package:polder/app_overrides.dart";
import "package:polder_core/services/device/device_conditions.dart";
import "package:polder_core/services/realtime/events_client.dart";
import "package:polder_core/services/storage/credentials_store.dart";
import "package:polder_core/services/storage/preferences_store.dart";

import "fake_document_scanner.dart";
import "fake_file_picker.dart";
import "fake_file_browser_location.dart";
import "fake_sync_platform.dart";

class FixedDeviceConditions implements DeviceConditions {
  FixedDeviceConditions({this.unmetered = true, this.charging = true, this.network = true});

  bool unmetered;
  bool charging;
  bool network;
  final _networkChanges = StreamController<bool>.broadcast();

  void setNetwork(bool available) {
    network = available;
    _networkChanges.add(available);
  }

  @override
  Future<bool> hasNetwork() async => network;

  @override
  Stream<bool> networkChanges() => _networkChanges.stream;

  @override
  Future<bool> isOnUnmeteredNetwork() async => unmetered;

  @override
  Future<bool> isCharging() async => charging;
}

Future<OfflineStorage> inMemoryOfflineStorage(String accountId) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final database = OfflineDatabase(NativeDatabase.memory());
  return OfflineStorage(database: database, content: DbContentStore(database));
}

ContentDownloader streamingDownloader({
  required String accountId,
  required OfflineStorage storage,
  required PolderApi api,
  required Future<DownloadRequest> Function(String path) requestFor,
  required DownloadNotificationTexts texts,
}) => StreamingContentDownloader(api: api, content: storage.content);

class OnlineServerConnection extends ServerConnectionNotifier {
  @override
  ServerConnection build() => const ServerConnection(reachability: ServerReachability.online);

  @override
  Future<void> check() async {}

  @override
  void report({required bool reachable}) {}
}

Account testAccount({String serverUrl = "https://cloud.test", UserRole role = UserRole.user}) => Account(
  serverUrl: serverUrl,
  accessToken: "access",
  refreshToken: "refresh",
  user: User(id: 1, username: "alice", role: role),
);

class ProviderHarness {
  ProviderHarness({
    this.httpClient,
    Account? account,
    PreferencesStore? preferences,
    this.hostedServerUrl,
    this.systemAccent,
    this.webSocketConnector,
    this.monitorConnection = false,
  }) : credentials = InMemoryCredentialsStore(account),
       preferences = preferences ?? InMemoryPreferencesStore() {
    container = ProviderContainer(retry: (_, _) => null, overrides: overrides);
  }

  final http.Client? httpClient;

  /// The origin a web client was served from; null behaves like a native app.
  final String? hostedServerUrl;

  final Color? systemAccent;

  final WebSocketConnector? webSocketConnector;
  final bool monitorConnection;

  final InMemoryCredentialsStore credentials;
  final PreferencesStore preferences;
  final conditions = FixedDeviceConditions();
  final syncPlatform = FakeSyncPlatform();
  final filePicker = FakeFilePickerService();
  final documentScanner = FakeDocumentScannerService();
  final fileBrowserLocation = FakeFileBrowserLocation();
  late final ProviderContainer container;

  List<Override> get overrides => [
    ...polderPackageOverrides,
    credentialsStoreProvider.overrideWithValue(credentials),
    httpClientProvider.overrideWithValue(httpClient),
    preferencesStoreProvider.overrideWithValue(preferences),
    deviceNameProvider.overrideWithValue("Test"),
    deviceConditionsProvider.overrideWithValue(conditions),
    syncPlatformProvider.overrideWithValue(syncPlatform),
    filePickerServiceProvider.overrideWithValue(filePicker),
    documentScannerServiceProvider.overrideWithValue(documentScanner),
    fileBrowserLocationProvider.overrideWithValue(fileBrowserLocation),
    hostedServerUrlProvider.overrideWithValue(hostedServerUrl),
    systemAccentReaderProvider.overrideWithValue(() async => systemAccent),
    webSocketConnectorProvider.overrideWithValue(webSocketConnector),
    if (!monitorConnection) serverConnectionProvider.overrideWith(OnlineServerConnection.new),
    offlineStorageOpenerProvider.overrideWithValue(inMemoryOfflineStorage),
    contentDownloaderFactoryProvider.overrideWithValue(streamingDownloader),
  ];

  void dispose() => container.dispose();
}
