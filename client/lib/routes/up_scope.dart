import "dart:async";
import "dart:math" as math;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:go_router/go_router.dart";

import "package:polder/routes/app_routes.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/widgets/navigation/intercept_back.dart";

class UpScope extends StatefulWidget {
  const UpScope({required this.child, super.key});

  final Widget child;

  static bool isActive(BuildContext context) => _BackScope.maybeOf(context) != null;

  static String? locationOf(BuildContext context) => context.findAncestorStateOfType<_UpScopeState>()?._location;

  static Future<void> navigateUp(BuildContext context) async {
    final scope = context.findAncestorStateOfType<_UpScopeState>();
    if (scope != null) await Navigator.of(scope.context).maybePop();
  }

  @override
  State<UpScope> createState() => _UpScopeState();
}

class _UpScopeState extends State<UpScope> with _BackHandler, SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _commitDuration = Duration(milliseconds: 160);

  late final _gesture = AnimationController(vsync: this, duration: _commitDuration);
  String? _up;
  String? _location;
  SwipeEdge _edge = SwipeEdge.left;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void activate() {
    super.activate();
    _active = true;
  }

  @override
  void deactivate() {
    _active = false;
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gesture.dispose();
    super.dispose();
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (!_active) return false;
    final route = ModalRoute.of(context);
    final accepts =
        _up != null &&
        canTakeBackGesture(context) &&
        !(route?.popGestureEnabled ?? false) &&
        !_children.any((child) => child.mounted && isFrontmost(child.context) && child._canPop);
    if (accepts) {
      _edge = backEvent.swipeEdge;
      _gesture.value = 0;
    }
    return accepts;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) => _gesture.value = backEvent.progress;

  @override
  void handleCancelBackGesture() => unawaited(_gesture.animateBack(0));

  @override
  void handleCommitBackGesture() {
    final up = _up;
    unawaited(
      _gesture.animateTo(1).then((_) {
        if (!mounted) return;
        if (up != null) context.go(up);
        _gesture.value = 0;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri;
    _location = location.toString();
    final up = _up = AppRoutes.upFrom(location, single: AdaptiveLayout.isSingle(context));
    return PopScope(
      canPop: up == null || Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _childHandledBack()) return;
        if (up != null) context.go(up);
      },
      child: _GestureGate(
        child: _BackScope(
          handler: this,
          child: AnimatedBuilder(
            animation: _gesture,
            builder: (context, child) => _GestureTransform(progress: _gesture.value, edge: _edge, child: child!),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _GestureTransform extends StatelessWidget {
  const _GestureTransform({required this.progress, required this.edge, required this.child});

  final double progress;
  final SwipeEdge edge;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (progress == 0) return child;
    final eased = Curves.easeOut.transform(progress);
    final direction = edge == SwipeEdge.left ? 1 : -1;
    return Opacity(
      opacity: 1 - eased,
      child: Transform.translate(
        offset: Offset(direction * eased * math.min(32, MediaQuery.sizeOf(context).width * 0.08), 0),
        child: Transform.scale(scale: 1 - 0.1 * eased, child: child),
      ),
    );
  }
}

class UpButton extends StatelessWidget {
  const UpButton({super.key});

  @override
  Widget build(BuildContext context) => BackButton(onPressed: () => unawaited(UpScope.navigateUp(context)));
}

@immutable
class StackPage {
  const StackPage({required this.location, required this.child, this.key});

  final String location;
  final Widget child;
  final LocalKey? key;

  LocalKey get pageKey => key ?? ValueKey(location);
}

class PageStack extends StatefulWidget {
  const PageStack({required this.pages, this.onPop, super.key});

  final List<StackPage> pages;
  final ValueChanged<String>? onPop;

  static bool contains(BuildContext context) => _BackScope.maybeOf(context)?.handler is _PageStackState;

  @override
  State<PageStack> createState() => _PageStackState();
}

class _PageStackState extends State<PageStack> with _BackHandler {
  final _navigator = GlobalKey<NavigatorState>();
  _BackHandler? _parent;

  bool get _canPop => _navigator.currentState?.canPop() ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parent = _BackScope.maybeOf(context)?.handler;
    if (identical(parent, _parent)) return;
    _parent?._children.remove(this);
    _parent = parent?.._children.add(this);
  }

  @override
  void dispose() {
    _parent?._children.remove(this);
    super.dispose();
  }

  @override
  bool handleBack() {
    if (_childHandledBack()) return true;
    final navigator = _navigator.currentState;
    if (navigator == null || !navigator.canPop()) return false;
    unawaited(navigator.maybePop());
    return true;
  }

  void _onDidRemovePage(Page<Object?> page) {
    final pages = widget.pages;
    if (pages.length < 2 || page.key != pages.last.pageKey) return;
    final beneath = pages[pages.length - 2].location;
    final onPop = widget.onPop;
    onPop == null ? goWithin(context, beneath) : onPop(beneath);
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.pages;
    return PopScope(
      canPop: pages.length < 2,
      child: _BackScope(
        handler: this,
        child: Navigator(
          key: _navigator,
          pages: [
            for (final (i, page) in pages.indexed)
              MaterialPage<void>(
                key: page.pageKey,
                child: i == pages.length - 1 ? _GestureGate(child: page.child) : page.child,
              ),
          ],
          onDidRemovePage: _onDidRemovePage,
        ),
      ),
    );
  }
}

void goWithin(BuildContext context, String location) {
  final configuration = GoRouter.of(context).routerDelegate.currentConfiguration;
  if (configuration.last is ImperativeRouteMatch) {
    context.replace(location);
  } else {
    context.go(location);
  }
}

bool canTakeBackGesture(BuildContext context) =>
    context.mounted && !InterceptBack.isIntercepting && isFrontmost(context) && TickerMode.valuesOf(context).enabled;

class _GestureGate extends StatefulWidget {
  const _GestureGate({required this.child});

  final Widget child;

  @override
  State<_GestureGate> createState() => _GestureGateState();
}

class _GestureGateState extends State<_GestureGate> implements PopEntry<Object?> {
  ModalRoute<Object?>? _route;
  bool _active = true;

  @override
  late final ValueListenable<bool> canPopNotifier = _LiveValue(() => _active && canTakeBackGesture(context));

  @override
  void activate() {
    super.activate();
    _active = true;
  }

  @override
  void deactivate() {
    _active = false;
    super.deactivate();
  }

  @override
  void onPopInvoked(bool didPop) {}

  @override
  void onPopInvokedWithResult(bool didPop, Object? result) {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route == _route) return;
    _route?.unregisterPopEntry(this);
    _route = route?..registerPopEntry(this);
  }

  @override
  void dispose() {
    _route?.unregisterPopEntry(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _LiveValue extends ChangeNotifier implements ValueListenable<bool> {
  _LiveValue(this._read);

  final bool Function() _read;

  @override
  bool get value => _read();
}

mixin _BackHandler<T extends StatefulWidget> on State<T> {
  final _children = <_PageStackState>[];

  bool handleBack() => _childHandledBack();

  bool _childHandledBack() =>
      _children.any((child) => child.mounted && isFrontmost(child.context) && child.handleBack());
}

class _BackScope extends InheritedWidget {
  const _BackScope({required this.handler, required super.child});

  final _BackHandler handler;

  static _BackScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_BackScope>();

  @override
  bool updateShouldNotify(_BackScope oldWidget) => handler != oldWidget.handler;
}
