import "package:flutter_test/flutter_test.dart";

import "package:polder/models/group.dart";
import "package:polder/routes/app_routes.dart";

void main() {
  String? up(String location, {bool single = true}) => AppRoutes.upFrom(Uri.parse(location), single: single);

  test("folders climb to the files root, where the app may close", () {
    expect(up(AppRoutes.filesAt("/Photos/2024")), AppRoutes.filesAt("/Photos"));
    expect(up(AppRoutes.filesAt("/Photos")), AppRoutes.filesAt("/"));
    expect(up(AppRoutes.filesAt("/")), isNull);
  });

  test("shares climb their folders, then back to their section", () {
    expect(up(AppRoutes.sharedAt(4, path: "/a/b")), AppRoutes.sharedAt(4, path: "/a"));
    expect(up(AppRoutes.sharedAt(4)), AppRoutes.sharedSection(SharedSection.withMe.segment));
    expect(up(AppRoutes.federatedAt(2, path: "/a")), AppRoutes.federatedAt(2));
    expect(up(AppRoutes.federatedAt(2)), AppRoutes.sharedSection(SharedSection.federated.segment));
  });

  test("a section goes to the section list on phones and to files on wide windows", () {
    final section = AppRoutes.sharedSection(SharedSection.links.segment);
    expect(up(section), AppRoutes.shared);
    expect(up(section, single: false), AppRoutes.files);
  });

  test("a group goes to the group list on phones and to files on wide windows", () {
    final group = AppRoutes.groupAt(3, scope: GroupScope.values.last);
    expect(up(group), AppRoutes.groupsScope(scope: GroupScope.values.last));
    expect(up(group, single: false), AppRoutes.files);
  });

  test("child pages go to their parent page", () {
    expect(up(AppRoutes.about), AppRoutes.settings);
    expect(up(AppRoutes.account), AppRoutes.settings);
    expect(up(AppRoutes.adminUsers), AppRoutes.admin);
    expect(up(AppRoutes.adminBranding), AppRoutes.admin);
    expect(up(AppRoutes.conflicts), AppRoutes.sync);
  });

  test("every other top-level page goes back to files", () {
    for (final location in [
      AppRoutes.shared,
      AppRoutes.notes,
      AppRoutes.noteAt("/Notes/a.md"),
      AppRoutes.sync,
      AppRoutes.activity,
      AppRoutes.autoUpload,
      AppRoutes.trash,
      AppRoutes.groups,
      AppRoutes.settings,
      AppRoutes.admin,
      AppRoutes.searchFor("cats"),
    ]) {
      expect(up(location), AppRoutes.files, reason: location);
      expect(up(location, single: false), AppRoutes.files, reason: location);
    }
  });
}
