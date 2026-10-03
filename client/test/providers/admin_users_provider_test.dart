import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

import "package:nomad/models/user.dart";
import "package:nomad/providers/admin/admin_users_provider.dart";
import "package:nomad/providers/admin/user_form_provider.dart";
import "package:nomad/util/quota_unit.dart";

import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

void main() {
  late ProviderHarness harness;
  late List<Map<String, dynamic>> users;
  late List<RecordedRequest> writes;
  final admin = testAccount(role: UserRole.admin);

  Map<String, dynamic> user(int id, String name) => {...userJson(), "id": id, "username": name};

  Future<http.StreamedResponse> handle(RecordedRequest request) async {
    if (request.method != "GET") writes.add(request);
    final id = int.tryParse(request.path.split("/").last);
    return switch ((request.method, id)) {
      ("GET", _) => jsonResponse(200, users),
      ("POST", _) => jsonResponse(200, user(3, (request.data as Map)["username"] as String)),
      ("PATCH", final id?) => jsonResponse(200, {
        ...users.firstWhere((u) => u["id"] == id),
        ...(request.data as Map<String, dynamic>),
      }),
      ("DELETE", _) => emptyResponse(204),
      _ => jsonResponse(404, {}),
    };
  }

  setUp(() {
    users = [user(2, "zoe"), user(1, "anna")];
    writes = [];
    harness = ProviderHarness(httpClient: ScriptedClient(handle), account: admin);
    harness.container.listen(adminUsersProvider, (_, _) {});
  });

  tearDown(() => harness.dispose());

  Future<List<String>> usernames() async =>
      (await harness.container.read(adminUsersProvider.future)).map((u) => u.username).toList();

  test("lists users sorted by name", () async {
    expect(await usernames(), ["anna", "zoe"]);
  });

  test("creating a user posts the quota in bytes", () async {
    await harness.container.read(adminUsersProvider.future);
    final form = userFormProvider(null);
    harness.container.listen(form, (_, _) {});
    harness.container.read(form.notifier)
      ..setUsername("bob")
      ..setPassword("pw")
      ..setQuotaAmount("2")
      ..setQuotaUnit(QuotaUnit.gb);

    await harness.container.read(form.notifier).save();

    expect(writes.single.data, {
      "username": "bob",
      "password": "pw",
      "role": "user",
      "quotaBytes": 2 * 1024 * 1024 * 1024,
    });
    expect(await usernames(), ["anna", "bob", "zoe"]);
  });

  test("editing only patches changed fields", () async {
    final anna = (await harness.container.read(adminUsersProvider.future)).first;
    final form = userFormProvider(anna);
    harness.container.listen(form, (_, _) {});
    harness.container.read(form.notifier).setDisabled(true);

    await harness.container.read(form.notifier).save();

    expect(writes.single.method, "PATCH");
    expect(writes.single.data, {"disabled": true});
    expect((await harness.container.read(adminUsersProvider.future)).first.disabled, isTrue);
  });

  test("deleting removes the user", () async {
    final zoe = (await harness.container.read(adminUsersProvider.future)).last;

    await harness.container.read(adminUsersProvider.notifier).delete(zoe);

    expect(await usernames(), ["anna"]);
  });
}
