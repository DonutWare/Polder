import "package:material_ui/material_ui.dart";

import "package:polder_core/services/api/api_exceptions.dart";
import "package:polder_ui/util/api_error_localization.dart";
import "package:polder_ui/util/localization_helper.dart";

extension ActionFeedback on BuildContext {
  Future<bool> runWithFeedback(Future<void> action) async {
    final messenger = ScaffoldMessenger.maybeOf(this);
    final localizations = localized;
    void show(Object error) => messenger?.showSnackBar(SnackBar(content: Text(localizations.describeError(error))));
    try {
      await action;
      return true;
    } on ApiException catch (error) {
      show(error);
      return false;
    } on Object catch (error, stack) {
      FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack, library: "polder"));
      show(error);
      return false;
    }
  }
}
