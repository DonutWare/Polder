import "dart:math" as math;

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/link_preview.dart";
import "package:polder/providers/notes/link_preview_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/screens/notes/editor/note_image_provider.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/external_link.dart";

String _hostOf(String url) => (Uri.tryParse(url)?.host ?? url).replaceFirst(RegExp(r"^www\."), "");

String _imageIdentity(String url, LinkPreviewImageKind kind) {
  final origin = Uri.tryParse(url);
  final source = kind == LinkPreviewImageKind.icon && origin != null && origin.hasAuthority ? origin.origin : url;
  return "link-preview|${kind.name}|$source";
}

ImageProvider _previewImage(PolderApi api, String url, LinkPreviewImageKind kind) => NoteImageProvider(
  identity: _imageIdentity(url, kind),
  load: () async => await api.linkPreviewImage(url, kind) ?? (throw StateError("the link has no ${kind.name}")),
);

class LinkPreviewCard extends ConsumerWidget {
  const LinkPreviewCard({required this.url, this.width = 300, super.key});

  static const height = 72.0;

  final String url;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final preview = ref.watch(linkPreviewProvider(url)).value;
    final api = ref.watch(polderApiProvider);
    final title = preview?.title ?? preview?.siteName ?? _hostOf(url);
    final site = preview?.siteName ?? _hostOf(url);
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: colors.surfaceContainer,
        shape: squircle(AppRadius.inset, side: BorderSide(color: colors.outlineVariant)),
        child: InkWell(
          onTap: () => openExternalLink(url),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: height,
                child: preview?.hasImage ?? false
                    ? Image(
                        image: _previewImage(api, url, LinkPreviewImageKind.image),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _IconTile(url: url, preview: preview),
                      )
                    : _IconTile(url: url, preview: preview),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (site != title) ...[
                        const SizedBox(height: 2),
                        Text(
                          site,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.url, required this.preview});

  final String url;
  final LinkPreview? preview;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: LinkIcon(url: url, preview: preview, size: 28),
      ),
    );
  }
}

class LinkIcon extends ConsumerWidget {
  const LinkIcon({required this.url, required this.preview, this.size = 16, super.key});

  final String url;
  final LinkPreview? preview;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fallback = Icon(IconsaxPlusLinear.global, size: size, color: Theme.of(context).colorScheme.onSurfaceVariant);
    if (!(preview?.hasIcon ?? false)) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 5),
      child: Image(
        image: _previewImage(ref.watch(polderApiProvider), url, LinkPreviewImageKind.icon),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

class LinkPreviewRow extends ConsumerWidget {
  const LinkPreviewRow({required this.url, super.key});

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final preview = ref.watch(linkPreviewProvider(url)).value;
    return Row(
      children: [
        LinkIcon(url: url, preview: preview),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            preview?.title ?? preview?.siteName ?? _hostOf(url),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class LinkPreviewStrip extends StatelessWidget {
  const LinkPreviewStrip({required this.urls, required this.gutters, super.key});

  static const _spacing = 8.0;
  static const _cardWidth = 300.0;

  final List<String> urls;
  final EdgeInsets gutters;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: LinkPreviewCard.height + 16,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(_cardWidth, constraints.maxWidth - gutters.horizontal);
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(gutters.left, 8, gutters.right, 8),
            itemCount: urls.length,
            separatorBuilder: (_, _) => const SizedBox(width: _spacing),
            itemBuilder: (context, index) =>
                LinkPreviewCard(key: ValueKey(urls[index]), url: urls[index], width: width),
          );
        },
      ),
    );
  }
}
