import "package:flutter/widgets.dart";

import "package:polder/routes/app_routes.dart";
import "package:polder/util/remote_path.dart";

class BrowserRoutes {
  const BrowserRoutes({required this.root, required this.routeFor, this.rootLabel, this.exitRoute});

  static const files = BrowserRoutes(root: RemotePath.root, routeFor: AppRoutes.filesAt);

  final String root;
  final String Function(String path, {String? select}) routeFor;
  final String? rootLabel;
  final String? exitRoute;

  bool isRoot(String path) => path == root;

  bool contains(String path) => root == RemotePath.root || path == root || path.startsWith("$root/");

  String? parentRoute(String path) => isRoot(path) ? exitRoute : routeFor(RemotePath.parent(path));

  static BrowserRoutes of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BrowserScope>()?.routes ?? files;
}

class BrowserScope extends InheritedWidget {
  const BrowserScope({required this.routes, required super.child, super.key});

  final BrowserRoutes routes;

  @override
  bool updateShouldNotify(BrowserScope oldWidget) =>
      routes.root != oldWidget.routes.root ||
      routes.rootLabel != oldWidget.routes.rootLabel ||
      routes.exitRoute != oldWidget.routes.exitRoute;
}
