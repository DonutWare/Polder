import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:http/http.dart" as http;

import "package:nomad/services/device/device_conditions.dart";
import "package:nomad/services/storage/credentials_store.dart";
import "package:nomad/services/storage/preferences_store.dart";
import "package:nomad/services/transfer/file_picker_service.dart";
import "package:nomad/util/device_name.dart";
import "package:nomad/util/hosted_server.dart";

final credentialsStoreProvider = Provider<CredentialsStore>((ref) => const SecureCredentialsStore());

final preferencesStoreProvider = Provider<PreferencesStore>((ref) => SharedPreferencesStore());

final filePickerServiceProvider = Provider<FilePickerService>((ref) => const PlatformFilePickerService());

final deviceConditionsProvider = Provider<DeviceConditions>((ref) => PlatformDeviceConditions());

final deviceNameProvider = Provider<String>((ref) => DeviceName.current());

final httpClientProvider = Provider<http.Client?>((ref) => null);

/// The server that served this web client, which login then connects to on its own.
final hostedServerUrlProvider = Provider<String?>((ref) => HostedServer.url);
