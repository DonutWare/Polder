import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/user.dart";
import "package:nomad/models/user_form.dart";
import "package:nomad/providers/nomad_api_provider.dart";
import "package:nomad/services/api/nomad_api.dart";

final adminUsersProvider = AsyncNotifierProvider.autoDispose<AdminUsersNotifier, List<User>>(AdminUsersNotifier.new);

class AdminUsersNotifier extends AsyncNotifier<List<User>> {
  NomadApi get _api => ref.read(nomadApiProvider);

  @override
  Future<List<User>> build() async => _sorted(await ref.watch(nomadApiProvider).listUsers());

  Future<void> save(UserForm form) async {
    final original = form.original;
    final saved = original == null
        ? await _api.createUser(form.toCreateRequest())
        : await _updateIfChanged(original, form);
    _replace(saved);
  }

  Future<void> delete(User user) async {
    await _api.deleteUser(user.id);
    state = AsyncData((state.value ?? []).where((existing) => existing.id != user.id).toList());
  }

  Future<User> _updateIfChanged(User original, UserForm form) {
    final request = form.toUpdateRequest();
    return request.isEmpty ? Future.value(original) : _api.updateUser(original.id, request);
  }

  void _replace(User user) =>
      state = AsyncData(_sorted([...(state.value ?? []).where((existing) => existing.id != user.id), user]));

  List<User> _sorted(List<User> users) => [...users]..sort((a, b) => a.username.compareTo(b.username));
}
