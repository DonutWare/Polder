import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/providers/update/update_preferences_provider.dart";
import "package:polder/providers/update/update_provider.dart";
import "package:polder/util/external_link.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/nav_group.dart";

class UpdateSettingsGroup extends ConsumerWidget {
  const UpdateSettingsGroup({super.key});

  static const _padding = EdgeInsets.symmetric(horizontal: 16, vertical: 4);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disabled = ref.watch(updateProvider.select((state) => state.phase == UpdatePhase.disabled));
    final preferences = ref.watch(updatePreferencesProvider).value;
    if (disabled || preferences == null) return const SizedBox.shrink();
    final localized = context.localized;
    final notifier = ref.read(updatePreferencesProvider.notifier);
    return NavGroup(
      title: localized.updates,
      children: [
        SwitchListTile(
          contentPadding: _padding,
          title: Text(localized.updatesAutomatic),
          subtitle: Text(localized.updatesAutomaticHint),
          value: preferences.automatic,
          onChanged: notifier.setAutomatic,
        ),
        SwitchListTile(
          contentPadding: _padding,
          title: Text(localized.updatesNightly),
          subtitle: Text(localized.updatesNightlyHint),
          value: preferences.nightly,
          onChanged: notifier.setNightly,
        ),
        const UpdateStatusTile(),
      ],
    );
  }
}

class UpdateStatusTile extends ConsumerWidget {
  const UpdateStatusTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateProvider);
    if (state.phase == UpdatePhase.disabled) return const SizedBox.shrink();
    final localized = context.localized;
    final notifier = ref.read(updateProvider.notifier);
    final manifest = state.manifest;
    return ListTile(
      contentPadding: UpdateSettingsGroup._padding,
      title: Text(_status(localized, state)),
      subtitle: manifest == null
          ? null
          : Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                onPressed: () => openExternalLink(manifest.notesUrl.toString()),
                child: Text(localized.updatesReleaseNotes),
              ),
            ),
      trailing: switch (state.phase) {
        UpdatePhase.checking => const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        UpdatePhase.downloading => SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2, value: state.progress),
        ),
        UpdatePhase.ready => FilledButton(onPressed: notifier.restartToUpdate, child: Text(localized.updatesRestart)),
        UpdatePhase.available when state.inPlace => FilledButton(
          onPressed: notifier.restartToUpdate,
          child: Text(localized.updatesInstall),
        ),
        UpdatePhase.available => FilledButton.tonal(
          onPressed: () => openExternalLink(manifest!.notesUrl.toString()),
          child: Text(localized.updatesDownload),
        ),
        _ => TextButton(onPressed: notifier.check, child: Text(localized.updatesCheck)),
      },
    );
  }

  static String _status(AppLocalizations localized, UpdateState state) {
    final manifest = state.manifest;
    return switch (state.phase) {
      UpdatePhase.checking => localized.updatesChecking,
      UpdatePhase.upToDate => localized.updatesUpToDate,
      UpdatePhase.failed when manifest != null => localized.updatesInstallFailed(manifest.version, manifest.build),
      UpdatePhase.failed => localized.updatesFailed,
      UpdatePhase.downloading => localized.updatesDownloading((state.progress * 100).round()),
      UpdatePhase.ready => localized.updatesReady(manifest!.version, manifest.build),
      UpdatePhase.available => localized.updatesAvailable(manifest!.version, manifest.build),
      UpdatePhase.idle || UpdatePhase.disabled => localized.updatesCheck,
    };
  }
}
