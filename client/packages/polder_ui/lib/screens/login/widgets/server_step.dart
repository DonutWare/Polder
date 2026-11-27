import "package:material_ui/material_ui.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/providers/login_provider.dart";
import "package:polder_ui/screens/login/widgets/login_failure_text.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/shared/loading_button.dart";

class ServerStep extends ConsumerWidget {
  const ServerStep({super.key});

  static const serverUrlFieldKey = Key("login.serverUrl");
  static const connectButtonKey = Key("login.connect");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Text(context.localized.loginServerIntro, textAlign: TextAlign.center),
        TextFormField(
          key: serverUrlFieldKey,
          initialValue: state.serverUrl,
          keyboardType: TextInputType.url,
          autofillHints: const [AutofillHints.url],
          decoration: InputDecoration(
            labelText: context.localized.serverUrl,
            hintText: context.localized.serverUrlHint,
          ),
          onChanged: notifier.setServerUrl,
          onFieldSubmitted: (_) => notifier.connect(),
        ),
        const LoginFailureText(),
        LoadingButton(
          key: connectButtonKey,
          label: context.localized.connect,
          loading: state.loading,
          onPressed: state.canConnect ? notifier.connect : null,
        ),
      ],
    );
  }
}
