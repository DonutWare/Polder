import "package:flutter/scheduler.dart";
import "package:flutter/widgets.dart";

class InterceptBack extends StatefulWidget {
  const InterceptBack({required this.active, required this.child, super.key});

  final bool active;
  final Widget child;

  static final _interceptors = <State<InterceptBack>>{};

  static final changes = _InterceptorChanges();

  static bool get hasInterceptors => _interceptors.isNotEmpty;

  static bool get isIntercepting =>
      _interceptors.any((interceptor) => interceptor.mounted && isFrontmost(interceptor.context));

  @override
  State<InterceptBack> createState() => _InterceptBackState();
}

bool isFrontmost(BuildContext context) {
  BuildContext? current = context;
  while (current != null && current.mounted) {
    final route = ModalRoute.of(current);
    if (route == null) return true;
    if (!route.isCurrent) return false;
    current = route.navigator?.context;
  }
  return true;
}

class _InterceptBackState extends State<InterceptBack> {
  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(InterceptBack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    if (InterceptBack._interceptors.remove(this)) InterceptBack.changes._schedule();
    super.dispose();
  }

  void _sync() {
    final changed = widget.active ? InterceptBack._interceptors.add(this) : InterceptBack._interceptors.remove(this);
    if (changed) InterceptBack.changes._schedule();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _InterceptorChanges extends ChangeNotifier {
  bool _scheduled = false;

  void _schedule() {
    if (_scheduled) return;
    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      notifyListeners();
    });
  }
}
