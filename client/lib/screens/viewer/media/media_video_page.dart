import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:media_kit/media_kit.dart";
import "package:media_kit_video/media_kit_video.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/media_source.dart";
import "package:polder/providers/browser/thumbnail_provider.dart";
import "package:polder/screens/viewer/media/media_chrome.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/loading_indicator.dart";

class MediaVideoPage extends ConsumerStatefulWidget {
  const MediaVideoPage({
    required this.entry,
    required this.active,
    required this.onPlayerChanged,
    this.onTap,
    this.onCompleted,
    super.key,
  });

  final FileEntry entry;
  final bool active;
  final void Function(Player player, {required bool attached}) onPlayerChanged;
  final VoidCallback? onTap;
  final VoidCallback? onCompleted;

  @override
  ConsumerState<MediaVideoPage> createState() => _MediaVideoPageState();
}

class _MediaVideoPageState extends ConsumerState<MediaVideoPage> {
  static const _failureGrace = Duration(seconds: 2);

  final _subscriptions = <StreamSubscription<Object?>>[];
  Player? _player;
  VideoController? _controller;
  Object? _error;
  int _generation = 0;
  Timer? _failureCheck;

  @override
  void initState() {
    super.initState();
    if (widget.active) unawaited(_start());
  }

  @override
  void didUpdateWidget(MediaVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      unawaited(_start());
    } else {
      _stop();
    }
  }

  @override
  void dispose() {
    _stop(rebuild: false);
    super.dispose();
  }

  Future<void> _start() async {
    final generation = ++_generation;
    setState(() => _error = null);
    try {
      final source = await resolveMediaSource(ref, widget.entry);
      if (!mounted || generation != _generation) return;
      final player = Player();
      _player = player;
      _controller = VideoController(player);
      _subscriptions
        ..add(
          player.stream.completed.listen((completed) {
            if (completed) widget.onCompleted?.call();
          }),
        )
        ..add(player.stream.error.listen((error) => _onPlayerError(player, error)));
      widget.onPlayerChanged(player, attached: true);
      setState(() {});
      await player.open(Media(source.url.toString(), httpHeaders: source.headers));
    } on Object catch (error) {
      if (mounted && generation == _generation) setState(() => _error = error);
    }
  }

  void _onPlayerError(Player player, String error) {
    _failureCheck?.cancel();
    _failureCheck = Timer(_failureGrace, () {
      if (!mounted || !identical(player, _player) || _hasLoaded(player.state)) return;
      setState(() => _error = error);
    });
  }

  static bool _hasLoaded(PlayerState state) => state.duration > Duration.zero || state.width != null;

  void _stop({bool rebuild = true}) {
    _generation++;
    _failureCheck?.cancel();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    final player = _player;
    _player = null;
    _controller = null;
    if (player == null) return;
    widget.onPlayerChanged(player, attached: false);
    unawaited(player.dispose());
    if (rebuild) setState(() {});
  }

  void _onTap() {
    if (AdaptiveLayout.usesPointer(context) && _player != null) {
      unawaited(_player!.playOrPause());
    } else {
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final poster = ref.watch(thumbnailProvider(mediaPoster(widget.entry))).value;
    final controller = _controller;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (poster != null) Image.memory(poster, fit: BoxFit.contain, gaplessPlayback: true),
          if (controller != null) Video(controller: controller, controls: null, fill: Colors.transparent),
          if (_error != null)
            MediaFailure(
              detail: context.localized.describeError(_error),
              onRetry: () {
                _stop();
                unawaited(_start());
              },
            )
          else if (!widget.active)
            const Center(child: MediaPlayBadge())
          else if (controller == null)
            const LoadingIndicator()
          else
            _BufferingIndicator(player: _player!),
        ],
      ),
    );
  }
}

class _BufferingIndicator extends StatelessWidget {
  const _BufferingIndicator({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
    stream: player.stream.buffering,
    initialData: player.state.buffering,
    builder: (context, snapshot) => snapshot.data ?? false ? const LoadingIndicator() : const SizedBox.shrink(),
  );
}
