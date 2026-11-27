import "package:material_ui/material_ui.dart";

import "package:polder_ui/widgets/shared/loading_indicator.dart";

class CenteredProgress extends StatelessWidget {
  const CenteredProgress({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: LoadingIndicator());
}
