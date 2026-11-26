import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/email_preferences.dart";
import "package:polder_core/providers/polder_api_provider.dart";

final emailPreferencesProvider = AsyncNotifierProvider.autoDispose<EmailPreferencesNotifier, EmailPreferences>(
  EmailPreferencesNotifier.new,
);

class EmailPreferencesNotifier extends AsyncNotifier<EmailPreferences> {
  @override
  Future<EmailPreferences> build() => ref.watch(polderApiProvider).emailPreferences();

  Future<void> setSecurity(bool enabled) => _save((current) => current.copyWith(security: enabled));

  Future<void> setQuota(bool enabled) => _save((current) => current.copyWith(quota: enabled));

  Future<void> setShares(bool enabled) => _save((current) => current.copyWith(shares: enabled));

  Future<void> _save(EmailPreferences Function(EmailPreferences current) change) async {
    final current = state.value;
    if (current == null) return;
    final next = change(current);
    state = AsyncData(
      await ref
          .read(polderApiProvider)
          .setEmailPreferences(security: next.security, quota: next.quota, shares: next.shares),
    );
  }
}
