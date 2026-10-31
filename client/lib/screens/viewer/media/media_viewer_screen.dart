import "dart:async";
import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:media_kit/media_kit.dart";
import "package:media_viewer/media_viewer.dart";
import "package:wakelock_plus/wakelock_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/media_siblings_provider.dart";
import "package:polder/providers/browser/thumbnail_provider.dart";
import "package:polder/screens/viewer/media/media_chrome.dart";
import "package:polder/screens/viewer/media/media_info_panel.dart";
import "package:polder/screens/viewer/media/media_photo_page.dart";
import "package:polder/screens/viewer/media/media_video_page.dart";
import "package:polder/screens/viewer/media/media_viewer_controls.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/util/remote_path.dart";

class MediaViewerScreen extends ConsumerStatefulWidget {
  const MediaViewerScreen({required this.entry, this.gallery, super.key});

  final FileEntry entry;
  final List<FileEntry>? gallery;

  @override
  ConsumerState<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends ConsumerState<MediaViewerScreen> with SingleTickerProviderStateMixin {
  static const _neighbourRange = 2;
  static const _sideInfoInset = 12.0;
  static const _sideInfoWidth = 360.0 + _sideInfoInset;
  static const _motion = MediaViewerMotion(sheet: AppMotion.spatialDuration, sheetCurve: AppMotion.spatial);

  final _viewer = MediaViewerController();
  late List<FileEntry>? _gallery = widget.gallery;
  bool? _browsesFolder;
  late final _slideshow = SlideshowController(vsync: this, onAdvance: _viewer.advance)
    ..addListener(_onSlideshowChanged);
  bool _slideshowRunning = false;
  Player? _player;

  @override
  void dispose() {
    _slideshow.dispose();
    unawaited(WakelockPlus.disable());
    super.dispose();
  }

  List<FileEntry> get _items => _itemsFrom(ref.read(mediaSiblingsProvider(_folder)));

  String get _folder => RemotePath.parent(widget.entry.path);

  List<FileEntry> _itemsFrom(List<FileEntry>? siblings) {
    if (_gallery case final gallery?) return gallery;
    if (siblings == null) return [widget.entry];
    _browsesFolder ??= siblings.any((sibling) => sibling.path == widget.entry.path);
    return _browsesFolder! ? siblings : [widget.entry];
  }

  void _onRenamed(FileEntry item, String path) {
    final gallery = _gallery;
    if (gallery != null) {
      setState(() {
        _gallery = [
          for (final entry in gallery)
            entry.path == item.path ? entry.copyWith(path: path, name: RemotePath.name(path)) : entry,
        ];
      });
    }
    _viewer.show(path);
  }

  void _onRemoved(FileEntry item) {
    final gallery = _gallery;
    if (gallery == null) return;
    setState(
      () => _gallery = [
        for (final entry in gallery)
          if (entry.path != item.path) entry,
      ],
    );
  }

  void _onItemChanged(FileEntry item) {
    _slideshow.showItem(isVideo: item.isVideo);
    final items = _items;
    final index = items.indexWhere((candidate) => candidate.path == item.path);
    for (var i = math.max(0, index - _neighbourRange); i <= math.min(items.length - 1, index + _neighbourRange); i++) {
      unawaited(ref.read(thumbnailProvider(mediaPoster(items[i])).future).then<void>((_) {}, onError: (_) {}));
    }
  }

  void _onSlideshowChanged() {
    if (_slideshow.running == _slideshowRunning) return;
    _slideshowRunning = _slideshow.running;
    unawaited(WakelockPlus.toggle(enable: _slideshowRunning));
    if (_slideshowRunning) _viewer.showOverlay(visible: false);
  }

  void _attachPlayer(Player player, {required bool attached}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (attached) {
        setState(() => _player = player);
      } else if (identical(_player, player)) {
        setState(() => _player = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _itemsFrom(ref.watch(mediaSiblingsProvider(_folder)));
    if (items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(Navigator.of(context).maybePop());
      });
    }
    final usesPointer = AdaptiveLayout.usesPointer(context);
    return MediaViewerTheme(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Builder(
          builder: (context) {
            final stage = Theme.of(context).colorScheme.surfaceContainerLowest;
            return Scaffold(
              backgroundColor: stage,
              body: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.space): () {
                    if (items.length > 1) _slideshow.toggle();
                  },
                },
                child: MediaGestureViewer<FileEntry>(
                  items: items,
                  itemKey: (item) => item.path,
                  initialItem: widget.entry,
                  controller: _viewer,
                  usesPointer: usesPointer,
                  sideInfo: !AdaptiveLayout.isPhone(context),
                  sideInfoWidth: _sideInfoWidth,
                  background: stage,
                  motion: _motion,
                  onItemChanged: _onItemChanged,
                  pageBuilder: _page,
                  overlayBuilder: (context, item, overlay) => MediaViewerControls(
                    entry: item,
                    overlay: overlay,
                    showArrows: usesPointer,
                    slideshow: _slideshow,
                    player: item.isVideo ? _player : null,
                    onBack: _viewer.close,
                    onInfo: _viewer.toggleInfo,
                    onPrevious: _viewer.previous,
                    onNext: _viewer.next,
                  ),
                  infoBuilder: _info,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _page(BuildContext context, FileEntry item, MediaPage page) => item.isVideo
      ? MediaVideoPage(
          entry: item,
          active: page.active,
          onPlayerChanged: _attachPlayer,
          onTap: page.onTap,
          onCompleted: _slideshow.videoCompleted,
        )
      : MediaPhotoPage(entry: item, page: page);

  Widget _info(BuildContext context, FileEntry item, MediaInfoPlacement placement) {
    final panel = MediaInfoPanel(
      entry: item,
      asSheet: placement == MediaInfoPlacement.sheet,
      onClose: _viewer.toggleInfo,
      onRenamed: (path) => _onRenamed(item, path),
      onRemoved: () => _onRemoved(item),
    );
    if (placement == MediaInfoPlacement.sheet) return panel;
    return SafeArea(
      left: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, _sideInfoInset, _sideInfoInset, _sideInfoInset),
        child: panel,
      ),
    );
  }
}
