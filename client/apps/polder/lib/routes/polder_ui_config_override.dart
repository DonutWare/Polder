import "package:polder/routes/app_routes.dart";
import "package:polder/screens/search/open_search.dart";
import "package:polder_ui/polder_ui_config.dart";
import "package:polder/widgets/layout/more_options_button.dart";

final polderUiConfigOverride = polderUiConfigProvider.overrideWithValue(
  PolderUiConfig(
    afterSignIn: AppRoutes.signIn.afterSignIn,
    accountSettings: AppRoutes.settingsPage(SettingsPage.account),
    upFrom: AppRoutes.upFrom,
    isTopLevel: AppRoutes.isTab,
    pageActions: const [SearchButton()],
    menuButton: const MoreOptionsButton(),
  ),
);
