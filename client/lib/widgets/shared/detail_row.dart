import "package:flutter/material.dart";

class DetailRow extends StatelessWidget {
  const DetailRow({required this.label, required this.value, this.valueColor, super.key});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(color: valueColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
