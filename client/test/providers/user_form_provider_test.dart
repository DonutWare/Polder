import "package:flutter_test/flutter_test.dart";

import "package:nomad/models/user.dart";
import "package:nomad/models/user_form.dart";
import "package:nomad/util/quota_unit.dart";

void main() {
  const user = User(id: 7, username: "anna", quotaBytes: 5 * 1024 * 1024 * 1024);

  test("an existing quota is shown in the largest exact unit", () {
    final form = UserForm.forUser(user);

    expect(form.quotaAmount, "5");
    expect(form.quotaUnit, QuotaUnit.gb);
  });

  test("zero means unlimited and is valid", () {
    const form = UserForm(username: "new", password: "pw", quotaAmount: "0");

    expect(form.isValid, isTrue);
    expect(form.toCreateRequest().quotaBytes, 0);
  });

  test("quota amounts convert with the chosen unit", () {
    const form = UserForm(quotaAmount: "1,5", quotaUnit: QuotaUnit.tb);

    expect(form.quotaBytes, (1.5 * 1024 * 1024 * 1024 * 1024).round());
  });

  test("an update only contains the changed fields", () {
    final form = UserForm.forUser(user).copyWith(role: UserRole.admin, disabled: true);

    final request = form.toUpdateRequest();

    expect(request.toJson(), {"role": "admin", "disabled": true});
  });

  test("an unchanged form produces an empty update", () {
    expect(UserForm.forUser(user).toUpdateRequest().isEmpty, isTrue);
  });

  test("negative or garbage quotas are invalid", () {
    expect(UserForm.forUser(user).copyWith(quotaAmount: "-1").isValid, isFalse);
    expect(UserForm.forUser(user).copyWith(quotaAmount: "lots").isValid, isFalse);
  });
}
