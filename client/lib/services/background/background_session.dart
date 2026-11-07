import "package:polder/models/account.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/api/stored_auth_session.dart";
import "package:polder/services/calendar/polder_calendar_source.dart";
import "package:polder/services/storage/credentials_store.dart";
import "package:polder/util/device_name.dart";

class BackgroundSession {
  const BackgroundSession._({required this.account, required this.api, required this.deviceName});

  static Future<BackgroundSession?> open(CredentialsStore credentials) async {
    final account = await credentials.load();
    if (account == null) return null;
    final deviceName = await DeviceName.resolve();
    final session = StoredAuthSession(store: credentials, accountId: account.id, accessToken: account.accessToken);
    final api = PolderApi(ApiClientFactory.create(account.serverUrl, session: session, deviceName: deviceName));
    return BackgroundSession._(account: account, api: api, deviceName: deviceName);
  }

  final Account account;
  final PolderApi api;
  final String deviceName;

  String get calendarSourceId => PolderCalendarSource.idFor(account.id);
}
