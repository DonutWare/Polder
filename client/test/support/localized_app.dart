import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder_calendar/polder_calendar.dart";

Widget localizedRouterApp(ProviderContainer container, GoRouter router) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp.router(
    localizationsDelegates: const [...AppLocalizations.localizationsDelegates, CalendarLocalizations.delegate],
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  ),
);

Widget localizedApp(ProviderContainer container, Widget home) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp(
    localizationsDelegates: const [...AppLocalizations.localizationsDelegates, CalendarLocalizations.delegate],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);
