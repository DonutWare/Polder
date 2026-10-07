import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/search.dart";
import "package:polder/models/server_settings.dart";
import "package:polder/providers/admin/server_settings_provider.dart";
import "package:polder/providers/admin/text_extraction_status_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/text_input_dialog.dart";

class SearchSettingsGroup extends ConsumerWidget {
  const SearchSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(serverSettingsProvider).value;
    final status = ref.watch(textExtractionStatusProvider).value;
    final notifier = ref.read(serverSettingsProvider.notifier);
    final localized = context.localized;
    if (settings == null) return const SizedBox.shrink();
    final pending = status?.pending ?? 0;
    final ocrProblem = status?.ocr == OcrState.unavailable ? status?.ocrProblem : null;
    final ocrActive = settings.searchContentEnabled && settings.ocrEnabled;
    return NavGroup(
      title: localized.serverSearchGroup,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(localized.searchContentSetting),
          subtitle: Text(
            settings.searchContentEnabled && pending > 0
                ? localized.searchContentPending(pending)
                : localized.searchContentSettingHint,
          ),
          value: settings.searchContentEnabled,
          onChanged: (enabled) => context.runWithFeedback(notifier.setSearchContentEnabled(enabled)),
        ),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(localized.ocrSetting),
          subtitle: Text(
            ocrActive && ocrProblem != null ? localized.ocrUnavailable(ocrProblem) : localized.ocrSettingHint,
            style: ocrActive && ocrProblem != null ? TextStyle(color: Theme.of(context).colorScheme.error) : null,
          ),
          value: settings.ocrEnabled,
          onChanged: settings.searchContentEnabled
              ? (enabled) => context.runWithFeedback(notifier.setOcrEnabled(enabled))
              : null,
        ),
        if (ocrActive) ...[
          NavEntry(
            icon: IconsaxPlusLinear.language_square,
            title: localized.ocrLanguagesSetting,
            subtitle: settings.ocrLanguages.join(", "),
            onTap: () => _chooseLanguages(context, notifier, settings),
          ),
          NavEntry(
            icon: IconsaxPlusLinear.document_text,
            title: localized.ocrMaxPagesSetting,
            subtitle: localized.ocrMaxPagesHint(settings.ocrMaxPages),
            onTap: () => _chooseMaxPages(context, notifier, settings),
          ),
        ],
      ],
    );
  }

  Future<void> _chooseLanguages(BuildContext context, ServerSettingsNotifier notifier, ServerSettings settings) async {
    final localized = context.localized;
    final value = await showTextInputDialog(
      context,
      title: localized.ocrLanguagesSetting,
      label: localized.ocrLanguagesLabel,
      confirmLabel: localized.save,
      initialValue: settings.ocrLanguages.join(", "),
    );
    if (value == null || !context.mounted) return;
    final languages = [
      for (final language in value.split(RegExp(r"[\s,+]+")))
        if (language.isNotEmpty) language,
    ];
    await context.runWithFeedback(notifier.setOcrLanguages(languages));
  }

  Future<void> _chooseMaxPages(BuildContext context, ServerSettingsNotifier notifier, ServerSettings settings) async {
    final localized = context.localized;
    final value = await showTextInputDialog(
      context,
      title: localized.ocrMaxPagesSetting,
      label: localized.ocrMaxPagesLabel,
      confirmLabel: localized.save,
      initialValue: "${settings.ocrMaxPages}",
      isValid: (value) => (int.tryParse(value.trim()) ?? 0) > 0,
    );
    final pages = int.tryParse(value?.trim() ?? "");
    if (pages != null && context.mounted) await context.runWithFeedback(notifier.setOcrMaxPages(pages));
  }
}
