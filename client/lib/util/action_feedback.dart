import "package:flutter/material.dart";

import "package:nomad/services/api/api_exceptions.dart";
import "package:nomad/util/api_error_localization.dart";
import "package:nomad/util/localization_helper.dart";

extension ActionFeedback on BuildContext {
  Future<bool> runWithFeedback(Future<void> action) async {
    final messenger = ScaffoldMessenger.maybeOf(this);
    final localizations = localized;
    try {
      await action;
      return true;
    } on ApiException catch (error) {
      messenger?.showSnackBar(SnackBar(content: Text(localizations.describeError(error))));
      return false;
    }
  }
}
