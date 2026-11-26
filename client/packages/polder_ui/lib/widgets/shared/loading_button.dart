import "package:flutter/material.dart";

class LoadingButton extends StatelessWidget {
  const LoadingButton({required this.label, required this.onPressed, this.loading = false, super.key});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: loading ? null : onPressed,
    child: loading
        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : Text(label),
  );
}
