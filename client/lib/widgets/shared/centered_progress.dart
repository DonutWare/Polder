import "package:flutter/material.dart";

import "package:polder/widgets/shared/loading_indicator.dart";

class CenteredProgress extends StatelessWidget {
  const CenteredProgress({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: LoadingIndicator());
}
