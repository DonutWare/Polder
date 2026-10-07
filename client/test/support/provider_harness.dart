import "package:flutter/painting.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/misc.dart";
import "package:http/http.dart" as http;

import "package:polder/models/account.dart";
import "package:polder/models/user.dart";
import "package:polder/providers/appearance/appearance_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/providers/sync/sync_platform_provider.dart";
import "package:polder/services/device/device_conditions.dart";
import "package:polder/services/realtime/events_client.dart";
import "package:polder/services/storage/credentials_store.dart";
import "package:polder/services/storage/preferences_store.dart";

import "fake_document_scanner.dart";
import "fake_file_picker.dart";
import "fake_sync_platform.dart";

class FixedDeviceConditions implements DeviceConditions {
  FixedDeviceConditions({this.unmetered = true, this.charging = true});

  bool unmetered;
  bool charging;

  @override
  Future<bool> isOnUnmeteredNetwork() async => unmetered;

  @override
  Future<bool> isCharging() async => charging;
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
  }) : credentials = InMemoryCredentialsStore(account),
       preferences = preferences ?? InMemoryPreferencesStore() {
    container = ProviderContainer(retry: (_, _) => null, overrides: overrides);
  }

  final http.Client? httpClient;

  /// The origin a web client was served from; null behaves like a native app.
  final String? hostedServerUrl;

  final Color? systemAccent;

  final WebSocketConnector? webSocketConnector;

  final InMemoryCredentialsStore credentials;
  final PreferencesStore preferences;
  final conditions = FixedDeviceConditions();
  final syncPlatform = FakeSyncPlatform();
  final filePicker = FakeFilePickerService();
  final documentScanner = FakeDocumentScannerService();
  late final ProviderContainer container;

  List<Override> get overrides => [
    credentialsStoreProvider.overrideWithValue(credentials),
    httpClientProvider.overrideWithValue(httpClient),
    preferencesStoreProvider.overrideWithValue(preferences),
    deviceNameProvider.overrideWithValue("Test"),
    deviceConditionsProvider.overrideWithValue(conditions),
    syncPlatformProvider.overrideWithValue(syncPlatform),
    filePickerServiceProvider.overrideWithValue(filePicker),
    documentScannerServiceProvider.overrideWithValue(documentScanner),
    hostedServerUrlProvider.overrideWithValue(hostedServerUrl),
    systemAccentReaderProvider.overrideWithValue(() async => systemAccent),
    webSocketConnectorProvider.overrideWithValue(webSocketConnector),
  ];

  void dispose() => container.dispose();
}
