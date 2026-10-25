import "package:flutter/material.dart";

class FadingPredictiveBackPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadingPredictiveBackPageTransitionsBuilder();

  static const _predictive = PredictiveBackPageTransitionsBuilder();

  @override
  Duration get transitionDuration => _predictive.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _predictive.reverseTransitionDuration;

  @override
  DelegatedTransitionBuilder? get delegatedTransition => _predictive.delegatedTransition;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => BackGestureFade(
    route: route,
    progress: animation,
    child: _predictive.buildTransitions(route, context, animation, secondaryAnimation, child),
  );
}

class BackGestureFade extends StatefulWidget {
  const BackGestureFade({required this.route, required this.progress, required this.child, super.key});

  final ModalRoute<Object?> route;
  final Animation<double> progress;
  final Widget child;

  @override
  State<BackGestureFade> createState() => _BackGestureFadeState();
}

class _BackGestureFadeState extends State<BackGestureFade> {
  NavigatorState? _navigator;
  bool _fading = false;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    widget.progress.addStatusListener(_onStatus);
    _opacity = CurvedAnimation(parent: widget.progress, curve: Curves.easeOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final navigator = widget.route.navigator;
    if (identical(navigator, _navigator)) return;
    _navigator?.userGestureInProgressNotifier.removeListener(_onGesture);
    _navigator = navigator?..userGestureInProgressNotifier.addListener(_onGesture);
  }

  @override
  void didUpdateWidget(BackGestureFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(widget.progress, oldWidget.progress)) return;
    oldWidget.progress.removeStatusListener(_onStatus);
    widget.progress.addStatusListener(_onStatus);
    _opacity = CurvedAnimation(parent: widget.progress, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    widget.progress.removeStatusListener(_onStatus);
    _navigator?.userGestureInProgressNotifier.removeListener(_onGesture);
    super.dispose();
  }

  void _onGesture() {
    if (widget.route.isCurrent && (_navigator?.userGestureInProgress ?? false)) setState(() => _fading = true);
  }

  void _onStatus(AnimationStatus status) {
    if (_fading && !status.isAnimating) setState(() => _fading = false);
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _fading ? _opacity : kAlwaysCompleteAnimation, child: widget.child);
}
