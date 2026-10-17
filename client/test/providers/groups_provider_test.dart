import "package:flutter_test/flutter_test.dart";

import "package:polder/models/group.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/groups/groups_provider.dart";

import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

Map<String, Object?> userJson(int id, String name) => {"id": id, "username": name, "displayName": name};

void main() {
  late List<Map<String, Object?>> members;
  late ScriptedClient client;
  late ProviderHarness harness;

  Map<String, Object?> details() => {
    "group": {
      "id": 5,
      "name": "Family",
      "memberCount": members.length,
      "createdAt": "2026-10-01T10:00:00Z",
      "myRole": "admin",
    },
    "members": members,
    "canManage": true,
  };

  setUp(() {
    members = [
      {"user": userJson(1, "alice"), "role": "admin"},
    ];
    client = ScriptedClient((request) async {
      switch ((request.method, request.path)) {
        case ("GET", "/groups/5"):
          return jsonResponse(200, details());
        case ("POST", "/groups/5/members"):
          final body = request.data! as Map;
          members.add({"user": userJson(body["userId"] as int, "bob"), "role": body["role"]});
          return jsonResponse(201, details());
        case ("PATCH", "/groups/5/members/2"):
          members[1] = {...members[1], "role": (request.data! as Map)["role"]};
          return jsonResponse(200, details());
        case ("GET", "/groups"):
          return jsonResponse(200, [details()["group"]]);
        case ("POST", "/groups"):
          return jsonResponse(201, details()["group"]);
      }
      return jsonResponse(404, {
        "error": {"code": "not_found", "message": "nope"},
      });
    });
    harness = ProviderHarness(httpClient: client, account: testAccount());
  });

  tearDown(() => harness.dispose());

  test("admins add members and change their roles", () async {
    await harness.container.read(accountProvider.future);
    harness.container.listen(groupProvider(5), (_, _) {});
    final loaded = await harness.container.read(groupProvider(5).future);
    expect(loaded.canManage, isTrue);
    expect(loaded.members.single.role, GroupRole.admin);

    final notifier = harness.container.read(groupProvider(5).notifier);
    await notifier.addMember(const ShareTarget(kind: ShareTargetKind.user, id: 2, name: "bob"), GroupRole.viewer);
    var current = harness.container.read(groupProvider(5)).requireValue;
    expect(current.members.map((member) => member.role), [GroupRole.admin, GroupRole.viewer]);
    expect(current.adminCount, 1);

    await notifier.setRole(current.members[1], GroupRole.member);
    current = harness.container.read(groupProvider(5)).requireValue;
    expect(current.members[1].role, GroupRole.member);
    expect(client.requests.where((request) => request.method == "PATCH").single.data, {"role": "member"});
  });

  test("creating a group refreshes the group lists", () async {
    await harness.container.read(accountProvider.future);
    harness.container.listen(groupsProvider(GroupScope.mine), (_, _) {});
    await harness.container.read(groupsProvider(GroupScope.mine).future);

    final created = await harness.container.read(groupsProvider(GroupScope.mine).notifier).create("Family");
    expect(created.id, 5);
    await harness.container.read(groupsProvider(GroupScope.mine).future);
    expect(client.requests.where((request) => request.method == "GET" && request.path == "/groups"), hasLength(2));
  });
}
