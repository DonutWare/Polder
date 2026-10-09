import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/appearance.dart";
import "package:polder/models/branding.dart";
import "package:polder/models/server_settings.dart";
import "package:polder/providers/admin/server_settings_provider.dart";
import "package:polder/providers/branding/branding_provider.dart";
import "package:polder/screens/login/widgets/login_backdrop.dart";
import "package:polder/screens/login/widgets/login_header.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/icon_badge.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/shared/image_source_menu.dart";
import "package:polder/widgets/shared/server_icon.dart";
import "package:polder/widgets/shared/text_input_dialog.dart";

class AdminBrandingScreen extends ConsumerWidget {
  const AdminBrandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    return AppPage(
      title: Text(localized.brandingGroup),
      body: AsyncValueView<ServerSettings>(
        value: ref.watch(serverSettingsProvider),
        onRetry: () => ref.invalidate(serverSettingsProvider),
        data: (settings) => ReadableWidth(
          maxWidth: 1080,
          builder: (context, inset) => ListView(
            padding: inset + const EdgeInsets.only(top: 8, bottom: 24),
            children: [
              const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 8), child: _LoginPreview()),
              _identity(context, ref, settings),
              _images(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _identity(BuildContext context, WidgetRef ref, ServerSettings settings) {
    final notifier = ref.read(serverSettingsProvider.notifier);
    final localized = context.localized;
    return NavGroup(
      title: localized.brandingIdentityGroup,
      children: [
        NavEntry(
          icon: IconsaxPlusLinear.edit_2,
          title: localized.serverName,
          subtitle: settings.instanceName.isEmpty
              ? localized.brandingDefault(localized.appTitle)
              : settings.instanceName,
          onTap: () => _editName(context, notifier, settings),
        ),
        NavEntry(
          icon: IconsaxPlusLinear.message_text,
          title: localized.welcomeMessage,
          subtitle: settings.welcomeMessage.isEmpty ? localized.welcomeMessageNone : settings.welcomeMessage,
          onTap: () => _editMessage(context, notifier, settings),
        ),
        NavEntry(
          icon: IconsaxPlusLinear.colorfilter,
          title: localized.brandingAccent,
          subtitle: localized.brandingAccentHint,
          trailing: _ColorDot(color: settings.accentColor ?? Appearance.defaultAccent),
          onTap: () => _chooseColor(context, notifier, settings),
        ),
      ],
    );
  }

  Widget _images(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(brandingProvider);
    final localized = context.localized;
    return NavGroup(
      title: localized.brandingImagesGroup,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: const ServerIcon(size: 40, fallback: _IconPlaceholder()),
          title: Text(localized.serverIcon),
          subtitle: Text(localized.serverIconHint),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (branding.icon != null)
                IconButton(
                  tooltip: localized.remove,
                  icon: const Icon(IconsaxPlusLinear.trash),
                  onPressed: () => context.runWithFeedback(ref.read(brandingProvider.notifier).removeIcon()),
                ),
              ImageSourceMenu(
                onSelected: (source) => _pickIcon(context, ref, source),
                builder: (open) => IconButton(
                  tooltip: localized.change,
                  icon: const Icon(IconsaxPlusLinear.gallery_edit),
                  onPressed: open,
                ),
              ),
            ],
          ),
        ),
        const _Backgrounds(),
      ],
    );
  }

  Future<void> _editName(BuildContext context, ServerSettingsNotifier notifier, ServerSettings settings) async {
    final localized = context.localized;
    final value = await showTextInputDialog(
      context,
      title: localized.serverName,
      label: localized.serverName,
      confirmLabel: localized.save,
      initialValue: settings.instanceName,
      isValid: (_) => true,
    );
    if (value != null && context.mounted) await context.runWithFeedback(notifier.setInstanceName(value));
  }

  Future<void> _editMessage(BuildContext context, ServerSettingsNotifier notifier, ServerSettings settings) async {
    final localized = context.localized;
    final value = await showTextInputDialog(
      context,
      title: localized.welcomeMessage,
      label: localized.welcomeMessage,
      confirmLabel: localized.save,
      initialValue: settings.welcomeMessage,
      isValid: (_) => true,
      maxLines: 4,
    );
    if (value != null && context.mounted) await context.runWithFeedback(notifier.setWelcomeMessage(value));
  }

