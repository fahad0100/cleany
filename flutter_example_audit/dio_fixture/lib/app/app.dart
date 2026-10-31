// Builds the application with routing, theme, and Arabic/English localization.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';

/// Builds the application with routing, theme, and Arabic/English localization.
class App extends StatelessWidget {
  const App({required this.router, super.key});
  final GoRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    debugShowCheckedModeBanner: false,
  );
}
