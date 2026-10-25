import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "package:polder/util/adaptive_layout/adaptive_layout_model.dart";
import "package:polder/util/adaptive_layout/input_detector.dart";

enum InputDevice { touch, pointer, dPad }

enum ViewSize {
  phone,
  tablet,
  desktop,
  television;

  bool operator >(ViewSize other) => index > other.index;
  bool operator >=(ViewSize other) => index >= other.index;
  bool operator <(ViewSize other) => index < other.index;
  bool operator <=(ViewSize other) => index <= other.index;
}

enum LayoutMode { single, dual }

const _layoutPoints = [
  LayoutPoints(start: 0, end: 600, type: ViewSize.phone),
  LayoutPoints(start: 600, end: 1920, type: ViewSize.tablet),
  LayoutPoints(start: 1920, end: 2561, type: ViewSize.desktop),
  LayoutPoints(start: 2561, end: double.infinity, type: ViewSize.television),
];

const dualLayoutMinWidth = 960.0;

class AdaptiveLayout extends InheritedWidget {
  const AdaptiveLayout({required this.data, required super.child, super.key});

  final AdaptiveLayoutModel data;

  static AdaptiveLayout? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AdaptiveLayout>();

  static AdaptiveLayoutModel of(BuildContext context) =>
      maybeOf(context)?.data ?? _modelFor(MediaQuery.sizeOf(context).width, input: _defaultInput);

  static ViewSize layoutOf(BuildContext context) => of(context).viewSize;

  static ViewSize viewSizeOf(BuildContext context) => of(context).viewSize;

  static LayoutMode layoutModeOf(BuildContext context) => of(context).layoutMode;

  static InputDevice inputDeviceOf(BuildContext context) => of(context).inputDevice;

  static bool isDesktop(BuildContext context) => of(context).isDesktop;

  static bool usesPointer(BuildContext context) => inputDeviceOf(context) == InputDevice.pointer;

  static bool isPhone(BuildContext context) => viewSizeOf(context) == ViewSize.phone;

  static bool isSingle(BuildContext context) => layoutModeOf(context) == LayoutMode.single;

  static EdgeInsets adaptivePadding(BuildContext context, {double horizontalPadding = 12}) {
    final viewPadding = MediaQuery.paddingOf(context);
    final directional = EdgeInsetsDirectional.only(
      start: of(context).sideBarWidth + horizontalPadding,
      end: horizontalPadding,
    ).resolve(Directionality.of(context));
    return EdgeInsets.only(left: viewPadding.left + directional.left, right: viewPadding.right + directional.right);
  }

  @override
  bool updateShouldNotify(AdaptiveLayout oldWidget) => data != oldWidget.data;
}

class AdaptiveLayoutBuilder extends StatefulWidget {
  const AdaptiveLayoutBuilder({required this.child, this.adaptiveLayout, super.key});

  final AdaptiveLayoutModel? adaptiveLayout;
  final Widget Function(BuildContext context) child;

  @override
  State<AdaptiveLayoutBuilder> createState() => _AdaptiveLayoutBuilderState();
}

class _AdaptiveLayoutBuilderState extends State<AdaptiveLayoutBuilder> {
  late double _width;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _width = MediaQuery.sizeOf(context).width;
  }

  @override
  Widget build(BuildContext context) => InputDetector(
    isDesktop: _isDesktopPlatform,
    child: (input) => AdaptiveLayout(
      data: (widget.adaptiveLayout ?? _modelFor(_width, input: input)).copyWith(inputDevice: input),
      child: Builder(builder: widget.child),
    ),
  );
}

bool get _isDesktopPlatform =>
    !kIsWeb &&
    const {TargetPlatform.macOS, TargetPlatform.windows, TargetPlatform.linux}.contains(defaultTargetPlatform);

InputDevice get _defaultInput => _isDesktopPlatform || kIsWeb ? InputDevice.pointer : InputDevice.touch;

AdaptiveLayoutModel _modelFor(double width, {required InputDevice input}) => AdaptiveLayoutModel(
  viewSize: _layoutPoints.where((point) => point.contains(width)).firstOrNull?.type ?? ViewSize.tablet,
  layoutMode: width > 0 && width < dualLayoutMinWidth ? LayoutMode.single : LayoutMode.dual,
  inputDevice: input,
  platform: defaultTargetPlatform,
  isDesktop: _isDesktopPlatform,
);
