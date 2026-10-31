import "dart:async";

import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";
import "package:media_kit/media_kit.dart";
import "package:media_viewer/media_viewer.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/screens/viewer/media/media_chrome.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/duration_format.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/tag.dart";

class MediaViewerControls extends StatelessWidget {
  const MediaViewerControls({
    required this.entry,
    required this.overlay,
    required this.showArrows,
    required this.slideshow,
    required this.player,
    required this.onBack,
    required this.onInfo,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  static const _edgeInset = 12.0;
  static const _bottomBarWidth = 720.0;

  final FileEntry entry;
  final MediaOverlay overlay;
  final bool showArrows;
  final SlideshowController slideshow;
  final Player? player;
  final VoidCallback onBack;
  final VoidCallback onInfo;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  int get index => overlay.index;

  int get count => overlay.count;

  bool get visible => overlay.visible;

  bool get _hasBottomBar => player != null || count > 1;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: !visible,
    child: SafeArea(
      minimum: const EdgeInsets.all(_edgeInset),
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, child: _reveal(_topBar(context), from: const Offset(0, -0.4))),
          if (_hasBottomBar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _reveal(
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _bottomBarWidth),
                    child: _BottomBar(player: player, slideshow: count > 1 ? slideshow : null),
                  ),
                ),
                from: const Offset(0, 0.4),
              ),
            ),
          if (showArrows && index > 0)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _reveal(
                Center(
                  child: _EdgeButton(
                    icon: IconsaxPlusLinear.arrow_left_1,
                    tooltip: context.localized.previousItem,
                    onPressed: onPrevious,
                  ),
                ),
                from: const Offset(-0.4, 0),
              ),
            ),
          if (showArrows && index < count - 1)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _reveal(
                Center(
                  child: _EdgeButton(
                    icon: IconsaxPlusLinear.arrow_right_3,
                    tooltip: context.localized.nextItem,
                    onPressed: onNext,
                  ),
                ),
                from: const Offset(0.4, 0),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _reveal(Widget child, {required Offset from}) => AnimatedSlide(
    offset: visible ? Offset.zero : from,
    duration: AppMotion.spatialDuration,
    curve: AppMotion.spatial,
    child: AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: AppMotion.effectsDuration,
      curve: AppMotion.effects,
      child: child,
    ),
  );

  Widget _topBar(BuildContext context) {
    final theme = Theme.of(context);
    final localized = context.localized;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FloatingPanel(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BackButton(onPressed: onBack),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, right: 12),
                      child: Text(entry.name, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
                    ),
                  ),
                  if (count > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Tag(text: localized.mediaCounter(index + 1, count), color: theme.colorScheme.primary),
                    ),
                ],
              ),
            ),
          ),
        ),
        FloatingPanel(
          child: _ToggleButton(
            selected: overlay.infoOpen,
            tooltip: localized.details,
            icon: IconsaxPlusLinear.info_circle,
            onPressed: onInfo,
          ),
        ),
      ],
    );
  }
}

class _EdgeButton extends StatelessWidget {
  const _EdgeButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FloatingPanel(
    radius: AppRadius.inset + 4,
    padding: const EdgeInsets.all(4),
    child: IconButton(tooltip: tooltip, icon: Icon(icon), onPressed: onPressed),
  );
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.selected,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.selectedIcon,
  });

  final bool selected;
  final String tooltip;
  final IconData icon;
  final IconData? selectedIcon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      isSelected: selected,
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon ?? icon),
      onPressed: onPressed,
      style: selected
          ? IconButton.styleFrom(
              backgroundColor: colors.secondaryContainer,
              foregroundColor: colors.onSecondaryContainer,
              shape: squircle(AppRadius.control, side: tintedSide(colors.secondary)),
            )
          : null,
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.player, required this.slideshow});

  static const _compactWidth = 520.0;

  final Player? player;
  final SlideshowController? slideshow;

  @override
  Widget build(BuildContext context) {
    final slideshow = this.slideshow;
    final player = this.player;
    final slideshowControls = slideshow == null ? null : _SlideshowControls(controller: slideshow);
    if (player == null) return FloatingPanel(child: slideshowControls!);
    return FloatingPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _compactWidth) {
            return Row(
              children: [
                _PlayButton(player: player),
                Expanded(child: _SeekBar(player: player)),
                _MuteButton(player: player),
                if (slideshowControls != null) ...[const _Separator(), slideshowControls],
              ],
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SeekBar(player: player),
              Row(
                children: [
                  _PlayButton(player: player),
                  _MuteButton(player: player),
                  const Spacer(),
                  ?slideshowControls,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 24,
    margin: const EdgeInsets.symmetric(horizontal: 6),
    color: AppColors.of(context).border,
  );
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
    stream: player.stream.playing,
    initialData: player.state.playing,
    builder: (context, snapshot) {
      final playing = snapshot.data ?? false;
      final colors = Theme.of(context).colorScheme;
      return IconButton.filled(
        style: IconButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary),
        tooltip: playing ? context.localized.pause : context.localized.play,
        icon: Icon(playing ? IconsaxPlusBold.pause : IconsaxPlusBold.play),
        onPressed: () => unawaited(player.playOrPause()),
      );
    },
  );
}

