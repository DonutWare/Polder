import "package:material_ui/material_ui.dart";

import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/widgets/shared/icon_badge.dart";

class MessageView extends StatelessWidget {
  const MessageView({required this.icon, required this.message, this.color, this.action, super.key});

  final IconData icon;
  final String message;
  final Color? color;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            IconBadge(icon: icon, color: color ?? theme.colorScheme.primary, size: 72, shape: AppShapes.sunny),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}
