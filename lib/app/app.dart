import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/localization/app_locale_controller.dart';
import '../core/localization/app_localizations.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';

class PsyCapNoteApp extends StatelessWidget {
  const PsyCapNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = AppLocaleController.instance;

    return AnimatedBuilder(
      animation: localeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) =>
              'SEED2START - Website hướng dẫn khởi nghiệp cùng Mầm',
          theme: AppTheme.light,
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
