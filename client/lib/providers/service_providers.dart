import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:http/http.dart" as http;
import "package:web_socket_channel/web_socket_channel.dart";

import "package:polder/services/device/device_conditions.dart";
import "package:polder/services/realtime/events_client.dart";
import "package:polder/services/storage/credentials_store.dart";
import "package:polder/services/storage/preferences_store.dart";
import "package:polder/services/transfer/document_scanner_service.dart";
import "package:polder/services/transfer/file_picker_service.dart";
import "package:polder/util/hosted_server.dart";

final credentialsStoreProvider = Provider<CredentialsStore>((ref) => platformCredentialsStore());

final preferencesStoreProvider = Provider<PreferencesStore>((ref) => SharedPreferencesStore());

final filePickerServiceProvider = Provider<FilePickerService>((ref) => const PlatformFilePickerService());

final documentScannerServiceProvider = Provider<DocumentScannerService>((ref) => const NativeDocumentScannerService());

final deviceConditionsProvider = Provider<DeviceConditions>((ref) => PlatformDeviceConditions());

final deviceNameProvider = Provider<String>((ref) => throw UnimplementedError("Resolved in main"));

final httpClientProvider = Provider<http.Client?>((ref) => null);

/// The server that served this web client, which login then connects to on its own.
final hostedServerUrlProvider = Provider<String?>((ref) => HostedServer.url);

final webSocketConnectorProvider = Provider<WebSocketConnector?>((ref) => WebSocketChannel.connect);
