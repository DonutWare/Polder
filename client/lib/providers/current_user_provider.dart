import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/user.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/polder_api_provider.dart";

final currentUserProvider = AsyncNotifierProvider<CurrentUserNotifier, User>(CurrentUserNotifier.new);

final isAdminProvider = Provider<bool>((ref) {
  final fetched = ref.watch(currentUserProvider).value;
  return fetched?.isAdmin ?? ref.watch(currentAccountProvider)?.user.isAdmin ?? false;
});

class CurrentUserNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() => ref.watch(polderApiProvider).me();

  Future<void> refresh() async => state = await AsyncValue.guard(() => ref.read(polderApiProvider).me());
}
