import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:nomad/models/appearance.dart";
import "package:nomad/providers/appearance/appearance_provider.dart";
import "package:nomad/services/storage/preferences_store.dart";

import "../support/provider_harness.dart";

void main() {
  const systemAccent = Color(0xFF123456);

  Future<Appearance> settled(ProviderHarness harness) async {
    harness.container.read(appearanceProvider);
    await pumpEventQueue();
    return harness.container.read(appearanceProvider);
  }

  test("follows the system accent until an accent is chosen", () async {
    final harness = ProviderHarness(systemAccent: systemAccent);
    addTearDown(harness.dispose);

    final appearance = await settled(harness);

    expect(appearance.mode, ThemeMode.system);
    expect(appearance.seed, systemAccent);
  });

  test("falls back to the default accent without a system accent", () async {
    final harness = ProviderHarness();
    addTearDown(harness.dispose);

    expect((await settled(harness)).seed, Appearance.defaultAccent);
  });

  test("remembers the theme and accent across launches", () async {
    final preferences = InMemoryPreferencesStore();
    final first = ProviderHarness(preferences: preferences, systemAccent: systemAccent);
    await settled(first);
    final notifier = first.container.read(appearanceProvider.notifier);
    await notifier.setMode(ThemeMode.dark);
    await notifier.setAccent(AccentPreset.violet.color);
    first.dispose();

    final second = ProviderHarness(preferences: preferences, systemAccent: systemAccent);
    addTearDown(second.dispose);
    final appearance = await settled(second);

    expect(appearance.mode, ThemeMode.dark);
    expect(appearance.seed, AccentPreset.violet.color);
    expect(appearance.isAccent(AccentPreset.violet.color), isTrue);
  });

  test("clearing the accent goes back to the system accent", () async {
    final harness = ProviderHarness(systemAccent: systemAccent);
    addTearDown(harness.dispose);
    await settled(harness);
    final notifier = harness.container.read(appearanceProvider.notifier);

    await notifier.setAccent(AccentPreset.rose.color);
    await notifier.setAccent(null);

    expect(harness.container.read(appearanceProvider).seed, systemAccent);
  });
}
