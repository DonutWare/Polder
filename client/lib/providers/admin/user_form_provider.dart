import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/user.dart";
import "package:polder/models/user_form.dart";
import "package:polder/providers/admin/admin_users_provider.dart";
import "package:polder/util/quota_unit.dart";

final userFormProvider = NotifierProvider.autoDispose.family<UserFormNotifier, UserForm, User?>(UserFormNotifier.new);

class UserFormNotifier extends Notifier<UserForm> {
  UserFormNotifier(this.user);

  final User? user;

  @override
  UserForm build() => UserForm.forUser(user);

  void setUsername(String value) => state = state.copyWith(username: value);

  void setPassword(String value) => state = state.copyWith(password: value);

  void setRole(UserRole role) => state = state.copyWith(role: role);

  void setQuotaAmount(String value) => state = state.copyWith(quotaAmount: value);

  void setQuotaUnit(QuotaUnit unit) => state = state.copyWith(quotaUnit: unit);

  void setDisabled(bool disabled) => state = state.copyWith(disabled: disabled);

  void setTrashRetentionOverride(int? days) => state = state.copyWith(trashRetentionOverrideDays: days);

  Future<void> save() async {
    state = state.copyWith(saving: true);
    try {
      await ref.read(adminUsersProvider.notifier).save(state);
    } finally {
      if (ref.mounted) state = state.copyWith(saving: false);
    }
  }
}