class _MuteButton extends StatelessWidget {
  const _MuteButton({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) => StreamBuilder<double>(
    stream: player.stream.volume,
    initialData: player.state.volume,
    builder: (context, snapshot) {
      final muted = (snapshot.data ?? 100) == 0;
      return IconButton(
        tooltip: muted ? context.localized.unmute : context.localized.mute,
        icon: Icon(muted ? IconsaxPlusLinear.volume_slash : IconsaxPlusLinear.volume_high),
        onPressed: () => unawaited(player.setVolume(muted ? 100 : 0)),
      );
    },
  );
}

class _SeekBar extends StatefulWidget {
  const _SeekBar({required this.player});

  final Player player;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return StreamBuilder<Duration>(
      stream: widget.player.stream.duration,
      initialData: widget.player.state.duration,
      builder: (context, durationSnapshot) => StreamBuilder<Duration>(
        stream: widget.player.stream.position,
        initialData: widget.player.state.position,
        builder: (context, positionSnapshot) {
          final duration = durationSnapshot.data ?? Duration.zero;
          final position = positionSnapshot.data ?? Duration.zero;
          final max = duration.inMilliseconds.toDouble();
          final value = (_dragValue ?? position.inMilliseconds.toDouble()).clamp(0.0, max > 0 ? max : 1.0);
          return Row(
            children: [
              const SizedBox(width: 8),
              Text(Duration(milliseconds: value.round()).clock, style: timeStyle),
              Expanded(
                child: Slider(
                  value: value,
                  max: max > 0 ? max : 1,
                  onChanged: max > 0 ? (next) => setState(() => _dragValue = next) : null,
                  onChangeEnd: (next) {
                    unawaited(widget.player.seek(Duration(milliseconds: next.round())));
                    setState(() => _dragValue = null);
                  },
                ),
              ),
              Text(duration.clock, style: timeStyle),
              const SizedBox(width: 8),
            ],
          );
        },
      ),
    );
  }
}

class _SlideshowControls extends StatelessWidget {
  const _SlideshowControls({required this.controller});

  final SlideshowController controller;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MenuAnchor(
            menuChildren: [
              for (final interval in SlideshowController.intervals)
                MenuItemButton(
                  leadingIcon: Icon(
                    controller.interval == interval ? IconsaxPlusBold.tick_circle : IconsaxPlusLinear.timer_1,
                  ),
                  onPressed: () => controller.interval = interval,
                  child: Text(localized.durationSeconds(interval.inSeconds)),
                ),
            ],
            builder: (context, menu, _) => TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              icon: const Icon(IconsaxPlusLinear.timer_1, size: 18),
              label: Text(localized.durationSeconds(controller.interval.inSeconds)),
              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              _ToggleButton(
                selected: controller.running,
                tooltip: localized.slideshow,
                icon: IconsaxPlusLinear.play_circle,
                selectedIcon: IconsaxPlusLinear.pause,
                onPressed: controller.toggle,
              ),
              if (controller.countingDown) _CountdownRing(progress: controller.progress),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownRing extends StatelessWidget {
  const _CountdownRing({required this.progress});

  static const _size = 38.0;

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: SizedBox.square(
      dimension: _size,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, _) => CircularProgressIndicator(
          value: progress.value,
          strokeWidth: 2.5,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.2),
        ),
      ),
    ),
  );
}
