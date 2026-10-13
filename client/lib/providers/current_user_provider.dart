import "dart:typed_data";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/user.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/util/branding_images.dart";

final currentUserProvider = AsyncNotifierProvider<CurrentUserNotifier, User>(CurrentUserNotifier.new);

final isAdminProvider = Provider<bool>((ref) {
  final fetched = ref.watch(currentUserProvider).value;
  return fetched?.isAdmin ?? ref.watch(currentAccountProvider)?.user.isAdmin ?? false;
});

class CurrentUserNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() async => _store(await ref.watch(polderApiProvider).me());

  Future<void> refresh() async =>
      state = await AsyncValue.guard(() async => _store(await ref.read(polderApiProvider).me()));

  Future<void> saveProfile(UserProfile profile) async => _apply(await ref.read(polderApiProvider).setProfile(profile));

  Future<void> changePassword({required String currentPassword, required String newPassword}) =>
      ref.read(polderApiProvider).changePassword(currentPassword: currentPassword, newPassword: newPassword);

  Future<void> setAvatar(Uint8List bytes) async =>
      _apply(await ref.read(polderApiProvider).setAvatar(await shrinkIcon(bytes)));

  Future<void> saveAppearance({required ThemeMode theme, required Color? accent}) async =>
      _apply(await ref.read(polderApiProvider).setAppearance(theme: theme, accent: accent));

  Future<void> removeAvatar() async => _apply(await ref.read(polderApiProvider).removeAvatar());

  void _apply(User user) {
    state = AsyncData(_store(user));
  }

  User _store(User user) {
    Future.microtask(() => ref.read(accountProvider.notifier).storeUser(user));
    return user;
  }
}
