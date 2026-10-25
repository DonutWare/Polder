import "package:flutter/foundation.dart";

import "package:polder/util/adaptive_layout/adaptive_layout.dart";

@immutable
class LayoutPoints {
  const LayoutPoints({required this.start, required this.end, required this.type});

  final double start;
  final double end;
  final ViewSize type;

  bool contains(double width) => width >= start && width < end;
}

@immutable
class AdaptiveLayoutModel {
  const AdaptiveLayoutModel({
    required this.viewSize,
    required this.layoutMode,
    required this.inputDevice,
    required this.platform,
    required this.isDesktop,
    this.sideBarWidth = 0,
  });

  final ViewSize viewSize;
  final LayoutMode layoutMode;
  final InputDevice inputDevice;
  final TargetPlatform platform;
  final bool isDesktop;
  final double sideBarWidth;

  AdaptiveLayoutModel copyWith({
    ViewSize? viewSize,
    LayoutMode? layoutMode,
    InputDevice? inputDevice,
    TargetPlatform? platform,
    bool? isDesktop,
    double? sideBarWidth,
  }) => AdaptiveLayoutModel(
    viewSize: viewSize ?? this.viewSize,
    layoutMode: layoutMode ?? this.layoutMode,
    inputDevice: inputDevice ?? this.inputDevice,
    platform: platform ?? this.platform,
    isDesktop: isDesktop ?? this.isDesktop,
    sideBarWidth: sideBarWidth ?? this.sideBarWidth,
  );

  @override
  bool operator ==(Object other) =>
      other is AdaptiveLayoutModel &&
      other.viewSize == viewSize &&
      other.layoutMode == layoutMode &&
      other.inputDevice == inputDevice &&
      other.platform == platform &&
      other.isDesktop == isDesktop &&
      other.sideBarWidth == sideBarWidth;

  @override
  int get hashCode => Object.hash(viewSize, layoutMode, inputDevice, platform, isDesktop, sideBarWidth);
}
