import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

class PolderUiConfig {
  const PolderUiConfig({
    required this.afterSignIn,
    required this.accountSettings,
    required this.upFrom,
    required this.isTopLevel,
    this.pageActions = const [],
    this.menuButton,
  });

  final String Function(Uri loginLocation) afterSignIn;
  final String accountSettings;
  final String? Function(Uri location, {required bool single}) upFrom;
  final bool Function(String location) isTopLevel;
  final List<Widget> pageActions;
  final Widget? menuButton;
}

final polderUiConfigProvider = Provider<PolderUiConfig>(
  (ref) => throw UnimplementedError("Each app overrides polderUiConfigProvider"),
);

PolderUiConfig readPolderUiConfig(BuildContext context) =>
    ProviderScope.containerOf(context, listen: false).read(polderUiConfigProvider);