  Future<void> _chooseColor(BuildContext context, ServerSettingsNotifier notifier, ServerSettings settings) async {
    final choice = await showDialog<(Color?,)>(
      context: context,
      builder: (_) => _ColorDialog(initial: settings.accentColor),
    );
    if (choice != null && context.mounted) await context.runWithFeedback(notifier.setAccentColor(choice.$1));
  }

  Future<void> _pickIcon(BuildContext context, WidgetRef ref, ImageSource source) async {
    final images = await pickImages(context, ref, source, multiple: false);
    if (images.isEmpty || !context.mounted) return;
    final notifier = ref.read(brandingProvider.notifier);
    await context.runWithFeedback(images.first().then(notifier.setIcon));
  }
}

class _IconPlaceholder extends StatelessWidget {
  const _IconPlaceholder();

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 40,
    child: Icon(IconsaxPlusLinear.gallery_slash, color: Theme.of(context).colorScheme.onSurfaceVariant),
  );
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.of(context).border),
    ),
  );
}

class _ColorDialog extends StatefulWidget {
  const _ColorDialog({required this.initial});

  final Color? initial;

  @override
  State<_ColorDialog> createState() => _ColorDialogState();
}

class _ColorDialogState extends State<_ColorDialog> {
  late final _controller = TextEditingController(text: widget.initial == null ? "" : hexColor(widget.initial!));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(localized.brandingAccent),
      content: SizedBox(
        width: 340,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final current = parseHexColor(_controller.text.trim());
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final preset in AccentPreset.values)
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _controller.text = hexColor(preset.color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: preset.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: current?.toARGB32() == preset.color.toARGB32() ? cs.onSurface : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: localized.hexColorLabel,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _ColorDot(color: current ?? Appearance.defaultAccent),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, (null,)), child: Text(localized.appDefault)),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(localized.cancel)),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final color = parseHexColor(_controller.text.trim());
            return FilledButton(
              onPressed: color == null ? null : () => Navigator.pop(context, (color,)),
              child: Text(localized.save),
            );
          },
        ),
      ],
    );
  }
}

class _Backgrounds extends ConsumerWidget {
  const _Backgrounds();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final branding = ref.watch(brandingProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const IconBadge(icon: IconsaxPlusLinear.gallery),
                  title: Text(localized.loginBackgrounds),
                  subtitle: Text(localized.loginBackgroundsHint(branding.backgrounds.length)),
                ),
              ),
              ImageSourceMenu(
                onSelected: (source) => _add(context, ref, source),
                builder: (open) => FilledButton.tonalIcon(
                  icon: const Icon(IconsaxPlusLinear.add),
                  label: Text(localized.add),
                  onPressed: open,
                ),
              ),
            ],
          ),
          if (branding.serverUrl != null && branding.backgrounds.isNotEmpty)
            GridView.extent(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 16 / 10,
              children: [
                for (final image in branding.backgrounds)
                  _BackgroundTile(url: branding.backgroundUrl(image), image: image),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, ImageSource source) async {
    final images = await pickImages(context, ref, source, multiple: true);
    final notifier = ref.read(brandingProvider.notifier);
    for (final image in images) {
      if (!context.mounted || !await context.runWithFeedback(image().then(notifier.addBackground))) return;
    }
  }
}

class _LoginPreview extends StatelessWidget {
  const _LoginPreview();

  @override
  Widget build(BuildContext context) => ClipRSuperellipse(
    borderRadius: BorderRadius.circular(GroupedTile.outer),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minWidth: double.infinity, minHeight: 320),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: ColoredBox(color: Theme.of(context).colorScheme.surface)),
          const Positioned.fill(child: LoginBackdrop()),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: const Card(
                child: Padding(padding: EdgeInsets.fromLTRB(24, 28, 24, 28), child: LoginHeader()),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _BackgroundTile extends ConsumerWidget {
  const _BackgroundTile({required this.url, required this.image});

  final String url;
  final ServerImage image;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ClipRSuperellipse(
    borderRadius: BorderRadius.circular(AppRadius.tag),
    child: Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: AppColors.of(context).inset),
        ServerImageView(url: url, image: image, fit: BoxFit.cover),
        Align(
          alignment: AlignmentDirectional.topEnd,
          child: IconButton.filledTonal(
            tooltip: context.localized.remove,
            icon: const Icon(IconsaxPlusLinear.trash, size: 18),
            onPressed: () => context.runWithFeedback(ref.read(brandingProvider.notifier).removeBackground(image.id)),
          ),
        ),
      ],
    ),
  );
}
