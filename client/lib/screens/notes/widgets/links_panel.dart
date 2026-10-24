import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/file_links.dart";
import "package:polder/providers/notes/file_links_provider.dart";
import "package:polder/screens/browser/widgets/file_type_icon.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/async_value_view.dart";

class LinksPanel extends ConsumerStatefulWidget {
  const LinksPanel({required this.entry, required this.onOpen, super.key});

  final FileEntry entry;
  final ValueChanged<FileEntry> onOpen;

  @override
  ConsumerState<LinksPanel> createState() => _LinksPanelState();
}

class _LinksPanelState extends ConsumerState<LinksPanel> {
  FileLinks? _lastShown;

  @override
  Widget build(BuildContext context) {
    if (widget.entry.mount != null) return _list(context, const FileLinks());
    final links = ref.watch(fileLinksProvider(widget.entry.id));
    if (links.value case final loaded?) _lastShown = loaded;
    final previous = _lastShown;
    if (links.isLoading && !links.hasValue && previous != null) return _list(context, previous);
    return AsyncValueView<FileLinks>(
      value: links,
      onRetry: () => ref.invalidate(fileLinksProvider(widget.entry.id)),
      data: (links) => _list(context, links),
    );
  }

  Widget _list(BuildContext context, FileLinks links) {
    final localized = context.localized;
    final onOpen = widget.onOpen;
    final incoming = _uniqueSources(links.incoming);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _Header(text: localized.noteLinkedFrom, count: incoming.length),
        if (incoming.isEmpty) _Empty(text: localized.noteNoBacklinks),
        for (final link in incoming)
          _LinkTile(entry: link.source, subtitle: link.title, onTap: () => onOpen(link.source)),
        const SizedBox(height: 16),
        _Header(text: localized.noteLinksTo, count: links.outgoing.length),
        if (links.outgoing.isEmpty) _Empty(text: localized.noteNoLinks),
        for (final link in links.outgoing)
          if (link.target case final target?)
            _LinkTile(entry: target, subtitle: link.title, onTap: () => onOpen(target))
          else
            ListTile(
              dense: true,
              leading: Icon(Icons.link_off, color: Theme.of(context).colorScheme.error),
              title: Text(link.title.isEmpty ? RemotePath.name(link.targetPath) : link.title),
              subtitle: Text(localized.noteBrokenLink(link.targetPath)),
            ),
      ],
    );
  }

  static List<IncomingLink> _uniqueSources(List<IncomingLink> links) {
    final seen = <int>{};
    return [
      for (final link in links)
        if (seen.add(link.source.id)) link,
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.text, required this.count});

  final String text;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        "$text · $count",
        style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
  );
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.entry, required this.subtitle, required this.onTap});

  final FileEntry entry;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = entry.displayName;
    return ListTile(
      dense: true,
      leading: FileTypeIcon(entry: entry, size: 22),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        subtitle.isEmpty || subtitle == name ? RemotePath.parent(entry.path) : subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
