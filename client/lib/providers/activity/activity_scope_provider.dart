import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/activity.dart";
import "package:nomad/providers/account_provider.dart";

final activityScopeProvider = NotifierProvider<ActivityScopeNotifier, ActivityScope>(ActivityScopeNotifier.new);

final selfUserIdProvider = Provider<int?>(
  (ref) => ref.watch(currentAccountProvider.select((account) => account?.user.id)),
);

class ActivityScopeNotifier extends Notifier<ActivityScope> {
  @override
  ActivityScope build() {
    ref.watch(currentAccountProvider.select((account) => account?.id));
    return const ActivityScope.me();
  }

  void select(ActivityScope scope) => state = scope;
}
