import "package:flutter/material.dart";

import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/navigation/app_mark.dart";

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      spacing: 16,
      children: [
        const AppMark(size: 64),
        Text(context.localized.appTitle, style: theme.textTheme.headlineSmall),
      ],
    );
  }
}
