import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/widgets/shared/centered_progress.dart";
import "package:nomad/widgets/shared/error_view.dart";

class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({required this.value, required this.data, this.onRetry, super.key});

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => switch (value) {
    AsyncValue(:final value?, hasValue: true) => data(value),
    AsyncError(:final error) => ErrorView(error: error, onRetry: onRetry),
    _ => const CenteredProgress(),
  };
}
