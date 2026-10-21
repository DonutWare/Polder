import "package:flutter_test/flutter_test.dart";

import "package:polder/models/federation.dart";
import "package:polder/models/file_space.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/federation/federation_providers.dart";
import "package:polder/providers/sharing/file_space_providers.dart";
import "package:polder/screens/settings/widgets/app_passwords_group.dart";

import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

Map<String, Object?> passwordJson(int id, String name) => {
  "id": id,
  "name": name,
  "readOnly": false,
  "createdAt": "2026-10-01T10:00:00Z",
  "lastUsedAddress": "",
};

Map<String, Object?> incomingJson(int id, String state, {bool create = false}) => {
  "id": id,
  "name": "Docs",
  "owner": "bob@cloud.example.com",
  "ownerName": "Bob",
  "sharedBy": "bob@cloud.example.com",
  "server": "cloud.example.com",
  "provider": "Nextcloud",
  "isDir": true,
  "permissions": {"create": create, "edit": create, "delete": false},
  "state": state,
  "createdAt": "2026-10-01T10:00:00Z",
};

Map<String, Object?> outgoingJson(int id, Map<String, bool> permissions) => {
  "id": id,
  "file": {"id": 7, "path": "/Docs", "name": "Docs", "isDir": true},
  "recipient": "bob@cloud.example.com",
  "recipientName": "",
  "permissions": permissions,
  "state": "pending",
  "available": true,
  "createdAt": "2026-10-01T10:00:00Z",
};

void main() {
  late ScriptedClient client;
  late ProviderHarness harness;
  late List<Map<String, Object?>> passwords;
  late Map<String, Object?> incoming;

  setUp(() {
    passwords = [passwordJson(1, "laptop")];
    incoming = incomingJson(3, "pending");
    client = ScriptedClient((request) async {
      switch ((request.method, request.path)) {
        case ("GET", "/account/app-passwords"):
          return jsonResponse(200, passwords);
        case ("POST", "/account/app-passwords"):
          final body = request.data! as Map;
          if (body["currentPassword"] != "secret") {
            return jsonResponse(403, {
              "error": {"code": "forbidden", "message": "current password is incorrect"},
            });
          }
          return jsonResponse(201, {...passwordJson(2, body["name"] as String), "token": "polder_abc_def"});
        case ("DELETE", "/account/app-passwords/1"):
          return emptyResponse(204);
        case ("GET", "/federation/shares/incoming"):
          return jsonResponse(200, [incoming]);
        case ("POST", "/federation/shares/incoming/3/accept"):
          incoming = incomingJson(3, "accepted", create: true);
          return jsonResponse(200, incoming);
        case ("POST", "/federation/shares/outgoing"):
          final body = request.data! as Map;
          return jsonResponse(201, outgoingJson(9, (body["permissions"] as Map).cast<String, bool>()));
        case ("GET", "/federation/shares/outgoing"):
          return jsonResponse(200, <Object?>[]);
        case ("GET", "/federation/contacts"):
          return jsonResponse(200, <Object?>[]);
        case ("POST", "/federation/invites/accept"):
          final body = request.data! as Map;
          if (body["token"] != "tok") {
            return jsonResponse(400, {
              "error": {"code": "invalid_request", "message": "unknown invite"},
            });
          }
          return jsonResponse(201, {
            "id": 4,
            "cloudId": "uuid-1@idp.example@cloud.example.com",
            "name": "Erin",
            "email": "",
            "server": body["provider"],
            "createdAt": "2026-10-01T10:00:00Z",
          });
      }
      return jsonResponse(404, {
        "error": {"code": "not_found", "message": "nope"},
      });
    });
    harness = ProviderHarness(httpClient: client, account: testAccount());
  });

  tearDown(() => harness.dispose());

  test("app passwords are created once with the account password and revoked", () async {
    await harness.container.read(accountProvider.future);
    final notifier = harness.container.read(appPasswordsProvider.notifier);
    expect((await harness.container.read(appPasswordsProvider.future)).map((p) => p.name), ["laptop"]);

    await expectLater(notifier.create(name: "phone", currentPassword: "wrong"), throwsA(anything));
    final created = await notifier.create(name: "phone", currentPassword: "secret");
    expect(created.token, "polder_abc_def");
    expect(harness.container.read(appPasswordsProvider).value!.map((p) => p.name), ["phone", "laptop"]);

    await notifier.revoke(harness.container.read(appPasswordsProvider).value!.last);
    expect(harness.container.read(appPasswordsProvider).value!.map((p) => p.name), ["phone"]);
  });

  test("accepting an incoming federated share unlocks its space", () async {
    await harness.container.read(accountProvider.future);
    final shares = await harness.container.read(incomingFederatedSharesProvider.future);
    expect(shares.single.isPending, isTrue);
    expect(shares.single.shownOwner, "Bob (bob@cloud.example.com)");
    const space = FileSpace.federated(shareId: 3);
    expect(harness.container.read(spaceCapabilitiesProvider(space)).canCreate, isFalse);

    await harness.container.read(incomingFederatedSharesProvider.notifier).accept(shares.single);
    expect(harness.container.read(incomingFederatedShareProvider(3))!.state, FederatedShareState.accepted);
    final capabilities = harness.container.read(spaceCapabilitiesProvider(space));
    expect(capabilities.canCreate, isTrue);
    expect(capabilities.canDownloadArchive, isFalse);
  });

  test("sharing with a cloud ID sends trimmed recipient and permissions for the entry", () async {
    await harness.container.read(accountProvider.future);
    final notifier = harness.container.read(federatedSharesProvider(7).notifier);
    await harness.container.read(federatedSharesProvider(7).future);
    await notifier.add(
      fileId: 7,
      recipient: " bob@cloud.example.com ",
      permissions: const SharePermissions(edit: true, create: true),
    );
    final request = client.requests.lastWhere((r) => r.method == "POST");
    expect((request.data! as Map)["recipient"], "bob@cloud.example.com");
    expect(harness.container.read(federatedSharesProvider(7)).value!.single.isPending, isTrue);
  });

  test("accepting an invite adds a contact that matches share searches", () async {
    await harness.container.read(accountProvider.future);
    await harness.container.read(federationContactsProvider.future);
    final notifier = harness.container.read(federationContactsProvider.notifier);
    await expectLater(notifier.acceptInvite(token: "nope", provider: "cloud.example.com"), throwsA(anything));
    final contact = await notifier.acceptInvite(token: " tok ", provider: " cloud.example.com ");
    expect(contact.shownName, "Erin");
    expect(contact.matches("erin"), isTrue);
    expect(contact.matches("uuid-1"), isTrue);
    expect(contact.matches("bob"), isFalse);
    expect(harness.container.read(federationContactsProvider).value!.single.cloudId, "uuid-1@idp.example@cloud.example.com");
  });

  test("cloud IDs and WebDAV addresses", () {
    expect(looksLikeCloudId("alice@cloud.example.com"), isTrue);
    expect(looksLikeCloudId("alice@example.com@cloud.example.com:8443/nc"), isTrue);
    expect(looksLikeCloudId("alice"), isFalse);
    expect(looksLikeCloudId("alice @host"), isFalse);
    expect(webdavAddress("https://files.example.com/", "jop"), "https://files.example.com/dav/files/jop/");
  });
}
