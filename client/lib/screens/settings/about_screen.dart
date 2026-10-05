import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:url_launcher/url_launcher.dart";

import "package:polder/providers/app/package_info_provider.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/shared/polder_logo.dart";

typedef _Link = ({String name, String platform, String url, IconData icon, Color? color});

const _socials = <_Link>[
  (
    name: "GitHub",
    platform: "GitHub",
    url: "https://github.com/DonutWare/Polder",
    icon: IconsaxPlusLinear.code,
    color: null,
  ),
];

const _sponsors = <_Link>[
  (
    name: "PartyDonut",
    platform: "GitHub Sponsors",
    url: "https://github.com/sponsors/PartyDonut",
    icon: IconsaxPlusLinear.heart,
    color: Color.fromARGB(255, 198, 68, 172),
  ),
  (
    name: "jopknaapen",
    platform: "Buy me a Coffee",
    url: "https://buymeacoffee.com/jopknaapen",
    icon: IconsaxPlusLinear.coffee,
    color: Color.fromARGB(255, 255, 220, 19),
  ),
];

Future<void> _open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final info = ref.watch(packageInfoProvider).value;
    final version = info == null ? null : "${info.version} (${info.buildNumber})";
    const divider = FractionallySizedBox(widthFactor: 0.25, child: Divider(indent: 16, endIndent: 16));
    return AppPage(
      title: Text(localized.about),
      body: ReadableWidth(
        maxWidth: 720,
        builder: (context, inset) => ListView(
          padding: inset + const EdgeInsets.only(top: 24, bottom: 32),
          children: [
            Column(
              spacing: 16,
              children: [
                const PolderLogo(),
                Column(
                  children: [
                    Text(localized.aboutLegalese, textAlign: TextAlign.center),
                    if (version != null) Text(localized.aboutVersion(version)),
                    const SizedBox(height: 16),
                    Text(localized.aboutCreatedBy),
                  ],
                ),
                divider,
                _LinkSection(title: localized.aboutSocials, links: _socials),
                divider,
                _LinkSection(title: localized.sponsor, message: localized.sponsorMessage, links: _sponsors),
                FilledButton.tonal(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: localized.appTitle,
                    applicationIcon: const Padding(padding: EdgeInsets.all(8), child: PolderIcon(size: 55)),
                    applicationVersion: version,
                    applicationLegalese: "DonutWare",
                    useRootNavigator: true,
                  ),
                  child: Text(localized.aboutLicenses),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkSection extends StatelessWidget {
  const _LinkSection({required this.title, required this.links, this.message});

  final String title;
  final String? message;
  final List<_Link> links;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      spacing: 6,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        if (message != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(message!, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final link in links)
              Tooltip(
                message: link.platform,
                child: IconButton.filledTonal(
                  onPressed: () => _open(link.url),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    minimumSize: const Size(64, 64),
                    backgroundColor: link.color?.withAlpha(75),
                    side: link.color == null ? null : BorderSide(color: link.color!.withAlpha(150), width: 2),
                  ),
                  icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(link.icon, color: link.color),
                      Text(link.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelSmall),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
